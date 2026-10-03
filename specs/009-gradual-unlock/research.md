# Research: Desbloqueo Gradual de Funciones (009-gradual-unlock)

## R1: Feature flags con SharedPreferences

**Decision**: Guardar el estado de cada función extra (bloqueada, desbloqueada-oculta, activa) y las métricas de confianza en SharedPreferences. Un `FeatureFlagRepository` abstrae la lectura/escritura.

**Implementación**:
```dart
class FeatureFlagRepository {
  final SharedPreferences _prefs;

  Future<FeatureState> getState(ExtraFeature feature) async {
    final key = 'unlock_${feature.name}_state';
    final value = _prefs.getString(key);
    return FeatureState.values.byName(value ?? 'locked');
  }

  Future<void> setState(ExtraFeature feature, FeatureState state) async {
    await _prefs.setString('unlock_${feature.name}_state', state.name);
  }

  Future<ConfidenceMetrics> getMetrics() async {
    return ConfidenceMetrics(
      successfulOpsWithoutHelp: _prefs.getInt('unlock_ops_no_help') ?? 0,
      practiceSessionsCompleted: _prefs.getInt('unlock_practice_sessions') ?? 0,
    );
  }

  Future<void> incrementOpsWithoutHelp() async {
    final current = _prefs.getInt('unlock_ops_no_help') ?? 0;
    await _prefs.setInt('unlock_ops_no_help', current + 1);
  }

  Future<int> getRejectionCount(ExtraFeature feature) async {
    return _prefs.getInt('unlock_${feature.name}_rejections') ?? 0;
  }

  Future<void> incrementRejection(ExtraFeature feature) async {
    final current = await getRejectionCount(feature);
    await _prefs.setInt('unlock_${feature.name}_rejections', current + 1);
  }
}
```

**Rationale**: SharedPreferences es la opción más simple para persistir preferencias de UI entre sesiones. Ya está permitida por la constitución (BSD-3). Las métricas no son datos sensibles (contadores de uso, no datos financieros).

**Alternatives considered**:
- Hive/Isar: overkill para unos pocos key-value pairs.
- Riverpod solo (in-memory): no persiste entre sesiones (FR-010 requiere persistencia).
- flutter_secure_storage: para secretos, no para preferencias de UI.

## R2: UnlockEvaluator — lógica de evaluación en domain

**Decision**: Clase Dart pura `UnlockEvaluator` que recibe métricas de confianza y estados de features, y decide qué función proponer.

**Implementación**:
```dart
class UnlockEvaluator {
  final UnlockThresholds thresholds;

  const UnlockEvaluator({this.thresholds = const UnlockThresholds()});

  /// Evalúa si hay una función para proponer.
  /// Retorna null si no hay propuesta pendiente.
  UnlockProposal? evaluate({
    required ConfidenceMetrics metrics,
    required Map<ExtraFeature, FeatureState> states,
    required Map<ExtraFeature, int> rejections,
    required bool proposalShownThisSession,
  }) {
    if (proposalShownThisSession) return null; // FR-006: una por sesión

    final meetsConfidence =
      metrics.successfulOpsWithoutHelp >= thresholds.opsWithoutHelp ||
      metrics.practiceSessionsCompleted >= thresholds.practiceSessions;

    if (!meetsConfidence) return null;

    // Buscar la primera función en orden de prioridad que sea elegible
    for (final feature in ExtraFeature.values) {
      final state = states[feature] ?? FeatureState.locked;
      if (state != FeatureState.locked) continue; // Ya desbloqueada
      if ((rejections[feature] ?? 0) >= thresholds.maxRejections) continue; // FR-005

      return UnlockProposal(feature: feature);
    }

    return null; // Todas desbloqueadas o rechazadas al máximo
  }
}
```

**Rationale**: Dart puro, sin dependencias de Flutter ni Riverpod. Testeable con unit tests triviales. La lógica es deliberadamente simple (umbrales fijos, prioridad fija).

**Alternatives considered**:
- Lógica inline en el provider: mezcla business logic con state management.
- Condiciones por feature (distintos umbrales para cada función): YAGNI, el spec dice umbrales fijos.

## R3: Integración con pantalla principal de 001

**Decision**: La `EasyModeHomeScreen` de 001 consume un `featureFlagsProvider` para decidir qué botones mostrar. Si hay funciones extra activas, muestra la sección "Más funciones" debajo de las 4 primarias.

