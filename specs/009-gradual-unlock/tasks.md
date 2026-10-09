# Tasks: Desbloqueo Gradual de Funciones

**Input**: Design documents from `/specs/009-gradual-unlock/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, research.md, quickstart.md

**Organization**: Tasks grouped by user story. Tests included per constitution (Principle V: domain ≥80% coverage, widget tests with a11y guidelines per screen).

**Note**: This project uses plain Dart entities with manual `copyWith`/`==`/`hashCode` (not freezed) and manual Riverpod providers (not codegen). Depends on 001-easy-mode (4 base actions) and 008-practice-mode (practice before activating).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Directory structure, dependencies, ARB strings

- [ ] T001 Create feature directory structure per plan.md: `lib/features/gradual_unlock/{domain/{entities,services},data/repositories,presentation/{providers,screens,widgets}}`, `test/features/gradual_unlock/{domain/services,presentation/screens}`
- [ ] T002 [P] Add ARB strings to lib/core/l10n/arb/app_es.arb — keys: `unlock_proposal_title` ("Tienes una sugerencia"), `unlock_accept` ("Sí, actívalo"), `unlock_practice` ("Primero quiero practicarlo"), `unlock_reject` ("No, por ahora no"), `unlock_feature_transactions` ("Ver movimientos"), `unlock_feature_recharge` ("Recargar celular"), `unlock_feature_qr` ("Pagar con QR"), `unlock_proposal_transactions` ("Ya manejas bien tus pagos. ¿Quieres ver tus movimientos?"), `unlock_proposal_recharge` ("¿Quieres recargar tu celular desde la app?"), `unlock_proposal_qr` ("¿Quieres pagar con código QR?"), `unlock_moreFeatures` ("Más funciones"), `unlock_resetToBasic` ("Volver a solo 4 acciones"), `unlock_resetConfirm` ("Vas a ocultar las funciones extra. Puedes volver a activarlas cuando quieras."), `unlock_reactivate` ("Activar de nuevo"), `unlock_desc_transactions` ("Consulta tus últimos movimientos"), `unlock_desc_recharge` ("Recarga tu celular con un monto fijo"), `unlock_desc_qr` ("Escanea un código y paga"). Run `flutter gen-l10n`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, unlock evaluator, repository, providers, routing. MUST be complete before ANY user story.

### Domain Entities (plain Dart, @immutable, manual copyWith/==/hashCode)

- [ ] T003 [P] Create ExtraFeature enum and FeatureState enum in lib/features/gradual_unlock/domain/entities/extra_feature.dart — ExtraFeature values: `transactionHistory`, `mobileRecharge`, `qrPayment` (order = priority). FeatureState values: `locked`, `unlockedHidden`, `active`. Create ExtraFeatureConfig class with fields: `feature` (ExtraFeature), `nameKey` (String), `descriptionKey` (String), `proposalMessageKey` (String), `iconData` (IconData), `route` (String). Static list of configs for the 3 features.
- [ ] T004 [P] Create ConfidenceMetrics entity in lib/features/gradual_unlock/domain/entities/confidence_metrics.dart — @immutable. Fields: `successfulOpsWithoutHelp` (int, ≥0), `practiceSessionsCompleted` (int, ≥0). Manual copyWith, ==, hashCode.
- [ ] T005 [P] Create UnlockThresholds entity in lib/features/gradual_unlock/domain/entities/extra_feature.dart (same file as ExtraFeature) — @immutable, const constructor. Fields: `opsWithoutHelp` (int, default 5), `practiceSessions` (int, default 3), `maxRejections` (int, default 3).
- [ ] T006 [P] Create UnlockProposal entity in lib/features/gradual_unlock/domain/entities/unlock_proposal.dart — @immutable. Field: `feature` (ExtraFeature, non-null). Manual ==, hashCode.

### Domain Service (Dart puro, no Flutter)

- [ ] T007 Create UnlockEvaluator in lib/features/gradual_unlock/domain/services/unlock_evaluator.dart — Method: `UnlockProposal? evaluate({required ConfidenceMetrics metrics, required Map<ExtraFeature, FeatureState> states, required Map<ExtraFeature, int> rejections, UnlockThresholds thresholds = const UnlockThresholds()})`. Logic: check if metrics meet either threshold (OR). Iterate features in priority order. Skip if state != locked. Skip if rejections >= maxRejections. Return first eligible as UnlockProposal, or null.

### Data Layer

- [ ] T008 Create FeatureFlagRepository in lib/features/gradual_unlock/data/repositories/feature_flag_repository.dart — uses SharedPreferences. Methods: `Future<Map<ExtraFeature, FeatureState>> getStates()`, `Future<void> setState(ExtraFeature, FeatureState)`, `Future<ConfidenceMetrics> getMetrics()`, `Future<void> incrementOpsWithoutHelp()`, `Future<void> incrementPracticeSessions()`, `Future<Map<ExtraFeature, int>> getRejections()`, `Future<void> incrementRejection(ExtraFeature)`, `Future<void> resetToBasicView()` (sets all active → unlockedHidden). Keys prefixed with `gradual_unlock_`.

### Providers & Routing

- [ ] T009 [P] Create feature_flags_provider in lib/features/gradual_unlock/presentation/providers/feature_flags_provider.dart — Providers: `featureFlagRepositoryProvider` (Provider<FeatureFlagRepository>), `featureStatesProvider` (FutureProvider<Map<ExtraFeature, FeatureState>>), `activeExtraFeaturesProvider` (Provider<List<ExtraFeature>> filtering active ones), `confidenceMetricsProvider` (FutureProvider<ConfidenceMetrics>).
- [ ] T010 [P] Create unlock_proposal_provider in lib/features/gradual_unlock/presentation/providers/unlock_proposal_provider.dart — StateNotifierProvider. Reads metrics, states, rejections. Calls UnlockEvaluator. Exposes current proposal. Has `proposalShownThisSession` flag (in-memory, FR-006). Methods: `accept(ExtraFeature)`, `reject(ExtraFeature)`, `dismiss()`.
- [ ] T011 Add routes to lib/core/router/app_router.dart — under `/easy-mode`: `transactions` → TransactionHistoryScreen, `recharge` → MobileRechargeScreen, `qr-payment` → QrPaymentScreen, `settings/features` → feature management screen.

### Foundational Tests

- [ ] T012 [P] Unit tests for UnlockEvaluator in test/features/gradual_unlock/domain/services/unlock_evaluator_test.dart — tests: (1) no metrics met → null, (2) 5 ops without help → proposes first locked feature, (3) 3 practice sessions → proposes first locked feature, (4) feature already active → skips to next, (5) feature has 3 rejections → skips, (6) all features active → null, (7) priority order respected (transactionHistory before mobileRecharge), (8) custom thresholds respected.

**Checkpoint**: Foundation ready. Evaluator tested, repo configured, routes added.

---

## Phase 3: US1 — Rosa recibe una propuesta de nueva función (Priority: P1)

**Goal**: Proposal card shown on EasyModeHomeScreen when confidence conditions are met. 3 options: activate, practice, reject.

- [ ] T013 [US1] Create UnlockProposalCard widget in lib/features/gradual_unlock/presentation/widgets/unlock_proposal_card.dart — receives UnlockProposal + ExtraFeatureConfig. Shows proposal message (ARB), 3 AccessibleButtons: "Sí, actívalo" (icon: check) → calls accept, "Primero quiero practicarlo" (icon: school) → navigates to 008 practice mode, "No, por ahora no" (icon: close) → calls reject. SemanticsService.announce proposal on mount. All buttons ≥48dp, 4.5:1 contrast.
- [ ] T014 [US1] Integrate UnlockProposalCard into EasyModeHomeScreen — modify lib/features/easy_mode/presentation/screens/easy_mode_home_screen.dart: if `ref.watch(unlockProposalProvider)` is non-null AND not yet shown this session → show UnlockProposalCard above the 4 main actions.
- [ ] T015 [US1] Integrate confidence tracking into pay/send flows — modify lib/features/easy_mode/presentation/screens/operation_success_screen.dart: on successful operation, call `ref.read(featureFlagRepositoryProvider).incrementOpsWithoutHelp()`. Check if help was requested during this flow (via operationInProgressProvider or a simple flag).
- [ ] T016 [US1] "Sí, actívalo" handler — in unlockProposalProvider.accept(): set feature state to `active`, dismiss proposal, invalidate featureStatesProvider.
- [ ] T017 [US1] "No, por ahora no" handler — in unlockProposalProvider.reject(): increment rejection count, dismiss proposal. Proposal does not reappear this session (proposalShownThisSession flag).

### Tests

- [ ] T018 [P] [US1] Widget test for UnlockProposalCard in test/features/gradual_unlock/presentation/widgets/unlock_proposal_card_test.dart — a11y guidelines (androidTapTargetGuideline, labeledTapTargetGuideline); verify 3 buttons present; verify SemanticsService.announce on mount; no overflow at textScaler 2.0.

**Checkpoint**: Proposal appears when confidence conditions are met. Accept activates feature. Reject dismisses without insisting.

---

## Phase 4: US3 — Límite de acciones por pantalla (Priority: P1)

**Goal**: Extra features shown in "Más funciones" section, never replacing the 4 originals.

- [ ] T019 [US3] Create ExtraFeaturesSection widget in lib/features/gradual_unlock/presentation/widgets/extra_features_section.dart — receives List<ExtraFeature> active extras. Shows section header "Más funciones" (ARB). Renders ActionCards for each extra feature with same style as original 4 (big buttons, accessible). Each navigates to its route. Only visible when there are active extras. ≥48dp, 4.5:1 contrast, Semantics labels.
- [ ] T020 [US3] Integrate ExtraFeaturesSection into EasyModeHomeScreen — below the 4 original actions, show ExtraFeaturesSection if `ref.watch(activeExtraFeaturesProvider)` is non-empty. The 4 originals always stay as primary actions.

### Tests

- [ ] T021 [P] [US3] Widget test for ExtraFeaturesSection in test/features/gradual_unlock/presentation/widgets/extra_features_section_test.dart — verify extras shown below main actions; verify a11y guidelines; verify empty list → section not rendered.

**Checkpoint**: Screen never has more than 4 primary actions. Extras in secondary section.

---

## Phase 5: US2 — Rosa vuelve a la vista simple (Priority: P1)

**Goal**: User can hide all extra features and reactivate them individually from settings.

- [ ] T022 [US2] Create feature management in settings — add option "Volver a solo 4 acciones" accessible from EasyModeHomeScreen settings. On tap: show confirmation dialog with ARB message. On confirm: call `featureFlagRepository.resetToBasicView()`. All active extras become unlockedHidden.
- [ ] T023 [US2] Create feature reactivation list in settings — show list of unlocked (hidden) features with toggle to reactivate individually. No conditions needed (FR-010). Each toggle calls `setState(feature, active)` or `setState(feature, unlockedHidden)`.

### Tests

- [ ] T024 [P] [US2] Test reset to basic view — verify all active features become unlockedHidden. Verify reactivation without conditions.

**Checkpoint**: User has full control. Can simplify and re-expand at will.

---

## Phase 6: Simulated Extra Feature Screens (Priority: P2)

**Purpose**: Minimal simulated screens for the 3 extra features

- [ ] T025 [P] Create TransactionHistoryScreen in lib/features/gradual_unlock/presentation/screens/transaction_history_screen.dart — shows list of last 10 mock transactions (from OperationRepository of 001). Each shows: type icon, description, amount, date. Read-only. Semantics labels. ≥48dp items.
- [ ] T026 [P] Create MobileRechargeScreen in lib/features/gradual_unlock/presentation/screens/mobile_recharge_screen.dart — simple form: phone number (9 digits), fixed amount options (S/ 5, S/ 10, S/ 20). "Recargar" button → simulated success (ConfirmationScreen from core). Validation: 9 digits starting with 9.
- [ ] T027 [P] Create QrPaymentScreen in lib/features/gradual_unlock/presentation/screens/qr_payment_screen.dart — simulated QR scan: show a placeholder image/icon with "Escanear código" button → after 2s delay, show simulated payment data (recipient, amount) → confirm button → ConfirmationScreen.

### Tests

- [ ] T028 [P] Widget tests for extra feature screens — basic rendering + a11y guidelines for each screen.

**Checkpoint**: All 3 extra features have working simulated screens.

---

## Phase 7: US4 — Accesibilidad con TalkBack (Priority: P2)

- [ ] T029 [US4] Verify TalkBack announces proposal — ensure SemanticsService.announce covers full proposal text + 3 options. Verify navigation by swipe gestures works for all options.
- [ ] T030 [US4] Verify ExtraFeaturesSection is TalkBack-navigable — section header announced, each extra feature button has Semantics label.

---

## Phase 8: Polish & Cross-Cutting

- [ ] T031 [P] Run `flutter analyze`, verify 0 warnings across all gradual_unlock files
- [ ] T032 [P] Run `dart format` on all source files in lib/features/gradual_unlock/ and test/features/gradual_unlock/
- [ ] T033 [P] Verify all UI strings come from ARB — no hard-coded Spanish in gradual_unlock widgets
- [ ] T034 Run quickstart.md validation scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup
- **US1 (Phase 3)**: Depends on Phase 2
- **US3 (Phase 4)**: Depends on Phase 3 (needs active features to show section)
- **US2 (Phase 5)**: Depends on Phase 4 (needs features to hide/reactivate)
- **Screens (Phase 6)**: Depends on Phase 2 (routes). Can parallel with Phase 3-5
- **US4 (Phase 7)**: Depends on Phases 3-4
- **Polish (Phase 8)**: Depends on all

### Parallel Opportunities

- T003, T004, T005, T006 run in parallel (different entity files)
- T009, T010 run in parallel
- T025, T026, T027 run in parallel (independent screens)
- All test tasks with [P] run in parallel

---

## Notes

- Plain Dart entities with manual copyWith/==/hashCode — NOT freezed
- Manual Riverpod providers — NOT codegen
- SharedPreferences for feature flags and metrics (not sensitive data)
- 4 original actions ALWAYS primary. Extras in "Más funciones" section
- No gamification — no points, levels, badges
- "Practicar primero" navigates to 008-practice-mode (dependency)
- Unlocked features persist between sessions. Hidden ≠ deleted
- One proposal per session (in-memory flag)
- 3 rejections = no more auto-proposals (manual activation still available)
