# Tasks: Modo Práctica

**Input**: Design documents from `/specs/008-practice-mode/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/practice-mode-contract.md, research.md

**Organization**: Tasks grouped by user story. This feature creates `lib/features/practice_mode/` with practice repositories that implement existing 001 interfaces via ProviderScope override. Entities use `@immutable` with manual `==`/`hashCode`/`copyWith` (matching existing codebase pattern). No new dependencies. Reuses screens from 001/002 without modification — all isolation via provider overrides. Green theme (#2E7D32), persistent PracticeBanner, TTS announcements.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Feature directory structure, ARB strings, verify 001 provider overridability

- [ ] T001 Create feature directory structure: `lib/features/practice_mode/{domain/entities,data/{repositories,services},presentation/{providers,screens,widgets}}`
- [ ] T002 [P] Add ARB strings to lib/core/l10n/arb/app_es.arb — keys for: `practice_title` ("Modo práctica"), `practice_entry_heading` ("Vas a practicar"), `practice_entry_body` ("Todo lo que hagas aquí es de mentira. Tu dinero real no se mueve."), `practice_entry_withGuide` ("Practicar con guía"), `practice_entry_withoutGuide` ("Practicar sin guía"), `practice_banner` ("MODO PRÁCTICA — tu dinero real no se mueve"), `practice_confirm_button` ("Confirmar práctica"), `practice_exit_button` ("Salir de práctica"), `practice_exit_title` ("¿Salir de práctica?"), `practice_exit_body` ("Vas a volver a tu cuenta real"), `practice_exit_confirm` ("Sí, salir"), `practice_exit_cancel` ("Seguir practicando"), `practice_tryAgain` ("Practicar otra vez"), `practice_guide_step` ("Paso {current} de {total}: {instruction}"), with placeholders for `current` (int), `total` (int), `instruction` (String). Also add guide step instructions: `practice_guide_balance` ("Toca 'Ver mi saldo' para ver cuánto tienes"), `practice_guide_payBill` ("Toca 'Pagar recibo' para ver tus recibos pendientes"), `practice_guide_selectBill` ("Elige un recibo de la lista"), `practice_guide_confirmPay` ("Revisa los datos y toca 'Confirmar práctica'"), `practice_guide_sendMoney` ("Toca 'Enviar dinero' para ver tus contactos"), `practice_guide_selectContact` ("Elige a quién quieres enviar"), `practice_guide_enterAmount` ("Escribe el monto que quieres enviar"), `practice_guide_confirmSend` ("Revisa los datos y toca 'Confirmar práctica'"), `practice_guide_done` ("¡Muy bien! Has completado la práctica"). Run `flutter gen-l10n`
- [ ] T003 [P] Verify 001 repository providers are overridable — check that `accountRepositoryProvider`, `billRepositoryProvider`, `contactRepositoryProvider`, `operationRepositoryProvider` exist as top-level Riverpod providers in lib/features/easy_mode/presentation/providers/. If any provider uses concrete implementations directly (not via abstract interface), refactor to use the abstract interface so ProviderScope override works. Also verify `riskEngineProvider` from 002 and `biometricAuthProvider` from 001 are overridable

---

## Phase 2: Foundational (Domain Entity + Practice Repositories)

**Purpose**: PracticeSession entity and all practice repositories implementing 001 interfaces. Dart puro where possible. MUST be complete before presentation.

- [ ] T004 [P] Create PracticeSession entity in lib/features/practice_mode/domain/entities/practice_session.dart — fields: `bool active` (non-null, default false), `bool guideEnabled` (non-null, default false), `DateTime? startedAt` (nullable, null when inactive). `@immutable`, manual `==`/`hashCode`/`copyWith`. Factory `PracticeSession.inactive()` returns `PracticeSession(active: false, guideEnabled: false, startedAt: null)`. Factory `PracticeSession.start({required bool guideEnabled})` returns `PracticeSession(active: true, guideEnabled: guideEnabled, startedAt: DateTime.now())`
- [ ] T005 [P] Create PracticeGuideStep entity in lib/features/practice_mode/domain/entities/practice_guide_step.dart — fields: `String routePattern` (non-empty, the route this step matches), `String instruction` (non-empty, ARB key for the instruction text), `int stepNumber` (>= 1), `int totalSteps` (>= stepNumber). `@immutable`, manual `==`/`hashCode`
- [ ] T006 [P] Create PracticeAccountRepository in lib/features/practice_mode/data/repositories/practice_account_repository.dart — implements `AccountRepository` from `lib/features/easy_mode/domain/repositories/account_repository.dart`. Initial account: id `'practice-account'`, holderName `'Cuenta de práctica'`, maskedNumber `'****0000'`, availableBalance `5000.0`, currency `'PEN'`. Methods: `getAccount()` returns current account, `updateBalance(String accountId, double newBalance)` updates in-memory balance. `void reset()` restores balance to 5000.0. Per contract
- [ ] T007 [P] Create PracticeBillRepository in lib/features/practice_mode/data/repositories/practice_bill_repository.dart — implements `BillRepository`. 3 initial bills per contract: Luz/Enel Práctica S/95, Agua/Sedapal Práctica S/38, Teléfono/Movistar Práctica S/55. All `BillStatus.pending`, IDs prefixed `p-bill-`. Methods: `getBills({BillStatus? status})` filters by status, `getBillById(String billId)` finds by id, `payBill(String billId)` marks paid. `void reset()` restores initial bills
- [ ] T008 [P] Create PracticeContactRepository in lib/features/practice_mode/data/repositories/practice_contact_repository.dart — implements `ContactRepository`. 3 static contacts per contract: Ana García/****1111, Pedro Ruiz/****2222, Lucía Torres/****3333. IDs prefixed `p-contact-`. Methods: `getContacts()`, `getContactById(String contactId)`. No reset needed (immutable)
- [ ] T009 [P] Create PracticeOperationRepository in lib/features/practice_mode/data/repositories/practice_operation_repository.dart — implements `OperationRepository`. In-memory list. `createOperation(...)` creates with ID `p-op-{n}`, status `success`. `getOperations()` returns reversed list. `void reset()` clears list
- [ ] T010 [P] Create PracticeRiskEngine in lib/features/practice_mode/data/services/practice_risk_engine.dart — implements `RiskEngine` from 002. `evaluate({required OperationContext context, required List<Operation> history})`: if `context.amount > 500` returns `RiskAlert(triggeredRules: {RiskRule.unusualAmount}, operation: context)`, else returns `null`. Fixed threshold, no history logic
- [ ] T011 [P] Create PracticeBiometricAuth in lib/features/practice_mode/data/services/practice_biometric_auth.dart — implements the biometric auth interface from 001. `authenticate()` always returns `true` (no actual biometric prompt in practice mode). This replaces real biometric confirmation with "Confirmar práctica"

**Checkpoint**: All practice repositories and services complete. Each implements the 001/002 abstract interface with fictional in-memory data.

---

## Phase 3: US1 — Rosa entra al modo práctica (Priority: P1) 🎯 MVP

**Goal**: User taps "Practicar" from home, sees explanation screen, chooses guide mode, enters practice with green theme + banner.

**Independent Test**: Tap "Practicar" on home → entry screen → choose "Con guía" → practice home shows with green banner "MODO PRÁCTICA".

### Implementation for US1

- [ ] T012 [US1] Create PracticeSessionNotifier provider in lib/features/practice_mode/presentation/providers/practice_session_provider.dart — `StateNotifier<PracticeSession>` (NOT codegen). Initial state: `PracticeSession.inactive()`. Methods: `void start({required bool guideEnabled})` — sets state to `PracticeSession.start(guideEnabled: guideEnabled)`, announces via TTS "Entrando al modo práctica"; `void end()` — sets state to `PracticeSession.inactive()`, announces via TTS "Saliendo del modo práctica". Create `practiceSessionProvider` as `StateNotifierProvider<PracticeSessionNotifier, PracticeSession>`
- [ ] T013 [US1] Create practiceTheme in lib/features/practice_mode/presentation/providers/practice_theme.dart — a `ThemeData` that copies the current theme but overrides `colorScheme.primary` to `Color(0xFF2E7D32)` (green 800), `colorScheme.primaryContainer` to `Color(0xFFC8E6C9)` (green 100), and `appBarTheme.backgroundColor` to `Color(0xFF2E7D32)`. Export as `ThemeData practiceTheme(ThemeData base)` function
- [ ] T014 [US1] Create PracticeBanner widget in lib/features/practice_mode/presentation/widgets/practice_banner.dart — `StatelessWidget`. Shows a green `Container` with `practice_banner` ARB text ("MODO PRÁCTICA — tu dinero real no se mueve"), white text on green background, 48dp height minimum, centered, `Semantics(liveRegion: true)`. Always visible in practice mode
- [ ] T015 [US1] Create PracticeEntryScreen in lib/features/practice_mode/presentation/screens/practice_entry_screen.dart — `ConsumerWidget`. Shows: icon (Icons.school, size 64), heading (`practice_entry_heading`), body text (`practice_entry_body`, 18sp), two buttons: "Practicar con guía" → calls `practiceSessionProvider.notifier.start(guideEnabled: true)` then navigates to `/easy-mode/practice/home`; "Practicar sin guía" → calls `practiceSessionProvider.notifier.start(guideEnabled: false)` then navigates to `/easy-mode/practice/home`. Both buttons 48dp minimum, 18sp. TTS announces screen on enter. Scaffold with AppBar title `practice_title`
- [ ] T016 [US1] Create practice ProviderScope shell and routes in lib/core/router/app_router.dart — Add a `ShellRoute` at path `/easy-mode/practice` that wraps its child in `ProviderScope(overrides: [...])` with all practice overrides per contract: `accountRepositoryProvider`, `billRepositoryProvider`, `contactRepositoryProvider`, `operationRepositoryProvider`, `riskEngineProvider`, `biometricAuthProvider`. The shell builder also wraps child in `Theme(data: practiceTheme(Theme.of(context)))` and a `Column` with `PracticeBanner()` on top and `Expanded(child: child)`. Sub-routes: `/easy-mode/practice` → `PracticeEntryScreen`, `/easy-mode/practice/home` → `EasyModeHomeScreen` (reused from 001), `/easy-mode/practice/balance` → reuse 001 balance, `/easy-mode/practice/pay-bill` → reuse 001 pay-bill, `/easy-mode/practice/pay-bill/:id/confirm` → reuse 001 confirm, `/easy-mode/practice/send-money` → reuse 001 send-money, `/easy-mode/practice/send-money/confirm` → reuse 001 confirm, `/easy-mode/practice/success` → reuse 001 success
- [ ] T017 [US1] Add "Practicar" button to EasyModeHomeScreen in lib/features/easy_mode/presentation/screens/easy_mode_home_screen.dart — Add an `OutlinedButton.icon` with `Icons.school` and text "Practicar" below the existing 4 ActionCards. 48dp min target. `onPressed` navigates to `/easy-mode/practice`. This is the ONLY change to a 001 screen — it's additive, not modifying existing behavior

**Checkpoint**: User can enter practice mode from home. Green theme + banner visible. Practice repos provide fictional data. 001 screens work unchanged.

---

## Phase 4: US2 — Rosa practica con guía paso a paso (Priority: P1)

**Goal**: Step-by-step guide overlay shows instructions for each screen in the practice flow.

**Independent Test**: Enter practice with guide → home shows step 1 instruction → navigate to pay-bill → step 2 instruction updates → complete flow → "¡Muy bien!" message.

### Implementation for US2

- [ ] T018 [US2] Create PracticeGuideService in lib/features/practice_mode/data/services/practice_guide_service.dart — Holds a `List<PracticeGuideStep>` for the guided flow. Steps mapped to routes per contract: step 1 `/easy-mode/practice/home` (practice_guide_balance), step 2 `/easy-mode/practice/balance` (practice_guide_payBill), step 3 `/easy-mode/practice/pay-bill` (practice_guide_selectBill), step 4 `/easy-mode/practice/pay-bill/.*/confirm` (practice_guide_confirmPay, route is regex), step 5 `/easy-mode/practice/home` again (practice_guide_sendMoney — after returning), step 6 `/easy-mode/practice/send-money` (practice_guide_selectContact), step 7 `/easy-mode/practice/send-money` with amount (practice_guide_enterAmount), step 8 `/easy-mode/practice/send-money/confirm` (practice_guide_confirmSend). Method `PracticeGuideStep? getStepForRoute(String currentRoute, int completedSteps)` returns the next guide step based on current route and how many steps have been completed. Method `bool isComplete(int completedSteps)` returns true when all steps done
- [ ] T019 [US2] Create PracticeGuideNotifier provider in lib/features/practice_mode/presentation/providers/practice_guide_provider.dart — `StateNotifier<PracticeGuideStep?>` (nullable, null when no guide or complete). Constructor takes `PracticeGuideService`. On route change (listens to GoRouter), calls `getStepForRoute()` and updates state. Method `void advanceStep()` increments completed count and recalculates. Method `void complete()` sets state to null. Create `practiceGuideProvider` as `StateNotifierProvider`
- [ ] T020 [US2] Create PracticeGuideOverlay widget in lib/features/practice_mode/presentation/widgets/practice_guide_overlay.dart — `ConsumerWidget`. Watches `practiceGuideProvider` and `practiceSessionProvider`. Only renders when `session.guideEnabled && step != null`. Renders a bottom-anchored `Card` with `practice_guide_step` ARB text ("Paso {current} de {total}: {instruction}"), 18sp text, green accent border, `Semantics(liveRegion: true)` for TTS. When step changes, calls `SemanticsService.announce()`. When guide is complete, shows `practice_guide_done` text briefly
- [ ] T021 [US2] Integrate PracticeGuideOverlay into practice shell in lib/core/router/app_router.dart — In the practice ShellRoute builder (from T016), add PracticeGuideOverlay as a layer in the Stack, above the banner and content

**Checkpoint**: Guided practice walks user through balance → pay bill → send money with step-by-step instructions.

---

## Phase 5: US3 — Rosa ve alerta de fraude simulada (Priority: P2)

**Goal**: Practice risk engine triggers when amount > S/500, showing the existing fraud alert screen with practice data.

**Independent Test**: In practice mode, send money > S/500 → fraud alert screen appears with "Este pago es mucho más alto" message.

### Implementation for US3

- [ ] T022 [US3] Verify PracticeRiskEngine integration — Confirm that the `riskEngineProvider` override (from T016) correctly injects `PracticeRiskEngine` into the fraud detection flow. The existing `FraudAlertScreen` from 002 should work without changes. Test: in practice mode, navigate to send money, enter amount > 500, confirm → fraud alert appears. If integration doesn't work, check that the 002 fraud alert provider reads from `riskEngineProvider` (not a concrete implementation)
- [ ] T023 [US3] [P] Add educational note for practice fraud alert — If the guide is active during a fraud alert, the `PracticeGuideOverlay` should show a special instruction like "Esta es una alerta de seguridad. En la vida real, te protege de pagos sospechosos." Add ARB key `practice_guide_fraudAlert` with this text. The overlay already renders based on route, so add a guide step that matches the fraud alert route pattern

**Checkpoint**: Simulated fraud alert works in practice. User sees the same 002 screen but with practice data and optional educational context.

---

## Phase 6: US4 — Rosa sale del modo práctica (Priority: P1)

**Goal**: User can exit practice and return to real account. Confirmation dialog prevents accidental exit.

**Independent Test**: In practice mode, tap "Salir" → confirmation dialog → confirm → return to real home with no green theme/banner.

### Implementation for US4

- [ ] T024 [US4] Create PracticeExitDialog widget in lib/features/practice_mode/presentation/widgets/practice_exit_dialog.dart — `ConsumerWidget`. Shows `AlertDialog` with title `practice_exit_title`, body `practice_exit_body`, two buttons: `practice_exit_confirm` ("Sí, salir") → calls `practiceSessionProvider.notifier.end()` then `context.go('/easy-mode')`; `practice_exit_cancel` ("Seguir practicando") → pops dialog. 48dp min targets, 18sp text
- [ ] T025 [US4] Add exit button to practice shell AppBar in lib/core/router/app_router.dart — In the practice ShellRoute builder, add an `IconButton(icon: Icon(Icons.close), onPressed: ...)` to the AppBar actions that shows `PracticeExitDialog`. Also handle Android back button at the practice shell level: when user presses back at `/easy-mode/practice/home`, show exit dialog instead of navigating back directly
- [ ] T026 [US4] Add "Practicar otra vez" to success screen — In the practice routes, when the success screen is shown (after payment/transfer in practice), add a route-specific extra button "Practicar otra vez" that navigates back to `/easy-mode/practice/home` and resets practice repos. This can be done by checking if the current route is under `/easy-mode/practice/` in the success screen, or by passing an `extra` parameter. Ensure repos `reset()` is called

**Checkpoint**: User can exit practice safely. Confirmation prevents accidental exit. "Practicar otra vez" allows repeated practice.

---

## Phase 7: US5 — Rosa practica sin guía (Priority: P2)

**Goal**: Practice mode without step-by-step guide — user explores freely with banner but no overlay instructions.

**Independent Test**: Enter practice "Sin guía" → practice home shows with banner but NO guide overlay → all flows work normally.

### Implementation for US5

- [ ] T027 [US5] Verify no-guide mode works — When `practiceSessionProvider.guideEnabled == false`, `PracticeGuideOverlay` must render nothing (`SizedBox.shrink()`). This should already work from T020 condition (`session.guideEnabled && step != null`). Verify by testing: enter practice "Sin guía" → no guide step cards appear → all practice flows still work (pay bill, send money, balance). If guide overlay incorrectly appears, fix the condition

**Checkpoint**: Free exploration mode works. Same practice repos, same banner, but no hand-holding.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: A11y compliance, TTS, route protection, edge cases

- [ ] T028 [P] Ensure all practice screens meet a11y guidelines — 48dp tap targets, 4.5:1 contrast ratio on green theme, 18sp minimum text, Semantics labels on all interactive elements. PracticeBanner must have `Semantics(liveRegion: true)`. Test with `androidTapTargetGuideline` and `labeledTapTargetGuideline`
- [ ] T029 [P] Add TTS announcements for practice mode transitions — `SemanticsService.announce()` on: entering practice mode (T012 already has this), exiting practice mode (T012 already has this), each guide step change (T020 already has this). Verify all three fire correctly. Also announce "Modo práctica" when PracticeEntryScreen loads
- [ ] T030 [P] Protect practice routes from direct navigation — If user navigates to `/easy-mode/practice/home` directly without an active PracticeSession, redirect to `/easy-mode/practice` (entry screen). Add a redirect guard in the route configuration or in the practice shell builder that checks `practiceSessionProvider` state
- [ ] T031 [P] Handle edge case: app backgrounded during practice — PracticeSession is ephemeral (in-memory StateNotifier). When app is killed and restarted, session resets to inactive. Verify that navigating to any practice route after restart redirects to entry screen (T030 covers this). No persistence needed per spec
- [ ] T032 Run `dart analyze` and fix all lint issues. Run `flutter gen-l10n` to verify ARB strings compile. Ensure zero warnings from `very_good_analysis`

---

## Dependencies

```
T001 ──┬──> T004, T005 (entities)
       ├──> T006, T007, T008, T009 (practice repos, parallel)
       ├──> T010, T011 (practice services, parallel)
       └──> T003 (verify 001 providers)
