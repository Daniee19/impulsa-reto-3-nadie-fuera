# Tasks: Ayuda Humana con Contexto

**Input**: Design documents from `/specs/003-contextual-human-help/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/context-service-contract.md, research.md, quickstart.md

**Organization**: Tasks grouped by user story. Tests included per constitution (Principle V: domain ≥80% coverage, widget tests with a11y guidelines per screen).

**Note**: This project uses plain Dart entities with manual `copyWith`/`==`/`hashCode` (not freezed) and manual Riverpod providers (not codegen), consistent with 001-easy-mode and 002-fraud-shield implementations. TrustedPerson stub from 002-fraud-shield is extended with `helpRequests` permission.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Directory structure, localization strings, and route map for contextual help feature

- [X] T001 Create feature directory structure per plan.md: `lib/features/contextual_help/{domain/{entities,services,repositories},data/repositories,presentation/{providers,screens,widgets}}`, `test/features/contextual_help/{domain/services,presentation/screens}`
- [X] T002 [P] Add contextual help ARB strings to lib/core/l10n/arb/app_es.arb — keys: `help_title` ("Pedir ayuda"), `help_contact_trustedPerson` ("Llamar a {name}"), `help_contact_bankAdvisor` ("Hablar con el banco"), `help_channel_call` ("Llamar"), `help_channel_chat` ("Escribir"), `help_channel_video` ("Videollamada con intérprete de lengua de señas"), `help_connecting_trustedPerson` ("Te estamos conectando con {name}..."), `help_connecting_bankAdvisor` ("Te estamos conectando con un asesor..."), `help_connecting_videoInterpreter` ("Te estamos conectando con un asesor e intérprete de lengua de señas"), `help_context_screen` ("Está en: {screen}"), `help_context_operation` ("Operación: {operation} por S/ {amount}"), `help_context_noOperation` ("Sin operación en curso"), `help_context_minimalMessage` ("{userName} necesita ayuda"), `help_fallback_title` ("No pudimos comunicarte con {name}"), `help_fallback_question` ("¿Quieres hablar con un asesor del banco?"), `help_fallback_yes` ("Sí"), `help_fallback_back` ("Volver"), `help_connected_title` ("Conectado"), `help_connected_contextSent` ("Contexto enviado a {name}:"), `help_back_button` ("Volver a la app"), `help_fab_label` ("Pedir ayuda"). Run `flutter gen-l10n` after adding strings.
- [X] T003 [P] Create route-to-screen-name map as a constant Map<RegExp, String> in lib/features/contextual_help/presentation/providers/screen_name_map.dart — mapping route patterns to Spanish screen names per data-model.md: `/easy-mode` → "Pantalla principal", `/easy-mode/balance` → "Ver mi saldo", `/easy-mode/pay-bill` → "Elegir recibo para pagar", `/easy-mode/pay-bill/.+/confirm` → "Confirmación de pago", `/easy-mode/send-money` → "Enviar dinero", `/easy-mode/send-money/confirm` → "Confirmación de envío", `/easy-mode/fraud-alert` → "Alerta de seguridad", `/easy-mode/help/.*` → "Pidiendo ayuda", `/easy-mode/success` → "Operación exitosa". Default: "Pantalla desconocida".

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, context collector service, navigation observer, providers, repository interface, and routing. MUST be complete before ANY user story.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Domain Entities (all plain Dart, @immutable from meta, manual copyWith/==/hashCode, no Flutter imports)

- [X] T004 [P] Create HelpChannel enum in lib/features/contextual_help/domain/entities/help_channel.dart — values: `call`, `chat`, `videoWithInterpreter`. Pure Dart.
- [X] T005 [P] Create HelpTarget enum in lib/features/contextual_help/domain/entities/help_target.dart — values: `trustedPerson`, `bankAdvisor`. Pure Dart.
- [X] T006 [P] Create HelpContext entity in lib/features/contextual_help/domain/entities/help_context.dart — @immutable. Fields: `screenName` (String, non-empty, en español), `screenRoute` (String, non-empty), `flowStep` (String?, null si no hay flujo), `operationType` (OperationType? from 001, null si no hay operación), `operationAmount` (double?, null si no aplica), `operationRecipient` (String?, null si no aplica), `timestamp` (DateTime, non-null). Security: NEVER contains passwords, PIN, biometric data, or full account numbers (FR-016). Manual copyWith, ==, hashCode.
- [X] T007 [P] Create OperationInProgress entity in lib/features/contextual_help/domain/entities/operation_in_progress.dart — @immutable. Fields: `type` (OperationType from 001), `amount` (double, must be >0), `recipientName` (String, non-empty), `recipientId` (String, non-empty). Manual ==, hashCode.
- [X] T008 [P] Create HelpRequestStatus enum and HelpRequest entity in lib/features/contextual_help/domain/entities/help_request.dart — HelpRequestStatus enum: `connecting`, `connected`, `noResponse`, `completed`, `cancelled`. HelpRequest @immutable: fields `id` (String, non-empty UUID), `target` (HelpTarget, non-null), `targetName` (String, non-empty), `channel` (HelpChannel, non-null), `context` (HelpContext, non-null), `includeContext` (bool — true for advisor, depends on permission for trusted person), `status` (HelpRequestStatus, non-null), `createdAt` (DateTime, non-null). Manual copyWith (for status transitions), ==, hashCode.

### Core Infrastructure

- [X] T009 Create NavigationObserver in lib/core/router/navigation_observer.dart — extends NavigatorObserver per contract. Overrides `didPush`, `didPop`, `didReplace`. Each calls `_updateContext(route)` which reads `route.settings.name` and updates `navigationContextProvider` via `ref.read(navigationContextProvider.notifier).updateFromRoute(routeName)`. Constructor takes `Ref ref`. Lives in core/ because it affects the global router.
- [X] T010 [P] Create navigationContextProvider in lib/features/contextual_help/presentation/providers/navigation_context_provider.dart — StateNotifierProvider<NavigationContextNotifier, NavigationState>. NavigationState holds: `currentRoute` (String), `screenName` (String), `flowStep` (String?). NavigationContextNotifier has `updateFromRoute(String routeName)` which uses the screen name map (T003) to resolve route → screenName, and extracts flowStep if applicable (e.g. confirm screens → "Paso 2 de 2").
- [X] T011 [P] Create operationInProgressProvider in lib/features/contextual_help/presentation/providers/operation_in_progress_provider.dart — StateNotifierProvider<OperationInProgressNotifier, OperationInProgress?>. Methods: `set(OperationInProgress op)`, `clear()`. Initially null. The 001 flows will call set() when entering a pay/send flow and clear() on completion or cancel.

### Domain Services

- [X] T012 Create ContextCollector service in lib/features/contextual_help/domain/services/context_collector.dart — Dart puro, MUST NOT import Flutter. Method: `HelpContext collect({required String currentRoute, required String screenName, String? flowStep, OperationInProgress? operation})`. Builds HelpContext from inputs. Security filter (FR-016): strips any field that could contain passwords, PIN, biometric data, or full account numbers. Monto and recipientName are included (operational data). Timestamp is `DateTime.now()`. Stateless, deterministic (except timestamp).

### Repository

- [X] T013 [P] Create HelpSessionRepository interface in lib/features/contextual_help/domain/repositories/help_session_repository.dart — abstract class per contract: `Future<HelpRequest> startSession({required HelpTarget target, required HelpChannel channel, required HelpContext context, required bool includeContext})`, `Future<void> waitForResponse(String requestId, {Duration timeout = const Duration(seconds: 60)})`, `Future<void> endSession(String requestId)`.
- [X] T014 [P] Create MockHelpSessionRepository in lib/features/contextual_help/data/repositories/mock_help_session_repository.dart — implements HelpSessionRepository. `startSession()` creates HelpRequest with status `connecting`, returns it. `waitForResponse()` waits for `timeout` duration then transitions to `noResponse` (for trusted person — simulates no answer). For bank advisor, transitions to `connected` after 2s delay. `endSession()` marks `completed`. Uses StreamController or callback to notify status changes.

### Providers

- [X] T015 Create help_context_provider in lib/features/contextual_help/presentation/providers/help_context_provider.dart — Provider<HelpContext> that reads navigationContextProvider and operationInProgressProvider, calls ContextCollector.collect() and returns the current HelpContext. Auto-updates when navigation or operation state changes.
- [X] T016 [P] Create help_session_provider in lib/features/contextual_help/presentation/providers/help_session_provider.dart — StateNotifierProvider<HelpSessionNotifier, HelpRequest?>. Methods: `startSession(HelpTarget target, HelpChannel channel, HelpContext context, bool includeContext)` delegates to repository, `endSession()`, `simulateNoResponse()` for testing fallback. Provides `helpSessionRepositoryProvider` (Provider<HelpSessionRepository>) returning MockHelpSessionRepository.

### Routing & Integration

- [X] T017 Add help routes to lib/core/router/app_router.dart — nested under `/easy-mode`: `help/contact-picker` → HelpContactPickerScreen, `help/channel-picker` → HelpChannelPickerScreen (receives HelpTarget via extra), `help/connecting` → HelpConnectingScreen (receives HelpRequest via extra or provider), `help/fallback` → HelpFallbackScreen. All use `context.push()` to preserve flow progress (FR-011).
- [X] T018 Register NavigationObserver in GoRouter constructor in lib/core/router/app_router.dart — add `observers: [NavigationObserver(ref)]`. This requires converting appRouter from a top-level final to a function or provider that receives Ref. Use a Provider<GoRouter> or pass observer list.
- [X] T019 Extend TrustedPerson stub in lib/features/fraud_shield/domain/entities/trusted_person.dart — add `helpRequests` value to TrustedPermission enum. `hasPermission()` still returns true for all permissions in the stub.

### Foundational Tests

- [X] T020 [P] Unit tests for ContextCollector in test/features/contextual_help/domain/services/context_collector_test.dart — Dart puro tests: (1) home screen without operation → screenName "Pantalla principal", operation fields null, (2) confirm payment with operation → includes monto and recipientName, (3) fraud alert screen → screenName "Alerta de seguridad", (4) timestamp is present and non-null, (5) operation null → operationType/amount/recipient all null, (6) security filter: no sensitive data leaks (verify no passwords/PIN fields exist in output)

**Checkpoint**: Foundation ready — entities, context collector tested, providers configured, observer registered, routes added. User story implementation can begin.

---

## Phase 3: US1 + US2 — Ayuda a persona de confianza y asesor del banco (Priority: P1) 🎯 MVP

**Goal**: Botón "Pedir ayuda" global visible en todas las pantallas. Usuario elige a quién contactar (familiar o asesor) y por qué canal. Contexto real enviado automáticamente. Conexiones simuladas.

**Independent Test**: Tocar FAB "Pedir ayuda" durante un pago → elegir contacto → elegir canal → ver pantalla de conexión con contexto real. Volver → flujo preservado. TalkBack anuncia cada opción. Asesor tiene 3 canales incluyendo videollamada con intérprete.

### Implementation

- [X] T021 [P] [US1] Create HelpFab widget in lib/features/contextual_help/presentation/widgets/help_fab.dart — FloatingActionButton with icon Icons.support_agent, label from ARB `help_fab_label`, Semantics label "Pedir ayuda", ≥48dp (Material FAB is 56dp by default). onPressed: `context.push('/easy-mode/help/contact-picker')`. SystemSound.play on tap. WCAG 4.5:1 contrast.
- [X] T022 [US1] Add ShellRoute wrapper with HelpFab to lib/core/router/app_router.dart — wrap all `/easy-mode` routes in a ShellRoute per research.md R4: `ShellRoute(builder: (context, state, child) => Scaffold(body: child, floatingActionButton: const HelpFab()))`. This makes the FAB visible on ALL screens without repeating it. Remove individual Scaffold from each screen or adjust nesting so FAB appears alongside each screen's AppBar.
- [X] T023 [US1] Create HelpContactPickerScreen in lib/features/contextual_help/presentation/screens/help_contact_picker_screen.dart — ConsumerWidget. Reads trustedPersonProvider. If non-null AND `hasPermission(TrustedPermission.helpRequests)` → show option "Llamar a {name}" (AccessibleButton, icon: person). Always shows "Hablar con el banco" (AccessibleButton, icon: support_agent). If no trusted person or no permission → only bank advisor option, no empty space, no error. Selecting an option pushes to `/easy-mode/help/channel-picker` with HelpTarget as extra. SemanticsService.announce title on mount. All buttons ≥48dp, 8dp separation, 4.5:1 contrast. ≤15 words per label.
- [X] T024 [US2] Create HelpChannelPickerScreen in lib/features/contextual_help/presentation/screens/help_channel_picker_screen.dart — ConsumerWidget. Receives HelpTarget via route extra. For `trustedPerson`: 2 channels — call ("Llamar a {name}") and chat ("Escribir a {name}"). For `bankAdvisor`: 3 channels — call ("Llamar al banco"), chat ("Escribir al banco"), videoWithInterpreter ("Videollamada con intérprete de lengua de señas"). Selecting a channel: reads helpContextProvider, builds HelpRequest via helpSessionProvider.startSession(), pushes to `/easy-mode/help/connecting`. AccessibleButtons, ≥48dp, Semantics labels, TalkBack announces each option including full "Videollamada con intérprete de lengua de señas" text (FR-004, US2-AS3).
- [X] T025 [US1] Create HelpConnectingScreen in lib/features/contextual_help/presentation/screens/help_connecting_screen.dart — ConsumerStatefulWidget. Reads helpSessionProvider for current HelpRequest. Shows connecting message per ARB: for trusted person → "Te estamos conectando con {name}...", for advisor → "Te estamos conectando con un asesor...", for videoWithInterpreter → "Te estamos conectando con un asesor e intérprete de lengua de señas". After 2s simulated delay, shows "Conectado" with context card: "Contexto enviado a {name}:" + screen name + operation details (if includeContext is true, else "necesita ayuda" without details). Shows "Volver a la app" button → pop all help routes back to original screen. SemanticsService.announce connecting message. CircularProgressIndicator during connecting. Liveregion for status changes.
- [X] T026 [US1] Integrate operationInProgressProvider into pay_bill flow — modify lib/features/easy_mode/presentation/screens/pay_bill_screen.dart: when user taps a bill to pay, call `ref.read(operationInProgressProvider.notifier).set(OperationInProgress(type: OperationType.payment, amount: bill.amount, recipientName: '${bill.serviceName} - ${bill.providerName}', recipientId: bill.id))`. In pay_bill_confirm_screen.dart: call `clear()` on successful payment or back navigation.
- [X] T027 [US2] Integrate operationInProgressProvider into send_money flow — modify lib/features/easy_mode/presentation/screens/send_money_screen.dart: when user selects contact and enters amount, call `ref.read(operationInProgressProvider.notifier).set(OperationInProgress(type: OperationType.transfer, amount: amount, recipientName: contact.name, recipientId: contact.id))`. In send_money_confirm_screen.dart: call `clear()` on successful transfer or back navigation.
- [X] T028 [US1] Replace existing HelpScreen from 001 — update route in lib/core/router/app_router.dart: change `/easy-mode/help` to redirect to `/easy-mode/help/contact-picker`. Remove or keep the old HelpScreen for backwards compatibility but the route now points to the new contact picker. Update lib/features/easy_mode/presentation/screens/easy_mode_home_screen.dart: if it references the old help route, update to new route. Remove the old `easyMode_help_callAdvisor`, `easyMode_help_chatAdvisor`, `easyMode_help_connecting` ARB keys if fully replaced (or keep for compatibility).
- [X] T029 [US1] Run `flutter gen-l10n` and `flutter analyze` — verify 0 errors after all integration changes

### Tests

- [X] T030 [P] [US1] Widget test for HelpContactPickerScreen in test/features/contextual_help/presentation/screens/help_contact_picker_screen_test.dart — a11y guidelines (androidTapTargetGuideline, labeledTapTargetGuideline); verify 2 options when trustedPerson has helpRequests permission; verify 1 option (bank only) when trustedPerson is null; verify 1 option when trustedPerson lacks helpRequests permission; SemanticsService.announce on mount
- [X] T031 [P] [US2] Widget test for HelpChannelPickerScreen in test/features/contextual_help/presentation/screens/help_channel_picker_screen_test.dart — a11y guidelines; verify 2 channels for trusted person target; verify 3 channels for bank advisor target; verify "Videollamada con intérprete de lengua de señas" text appears for bank advisor; all buttons ≥48dp

**Checkpoint**: Help FAB visible everywhere. Contact and channel selection working. Context sent with connecting screen. MVP for contextual help.

---

## Phase 4: US4 — Consentimiento para Compartir Contexto (Priority: P1)

**Goal**: Sin consentimiento activo (permiso helpRequests de TrustedPerson), el familiar no recibe contexto — solo "Rosa necesita ayuda". El asesor siempre recibe contexto (relación contractual).

**Independent Test**: Con helpRequests desactivado: pedir ayuda → elegir familiar → canal → pantalla de conexión muestra "Rosa necesita ayuda" sin detalles de pantalla ni operación. Con helpRequests activo: muestra contexto completo.

### Implementation

- [X] T032 [US4] Implement includeContext logic in HelpChannelPickerScreen — when building HelpRequest for trusted person, check `trustedPerson.hasPermission(TrustedPermission.helpRequests)`. If true → `includeContext: true`. If false → `includeContext: false`. For bank advisor → always `includeContext: true`. The HelpConnectingScreen already reads includeContext to show full context or minimal message.
- [X] T033 [US4] Implement minimal context display in HelpConnectingScreen — when `helpRequest.includeContext == false`, the context card shows only `help_context_minimalMessage` ("{userName} necesita ayuda") without screen name, operation type, amount, or recipient. When `includeContext == true`, shows full context. Update lib/features/contextual_help/presentation/screens/help_connecting_screen.dart.
- [X] T034 [P] [US4] Test consent logic — add test cases to help_channel_picker_screen_test.dart: verify includeContext is false when trusted person lacks helpRequests permission; verify includeContext is true for bank advisor regardless; verify HelpConnectingScreen shows minimal message when includeContext is false

**Checkpoint**: Consent integrated. Familiar without permission gets no context details. FR-007 satisfied.

---

## Phase 5: US3 — Fallback a Asesor cuando Familiar No Responde (Priority: P2)

**Goal**: Si la persona de confianza no responde en 60s (simulado), la app ofrece contactar al asesor con el mismo contexto.

**Independent Test**: Pedir ayuda → elegir familiar → canal → pantalla de conexión → simular timeout → pantalla de fallback con mensaje y opciones "Sí" / "Volver". Elegir "Sí" → conexión con asesor con el MISMO contexto original.

### Implementation

- [X] T035 [US3] Create HelpFallbackScreen in lib/features/contextual_help/presentation/screens/help_fallback_screen.dart — ConsumerWidget. Shows message: "No pudimos comunicarte con {name}. ¿Quieres hablar con un asesor del banco?" (ARB keys `help_fallback_title` + `help_fallback_question`). Two AccessibleButtons: "Sí" (icon: check) → starts new session with HelpTarget.bankAdvisor using SAME HelpContext from the original request, pushes to `/easy-mode/help/connecting`. "Volver" (icon: arrow_back) → pops back to original screen. ≥48dp buttons, Semantics labels, 4.5:1 contrast. SemanticsService.announce fallback message on mount.
- [X] T036 [US3] Implement timeout and fallback transition — in HelpConnectingScreen: when target is trustedPerson, start a 60s timer (simulated). If timer completes without connection → navigate to `/easy-mode/help/fallback` with the original HelpContext preserved. Add a debug button (only in debug mode) "Simular no respuesta" to instantly trigger fallback for testing. For bank advisor: no timeout, always transitions to connected after 2s.
- [X] T037 [P] [US3] Widget test for HelpFallbackScreen in test/features/contextual_help/presentation/screens/help_fallback_screen_test.dart — a11y guidelines; verify "Sí" and "Volver" buttons present; verify message contains trusted person name; verify tapping "Sí" navigates to connecting with bank advisor target

**Checkpoint**: Fallback to advisor working. User never left without help. FR-010 satisfied.

---

## Phase 6: US5 — Ayuda sin Operación en Curso (Priority: P2)

**Goal**: El botón de ayuda funciona desde la pantalla principal sin operación activa. El contexto dice "Pantalla principal, sin operación en curso".

**Independent Test**: Desde pantalla principal (sin iniciar flujo) → tocar FAB → elegir contacto → canal → pantalla de conexión muestra contexto con "Pantalla principal" y "Sin operación en curso".

### Implementation

- [X] T038 [US5] Verify no-operation context display — ensure HelpConnectingScreen correctly handles null operation in HelpContext: when operationType is null, show "Sin operación en curso" (ARB key `help_context_noOperation`) instead of operation details. Already handled by ContextCollector returning null operation fields; verify the screen renders it correctly.
- [X] T039 [P] [US5] Add no-operation test case — in context_collector_test.dart: verify collect() with null operation returns HelpContext with null operationType/amount/recipient. In help_connecting_screen tests (if exists): verify "Sin operación en curso" text appears when context has no operation.

**Checkpoint**: Help works from any screen, with or without active operation. SC-001 satisfied (≤2 touches).

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates, formatting, full validation against quickstart scenarios

- [X] T040 [P] Run `flutter analyze`, verify 0 warnings across all contextual_help and modified 001/002 files
- [X] T041 [P] Run `dart format` on all source files in lib/features/contextual_help/, lib/core/router/, and test/features/contextual_help/
- [X] T042 [P] Verify all contextual help ARB strings are used — no hard-coded Spanish strings in contextual_help widgets (Principle VII)
- [X] T043 Run quickstart.md validation scenarios VS-1 through VS-8

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **US1+US2 (Phase 3)**: Depends on Phase 2 — first deliverable MVP
- **US4 (Phase 4)**: Depends on Phase 3 — refines consent behavior
- **US3 (Phase 5)**: Depends on Phase 3 — adds fallback flow
- **US5 (Phase 6)**: Depends on Phase 3 — verifies no-operation scenario
- **Polish (Phase 7)**: Depends on all story phases complete

### User Story Dependencies

- **US1+US2 (P1)**: Can start after Phase 2. Creates all shared screens (contact picker, channel picker, connecting).
- **US4 (P1)**: Can start after Phase 3. Modifies consent logic in existing screens.
- **US3 (P2)**: Can start after Phase 3, in parallel with US4.
- **US5 (P2)**: Can start after Phase 3, in parallel with US4 and US3.

### Within Each Phase

- Entities before services (T004–T008 before T012)
- Observer + providers before screens (T009–T011 before T021–T025)
- Services before providers (T012 before T015)
- Repository before session provider (T013–T014 before T016)
- Screens before flow integration (T023–T025 before T026–T028)
- ShellRoute (T022) before integration testing

### Parallel Opportunities

- All entity tasks T004–T008 run in parallel
- T009, T010, T011 can run in parallel (different files)
- T013, T014 run in parallel
- T015, T016 run in parallel
- T021, T020 (ContextCollector test) can run in parallel
- US4, US3, US5 can run in parallel after Phase 3

---

## Parallel Example: Phase 2 — Domain Layer

```bash
# Launch all entities in parallel:
Task T004: "Create HelpChannel enum"
Task T005: "Create HelpTarget enum"
Task T006: "Create HelpContext entity"
Task T007: "Create OperationInProgress entity"
Task T008: "Create HelpRequest entity"

