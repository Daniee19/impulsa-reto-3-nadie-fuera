# Tasks: Contratos Explicados en Audio

**Input**: Design documents from `/specs/010-audio-contracts/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, research.md, quickstart.md

**Organization**: Tasks grouped by user story. Tests included per constitution (Principle V: domain ≥80% coverage, widget tests with a11y guidelines per screen).

**Note**: This project uses plain Dart entities with manual `copyWith`/`==`/`hashCode` (not freezed) and manual Riverpod providers (not codegen). Reuses `flutter_tts` from 004-voice-text-assistant. Contracts are static example data.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Directory structure, ARB strings for contracts and UI

- [x] T001 Create feature directory structure per plan.md: `lib/features/audio_contracts/{domain/{entities,repositories},data/repositories,presentation/{providers,screens,widgets}}`, `test/features/audio_contracts/{domain,presentation/screens}`
- [x] T002 [P] Add ARB strings to lib/core/l10n/arb/app_es.arb — keys for UI: `contract_summary_title` ("Resumen del contrato"), `contract_section_whatYouAccept` ("Qué aceptas"), `contract_section_cost` ("Cuánto cuesta"), `contract_section_risks` ("Qué puede salir mal"), `contract_section_howToCancel` ("Cómo cancelar"), `contract_accept` ("Aceptar"), `contract_acceptDisabled` ("Primero escucha o lee el resumen"), `contract_viewFull` ("Ver contrato completo"), `contract_disclaimer` ("Este resumen te ayuda a entender. El documento completo está disponible abajo."), `contract_pause` ("Pausar lectura"), `contract_resume` ("Continuar lectura"), `contract_repeatSection` ("Repetir esta sección"), `contract_slower` ("Más lento"), `contract_normalSpeed` ("Velocidad normal"), `contract_speedMin` ("Ya estás en la velocidad más lenta"), `contract_askAssistant` ("Preguntar al asistente"), `contract_backToSummary` ("Volver al resumen"), `contract_readThis` ("Leer esto"), `contract_volumeLow` ("Tu volumen está bajo. Puedes subir el volumen o leer el resumen."), `contract_sectionOf` ("Sección {current} de {total}"), `contract_accepted` ("Contrato aceptado"), `contract_savingsAccount` ("Cuenta de ahorro básica"), `contract_personalLoan` ("Préstamo personal"). Plus content keys for each section of each contract (8 keys total for 2 contracts × 4 sections). Run `flutter gen-l10n`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, repository, providers. MUST be complete before ANY user story.

### Domain Entities (plain Dart, @immutable, manual copyWith/==/hashCode)

- [x] T003 [P] Create ContractSectionType enum and PlaybackSpeed enum in lib/features/audio_contracts/domain/entities/contract_summary.dart — ContractSectionType: `whatYouAccept`, `cost`, `risks`, `howToCancel`. PlaybackSpeed: `normal` (rate 1.0), `slow` (rate 0.75), `slower` (rate 0.5).
- [x] T004 [P] Create ContractSection entity in same file — @immutable. Fields: `type` (ContractSectionType), `title` (String, non-empty), `content` (String, non-empty). Manual ==, hashCode.
- [x] T005 [P] Create ContractSummary entity in same file — @immutable. Fields: `id` (String, non-empty), `title` (String, non-empty), `sections` (List<ContractSection>, length == 4), `fullContractParagraphs` (List<String>, non-empty). Manual ==, hashCode.
- [x] T006 [P] Create TtsState enum and ReviewSession entity in lib/features/audio_contracts/domain/entities/review_session.dart — TtsState: `idle`, `playing`, `paused`, `completed`. ReviewSession @immutable: fields `contractId` (String), `sectionsHeard` (Set<ContractSectionType>, default empty), `currentSection` (ContractSectionType?, default null), `scrolledToEnd` (bool, default false), `speed` (PlaybackSpeed, default normal), `ttsState` (TtsState, default idle). Computed: `bool get reviewCompleted => sectionsHeard.length == 4 || scrolledToEnd`. Manual copyWith, ==, hashCode.

### Data Layer

- [x] T007 [P] Create abstract ContractRepository in lib/features/audio_contracts/domain/repositories/contract_repository.dart — methods: `ContractSummary getContractSummary(String id)`, `List<ContractSummary> getAllContracts()`.
- [x] T008 Create MockContractRepository in lib/features/audio_contracts/data/repositories/mock_contract_repository.dart — implements ContractRepository. Returns 2 static contracts: `savings_account` (cuenta de ahorro) and `personal_loan` (préstamo personal). Section content from ARB keys. Full contract paragraphs as static strings (8 and 10 paragraphs respectively).

### Providers & Routing

- [x] T009 [P] Create contract_review_provider in lib/features/audio_contracts/presentation/providers/contract_review_provider.dart — StateNotifierProvider<ContractReviewNotifier, ReviewSession?>. Methods: `startReview(String contractId)`, `markSectionHeard(ContractSectionType)`, `setCurrentSection(ContractSectionType?)`, `markScrolledToEnd()`, `setSpeed(PlaybackSpeed)`, `setTtsState(TtsState)`, `clear()`. Provides `contractRepositoryProvider`.
- [x] T010 Add routes to lib/core/router/app_router.dart — under `/easy-mode`: `contract/:contractId` → ContractSummaryScreen, `contract/:contractId/full` → FullContractScreen. Add navigable entry point (e.g., from a product/settings screen).

### Foundational Tests

- [x] T011 [P] Unit tests for ReviewSession in test/features/audio_contracts/domain/review_session_test.dart — tests: (1) reviewCompleted false initially, (2) reviewCompleted true after 4 sections heard, (3) reviewCompleted true after scrolledToEnd, (4) copyWith preserves fields, (5) speed transitions.

**Checkpoint**: Foundation ready. Entities, repo, providers configured.

---

## Phase 3: US1 + US2 — Carmen escucha el resumen y controla la reproducción (Priority: P1)

**Goal**: Contract summary screen with auto-TTS, playback controls (pause, repeat section, speed), and gated accept button.

- [x] T012 [US1] Create TtsPlaybackControls widget in lib/features/audio_contracts/presentation/widgets/tts_playback_controls.dart — Row of AccessibleButtons: "Pausar/Continuar" (toggle based on TtsState), "Repetir esta sección", "Más lento" (cycles normal→slow→slower; disabled at slower with note), "Velocidad normal" (visible when not at normal). All ≥48dp, 8dp separation, Semantics labels in Spanish, 4.5:1 contrast.
- [x] T013 [US1] Create AcceptButton widget in lib/features/audio_contracts/presentation/widgets/accept_button.dart — AccessibleButton. Disabled until `reviewSession.reviewCompleted`. When disabled: shows note `contract_acceptDisabled`. When enabled: on tap → show ConfirmationScreen with `contract_accepted`. Semantics label announces enabled/disabled state + reason.
- [x] T014 [US1] Create ContractSummaryScreen in lib/features/audio_contracts/presentation/screens/contract_summary_screen.dart — ConsumerStatefulWidget. Reads contractId from route param. Loads ContractSummary from repo. Shows: title, disclaimer note (always visible), 4 sections as expandable/scrollable cards, TtsPlaybackControls, AcceptButton, "Ver contrato completo" link. On mount: starts TTS reading section 1 automatically (FR-003). Tracks scroll position — if user scrolls to end of summary text, marks scrolledToEnd. SemanticsService.announce title + "Sección 1 de 4" on mount.
- [x] T015 [US2] Implement TTS integration in ContractSummaryScreen — use ttsServiceProvider from 004. On mount: `tts.speak(section1.content)`. On section complete: mark section heard, advance to next. Pause button: `tts.stop()` + set ttsState paused. Resume: `tts.speak(currentSection.content)` from start of section. Repeat: re-speak current section. Speed: `tts.setSpeechRate(speed.rate)`.
- [ ] T016 [US1] Volume detection — on mount, check device volume. If low/muted: show banner with `contract_volumeLow`. Banner dismissible. Text summary always visible regardless.

### Tests

- [x] T017 [P] [US1] Widget test for ContractSummaryScreen in test/features/audio_contracts/presentation/screens/contract_summary_screen_test.dart — a11y guidelines; verify 4 sections displayed; verify accept button disabled initially; verify disclaimer always visible; verify TtsPlaybackControls present.
- [ ] T018 [P] [US2] Widget test for TtsPlaybackControls — a11y guidelines; verify pause/resume toggle; verify speed button disables at minimum.

**Checkpoint**: Summary screen with TTS controls and gated accept. MVP for audio contracts.

---

## Phase 4: US5 — Carmen accede al contrato completo (Priority: P2)

- [x] T019 [US5] Create FullContractScreen in lib/features/audio_contracts/presentation/screens/full_contract_screen.dart — ConsumerWidget. Shows all paragraphs from `contractSummary.fullContractParagraphs`. Each paragraph has a "Leer esto" button → TTS reads just that paragraph. "Volver al resumen" button always visible → pops back preserving review progress. Semantics labels for all controls.

### Tests

- [x] T020 [P] [US5] Widget test for FullContractScreen — verify paragraphs shown; verify "Leer esto" buttons present; verify back button; a11y guidelines.

**Checkpoint**: Full contract accessible. Selective paragraph reading works.

---

## Phase 5: US3 — Carmen pregunta al asistente (Priority: P2)

- [x] T021 [US3] Add "Preguntar al asistente" to ContractSummaryScreen — button navigates to voice assistant (004) passing contract context (title, current section). On return: resume from where user left off. TTS pauses when navigating to assistant.

---

## Phase 6: US4 — TalkBack accessibility (Priority: P2)

- [ ] T022 [US4] Verify TalkBack navigation — ensure sections are navigable by swipe. Each section announces title + "Sección X de 4". Controls have descriptive labels. Accept button announces state.

---

## Phase 7: Polish & Cross-Cutting

- [ ] T023 [P] Run `flutter analyze`, verify 0 warnings
- [ ] T024 [P] Run `dart format` on all audio_contracts files
- [ ] T025 [P] Verify all UI strings come from ARB
- [ ] T026 Run quickstart.md validation scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup
- **US1+US2 (Phase 3)**: Depends on Phase 2 + 004 TTS service
- **US5 (Phase 4)**: Depends on Phase 3
- **US3 (Phase 5)**: Depends on Phase 3 + 004 voice assistant
- **US4 (Phase 6)**: Depends on Phases 3-4
- **Polish (Phase 7)**: Depends on all

### Parallel Opportunities

- T003, T004, T005, T006, T007 run in parallel
- T012, T013 run in parallel (different widgets)
- T019 can run parallel with Phase 5
- All [P] test tasks run in parallel

---

## Notes

- Plain Dart entities — NOT freezed
- Manual Riverpod providers — NOT codegen
- TTS service reused from 004 (`ttsServiceProvider`)
- 2 example contracts: savings account and personal loan
- Accept button gated by: audio complete (4 sections) OR scroll to end
- Review session is ephemeral — not persisted
- Speed levels: 100% → 75% → 50%. No faster than normal
- Volume detection is advisory, not blocking
- Contracts are static content, not dynamically generated
