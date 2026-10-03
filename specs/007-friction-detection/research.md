# Research: Detección de Fricción (007-friction-detection)

## R1: Reutilización del NavigationObserver de 003

**Decision**: Reutilizar el `NavigationObserver` de `lib/core/router/navigation_observer.dart` (definido en 003) y el `navigationContextProvider` que ya trackea la ruta actual, nombre de pantalla legible y paso del flujo. No se crea un observer nuevo.

**Rationale**: El observer de 003 ya vive en `core/` (no en la feature) y expone exactamente los datos que el detector necesita: ruta actual, nombre de pantalla y paso del flujo. Duplicar sería violar la constitución (Clean Architecture — reuse over rewrite).

**Lo que 007 agrega**: Un listener sobre `navigationContextProvider` que el `FrictionProvider` usa para:
- Detectar retrocesos (comparar ruta anterior con ruta actual).
- Reiniciar el timer de inactividad cuando cambia la ruta.
- Determinar si la pantalla actual es una pantalla excluida.

**Alternatives considered**:
- Observer dedicado para 007: duplica lógica, dos observers en el router.
- Sobrescribir `didPop` del observer existente con lógica de fricción: viola separación de concerns, acopla 003 con 007.

## R2: Detección de retrocesos (back navigation)

**Decision**: Contar `didPop` events dentro del mismo flujo. El `FrictionProvider` escucha los cambios del `navigationContextProvider` y detecta retrocesos comparando si la ruta nueva es un ancestro de la ruta anterior dentro del mismo flujo (ej: de `/pay-bill/123/confirm` vuelve a `/pay-bill/123`).

**Implementación**:
```dart
class FrictionDetector {
  int _backCount = 0;
  String? _currentFlowPrefix;

  void onRouteChanged(String previousRoute, String newRoute) {
    final newFlow = _extractFlowPrefix(newRoute);
    final prevFlow = _extractFlowPrefix(previousRoute);

    if (newFlow == prevFlow && _isBackNavigation(previousRoute, newRoute)) {
      _backCount++;
    } else if (newFlow != prevFlow) {
      _backCount = 0; // Nuevo flujo, reset
      _currentFlowPrefix = newFlow;
    }
  }

  bool get shouldOfferHelp => _backCount >= backThreshold;
}
```

**Definición de "retroceso"**: La ruta nueva tiene menos segmentos que la anterior dentro del mismo prefijo de flujo (`/easy-mode/pay-bill/*`, `/easy-mode/send-money/*`). No cuenta navegar de un flujo a otro (ej: de pay-bill a home).

**Rationale**: Contar pops a nivel de observer (via el provider) es más fiable que interceptar el botón back del dispositivo. El observer ya captura `didPop`.

**Alternatives considered**:
- `WillPopScope`/`PopScope` en cada pantalla: repetitivo, invasivo, propenso a olvidos.
- Contar toques en botón "Volver" del UI: no captura el back button del dispositivo Android.

## R3: Detección de inactividad (idle timer)

**Decision**: Timer de Dart (`Timer`) manejado por el `FrictionProvider`. Se inicia al entrar a un paso de flujo activo. Se reinicia con cualquier interacción (toque, escritura, cambio de ruta). Se cancela en pantallas excluidas.

**Implementación**:
```dart
Timer? _inactivityTimer;

void _startInactivityTimer() {
  _inactivityTimer?.cancel();
  if (_isExcludedScreen()) return; // No arrancar en confirmaciones
  if (!_isActiveFlow()) return;    // Solo en flujos activos

  _inactivityTimer = Timer(
    Duration(seconds: inactivityThresholdSeconds),
    _onInactivityDetected,
  );
}

void resetInactivityTimer() {
  if (_inactivityTimer?.isActive ?? false) {
    _startInactivityTimer(); // Reinicia
  }
}
```

**Captura de interacciones del usuario**: Un `Listener` widget (transparente, no consume eventos) que envuelve el body del ShellRoute. Detecta `onPointerDown` y llama `resetInactivityTimer()`. No interfiere con los widgets debajo.

**Rationale**: `Timer` de `dart:async` es la herramienta estándar. El `Listener` widget es el patrón de Flutter para observar gestos sin consumirlos. Ambos stdlib/platform nativos.

**Alternatives considered**:
- `GestureDetector`: consume gestos, interfiere con widgets debajo.
- `WidgetsBindingObserver.didChangeAppLifecycleState`: detecta app al fondo, no inactividad dentro de la app.
- Polling periódico del timestamp del último toque: más complejo, Timer es más limpio.

