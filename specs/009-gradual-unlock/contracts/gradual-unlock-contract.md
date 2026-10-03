# Gradual Unlock Contract (009-gradual-unlock)

Sistema de feature flags por usuario que desbloquea funciones extra basándose en métricas de confianza.

## UnlockEvaluator

Ubicación: `lib/features/gradual_unlock/domain/services/unlock_evaluator.dart`

Dart puro. Sin dependencias de Flutter.

```dart
class UnlockEvaluator {
  final UnlockThresholds thresholds;

  const UnlockEvaluator({this.thresholds = const UnlockThresholds()});

  /// Evalúa si hay una función para proponer al usuario.
  /// Retorna null si no se debe proponer nada.
  UnlockProposal? evaluate({
    required ConfidenceMetrics metrics,
    required Map<ExtraFeature, FeatureState> states,
    required Map<ExtraFeature, int> rejections,
    required bool proposalShownThisSession,
  });
}
```

**Contrato**:
- `evaluate()` es síncrono y puro — no accede a SharedPreferences ni a providers.
- Retorna `null` si: ya se mostró una propuesta esta sesión, métricas no alcanzan umbral, o todas las features están desbloqueadas/rechazadas al máximo.
- Recorre `ExtraFeature.values` en orden (enum order = prioridad) y retorna la primera `locked` elegible.
- Una feature con `rejections >= thresholds.maxRejections` se salta.
- Features en estado `unlockedHidden` o `active` se saltan (ya desbloqueadas).

## FeatureFlagRepository

Ubicación: `lib/features/gradual_unlock/data/repositories/feature_flag_repository.dart`

```dart
abstract class FeatureFlagRepository {
  /// Lee el estado de una función extra.
  Future<FeatureState> getState(ExtraFeature feature);

  /// Cambia el estado de una función extra.
  Future<void> setState(ExtraFeature feature, FeatureState state);

  /// Lee las métricas de confianza acumuladas.
  Future<ConfidenceMetrics> getMetrics();

  /// Incrementa operaciones exitosas sin ayuda.
  Future<void> incrementOpsWithoutHelp();

  /// Incrementa sesiones de práctica completadas.
  Future<void> incrementPracticeSessions();

  /// Lee el contador de rechazos de una función.
  Future<int> getRejectionCount(ExtraFeature feature);

  /// Incrementa el contador de rechazos de una función.
  Future<void> incrementRejection(ExtraFeature feature);

  /// Oculta todas las extras activas (→ unlockedHidden).
  Future<void> resetToBasicView();

  /// Lee los estados de todas las funciones.
  Future<Map<ExtraFeature, FeatureState>> getAllStates();

  /// Lee los rechazos de todas las funciones.
  Future<Map<ExtraFeature, int>> getAllRejections();
}
```

**Contrato**:
- `getState()` retorna `FeatureState.locked` si no hay valor guardado.
- `setState()` persiste en SharedPreferences. Solo permite transiciones válidas (ver state transitions en data-model).
- `incrementOpsWithoutHelp()` y `incrementPracticeSessions()` son acumulativos (nunca decrementan).
- `resetToBasicView()` cambia `active` → `unlockedHidden` para todas. No toca `locked`.
- `getAllStates()` retorna un mapa completo para el evaluator.

## FeatureFlagsProvider

Ubicación: `lib/features/gradual_unlock/presentation/providers/feature_flags_provider.dart`

```dart
@riverpod
class FeatureFlagsNotifier extends _$FeatureFlagsNotifier {
  @override
  Future<Map<ExtraFeature, FeatureState>> build() async {
    return ref.read(featureFlagRepositoryProvider).getAllStates();
  }

  /// Activa una función extra.
  Future<void> activate(ExtraFeature feature) async {
    await ref.read(featureFlagRepositoryProvider)
        .setState(feature, FeatureState.active);
    ref.invalidateSelf();
  }

  /// Oculta una función extra (no la elimina).
  Future<void> hide(ExtraFeature feature) async {
    await ref.read(featureFlagRepositoryProvider)
        .setState(feature, FeatureState.unlockedHidden);
    ref.invalidateSelf();
  }

  /// Oculta todas las extras activas.
  Future<void> resetToBasicView() async {
    await ref.read(featureFlagRepositoryProvider).resetToBasicView();
    ref.invalidateSelf();
  }
}
```

