# Tasks: Microlecciones contra Estafas

**Input**: Design documents from `/specs/011-scam-lessons/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, research.md, quickstart.md

**Organization**: Tasks grouped by user story. Tests included per constitution (Principle V: domain ≥80% coverage, widget tests with a11y guidelines per screen).

**Note**: This project uses plain Dart entities with manual `copyWith`/`==`/`hashCode` (not freezed) and manual Riverpod providers (not codegen). Reuses `flutter_tts` from 004 and `RiskRule` from 002. Lessons are static content (5 lessons).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Directory structure, ARB strings for lessons and UI

- [ ] T001 Create feature directory structure per plan.md: `lib/features/scam_lessons/{domain/{entities,repositories},data/repositories,presentation/{providers,screens,widgets}}`, `test/features/scam_lessons/{domain,presentation/screens}`
- [ ] T002 [P] Add ARB strings to lib/core/l10n/arb/app_es.arb — keys for UI: `lesson_suggestion_prefix` ("¿Sabías que"), `lesson_viewLesson` ("Ver lección"), `lesson_notNow` ("Ahora no"), `lesson_back` ("Volver"), `lesson_listTitle` ("Aprender sobre estafas"), `lesson_completed` ("Completada"), `lesson_notSeen` ("No vista"), `lesson_volumeLow` ("Tu volumen está bajo. Puedes leer la lección."), `lesson_pause` ("Pausar"). Plus content keys for each of the 5 lessons: title, content, question prompt, 3 option texts, 3 feedback texts = 5 × 9 = 45 keys. Run `flutter gen-l10n`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, repository, alert-to-lesson mapping. MUST be complete before ANY user story.

### Domain Entities (plain Dart, @immutable, manual copyWith/==/hashCode)

- [ ] T003 [P] Create AnswerOption entity in lib/features/scam_lessons/domain/entities/lesson.dart — @immutable. Fields: `text` (String, non-empty), `isCorrect` (bool), `feedback` (String, non-empty). Manual ==, hashCode.
- [ ] T004 [P] Create PracticeQuestion entity in same file — @immutable. Fields: `prompt` (String, non-empty), `options` (List<AnswerOption>, length ≥ 3). Computed: `AnswerOption get correctOption`. Manual ==, hashCode.
- [ ] T005 [P] Create Lesson entity in same file — @immutable. Fields: `id` (String, non-empty), `title` (String, non-empty), `content` (String, non-empty, ≤150 words), `relatedRiskRules` (Set<RiskRule> from 002, non-empty), `question` (PracticeQuestion, non-null). Manual ==, hashCode.
- [ ] T006 [P] Create LessonSuggestion entity in lib/features/scam_lessons/domain/entities/lesson_suggestion.dart — @immutable. Fields: `lesson` (Lesson, non-null), `triggeredRules` (Set<RiskRule>, non-empty). Manual ==, hashCode.

### Data Layer

- [ ] T007 [P] Create abstract LessonRepository in lib/features/scam_lessons/domain/repositories/lesson_repository.dart — methods: `List<Lesson> getAllLessons()`, `Lesson getLessonById(String id)`, `List<Lesson> getLessonsForRules(Set<RiskRule> rules)`.
- [ ] T008 Create MockLessonRepository in lib/features/scam_lessons/data/repositories/mock_lesson_repository.dart — implements LessonRepository. Contains 5 static lessons from data-model.md: `fake_yape` (relatedRules: newRecipient), `bank_call_scam` (unusualAmount, unusualTime), `fake_prize` (highFrequency), `fake_relative` (newRecipient), `sms_phishing` (unusualTime). Content from ARB keys. `getLessonsForRules()` returns lessons where relatedRiskRules intersects the given rules.
- [ ] T009 [P] Create alert-to-lesson mapping as constant in lib/features/scam_lessons/domain/entities/lesson_suggestion.dart — `Map<RiskRule, List<String>>` mapping each RiskRule to relevant lesson IDs.

### Providers & Routing

- [ ] T010 [P] Create lesson_provider in lib/features/scam_lessons/presentation/providers/lesson_provider.dart — Providers: `lessonRepositoryProvider`, `allLessonsProvider`, `lessonProgressProvider` (reads completed status from SharedPreferences per lesson ID), `isLessonCompletedProvider(String lessonId)`.
- [ ] T011 [P] Create lesson_suggestion_provider in lib/features/scam_lessons/presentation/providers/lesson_suggestion_provider.dart — StateNotifierProvider. Exposes `LessonSuggestion?`. Methods: `triggerFromAlert(Set<RiskRule> rules)` — finds first relevant lesson not completed, not exceeding 3 consecutive rejections; `dismiss()` — increments rejection counter; `acceptSuggestion()` — navigates to lesson. Uses SharedPreferences for: completed lessons (Set<String>), consecutive rejections (int).
- [ ] T012 Add routes to lib/core/router/app_router.dart — under `/easy-mode`: `lessons` → LessonListScreen, `lessons/:lessonId` → LessonScreen.

### Foundational Tests

- [ ] T013 [P] Unit tests for MockLessonRepository in test/features/scam_lessons/domain/mock_lesson_repository_test.dart — tests: (1) getAllLessons returns 5, (2) getLessonById returns correct lesson, (3) getLessonsForRules with newRecipient returns fake_yape + fake_relative, (4) getLessonsForRules with no matching rule returns empty.

**Checkpoint**: Foundation ready. Lessons defined, mapping configured.

---

## Phase 3: US1 + US5 — Sugerencia contextual post-alerta (Priority: P1)

**Goal**: After resolving a fraud alert (002), suggest a relevant lesson on the home screen. Never during an operation.

- [ ] T014 [US1] Create LessonSuggestionCard widget in lib/features/scam_lessons/presentation/widgets/lesson_suggestion_card.dart — shows suggestion message (contextual intro from ARB + lesson title + "en 1 minuto"). Two AccessibleButtons: "Ver lección" (icon: school) → navigates to lesson, "Ahora no" (icon: close) → dismisses. SemanticsService.announce on mount. ≥48dp, 4.5:1 contrast.
- [ ] T015 [US1] Integrate suggestion trigger into FraudAlertScreen — modify lib/features/fraud_shield/presentation/screens/fraud_alert_screen.dart: when user resolves alert (cancel or continue), set pending trigger in lessonSuggestionProvider with the alert's triggeredRules. The suggestion appears on EasyModeHomeScreen after the operation completes.
- [ ] T016 [US5] Gate suggestion on operation completion — in lessonSuggestionProvider: only expose suggestion when `ref.watch(operationInProgressProvider)` is null. If operation in progress, hold the trigger until it clears.
- [ ] T017 [US1] Integrate LessonSuggestionCard into EasyModeHomeScreen — if `ref.watch(lessonSuggestionProvider)` is non-null → show card. After "Ver lección" or "Ahora no" → card disappears.

### Tests

- [ ] T018 [P] [US1] Widget test for LessonSuggestionCard — a11y guidelines; verify 2 buttons; verify suggestion text contains lesson title.

**Checkpoint**: Contextual suggestions work post-alert. Never during operations.

---

## Phase 4: US2 — Pregunta de práctica (Priority: P1)

**Goal**: Each lesson ends with a practice question. Correct → positive feedback. Incorrect → kind explanation.

- [ ] T019 [US2] Create PracticeQuestionWidget in lib/features/scam_lessons/presentation/widgets/practice_question_widget.dart — shows prompt text, then 3+ AccessibleButtons for options. On select: shows feedback card — green tint + positive text for correct, amber tint + kind explanation for incorrect (never "Incorrecto"/"Error"/"Mal"). Marks lesson as completed regardless of answer. "Volver" button after answering. ≥48dp, Semantics labels.
- [ ] T020 [US2] Create LessonScreen in lib/features/scam_lessons/presentation/screens/lesson_screen.dart — ConsumerStatefulWidget. Loads lesson by ID from route param. Shows: title, content text (scrollable), TTS reads content via ttsServiceProvider from 004 (auto-play, pausable). After content: PracticeQuestionWidget. On mount: SemanticsService.announce title. Volume check (low → banner like 010).

### Tests

- [ ] T021 [P] [US2] Widget test for PracticeQuestionWidget — verify 3 options shown; verify correct answer shows positive feedback; verify incorrect shows kind explanation without "Incorrecto"/"Error"/"Mal"; a11y guidelines.
- [ ] T022 [P] Widget test for LessonScreen — verify content displayed; verify question at end; a11y guidelines.

**Checkpoint**: Lessons with practice questions. Feedback is kind and educational.

---

## Phase 5: US3 — Lista de lecciones accesible (Priority: P2)

**Goal**: User can browse all lessons from help/settings.

- [ ] T023 [US3] Create LessonListTile widget in lib/features/scam_lessons/presentation/widgets/lesson_list_tile.dart — shows lesson title + completion status badge ("Completada" / "No vista"). Tappable → navigates to lesson. ≥48dp, Semantics label includes status.
- [ ] T024 [US3] Create LessonListScreen in lib/features/scam_lessons/presentation/screens/lesson_list_screen.dart — ConsumerWidget. Title: "Aprender sobre estafas" (ARB). Lists all lessons with LessonListTile. Shows completion status per lesson. SemanticsService.announce title on mount.
- [ ] T025 [US3] Add entry point — add "Aprender sobre estafas" option accessible from EasyModeHomeScreen help section or settings. Navigates to `/easy-mode/lessons`.

### Tests

- [ ] T026 [P] [US3] Widget test for LessonListScreen — verify all 5 lessons listed; verify completion badge; a11y guidelines.

**Checkpoint**: Lessons browsable by user initiative.

---

## Phase 6: US4 — TalkBack accessibility (Priority: P2)

- [ ] T027 [US4] Verify TalkBack for suggestion card — announcement includes suggestion text and both options.
- [ ] T028 [US4] Verify TalkBack for lesson content — content navigable, question options selectable, feedback readable.

---

## Phase 7: Polish & Cross-Cutting

- [ ] T029 [P] Run `flutter analyze`, verify 0 warnings
- [ ] T030 [P] Run `dart format` on all scam_lessons files
- [ ] T031 [P] Verify all UI strings come from ARB — especially lesson content and feedback
- [ ] T032 Run quickstart.md validation scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Setup
- **US1+US5 (Phase 3)**: Depends on Phase 2 + 002 fraud alert + 003 operationInProgressProvider
- **US2 (Phase 4)**: Depends on Phase 2 + 004 TTS
- **US3 (Phase 5)**: Depends on Phase 4 (lesson screen must exist)
- **US4 (Phase 6)**: Depends on Phases 3-5
- **Polish (Phase 7)**: Depends on all

### Parallel Opportunities

- T003, T004, T005, T006, T007, T009 run in parallel
- US1+US5 (Phase 3) and US2 (Phase 4) can run in parallel after Phase 2
- T023, T024 run in parallel with lesson screen work
- All [P] test tasks run in parallel

---

## Notes

- Plain Dart entities — NOT freezed
- Manual Riverpod providers — NOT codegen
- 5 static lessons from data-model.md, content in ARB
- TTS from 004 reads lesson content (auto-play, pausable)
- Suggestion only after fraud alert resolution AND after operation completes
- 3 consecutive rejections → stop auto-suggesting (manual access still works)
- Feedback tone: positive for correct, kind for incorrect (NO "Incorrecto"/"Error"/"Mal")
- Completed = answered question (correct or incorrect). Binary, no undo
- Lessons can be re-read but won't be re-suggested
- RiskRule mapping: newRecipient → fake_yape + fake_relative, unusualAmount/unusualTime → bank_call_scam, highFrequency → fake_prize, unusualTime → sms_phishing