## R4: Detección de errores repetidos

**Decision**: Los flujos de 001 (pay-bill, send-money) ya validan inputs. Agregar un `ErrorTracker` en el `FrictionDetector` que recibe notificaciones de error de validación desde los providers de 001. Cuenta errores del mismo tipo en el mismo campo/paso.

**Implementación**:
```dart
void onValidationError(String fieldId, String errorType) {
  final key = '$fieldId:$errorType';
  _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;
}

bool hasRepeatedErrors(String fieldId, String errorType) {
  final key = '$fieldId:$errorType';
  return (_errorCounts[key] ?? 0) >= errorThreshold;
}
```

**Integración con 001**: Los providers de validación de 001 llaman `ref.read(frictionDetectorProvider).onValidationError(fieldId, errorType)` cuando ocurre un error de validación. Similar a como 001 ya notifica `operationInProgressProvider` de 003.

**Qué NO cuenta como error repetido** (FR-009): Errores de reconocimiento de voz de 004. Solo errores de validación de datos ingresados (formato incorrecto, campo vacío, valor fuera de rango).

**Alternatives considered**:
- Observer global de FormField: Flutter no tiene un observer global de validación.
- Wrap de TextFormField con lógica de conteo: invasivo, modifica widgets de 001.

## R5: Pantallas excluidas

**Decision**: Lista de patrones de ruta que excluyen la detección. Definida como constante en el detector.

**Pantallas excluidas**:
| Route pattern | Reason |
|---------------|--------|
| `*/confirm` | Confirmación de pago/transferencia (US4) |
| `/easy-mode/fraud-alert` | Alerta del escudo antifraude (spec) |
| `/easy-mode/assistant/consent` | Consentimiento de micrófono (spec) |
| `/easy-mode/settings/trusted-person/consent` | Consentimiento de persona de confianza (spec) |
| `/easy-mode/help/*` | Ya está en pantalla de ayuda |

**Implementación**:
```dart
static const _excludedPatterns = [
  RegExp(r'/confirm$'),
  'fraud-alert',
  'assistant/consent',
  'trusted-person/consent',
  RegExp(r'/help/'),
];

bool _isExcludedScreen() {
  final route = _currentRoute;
  return _excludedPatterns.any((p) =>
    p is RegExp ? p.hasMatch(route) : route.contains(p as String));
}
```

**Rationale**: El spec es explícito (FR-003): NUNCA en confirmaciones, alertas de fraude ni consentimientos. El patrón `*/confirm` cubre todas las pantallas de confirmación de operaciones monetarias sin listarlas una por una.

**Alternatives considered**:
- Flag en cada ruta de GoRouter: invasivo, requiere tocar la definición de rutas de otros features.
- Metadata en el NavigationObserver: sobrecarga el observer de 003.

## R6: Ofrecimiento de ayuda (overlay, no ruta)

**Decision**: `SnackBar` personalizado (Material) o `AnimatedPositioned` bottom-sheet no-modal que aparece sobre la pantalla actual. No es una ruta nueva, no bloquea interacción, no es un diálogo modal.

**Implementación preferida**: `SnackBar` personalizado con `SnackBarAction` no es suficiente (necesita 3 botones). Usar un `AnimatedPositioned` widget en el Stack del ShellRoute, similar a como un Snackbar aparece pero con contenido custom.

```dart
// En el ShellRoute builder (ya existente para HelpFab de 003):
Stack(
  children: [
    child, // Pantalla actual
    const HelpFab(), // De 003
    const FrictionOfferOverlay(), // Nuevo — se auto-muestra/oculta via provider
  ],
)
```

El overlay:
- Aparece desde abajo con animación suave (300ms).
- Mensaje: "Parece que necesitas ayuda con este paso." (≤ 15 palabras).
- 3 botones grandes (48×48 dp): "Sí, explícame", "Hablar con alguien", "No, estoy bien".
- `SemanticsService.announce()` al aparecer (FR-012).
- No modal: el usuario puede ignorarlo y seguir interactuando.
- No se apila: si hay múltiples señales simultáneas, un solo overlay (FR-005).

**Rationale**: El spec dice "no intrusivo", "no un diálogo modal que bloquee la pantalla". Un overlay posicionado en el bottom cumple esto. Vive en el ShellRoute existente sin crear rutas nuevas.