**Implementación**:
```dart
// En EasyModeHomeScreen:
final activeExtras = ref.watch(activeExtraFeaturesProvider);

Column(
  children: [
    // 4 acciones principales (siempre)
    _PrimaryActionsGrid(), // ver saldo, pagar, enviar, ayuda
    if (activeExtras.isNotEmpty) ...[
      const SizedBox(height: 16),
      _ExtraFeaturesSection(features: activeExtras),
    ],
  ],
)
```

**Cambio mínimo en 001**: Solo se agrega un `Consumer` (o se lee un provider) en `EasyModeHomeScreen` para renderizar la sección extra. Las 4 acciones primarias no cambian.

**Sección "Más funciones"**: Un heading "Más funciones" con botones del mismo estilo que los primarios pero en una fila separada. Cumple 48×48 dp, 4.5:1 contraste, Semantics labels.

**Alternatives considered**:
- Pantalla separada para funciones extra: pierde visibilidad, el usuario no las descubriría.
- Tabs/drawer: complejidad de navegación, no alineado con el Modo Fácil (1 pantalla simple).

## R4: Integración con modo práctica (008)

**Decision**: Al elegir "Primero quiero practicarlo", se navega al modo práctica (008) con la función extra incluida en los repositorios de práctica. El `ProviderScope` de práctica ya overridea los repos; solo se agrega el repo de la nueva función.

**Implementación**:
```dart
// En unlock_proposal_provider cuando elige "Practicar primero":
ref.read(practiceIncludeFeatureProvider.notifier).set(feature);
context.push('/easy-mode/practice');
```

El `PracticeEntryScreen` de 008 lee `practiceIncludeFeatureProvider` y, si hay una función a probar, la incluye en la práctica (ej: agrega "Ver movimientos" a la pantalla de práctica).

**Flujo**: Después de practicar, al salir del modo práctica, el usuario ve la propuesta de nuevo con la opción "Sí, actívalo" para confirmar. La función no se activa automáticamente al practicar.

**Alternatives considered**:
- Práctica separada solo para la función nueva: pierde el contexto del Modo Fácil completo.
- Activar automáticamente después de practicar: viola autonomía del usuario.

## R5: Funciones extra simuladas

**Decision**: 3 pantallas simples, cada una con datos ficticios. No reutilizan pantallas de 001 porque son flujos nuevos.

### Ver movimientos (`TransactionHistoryScreen`)
- Lista de operaciones ficticias precargadas (5-10 entradas).
- Cada entrada: fecha, descripción, monto, tipo (ingreso/egreso).
- Solo lectura, sin acciones.

### Recargar celular (`MobileRechargeScreen`)
- Formulario: número de celular (precargado ficticio) + monto (selección de 10, 20, 50 soles).
- Confirmación simple (botón, sin biometría en primera implementación).
- Mensaje de éxito ficticio.

### Pagar con QR (`QrPaymentScreen`)
- Simulación: botón "Escanear QR" que muestra un QR ficticio con datos de pago.
- No se usa la cámara real. Se simula el escaneo y se muestra un resumen de pago ficticio.
- Confirmación + éxito ficticio.

**Rationale**: Las pantallas son intencionalmente simples — son simulaciones para el prototipo. No necesitan repos complejos ni integración con el escudo antifraude (eso sería para una versión real).

**Alternatives considered**:
- Reutilizar PayBillScreen para recarga: flujos distintos (recibo vs. monto libre).
- Integrar cámara real para QR: fuera del alcance del prototipo.

## R6: Métricas de confianza — tracking de operaciones

**Decision**: El `FeatureFlagRepository` expone `incrementOpsWithoutHelp()` y `incrementPracticeSessions()`. Los providers de 001 llaman `incrementOpsWithoutHelp()` al completar una operación exitosa sin haber tocado "Pedir ayuda" durante el flujo. El provider de 008 llama `incrementPracticeSessions()` al completar una sesión de práctica.

**Detección de "sin ayuda"**: Un flag `helpRequestedDuringFlow` en el provider del flujo de 001. Se pone a true cuando el usuario toca "Pedir ayuda" (003) durante un flujo activo. Al completar la operación, si el flag es false, se incrementa el contador.

**Implementación**:
```dart
// Al completar operación exitosa en 001:
final helpUsed = ref.read(helpRequestedDuringFlowProvider);
if (!helpUsed) {
  await ref.read(featureFlagRepositoryProvider).incrementOpsWithoutHelp();
}
ref.read(helpRequestedDuringFlowProvider.notifier).reset();
```

**Alternatives considered**:
- Tracking global de todos los toques: invasivo, YAGNI.
- Solo contar operaciones (sin distinguir si pidió ayuda): no mide confianza real.