# Then services + providers (depends on T004–T008):
Task T009: "Create NavigationObserver"
Task T010: "Create navigationContextProvider"
Task T011: "Create operationInProgressProvider"
Task T012: "Create ContextCollector service"

# Parallel with above: repository
Task T013: "Create HelpSessionRepository interface"
Task T014: "Create MockHelpSessionRepository"
```

---

## Implementation Strategy

### MVP First (US1+US2 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: US1+US2 (FAB + contact picker + channels + connecting)
4. **STOP and VALIDATE**: FAB visible everywhere. Tap → choose contact → choose channel → see context. Volver preserva datos.
5. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundational → Observer, collector tested, providers ready
2. US1+US2 → Help system with real context → Demo (MVP!)
3. US4 → Consent logic → Demo
4. US3 → Fallback to advisor → Demo
5. US5 → No-operation context verified → Demo (all stories complete)
6. Polish → Quality gates, quickstart validation

### Parallel Team Strategy

With multiple developers after Phase 2:
- Developer A: US1+US2 (screens + FAB + integration)
- After Phase 3 complete:
  - Developer A: US4 (consent)
  - Developer B: US3 (fallback)
  - Developer C: US5 (no-operation verification)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Plain Dart entities with manual copyWith/==/hashCode — NOT freezed (removed from project)
- Manual Riverpod providers — NOT codegen (riverpod_generator removed from project)
- Constitution compliance: widget tests with a11y guidelines, domain tests ≥80% coverage
- All UI text in ARB — no hard-coded Spanish strings (Principle VII)
- Frases ≤ 15 palabras, sin jerga bancaria, tono empático (Principle VI)
- TrustedPerson stub from 002-fraud-shield is EXTENDED (add helpRequests permission) — replace when 006 is implemented
- ShellRoute approach per research.md R4 for global FAB — may require refactoring existing Scaffolds in 001 screens
- NavigationObserver requires GoRouter to accept Ref — may need Provider<GoRouter> pattern
- Connections are simulated but context is REAL (FR-006, FR-015)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