**Alternatives considered**:
- Modal dialog: bloquea la pantalla, contradice el spec.
- Ruta de navegación: pierde el contexto visual de la pantalla donde está trabado.
- showBottomSheet de Scaffold: bloquea interacción parcialmente.

## R7: Integración con 004 ("Sí, explícame")

**Decision**: Al tocar "Sí, explícame", se activa una explicación contextual breve del asistente de voz (004). El spec dice "la explicación es predefinida por paso, no generada libremente por la IA."

**Implementación**: Un mapa de explicaciones por paso en ARB. El ofrecimiento conoce el paso actual (vía `navigationContextProvider`), busca la explicación en el mapa, y usa TTS (`flutter_tts` o el sistema TTS que 004 implemente) para leerla.

```dart
// En el handler del botón "Sí, explícame":
final explanation = FrictionExplanations.forStep(currentRoute);
await ttsService.speak(explanation); // Reutilizar servicio TTS de 004
```

No se abre la pantalla completa del asistente. Solo se lee la explicación y se cierra el overlay.

**Rationale**: Abrir la VoiceAssistantScreen sería excesivo para una explicación predefinida. TTS directo es más rápido y menos disruptivo.

**Alternatives considered**:
- Navegar a VoiceAssistantScreen de 004: demasiada ceremonia para una frase predefinida.
- Texto estático en el overlay: el spec dice que el asistente "dice en lenguaje simple", implica voz.

## R8: Integración con 003 ("Hablar con alguien")

**Decision**: Al tocar "Hablar con alguien", se navega a `HelpContactPickerScreen` de 003 via `context.push('/easy-mode/help/contact-picker')`, enriqueciendo el contexto con los datos de fricción.

**Enriquecimiento del contexto** (FR-008):
```dart
// Antes de navegar a 003:
ref.read(frictionContextProvider.notifier).set(
  FrictionContext(
    signalType: FrictionType.repeatedBackNavigation,
    occurrences: 3,
    stepName: "Confirmación del pago de recibo de Luz por S/ 120",
  ),
);
context.push('/easy-mode/help/contact-picker');
```

El `ContextCollector` de 003 lee `frictionContextProvider` y lo incluye en el `HelpContext`. El asesor/familiar ve: "Rosa retrocedió 3 veces en la confirmación del pago de su recibo de luz por S/ 120."

**Alternatives considered**:
- Pasar datos de fricción por query params en la ruta: mezcla datos con navegación.
- Crear un paquete de contexto nuevo: duplica ContextCollector de 003.

## R9: Umbrales configurables

**Decision**: Clase `FrictionThresholds` con valores por defecto como constantes. No persisten ni se ajustan dinámicamente (spec: "fijos para el prototipo"). Son inyectables para testing.

```dart
class FrictionThresholds {
  final int backNavigationCount;
  final int inactivitySeconds;
  final int repeatedErrorCount;

  const FrictionThresholds({
    this.backNavigationCount = 3,
    this.inactivitySeconds = 20,
    this.repeatedErrorCount = 3,
  });
}
```

**Rationale**: El spec dice "umbrales fijos para el prototipo". Constantes con nombres claros son suficientes. La clase los agrupa e inyecta limpiamente para tests donde se quieran variar.

**Alternatives considered**:
- Hardcoded inline: funciona, pero dificulta testing con umbrales distintos.
- SharedPreferences / config remoto: YAGNI, el spec dice fijos.

## R10: Deduplicación de señales (FR-005)

**Decision**: El `FrictionProvider` mantiene un flag `_offerShown` por operación. Cuando cualquier señal dispara, revisa si ya hay un ofrecimiento activo. Si sí, no muestra otro. Si la señal fue descartada ("No, estoy bien"), registra la señal como `_dismissed` y no vuelve a ofrecer para esa señal/operación (FR-004).

**State tracking**:
```dart
Set<String> _dismissedSignals = {};  // ej: {'back:pay-bill', 'idle:pay-bill'}
bool _offerVisible = false;

void _maybeTriggerOffer(FrictionType type, String flowId) {
  final key = '${type.name}:$flowId';
  if (_offerVisible || _dismissedSignals.contains(key)) return;
  _showOffer(type);
}

void dismiss(FrictionType type, String flowId) {
  _dismissedSignals.add('${type.name}:$flowId');
  _offerVisible = false;
}
```

**Reset**: Al cambiar de flujo (nuevo `flowId`), se limpia `_dismissedSignals`. Cada operación es independiente.

**Alternatives considered**:
- Guardar dismissed en SharedPreferences: YAGNI, efímero per-session es suficiente.