T002 ──> T015, T020 (ARB strings needed for screens)
T004 ──> T012 (PracticeSession entity for provider)
T006-T011 ──> T016 (repos must exist for ProviderScope override)
T012 ──> T015 (session provider for entry screen)
T013 ──> T016 (theme for shell route)
T014 ──> T016 (banner for shell route)
T015 ──> T016 (entry screen for route)
T016 ──> T017 (routes must exist before adding nav button)
T018 ──> T019 (guide service for guide provider)
T019 ──> T020 (guide provider for overlay widget)
T020 ──> T021 (overlay for integration into shell)
T016 ──> T022 (practice routes needed for fraud test)
T012 ──> T024 (session provider for exit dialog)
T024 ──> T025 (exit dialog for shell integration)
```

## Parallel Execution Opportunities

**Phase 2**: T004, T005, T006, T007, T008, T009, T010, T011 — all independent files, run all 8 in parallel
**Phase 3**: T012, T013, T14 can start in parallel (different files), T15 depends on T012, T016 depends on T013+T14+T15, T017 depends on T016
**Phase 5**: T022 and T023 can run in parallel
**Phase 8**: T028, T029, T030, T031 all independent concerns, run in parallel

## Implementation Strategy

**MVP (Phase 1-3 + Phase 6)**: US1 + US4 = enter practice with repos + exit safely. This is the minimum viable practice mode — user can practice with fictional data and return to real mode. ~17 tasks.

**Increment 1 (Phase 4)**: US2 = guided practice. Adds the step-by-step overlay. ~4 tasks.

**Increment 2 (Phase 5)**: US3 = simulated fraud alert. Validates 002 integration. ~2 tasks.

**Increment 3 (Phase 7)**: US5 = free exploration. Mostly verification. ~1 task.

**Polish (Phase 8)**: Cross-cutting concerns. ~5 tasks.
