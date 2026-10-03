# Payment Reminders Contract (012-payment-reminders)

Recordatorios de pagos recurrentes in-app con lectura TTS, pago directo desde recordatorio, y aviso opcional a persona de confianza.

## ReminderGenerator

Ubicación: `lib/features/payment_reminders/domain/services/reminder_generator.dart`

Dart puro. Sin dependencias de Flutter.

```dart
class ReminderGenerator {
  /// Genera recordatorios activos a partir de bills, configuración y fecha actual.
  /// Retorna lista ordenada por dueDate (más próximo primero).
  List<Reminder> generate({
    required List<Bill> bills,
    required ReminderConfig config,
    required DateTime now,
    required Set<String> dismissedBillIds,
  });
}
```

**Contrato**:
- Solo incluye bills con `status == BillStatus.pending`.
- Solo incluye bills cuyo `id` está en `config.enabledBillIds`.
- Excluye bills cuyo `id` está en `dismissedBillIds`.
- Incluye bills cuyo `dueDate` está en la ventana: `[now - 3 días, now + config.anticipationDays.value]`.
- Retorna lista ordenada por `dueDate` ascendente.
- Cada `Reminder` tiene `isOverdue = true` si `dueDate < startOfDay(now)`.
- El `message` se genera con `formatDueDate()` en lenguaje natural.
- Es síncrono y puro — no accede a repos ni providers.

## ReminderConfigRepository

Ubicación: `lib/features/payment_reminders/data/repositories/reminder_config_repository.dart`

```dart
class ReminderConfigRepository {
  final SharedPreferences _prefs;

  ReminderConfigRepository(this._prefs);

  Future<ReminderConfig> getConfig(List<String> allBillIds) async {
    final enabledIds = _prefs.getStringList('reminder_enabled_bills');
    final days = _prefs.getInt('reminder_anticipation_days') ?? 3;
    final share = _prefs.getBool('reminder_share_with_trusted') ?? false;
    final consent = _prefs.getBool('reminder_share_consent_granted') ?? false;

    return ReminderConfig(
      enabledBillIds: enabledIds?.toSet() ?? allBillIds.toSet(),
      anticipationDays: AnticipationDays.fromValue(days),
      shareWithTrusted: share && consent,
      shareConsentGranted: consent,
    );
  }

  Future<void> setEnabledBills(Set<String> billIds) async =>
      await _prefs.setStringList('reminder_enabled_bills', billIds.toList());

  Future<void> setAnticipationDays(AnticipationDays days) async =>
      await _prefs.setInt('reminder_anticipation_days', days.value);

  Future<void> setShareWithTrusted(bool value) async =>
      await _prefs.setBool('reminder_share_with_trusted', value);

  Future<void> setShareConsentGranted(bool value) async =>
      await _prefs.setBool('reminder_share_consent_granted', value);

  Future<Set<String>> getDismissedBillIds() async {
    final list = _prefs.getStringList('reminder_dismissed_bills');
    return list?.toSet() ?? {};
  }

  Future<void> dismissBill(String billId) async {
    final current = await getDismissedBillIds();
    current.add(billId);
    await _prefs.setStringList('reminder_dismissed_bills', current.toList());
  }

  Future<void> clearDismissed() async =>
      await _prefs.remove('reminder_dismissed_bills');
}
```

**Contrato**:
- `getConfig()` retorna defaults si no hay valores guardados: todos los bills activos, 3 días, sin compartir.
- `setEnabledBills()` persiste el set de IDs con recordatorio activo.
- `setAnticipationDays()` persiste la opción elegida.
- `setShareWithTrusted()` solo se activa si `shareConsentGranted == true`.
- `dismissBill()` agrega un bill al set de descartados (no vuelve a mostrarse para esa fecha de vencimiento).
- `clearDismissed()` limpia los descartados (al cambiar de mes/ciclo).

## ActiveRemindersProvider

Ubicación: `lib/features/payment_reminders/presentation/providers/reminder_provider.dart`

```dart
@riverpod
Future<List<Reminder>> activeReminders(Ref ref) async {
  final billRepo = ref.read(billRepositoryProvider);
  final configRepo = ref.read(reminderConfigRepositoryProvider);

  final bills = await billRepo.getPendingBills();
  final allBillIds = bills.map((b) => b.id).toList();
  final config = await configRepo.getConfig(allBillIds);
  final dismissed = await configRepo.getDismissedBillIds();

  final generator = const ReminderGenerator();
  return generator.generate(
    bills: bills,
    config: config,
    now: DateTime.now(),
    dismissedBillIds: dismissed,
  );
}
```

**Contrato**:
- Se re-evalúa al cambiar config o al pagar un bill (invalidación via `ref.invalidate`).
- Retorna lista ordenada por urgencia (más próximo primero).
- Máximo de display (3 en pantalla principal) se maneja en el widget, no en el provider.

## ReminderConfigProvider

Ubicación: `lib/features/payment_reminders/presentation/providers/reminder_config_provider.dart`