## R7: Propuesta — timing y UX

**Decision**: La propuesta aparece al abrir la pantalla principal del Modo Fácil, como un `Card` dismissable encima de las acciones principales. Se evalúa una sola vez por sesión (FR-006). No es un dialog modal.

**Implementación**:
```dart
// En EasyModeHomeScreen.build():
final proposal = ref.watch(unlockProposalProvider);

Column(
  children: [
    if (proposal != null) UnlockProposalCard(proposal: proposal),
    _PrimaryActionsGrid(),
    if (activeExtras.isNotEmpty) _ExtraFeaturesSection(...),
  ],
)
```

**El card tiene**:
- Mensaje: "Ya manejas bien tus pagos. ¿Quieres ver también tus movimientos recientes?" (≤ 15 palabras cada frase).
- 3 botones: "Sí, actívalo" / "Primero quiero practicarlo" / "No, por ahora no" (48×48 dp cada uno).
- `SemanticsService.announce()` al aparecer.

**"No, por ahora no"**: Descarta el card, incrementa rejection count, no vuelve a aparecer en esta sesión.

**Alternatives considered**:
- Bottom sheet: más intrusivo.
- Notificación al día siguiente: fuera del alcance (no hay push notifications).
- Badge en el botón de configuración: fácil de ignorar.

## R8: Sección "Más funciones" y límite de pantalla

**Decision**: Las 4 originales siempre son grid principal. Si `activeExtras.isNotEmpty`, aparece un heading "Más funciones" con los botones extra abajo. Si hay muchas extras, se scrollea — la pantalla principal se convierte en `SingleChildScrollView` con las primarias siempre visibles arriba.

**Layout**:
```
┌──────────────────────────┐
│  [Propuesta, si aplica]  │
├──────────────────────────┤
│  ┌──────┐  ┌──────┐     │
│  │Saldo │  │Pagar │     │  ← 4 primarias (siempre)
│  └──────┘  └──────┘     │
│  ┌──────┐  ┌──────┐     │
│  │Enviar│  │Ayuda │     │
│  └──────┘  └──────┘     │
├──────────────────────────┤
│  Más funciones           │  ← solo si hay extras activas
│  ┌──────┐  ┌──────┐     │
│  │Movim.│  │Recarg│     │
│  └──────┘  └──────┘     │
└──────────────────────────┘
```

**Alternatives considered**:
- Drawer/hamburger menu: oculta funciones, contradice accesibilidad.
- Tabs: cambia paradigma de pantalla única del Modo Fácil.

## R9: Volver a solo 4 acciones

**Decision**: En configuración, opción "Volver a solo 4 acciones" que cambia el estado de todas las extras de `active` a `unlockedHidden`. Requiere confirmación. No cambia `locked` ni borra métricas.

**Implementación**:
```dart
Future<void> resetToBasicView() async {
  for (final feature in ExtraFeature.values) {
    final state = await getState(feature);
    if (state == FeatureState.active) {
      await setState(feature, FeatureState.unlockedHidden);
    }
  }
}
```

**Reactivar individualmente**: En configuración, lista de funciones desbloqueadas con toggle on/off. Solo aparecen las que alguna vez fueron desbloqueadas.

**Alternatives considered**:
- Eliminar funciones completamente: contradice FR-010 (reactivar sin cumplir condiciones de nuevo).
- Un solo toggle "modo avanzado": pierde granularidad.

## R10: Persistencia de métricas y flags — datos no sensibles

**Decision**: Todo se guarda en SharedPreferences con prefijo `unlock_`. No se guarda en `flutter_secure_storage` porque no son datos sensibles (contadores de uso y preferencias de UI).

**Keys**:
| Key | Type | Description |
|-----|------|-------------|
| `unlock_ops_no_help` | `int` | Operaciones exitosas sin ayuda |
| `unlock_practice_sessions` | `int` | Sesiones de práctica completadas |
| `unlock_transactionHistory_state` | `String` | Estado de "Ver movimientos" |
| `unlock_mobileRecharge_state` | `String` | Estado de "Recargar celular" |
| `unlock_qrPayment_state` | `String` | Estado de "Pagar con QR" |
| `unlock_transactionHistory_rejections` | `int` | Rechazos de la propuesta |
| `unlock_mobileRecharge_rejections` | `int` | Rechazos de la propuesta |
| `unlock_qrPayment_rejections` | `int` | Rechazos de la propuesta |

**Alternatives considered**:
- SQLite: overkill para 8 key-value pairs.
- JSON file: más propenso a corrupción que SharedPreferences.
