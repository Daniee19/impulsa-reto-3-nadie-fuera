# Context Service Contract (003-contextual-human-help)

Este servicio captura el contexto real de la sesión del usuario y lo empaqueta para enviar a quien lo ayuda.

## NavigationObserver

Ubicación: `lib/core/router/navigation_observer.dart`

Vive en `core/` porque afecta al router global, no solo a esta feature.

```dart
class NavigationObserver extends NavigatorObserver {
  final Ref ref;
  NavigationObserver(this.ref);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateContext(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _updateContext(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _updateContext(newRoute);
  }

  void _updateContext(Route<dynamic> route) {
    final settings = route.settings;
    ref.read(navigationContextProvider.notifier).updateFromRoute(
      settings.name ?? 'unknown',
    );
  }
}
```

**Registro en GoRouter**:
```dart
GoRouter(
  observers: [NavigationObserver(ref)],
  routes: [...],
)
```

## ContextCollector

Ubicación: `lib/features/contextual_help/domain/services/context_collector.dart`

Dart puro. Sin dependencias de Flutter.

```dart
class ContextCollector {
  /// Construye un HelpContext seguro a partir de los datos de navegación y operación.
  /// Filtra datos sensibles antes de empaquetar.
  HelpContext collect({
    required String currentRoute,
    required String screenName,
    String? flowStep,
    OperationInProgress? operation,
  });
}
```

**Contrato de seguridad**:
- `collect()` NUNCA retorna un HelpContext con contraseñas, PIN, datos biométricos, o números de cuenta completos.
- Si `operation` contiene datos sensibles, los filtra/enmascara antes de incluirlos.
- El monto y nombre del destinatario SÍ se incluyen (son datos operativos necesarios para que la ayuda sea efectiva).

## HelpSessionRepository

Ubicación: `lib/features/contextual_help/domain/repositories/help_session_repository.dart`

```dart
abstract class HelpSessionRepository {
  /// Inicia una sesión de ayuda simulada.
  Future<HelpRequest> startSession({
    required HelpTarget target,
    required HelpChannel channel,
    required HelpContext context,
    required bool includeContext,
  });

  /// Simula timeout de persona de confianza.
  Future<void> waitForResponse(String requestId, {Duration timeout = const Duration(seconds: 60)});

  /// Completa la sesión.
  Future<void> endSession(String requestId);
}
```

**Contrato de simulación**:
- `startSession()` crea un HelpRequest con status `connecting`, espera 2s, cambia a `connected`.
- `waitForResponse()` para familiar: después de `timeout`, cambia status a `noResponse` (triggerea fallback UI).
- En el mock, se puede forzar `noResponse` inmediato para testing.

## Contrato de integración con 001-easy-mode

Los flows de 001 deben notificar a 003 cuando hay operación en curso:

```dart
// En provider de PayBillScreen (001), al seleccionar recibo:
ref.read(operationInProgressProvider.notifier).set(
  OperationInProgress(
    type: OperationType.payment,
    amount: bill.amount,
    recipientName: bill.serviceName,
    recipientId: bill.id,
  ),
);

// Al completar o cancelar el flujo:
ref.read(operationInProgressProvider.notifier).clear();
```

El provider `operationInProgressProvider` vive en `lib/features/contextual_help/presentation/providers/` y es importado por los flows de 001. Alternativamente, vive en `lib/core/` si se considera infraestructura compartida.

## Contrato de integración con 006-trusted-person

```dart
// En HelpContactPickerScreen:
final trustedPerson = ref.watch(trustedPersonProvider).valueOrNull;
final showTrustedOption = trustedPerson != null &&
    trustedPerson.hasPermission(TrustedPermission.helpRequests);

// Opciones:
// Si showTrustedOption: "Llamar a [trustedPerson.name]" + "Hablar con el banco"
// Si !showTrustedOption: solo "Hablar con el banco"

// Contexto compartido con familiar:
final includeContext = showTrustedOption; // helpRequests implica consentimiento
```

## Rutas de navegación

Todas push sobre la ruta actual (preservan el flujo):

```
/easy-mode/help/contact-picker    → HelpContactPickerScreen
/easy-mode/help/channel-picker    → HelpChannelPickerScreen
/easy-mode/help/connecting        → HelpConnectingScreen
/easy-mode/help/fallback          → HelpFallbackScreen
```

## Invariantes

1. **Contexto siempre real**: HelpContext refleja la pantalla actual via el observer, no datos inventados.
2. **Sin datos sensibles en contexto**: el ContextCollector filtra todo lo prohibido por FR-016.
3. **Progreso siempre preservado**: push/pop, datos en Riverpod providers.
4. **Botón siempre visible**: HelpFab presente en todas las pantallas del Modo Fácil via shell route.
5. **Familiar sin permiso = sin opción**: si `helpRequests` desactivado, familiar no aparece como opción.
6. **Fallback siempre disponible**: si familiar no responde, siempre se ofrece asesor con el mismo contexto.
