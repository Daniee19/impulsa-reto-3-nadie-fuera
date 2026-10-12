# Tasks: Detección de Fricción

**Input**: Design documents from `/specs/007-friction-detection/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/friction-detector-contract.md, research.md, quickstart.md

**Organization**: Tasks grouped by user story. This feature creates `lib/features/friction_detection/` with a domain detector (Dart puro) and a presentation overlay. Entities use `@immutable` with manual `==`/`hashCode`/`copyWith` (matching existing codebase pattern, NOT freezed despite plan.md mention). No new dependencies — uses existing riverpod, go_router. Reuses NavigationObserver and providers from 003.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Feature directory structure, ARB strings, no new dependencies needed

- [X] T001 Create feature directory structure: `lib/features/friction_detection/{domain/{entities,services},presentation/{providers,widgets}}`
- [X] T002 [P] Add ARB strings to lib/core/l10n/arb/app_es.arb — keys for: `friction_offerMessage` ("Parece que necesitas ayuda con este paso"), `friction_offerMessageField` ("Parece que hay un problema con este campo. ¿Te ayudo?"), `friction_offerMessageInactivity` ("¿Necesitas ayuda con este paso?"), `friction_optionExplain` ("Sí, explícame"), `friction_optionHuman` ("Hablar con alguien"), `friction_optionDismiss` ("No, estoy bien"), `friction_explain_payBillConfirm` ("El botón confirmar envía el pago. Tu dinero está seguro"), `friction_explain_sendMoneyAmount` ("Escribe cuánto dinero quieres enviar. Por ejemplo, 50"), `friction_explain_sendMoneyConfirm` ("Confirma que los datos son correctos y envía el dinero"), `friction_explain_payBillSelect` ("Elige el recibo que quieres pagar de la lista"), `friction_contextBack` ("Retrocedió {n} veces en {stepName}"), `friction_contextInactivity` ("Estuvo sin interactuar en {stepName}"), `friction_contextError` ("Cometió el mismo error {n} veces en {stepName}"). Run `flutter gen-l10n`

---

## Phase 2: Foundational (Domain Entities + Detector Service)

**Purpose**: Domain entities and the FrictionDetector service. All Dart puro — no Flutter imports except `package:meta/meta.dart`. MUST be complete before presentation.

- [X] T003 [P] Create FrictionType enum in lib/features/friction_detection/domain/entities/friction_signal.dart — values: `repeatedBackNavigation`, `prolongedInactivity`, `repeatedError`
- [X] T004 [P] Create FrictionThresholds class in lib/features/friction_detection/domain/entities/friction_signal.dart (same file as T003) — fields: `int backNavigationCount` (default 3), `int inactivitySeconds` (default 20), `int repeatedErrorCount` (default 3). `@immutable`, const constructor with defaults
- [X] T005 Create FrictionSignal entity in lib/features/friction_detection/domain/entities/friction_signal.dart (same file) — fields: `FrictionType type` (non-null), `String flowId` (non-empty), `String stepRoute` (non-empty), `String stepName` (non-empty), `int occurrences` (>= threshold), `DateTime detectedAt` (non-null). `@immutable`, manual `==`/`hashCode`. Depends on T003
- [X] T006 [P] Create FrictionOfferStatus enum and FrictionOffer entity in lib/features/friction_detection/domain/entities/friction_offer.dart — FrictionOfferStatus values: `hidden`, `showing`, `dismissed`, `acceptedExplain`, `acceptedHuman`. FrictionOffer fields: `FrictionSignal? signal` (nullable, null when hidden), `FrictionOfferStatus status` (non-null, default `hidden`). `@immutable`, manual `==`/`hashCode`, `copyWith` for status transitions. Factory constructors: `FrictionOffer.hidden()`, `FrictionOffer.showing(FrictionSignal signal)`
- [X] T007 [P] Create FrictionContext entity in lib/features/friction_detection/domain/entities/friction_context.dart — fields: `FrictionType signalType` (non-null), `int occurrences` (> 0), `String stepName` (non-empty), `String humanReadable` (non-empty, ≤ 15 words). `@immutable`, manual `==`/`hashCode`. Static method `String buildHumanReadable(FrictionType type, int occurrences, String stepName)` using templates from data-model.md
- [X] T008 Create FrictionDetector service in lib/features/friction_detection/domain/services/friction_detector.dart — Dart puro, no Flutter imports. Constructor takes `FrictionThresholds thresholds` (default const). Methods per contract: `FrictionSignal? onBackNavigation({required String flowId, required String stepRoute, required String stepName})` — counts retrocesos per flowId, returns signal at threshold; `FrictionSignal? onInactivityTimeout({required String flowId, required String stepRoute, required String stepName})` — returns signal; `FrictionSignal? onValidationError({required String flowId, required String stepRoute, required String stepName, required String fieldId, required String errorType})` — groups by `fieldId:errorType`, returns signal at threshold; `bool isExcludedScreen(String route)` — patterns: RegExp(r'/confirm$'), 'fraud-alert', 'assistant/consent', 'trusted-person/consent', RegExp(r'/help/'); `bool isActiveFlow(String route)` — prefixes: '/easy-mode/pay-bill', '/easy-mode/send-money'; `void resetForNewFlow()` — clears all counters and dismissed; `void dismissSignal(FrictionType type, String flowId)`; `bool isDismissed(FrictionType type, String flowId)`. Depends on T003, T004, T005

**Checkpoint**: Domain layer complete. Detector is Dart puro, fully unit-testable.

---

## Phase 3: US1 — Rosa retrocede varias veces pagando un recibo (Priority: P1) 🎯 MVP

**Goal**: Detect 3+ back navigations in the same flow and show a non-intrusive help offer overlay with 3 options.

**Independent Test**: Navigate back 3 times in a pay-bill flow → overlay appears with "Sí, explícame", "Hablar con alguien", "No, estoy bien".

### Implementation for US1

- [X] T009 [US1] Create FrictionNotifier provider in lib/features/friction_detection/presentation/providers/friction_provider.dart — `StateNotifier<FrictionOffer>` (NOT codegen). Holds a FrictionDetector instance. Listens to `navigationContextProvider` (from 003) to detect route changes and back navigations. Extracts flowId from route prefix. On back navigation calls `detector.onBackNavigation()`. If signal returned and not excluded and not dismissed → state = `FrictionOffer.showing(signal)`. Methods: `void dismiss()` — calls `detector.dismissSignal()`, state = hidden; `void acceptExplain()` — state = acceptedExplain then hidden; `void acceptHuman(BuildContext context)` — sets FrictionContext, navigates to 003, state = hidden; `void onUserInteraction()` — restarts inactivity timer (Phase 4). Create `frictionNotifierProvider` as `StateNotifierProvider<FrictionNotifier, FrictionOffer>`
- [X] T010 [US1] Create FrictionOfferOverlay widget in lib/features/friction_detection/presentation/widgets/friction_offer_overlay.dart — ConsumerWidget that watches `frictionNotifierProvider`. When status == `showing`: renders an `AnimatedPositioned` bottom panel (not modal) with message text (from ARB, based on signal type), 3 `ElevatedButton` options (48dp min targets, 18sp text, 4.5:1 contrast). Calls `SemanticsService.announce()` when overlay appears (FR-012). Each button has Semantics label. When status != `showing`: renders `SizedBox.shrink()`
- [X] T011 [US1] Integrate FrictionOfferOverlay into ShellRoute in lib/core/router/app_router.dart — in the existing ShellRoute builder that wraps easy_mode routes, wrap child in a `Stack` with `FrictionOfferOverlay()` layered on top. Add a `Listener(onPointerDown: ...)` that calls `frictionNotifierProvider.notifier.onUserInteraction()` to reset the inactivity timer

**Checkpoint**: Back-navigation friction detection works end-to-end. 3 back navigations in pay-bill or send-money flow show the help offer.

---

## Phase 4: US2 — Carmen se queda quieta 20 segundos en un paso (Priority: P1)

**Goal**: Detect 20+ seconds of inactivity in an active flow step and show the help offer.

**Independent Test**: Stay idle for 20 seconds in a send-money step → overlay appears.

### Implementation for US2

- [X] T012 [US2] Add inactivity timer logic to FrictionNotifier in lib/features/friction_detection/presentation/providers/friction_provider.dart — `Timer? _inactivityTimer`. `_startInactivityTimer()`: cancels existing, checks `isActiveFlow` and `!isExcludedScreen`, starts Timer(Duration(seconds: thresholds.inactivitySeconds), _onInactivityDetected). `onUserInteraction()`: restarts timer if in active flow. `_onInactivityDetected()`: calls `detector.onInactivityTimeout()`, if signal and not dismissed → state = showing. Timer cancels on route change to non-active-flow. `ref.onDispose` cancels timer

**Checkpoint**: Inactivity detection works. Timer only runs in active flows, resets on interaction, never fires in excluded screens.

---

## Phase 5: US3 — Luis comete el mismo error repetido (Priority: P2)

**Goal**: Detect 3+ validation errors of the same type in the same field/step and show the help offer.

**Independent Test**: Enter invalid data 3 times in the same field → overlay appears.

### Implementation for US3

- [ ] T013 [US3] Add onValidationError method to FrictionNotifier in lib/features/friction_detection/presentation/providers/friction_provider.dart — `void onValidationError(String fieldId, String errorType)`. Gets current flowId/stepRoute/stepName from navigationContextProvider. Calls `detector.onValidationError(...)`. If signal returned and not dismissed → state = showing
- [ ] T014 [US3] Add friction error notification to pay-bill validation in lib/features/easy_mode/presentation/screens/pay_bill_screen.dart — in the validation error handler, call `ref.read(frictionNotifierProvider.notifier).onValidationError(fieldId, errorType)` with appropriate fieldId and errorType strings
- [ ] T015 [US3] Add friction error notification to send-money validation in lib/features/easy_mode/presentation/screens/send_money_screen.dart — same pattern as T014

**Checkpoint**: Error-based friction detection works. 3 validation errors of the same type in the same field trigger the help offer.

---

## Phase 6: US4 — El ofrecimiento no interrumpe una confirmación de pago (Priority: P1)

**Goal**: Friction detection NEVER fires on confirmation screens, fraud alerts, or consent screens.

**Independent Test**: Wait 25 seconds on a confirmation screen → NO overlay appears.

### Implementation for US4

- [X] T016 [US4] Verify exclusion logic in FrictionDetector (already implemented in T008) — ensure `isExcludedScreen()` correctly matches: routes ending in `/confirm`, routes containing `fraud-alert`, routes containing `assistant/consent`, routes containing `trusted-person/consent`, routes containing `/help/`. The timer start in T012 already checks `!isExcludedScreen()`. No new code needed — this task validates T008 and T012 work correctly for exclusion

**Checkpoint**: Confirmed: no friction detection in excluded screens.

---

## Phase 7: US5 — La fricción detectada se envía como contexto a la ayuda humana (Priority: P2)

**Goal**: When user chooses "Hablar con alguien", the help context (003) includes friction data.

**Independent Test**: Trigger friction → choose "Hablar con alguien" → verify help context includes friction type and step.

### Implementation for US5

- [X] T017 [US5] Create frictionContextProvider in lib/features/friction_detection/presentation/providers/friction_provider.dart (same file as T009) — `StateProvider<FrictionContext?>` initialized to null. FrictionNotifier.acceptHuman() sets it with data from the current signal before navigating to 003
- [ ] T018 [US5] Modify ContextCollector or helpContextProvider in lib/features/contextual_help/presentation/providers/help_context_provider.dart — read `frictionContextProvider` and if non-null, append the `humanReadable` string to the help context. Clear frictionContextProvider after reading
- [X] T019 [US5] Create friction explanation map provider in lib/features/friction_detection/presentation/providers/friction_provider.dart — `frictionExplanationProvider` that maps step routes to ARB explanation strings: `/easy-mode/pay-bill/{id}/confirm` → `friction_explain_payBillConfirm`, `/easy-mode/send-money/amount` → `friction_explain_sendMoneyAmount`, etc. Used by `acceptExplain()` to get the TTS text for "Sí, explícame"
- [X] T020 [US5] Implement acceptExplain TTS integration in FrictionNotifier — when user taps "Sí, explícame", read the explanation from frictionExplanationProvider for the current step route, call TTS service (from 004) to speak it, then set state to hidden

**Checkpoint**: Friction context enriches help requests. TTS explains the current step when user asks.

---

## Phase 8: Tests

**Purpose**: Unit tests for domain detector, widget tests for overlay with a11y

- [X] T021 [P] Create unit tests in test/features/friction_detection/domain/services/friction_detector_test.dart — test: 2 retrocesos no disparan señal (returns null), 3 retrocesos disparan señal (returns FrictionSignal); cambio de flujo resetea contador; ruta `/confirm` es pantalla excluida; ruta `/fraud-alert` es pantalla excluida; pantalla principal NO es flujo activo; `/easy-mode/pay-bill/1` IS flujo activo; 2 errores no disparan, 3 del mismo fieldId+errorType sí; errores de distinto errorType se cuentan por separado; dismissSignal impide re-trigger; resetForNewFlow limpia todo; custom thresholds work (backNavigationCount: 5 → need 5 backs)
- [ ] T022 [P] Create unit tests in test/features/friction_detection/domain/entities/friction_signal_test.dart — test: FrictionSignal construction, equality, hashCode; FrictionThresholds default values (3, 20, 3); FrictionOffer.hidden() has null signal; FrictionOffer.showing(signal) has signal; copyWith status transition
- [ ] T023 [P] Create unit tests in test/features/friction_detection/domain/entities/friction_context_test.dart — test: FrictionContext construction; buildHumanReadable for each FrictionType returns expected template string
- [ ] T024 [P] Create widget test in test/features/friction_detection/presentation/widgets/friction_offer_overlay_test.dart — test: overlay hidden when status is hidden (SizedBox.shrink); overlay visible when status is showing (3 buttons); buttons have correct text from ARB; tapping "No, estoy bien" calls dismiss; meetsGuideline(androidTapTargetGuideline); meetsGuideline(labeledTapTargetGuideline)

---

## Phase 9: Polish & Cross-Cutting

- [ ] T025 [P] Run `dart format` on all new and modified files
- [ ] T026 [P] Run `flutter analyze`, verify 0 issues
- [ ] T027 [P] Verify all UI strings come from ARB — grep for hardcoded Spanish in lib/features/friction_detection/
- [ ] T028 Run quickstart.md validation scenarios VS-1 through VS-9

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: T005 depends on T003. T008 depends on T003, T004, T005
- **US1 (Phase 3)**: Depends on Phase 2 (detector must exist). T010 depends on T009. T011 depends on T010
- **US2 (Phase 4)**: Depends on US1 (FrictionNotifier must exist to add timer)
- **US3 (Phase 5)**: Depends on US1 (FrictionNotifier must exist to add error handling)
- **US4 (Phase 6)**: Depends on US1+US2 (validation of exclusion logic, no new code)
- **US5 (Phase 7)**: Depends on US1 (FrictionNotifier must have acceptHuman/acceptExplain)
- **Tests (Phase 8)**: Depends on Phases 2-7 (entities + detector + overlay must exist)
- **Polish (Phase 9)**: Depends on all prior phases

### User Story Dependencies

- **US1 (P1)**: Foundation for everything. Back navigation detection + overlay + ShellRoute integration
- **US2 (P1)**: Adds inactivity timer to existing FrictionNotifier. Depends on US1
- **US3 (P2)**: Adds error tracking to existing FrictionNotifier. Depends on US1
- **US4 (P1)**: Validation only — depends on US1+US2 existing
- **US5 (P2)**: Adds context enrichment and TTS. Depends on US1

### Parallel Opportunities

- T001, T002 run in parallel (setup)
- T003, T004, T006, T007 run in parallel (different entity files)
- US3 (T013-T015) can run parallel with US4 (T016) after US2 done
- US5 (T017-T020) can run parallel with US3+US4 after US1 done
- All test tasks T021-T024 run in parallel

---

## Implementation Strategy

### MVP First (US1 + US4 Only)

1. Phase 1: Setup (ARB, structure)
2. Phase 2: Domain entities + FrictionDetector
3. Phase 3: US1 — Back navigation detection + overlay
4. Phase 6: US4 — Verify exclusion logic
5. **STOP**: User gets help offer on 3+ back navigations. Never on confirmations.

### Full Feature

1. Phases 1-2 → Foundation
2. Phase 3 (US1) → Back navigation detection working
3. Phase 4 (US2) → Inactivity timer
4. Phase 6 (US4) → Exclusion verification
5. Phase 5 (US3) → Error repetition detection
6. Phase 7 (US5) → Context enrichment + TTS explanation
7. Phase 8 → Tests
8. Phase 9 → Polish

---

## Notes

- Entities use `@immutable` + manual `==`/`hashCode`/`copyWith` (existing codebase pattern, NOT freezed despite plan.md mention)
- FrictionDetector is Dart puro — no Flutter imports, no async. Timer lives in provider (presentation)
- Overlay is NOT a route — it's a widget in the ShellRoute Stack, auto-shows/hides via provider
- Reuses NavigationObserver and navigationContextProvider from 003 (core/)
- Reuses operationInProgressProvider from 003 for context enrichment
- Excluded screens: routes ending `/confirm`, containing `fraud-alert`, `assistant/consent`, `trusted-person/consent`, `/help/`
- Active flows only: `/easy-mode/pay-bill/*`, `/easy-mode/send-money/*`
- No new dependencies — only existing riverpod, go_router
- Constitution Principle I drives 48dp targets, 4.5:1 contrast, SemanticsService.announce
- Constitution Principle VI drives ≤15 word messages, empathetic tone
- All ARB texts in Spanish, code identifiers in English
