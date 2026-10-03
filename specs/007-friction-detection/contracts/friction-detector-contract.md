# Friction Detector Contract (007-friction-detection)

El detector de fricción es un servicio domain (Dart puro) que evalúa señales de comportamiento y decide cuándo ofrecer ayuda.

## FrictionDetector

Ubicación: `lib/features/friction_detection/domain/services/friction_detector.dart`

Dart puro. Sin dependencias de Flutter.

```dart
class FrictionDetector {
  final FrictionThresholds thresholds;

  FrictionDetector({this.thresholds = const FrictionThresholds()});

  /// Registra un retroceso en el flujo actual.
  /// Retorna FrictionSignal si se alcanzó el umbral, null si no.
  FrictionSignal? onBackNavigation({
    required String flowId,
    required String stepRoute,
    required String stepName,
  });

  /// Evalúa si ha pasado suficiente tiempo de inactividad.
  /// Llamado por el timer cuando expira.
  /// Retorna FrictionSignal si aplica.
  FrictionSignal? onInactivityTimeout({
    required String flowId,
    required String stepRoute,
    required String stepName,
  });

  /// Registra un error de validación en un campo.
  /// Retorna FrictionSignal si se alcanzó el umbral de errores repetidos.
  FrictionSignal? onValidationError({
    required String flowId,
    required String stepRoute,
    required String stepName,
    required String fieldId,
    required String errorType,
  });

  /// Verifica si una ruta está excluida de la detección.
  bool isExcludedScreen(String route);

  /// Verifica si una ruta pertenece a un flujo activo (pagar, enviar).
  bool isActiveFlow(String route);

  /// Limpia los contadores al cambiar de flujo/operación.
  void resetForNewFlow();

  /// Marca una señal como descartada para esta operación.
  void dismissSignal(FrictionType type, String flowId);

  /// Verifica si una señal ya fue descartada.
  bool isDismissed(FrictionType type, String flowId);
}
```

**Contrato**:
- Todos los métodos son síncronos (Dart puro, sin async).
- `onBackNavigation()` cuenta retrocesos por `flowId`. Retorna señal solo al alcanzar `thresholds.backNavigationCount`.
- `onInactivityTimeout()` no maneja el timer — solo evalúa si debe producir señal. El timer vive en el provider (presentation layer).
- `onValidationError()` agrupa errores por `fieldId:errorType`. Retorna señal al alcanzar `thresholds.repeatedErrorCount`.
- `isExcludedScreen()` usa los patrones definidos en el data model (rutas de confirmación, fraude, consentimiento, ayuda).
- `isActiveFlow()` retorna true para rutas bajo `/easy-mode/pay-bill/` y `/easy-mode/send-money/`.
- `resetForNewFlow()` limpia todos los contadores y dismissed signals.
- `dismissSignal()` registra que "No, estoy bien" fue elegido. `isDismissed()` lo consulta.

**Flujos activos**:
```dart
static const _activeFlowPrefixes = [
  '/easy-mode/pay-bill',
  '/easy-mode/send-money',
];
```

**Invariantes**:
1. El detector NUNCA genera señales en pantallas excluidas.
2. El detector NUNCA genera señales fuera de flujos activos.
3. El detector NUNCA genera una señal descartada por el usuario.
4. Los umbrales son inmutables durante la vida del detector.

## FrictionProvider

Ubicación: `lib/features/friction_detection/presentation/providers/friction_provider.dart`

Riverpod provider que orquesta detector + observer + timer + overlay state.

```dart
@riverpod
class FrictionNotifier extends _$FrictionNotifier {
  late final FrictionDetector _detector;
  Timer? _inactivityTimer;

  @override
  FrictionOffer build() {
    _detector = FrictionDetector();

    // Escuchar cambios de navegación del observer de 003
    ref.listen(navigationContextProvider, (prev, next) {
      _onNavigationChanged(prev, next);
    });

    ref.onDispose(() => _inactivityTimer?.cancel());

    return const FrictionOffer.hidden();
  }

  /// Llamado por el Listener widget cuando el usuario toca la pantalla.
  void onUserInteraction() {
    _restartInactivityTimer();
  }

  /// Llamado por los providers de 001 cuando ocurre error de validación.
  void onValidationError(String fieldId, String errorType) {
    // Delega al detector, evalúa si mostrar ofrecimiento
  }

  /// Acciones del overlay.
  void dismiss();
  void acceptExplain();
  void acceptHuman(BuildContext context);
}
```

**Contrato de integración**:
- Escucha `navigationContextProvider` (de 003) para detectar retrocesos y cambios de pantalla.
- Maneja el `Timer` de inactividad (presentation concern, no domain).
- Recibe `onUserInteraction()` desde el `Listener` widget del ShellRoute.
- Recibe `onValidationError()` desde los providers de validación de 001.
- Actualiza el state (`FrictionOffer`) que el overlay widget observa.

## Contrato de integración con ShellRoute (003)

El ShellRoute existente de 003 se extiende para incluir el overlay y el listener:

```dart
ShellRoute(
  builder: (context, state, child) => Scaffold(
    body: Listener(
      onPointerDown: (_) {
        ref.read(frictionNotifierProvider.notifier).onUserInteraction();
      },
      child: Stack(
        children: [
          child,
          const FrictionOfferOverlay(), // Nuevo
        ],
      ),
    ),
    floatingActionButton: const HelpFab(), // Existente de 003
  ),
  routes: [/* rutas easy_mode */],
)
```

## Contrato de integración con 001 (notificación de errores)

Los providers de validación de 001 notifican errores:

```dart
// En el provider de PayBillScreen cuando el usuario ingresa un dato inválido:
ref.read(frictionNotifierProvider.notifier).onValidationError(
  'amount_field',  // fieldId
  'invalid_format', // errorType
);
```

## Contrato de integración con 003 (contexto enriquecido)

Al elegir "Hablar con alguien":

```dart
// FrictionProvider.acceptHuman():
final signal = state.signal;
ref.read(frictionContextProvider.notifier).set(
  FrictionContext(
    signalType: signal.type,
    occurrences: signal.occurrences,
    stepName: signal.stepName,
    humanReadable: _buildHumanReadable(signal),
  ),
);
context.push('/easy-mode/help/contact-picker');
```

El `ContextCollector` de 003 se modifica para leer `frictionContextProvider` y anexar los datos de fricción al `HelpContext`.

## Contrato de integración con 004 (explicación por voz)

Al elegir "Sí, explícame":

```dart
// FrictionProvider.acceptExplain():
final explanation = ref.read(frictionExplanationProvider(state.signal.stepRoute));
await ref.read(ttsServiceProvider).speak(explanation);
state = const FrictionOffer.hidden();
```

`frictionExplanationProvider`: mapa de ruta → texto de explicación en español (ARB). Las explicaciones son predefinidas por paso, no generadas por IA.

## Invariantes

1. **Observer de 003 compartido**: No se crea un segundo observer. Se escucha el provider existente.
2. **Timer en presentation**: El `Timer` de inactividad vive en el provider, no en el detector domain.
3. **Detector sin side effects**: El detector solo evalúa y retorna. No muestra UI, no navega, no habla.
4. **Overlay no bloquea**: `FrictionOfferOverlay` nunca es modal. El usuario puede ignorarlo.
5. **Contexto de fricción efímero**: `frictionContextProvider` se limpia después de navegar a 003.
6. **Explicaciones predefinidas**: Los textos de "Sí, explícame" vienen de ARB, no de IA.