```dart
@riverpod
class ReminderConfigNotifier extends _$ReminderConfigNotifier {
  @override
  Future<ReminderConfig> build() async {
    final billRepo = ref.read(billRepositoryProvider);
    final bills = await billRepo.getPendingBills();
    final allBillIds = bills.map((b) => b.id).toList();
    return ref.read(reminderConfigRepositoryProvider).getConfig(allBillIds);
  }

  Future<void> toggleBill(String billId, bool enabled) async {
    final config = state.requireValue;
    final updated = enabled
        ? {...config.enabledBillIds, billId}
        : (config.enabledBillIds..remove(billId));
    await ref.read(reminderConfigRepositoryProvider).setEnabledBills(updated);
    ref.invalidateSelf();
    ref.invalidate(activeRemindersProvider);
  }

  Future<void> setAnticipation(AnticipationDays days) async {
    await ref.read(reminderConfigRepositoryProvider).setAnticipationDays(days);
    ref.invalidateSelf();
    ref.invalidate(activeRemindersProvider);
  }

  Future<void> enableShareWithTrusted(bool value) async {
    if (value && !state.requireValue.shareConsentGranted) {
      return; // Must grant consent first
    }
    await ref.read(reminderConfigRepositoryProvider).setShareWithTrusted(value);
    ref.invalidateSelf();
  }

  Future<void> grantShareConsent() async {
    final repo = ref.read(reminderConfigRepositoryProvider);
    await repo.setShareConsentGranted(true);
    await repo.setShareWithTrusted(true);
    ref.invalidateSelf();
  }
}
```

## ReminderCard Widget

Ubicación: `lib/features/payment_reminders/presentation/widgets/reminder_card.dart`

```dart
class ReminderCard extends ConsumerWidget {
  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: reminder.message,
      child: Card(
        color: reminder.isOverdue
            ? Theme.of(context).colorScheme.errorContainer
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.message,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push(
                        '/easy-mode/pay-bill',
                        extra: {'preselectedBillId': reminder.billId},
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text(context.l10n.reminderPayNow),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref.read(reminderConfigRepositoryProvider)
                            .dismissBill(reminder.billId);
                        ref.invalidate(activeRemindersProvider);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text(context.l10n.reminderDismiss),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Contrato**:
- "Pagar ahora": navega a `/easy-mode/pay-bill` con `preselectedBillId`.
- "Ya lo sé, gracias": descarta (no vuelve para esa fecha de vencimiento).
- Ambos botones ≥ 48dp alto.
- Card con fondo error si `isOverdue`.
- Semantics.label con el mensaje completo.

## Contrato de integración con 001 (Bills y pago)

**Bills**: `ReminderProvider` consume `BillRepository.getPendingBills()`. Sin wrapper.

**Pago preseleccionado**:
```dart
// En el flujo de pago de 001, leer extra:
final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
final preselectedBillId = extra?['preselectedBillId'] as String?;
if (preselectedBillId != null) {
  // Preseleccionar bill y prellenar monto
}
```

**Al completar pago**: `BillRepository` cambia `bill.status` a `paid`. `activeRemindersProvider` se invalida y el recordatorio desaparece (bill ya no es pending).

**Home screen**:
```dart
// En EasyModeHomeScreen.build():
final reminders = ref.watch(activeRemindersProvider);

Column(
  children: [
    // Recordatorios (hasta 3):
    if (reminders.valueOrNull?.isNotEmpty ?? false)
      ...reminders.valueOrNull!.take(3).map(
        (r) => ReminderCard(reminder: r),
      ),
    // ... sugerencia de lección (011), propuesta (009), acciones primarias
  ],
)
```

**Prioridad visual**: Recordatorios encima de sugerencias de lección (011) y propuestas (009). Los recordatorios son info del momento actual; las sugerencias pueden esperar.

## Contrato de integración con 006 (Persona de confianza)

```dart
// En ReminderConfigScreen:
final trustedPerson = ref.watch(trustedPersonProvider);

// Solo mostrar opción si hay persona de confianza:
if (trustedPerson != null)
  SwitchListTile(
    title: Text(l10n.reminderShareWithTrusted(trustedPerson.name)),
    value: config.shareWithTrusted,
    onChanged: (value) {
      if (value && !config.shareConsentGranted) {
        _showConsentDialog(context, trustedPerson.name);
      } else {
        configNotifier.enableShareWithTrusted(value);
      }
    },
  ),
```

**Badge en ReminderCard** (cuando compartir está activo):
```dart
if (config.shareWithTrusted)
  Text(
    l10n.reminderSharedWithTrusted(trustedPerson.name),
    style: Theme.of(context).textTheme.bodySmall,
  ),
```

## Contrato de integración con 004 (TTS)

```dart
// En EasyModeHomeScreen, al cargar recordatorios:
ref.listen(activeRemindersProvider, (_, reminders) {
  final list = reminders.valueOrNull;
  if (list != null && list.isNotEmpty) {
    ref.read(ttsServiceProvider).speak(list.first.message);
  }
});
```

Solo lee el primer recordatorio (más urgente).

## Rutas de navegación

```
/easy-mode/settings/reminders    → ReminderConfigScreen
```

Los recordatorios se muestran en `EasyModeHomeScreen` (no tienen ruta propia). "Pagar ahora" navega a `/easy-mode/pay-bill`.

## Invariantes

1. **Solo pendientes activos**: `status == pending` AND `enabledBillIds.contains(id)`.
2. **Ventana temporal**: `[now - 3, now + anticipationDays]`.
3. **Ordenados por urgencia**: `dueDate` ascendente.
4. **Hasta 3 en pantalla**: Widget limita a 3, scroll para más.
5. **TTS del más urgente**: Solo el primero, automáticamente.
6. **"Pagar ahora" prellenado**: `preselectedBillId` en extra.
7. **Desaparece al pagar**: Bill `paid` → filtrado por generator.
8. **"Ya lo sé" no vuelve**: `dismissedBillIds` persiste en SharedPreferences.
9. **Default todos activos, 3 días**: First-run experience sin configuración.
10. **Persona de confianza sin monto**: Solo servicio + fecha (Ley 29733, FR-010).
11. **Consentimiento obligatorio**: `shareConsentGranted` antes de `shareWithTrusted`.
12. **Nunca interrumpe**: Solo en pantalla principal, no modal ni push.
13. **Accesibilidad**: 48×48 dp, 4.5:1, Semantics, TalkBack.