**Provider derivado**:
```dart
@riverpod
List<ExtraFeature> activeExtraFeatures(Ref ref) {
  final states = ref.watch(featureFlagsNotifierProvider).valueOrNull ?? {};
  return ExtraFeature.values
      .where((f) => states[f] == FeatureState.active)
      .toList();
}
```

## UnlockProposalProvider

Ubicación: `lib/features/gradual_unlock/presentation/providers/unlock_proposal_provider.dart`

```dart
@riverpod
class UnlockProposalNotifier extends _$UnlockProposalNotifier {
  bool _shownThisSession = false;

  @override
  Future<UnlockProposal?> build() async {
    if (_shownThisSession) return null;

    final repo = ref.read(featureFlagRepositoryProvider);
    final metrics = await repo.getMetrics();
    final states = await repo.getAllStates();
    final rejections = await repo.getAllRejections();

    final evaluator = const UnlockEvaluator();
    final proposal = evaluator.evaluate(
      metrics: metrics,
      states: states,
      rejections: rejections,
      proposalShownThisSession: false,
    );

    if (proposal != null) _shownThisSession = true;
    return proposal;
  }

  Future<void> accept(ExtraFeature feature) async {
    await ref.read(featureFlagsNotifierProvider.notifier).activate(feature);
    state = const AsyncValue.data(null);
  }

  Future<void> practiceFirst(ExtraFeature feature, BuildContext context) async {
    ref.read(practiceIncludeFeatureProvider.notifier).set(feature);
    context.push('/easy-mode/practice');
    state = const AsyncValue.data(null);
  }

  Future<void> reject(ExtraFeature feature) async {
    await ref.read(featureFlagRepositoryProvider).incrementRejection(feature);
    state = const AsyncValue.data(null);
  }
}
```

## Contrato de integración con 001

Cambio mínimo en `EasyModeHomeScreen`:

```dart
// Agregar en EasyModeHomeScreen.build():
final proposal = ref.watch(unlockProposalNotifierProvider);
final activeExtras = ref.watch(activeExtraFeaturesProvider);

// Propuesta (si aplica):
if (proposal.valueOrNull != null)
  UnlockProposalCard(proposal: proposal.valueOrNull!),

// Sección extra (si hay activas):
if (activeExtras.isNotEmpty)
  ExtraFeaturesSection(features: activeExtras),
```

**Tracking de métricas** — en providers de operación de 001:
```dart
// Al completar operación exitosa:
if (!ref.read(helpRequestedDuringFlowProvider)) {
  await ref.read(featureFlagRepositoryProvider).incrementOpsWithoutHelp();
}
```

## Contrato de integración con 008

Al elegir "Practicar primero":
```dart
ref.read(practiceIncludeFeatureProvider.notifier).set(feature);
context.push('/easy-mode/practice');
```

El mode práctica de 008 lee `practiceIncludeFeatureProvider` y agrega la función en su pantalla principal de práctica.

## Rutas de navegación

```
/easy-mode                              → EasyModeHomeScreen (+ propuesta + extras)
/easy-mode/transactions                 → TransactionHistoryScreen (función extra)
/easy-mode/recharge                     → MobileRechargeScreen (función extra)
/easy-mode/qr-payment                   → QrPaymentScreen (función extra)
/easy-mode/settings/unlock              → UnlockSettingsScreen (reactivar/ocultar)
```

## Invariantes

1. **4 primarias siempre**: Las acciones originales nunca se mueven, ocultan ni reordenan.
2. **Evaluator puro**: No tiene side effects. Solo evalúa datos y retorna propuesta.
3. **Persistencia correcta**: Feature flags persisten entre sesiones (SharedPreferences). Métricas acumulan.
4. **Reversible**: "Volver a solo 4 acciones" nunca elimina — solo oculta. Reactivación sin condiciones.
5. **Una propuesta por sesión**: Flag in-memory. Se resetea al cerrar la app.
6. **3 rechazos = manual only**: Después de 3 rechazos, la función solo se activa desde configuración.
7. **Sin gamificación**: Sin puntos, badges, progress bars, ni celebraciones.
