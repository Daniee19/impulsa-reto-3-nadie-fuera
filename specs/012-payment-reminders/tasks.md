# Tasks: Recordatorios de Pagos Recurrentes

**Input**: Design documents from `/specs/012-payment-reminders/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, research.md, quickstart.md

**Organization**: Tasks grouped by user story. Tests included per constitution (Principle V: domain ≥80% coverage, widget tests with a11y guidelines per screen).

**Note**: This project uses plain Dart entities with manual `copyWith`/`==`/`hashCode` (not freezed) and manual Riverpod providers (not codegen). Reuses `Bill` from 001, `TrustedPerson` from 006, and `flutter_tts` from 004. Reminders are generated at runtime, not persisted.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Directory structure, ARB strings

- [ ] T001 Create feature directory structure per plan.md: `lib/features/payment_reminders/{domain/{entities,services},data/repositories,presentation/{providers,screens,widgets}}`, `test/features/payment_reminders/{domain/services,presentation/screens}`
- [ ] T002 [P] Add ARB strings to lib/core/l10n/arb/app_es.arb — keys: `reminder_title` ("Recordatorios"), `reminder_payNow` ("Pagar ahora"), `reminder_dismiss` ("Ya lo sé, gracias"), `reminder_configTitle` ("Mis recordatorios"), `reminder_anticipation` ("¿Cuántos días antes te avisamos?"), `reminder_anticipation_1` ("1 día antes"), `reminder_anticipation_3` ("3 días antes"), `reminder_anticipation_5` ("5 días antes"), `reminder_shareWithTrusted` ("Avisar también a mi persona de confianza"), `reminder_shareConsent` ("Vamos a enviar a {name} un aviso con el nombre del recibo y la fecha. No incluye tu saldo ni datos de tu cuenta. ¿Estás de acuerdo?"), `reminder_sharedNotification` ("También se avisó a {name}"), `reminder_duesToday` ("Tu recibo de {service} vence hoy: {amount} soles"), `reminder_duesTomorrow` ("Tu recibo de {service} vence mañana: {amount} soles"), `reminder_duesWeekday` ("Tu recibo de {service} vence el {weekday}: {amount} soles"), `reminder_duesDate` ("Tu recibo de {service} vence el {date}: {amount} soles"), `reminder_overdueYesterday` ("Tu recibo de {service} venció ayer. Aún puedes pagarlo."), `reminder_overdueWeekday` ("Tu recibo de {service} venció el {weekday}. Aún puedes pagarlo."), `reminder_consentTitle` ("Consentimiento"), `reminder_consentAccept` ("Sí, de acuerdo"), `reminder_consentReject` ("No"). Run `flutter gen-l10n`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, reminder generator, repository, providers. MUST be complete before ANY user story.

### Domain Entities (plain Dart, @immutable, manual copyWith/==/hashCode)

- [ ] T003 [P] Create AnticipationDays enum in lib/features/payment_reminders/domain/entities/reminder_config.dart — values: `one` (1), `three` (3), `five` (5). Each has `int get days` getter.
- [ ] T004 [P] Create ReminderConfig entity in same file — @immutable. Fields: `enabledBillIds` (Set<String>, default all bill IDs), `anticipationDays` (AnticipationDays, default `three`), `shareWithTrusted` (bool, default false), `shareConsentGranted` (bool, default false). Invariant: shareWithTrusted only true if shareConsentGranted is true. Manual copyWith, ==, hashCode.
- [ ] T005 [P] Create Reminder entity in lib/features/payment_reminders/domain/entities/reminder.dart — @immutable. Fields: `bill` (Bill from 001, non-null), `message` (String, non-empty), `isOverdue` (bool). Computed: `billId`, `dueDate`, `amount`, `serviceName` (delegates to bill). Manual ==, hashCode.

### Domain Service (Dart puro, no Flutter)

- [ ] T006 Create ReminderGenerator in lib/features/payment_reminders/domain/services/reminder_generator.dart — Method: `List<Reminder> generate({required List<Bill> bills, required ReminderConfig config, required DateTime now, required Set<String> dismissedBillIds})`. Logic: (1) filter by status == pending, (2) filter by enabledBillIds, (3) exclude dismissedBillIds, (4) include if dueDate within window (now - 3 days to now + anticipationDays), (5) sort by dueDate ascending, (6) generate natural language message per date difference table from data-model.md, (7) set isOverdue if dueDate < today.

### Data Layer

- [ ] T007 Create ReminderConfigRepository in lib/features/payment_reminders/data/repositories/reminder_config_repository.dart — uses SharedPreferences. Methods: `Future<ReminderConfig> getConfig()`, `Future<void> saveConfig(ReminderConfig)`, `Future<Set<String>> getDismissedBillIds()`, `Future<void> dismissBill(String billId)`, `Future<void> clearDismissed()`. Keys prefixed with `reminder_`.

### Providers & Routing

- [ ] T008 [P] Create reminder_config_provider in lib/features/payment_reminders/presentation/providers/reminder_config_provider.dart — Providers: `reminderConfigRepositoryProvider`, `reminderConfigProvider` (FutureProvider<ReminderConfig>). StateNotifier for config changes.
- [ ] T009 [P] Create reminder_provider in lib/features/payment_reminders/presentation/providers/reminder_provider.dart — `activeRemindersProvider` (Provider<List<Reminder>>): reads bills from billRepositoryProvider (001), reads config, reads dismissed IDs, calls ReminderGenerator.generate(). Auto-updates when bills or config change.
- [ ] T010 Add routes to lib/core/router/app_router.dart — under `/easy-mode`: `settings/reminders` → ReminderConfigScreen.

### Foundational Tests

- [ ] T011 [P] Unit tests for ReminderGenerator in test/features/payment_reminders/domain/services/reminder_generator_test.dart — tests: (1) bill due in 2 days with anticipation=3 → generates reminder, (2) bill due in 4 days with anticipation=3 → no reminder, (3) bill due yesterday → generates with isOverdue=true, (4) bill due 4 days ago → no reminder (past 3-day overdue window), (5) disabled bill → no reminder, (6) dismissed bill → no reminder, (7) paid bill (status != pending) → no reminder, (8) multiple bills sorted by dueDate ascending, (9) natural language date: today → "hoy", tomorrow → "mañana", day of week, (10) overdue message uses past tense.

**Checkpoint**: Foundation ready. Generator tested, config repo configured.

---

## Phase 3: US1 — Rosa recibe un recordatorio (Priority: P1)

**Goal**: Reminder cards on EasyModeHomeScreen with "Pagar ahora" (→ pay bill flow with preselected bill) and "Ya lo sé, gracias" (dismiss).

- [ ] T012 [US1] Create ReminderCard widget in lib/features/payment_reminders/presentation/widgets/reminder_card.dart — shows reminder message text. Two AccessibleButtons: "Pagar ahora" (icon: payment) → navigates to `/easy-mode/pay-bill` with preselectedBillId as extra, "Ya lo sé, gracias" (icon: check) → dismisses via reminderConfigRepository.dismissBill(). If shareWithTrusted active → shows badge `reminder_sharedNotification`. ≥48dp, 4.5:1 contrast, Semantics labels.
- [ ] T013 [US1] Integrate reminders into EasyModeHomeScreen — if `ref.watch(activeRemindersProvider)` is non-empty → show up to 3 ReminderCards above the main actions. TTS reads first (most urgent) reminder automatically via ttsServiceProvider from 004. Only reads the first one to avoid overwhelming.
- [ ] T014 [US1] Handle "Pagar ahora" navigation — ensure pay_bill_screen.dart accepts preselectedBillId via route extra. If provided, auto-selects that bill and pre-fills amount so user only needs to confirm.
- [ ] T015 [US1] Auto-dismiss on payment — when a bill's status changes to paid (via 001 flow), the reminder disappears because ReminderGenerator filters by status == pending.

### Tests

- [ ] T016 [P] [US1] Widget test for ReminderCard — a11y guidelines; verify message text; verify 2 buttons; verify shared badge when applicable.

**Checkpoint**: Reminders appear, auto-read, one-tap to pay, dismiss works.

---

## Phase 4: US2 — Configuración de recordatorios (Priority: P1)

**Goal**: User controls which bills generate reminders and how far in advance.

- [ ] T017 [US2] Create ReminderConfigTile widget in lib/features/payment_reminders/presentation/widgets/reminder_config_tile.dart — shows bill service name + SwitchListTile (enable/disable). ≥48dp, Semantics label includes state.
- [ ] T018 [US2] Create ReminderConfigScreen in lib/features/payment_reminders/presentation/screens/reminder_config_screen.dart — ConsumerWidget. Title: "Mis recordatorios" (ARB). Shows: list of all mock bills with ReminderConfigTile for each, anticipation selector (radio buttons: 1/3/5 days), optional shareWithTrusted toggle (only if trustedPerson exists from 006). Changes auto-save via reminderConfigRepository. SemanticsService.announce title on mount.
- [ ] T019 [US2] Add entry point — add "Mis recordatorios" option accessible from EasyModeHomeScreen settings area. Navigates to `/easy-mode/settings/reminders`.

### Tests

- [ ] T020 [P] [US2] Widget test for ReminderConfigScreen — verify all 4 bills shown with toggles; verify anticipation options; verify share toggle hidden when no trusted person; a11y guidelines.

**Checkpoint**: User has full control over which reminders to receive and when.

---

## Phase 5: US3 — Compartir con persona de confianza (Priority: P2)

**Goal**: Optionally share reminders (service + date only, no amount) with trusted person.

- [ ] T021 [US3] Implement share toggle with consent — in ReminderConfigScreen: when user toggles shareWithTrusted ON and consent not yet granted → show consent dialog (ARB `reminder_shareConsent` with trusted person name). Accept → set shareConsentGranted + shareWithTrusted. Reject → toggle stays off. If consent already granted → toggle directly.
- [ ] T022 [US3] Implement shared notification badge — in ReminderCard: when shareWithTrusted is active and trustedPerson exists → show small badge "También se avisó a {name}". The actual notification is simulated (no real push).

### Tests

- [ ] T023 [P] [US3] Test consent flow — verify dialog shown on first toggle; verify consent not re-asked after grant; verify toggle off without consent does nothing.

**Checkpoint**: Sharing works with proper consent. No amount/balance leaked.

---

## Phase 6: US4 + US5 — TalkBack + multiple reminders (Priority: P2)

- [ ] T024 [US4] Verify TalkBack for reminders — announcement includes service, date, amount and both options.
- [ ] T025 [US5] Verify multiple reminders display — when 2+ reminders: ordered by dueDate, only first read by TTS, up to 3 visible, scroll for rest.

---

## Phase 7: Extend mock bills (Priority: P2)

- [ ] T026 Ensure 4 mock bills exist in 001's BillRepository — verify luz (S/ 85.50, due 15th), agua (S/ 42.00, due 20th), teléfono (S/ 60.00, due 10th), pensión (S/ 150.00, due 5th). Add any missing. Due dates relative to current month so at least 1 is always upcoming during demo.

---

## Phase 8: Polish & Cross-Cutting

- [ ] T027 [P] Run `flutter analyze`, verify 0 warnings
- [ ] T028 [P] Run `dart format` on all payment_reminders files
- [ ] T029 [P] Verify all UI strings come from ARB
- [ ] T030 Run quickstart.md validation scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup
- **US1 (Phase 3)**: Depends on Phase 2 + 001 bill/pay flow + 004 TTS
- **US2 (Phase 4)**: Depends on Phase 2
- **US3 (Phase 5)**: Depends on Phase 4 + 006 trusted person
- **US4+US5 (Phase 6)**: Depends on Phases 3-4
- **Mock bills (Phase 7)**: Can run anytime after Phase 2
- **Polish (Phase 8)**: Depends on all

### Parallel Opportunities

- T003, T004, T005 run in parallel (different entity files)
- T008, T009 run in parallel
- US1 (Phase 3) and US2 (Phase 4) can run in parallel after Phase 2
- T026 (mock bills) can run in parallel with everything after Phase 2
- All [P] test tasks run in parallel

---

## Notes

- Plain Dart entities — NOT freezed
- Manual Riverpod providers — NOT codegen
- Reminders generated at runtime, not persisted (ephemeral)
- Reuses Bill from 001 — does NOT duplicate bill data
- "Pagar ahora" navigates to existing 001 pay bill flow with preselected bill
- Natural language dates: hoy, mañana, el viernes, el 20 de octubre
- Overdue reminders shown up to 3 days past due, then disappear
- Default config: all bills active, 3 days anticipation, no sharing
- Share with trusted: service + date ONLY, never amount/balance (Ley 29733)
- Consent required before sharing (explicit dialog)
- TTS reads only the most urgent reminder (first in list)
- Never interrupts operations — shown on home screen only
- 4 mock bills for hackathon demo
