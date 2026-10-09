# Tasks: Asistente de Voz y Texto

**Input**: Design documents from `/specs/004-voice-text-assistant/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/assistant-service-contract.md, research.md, quickstart.md

**Organization**: Tasks grouped by user story. Tests included per constitution (Principle V: domain ≥80% coverage, widget tests with a11y guidelines per screen).

**Note**: This project uses plain Dart entities with manual `copyWith`/`==`/`hashCode` (not freezed) and manual Riverpod providers (not codegen), consistent with 001-easy-mode, 002-fraud-shield, and 003-contextual-human-help implementations. The data-model.md mentions freezed, but the codebase removed it — follow codebase convention.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Directory structure, dependencies, localization strings, and platform configuration for voice assistant feature

- [ ] T001 Create feature directory structure per plan.md: `lib/features/voice_assistant/{domain/{entities,services},data/services,presentation/{providers,screens,widgets}}`, `test/features/voice_assistant/{domain/services,presentation/screens}`
- [ ] T002 Add dependencies to pubspec.yaml: `speech_to_text: ^7.5.0` (MIT), `flutter_tts: ^4.2.5` (MIT), `local_auth: ^3.0.2` (BSD-3-Clause), `shared_preferences: ^2.3.0` (BSD-3-Clause). Run `flutter pub get`
- [ ] T003 [P] Add Android platform configuration — in `android/app/src/main/AndroidManifest.xml`: add `<uses-permission android:name="android.permission.RECORD_AUDIO"/>` and `<uses-permission android:name="android.permission.USE_BIOMETRIC"/>` and `<uses-permission android:name="android.permission.USE_FINGERPRINT"/>`. In `android/app/build.gradle`: verify `minSdk >= 26` (already set)
- [ ] T004 [P] Add voice assistant ARB strings to lib/core/l10n/arb/app_es.arb — keys: `assistant_title` ("Asistente"), `assistant_mic_label` ("Activar micrófono"), `assistant_text_label` ("Escribe tu solicitud"), `assistant_listening` ("Te escucho..."), `assistant_processing` ("Entendiendo..."), `assistant_unknown` ("No estoy seguro de lo que necesitas. ¿Quieres ver tu saldo, pagar un recibo, enviar dinero o pedir ayuda?"), `assistant_outOfScope` ("Solo puedo ayudarte con tu cuenta. ¿Quieres ver tu saldo, pagar un recibo, enviar dinero o pedir ayuda?"), `assistant_balance` ("Tienes S/ {amount} disponibles"), `assistant_payConfirm` ("Vas a pagar tu recibo de {service} por S/ {amount}. ¿Confirmas con tu huella?"), `assistant_sendConfirm` ("Vas a enviar S/ {amount} a {name}. ¿Confirmas con tu huella?"), `assistant_payDone` ("Pago realizado"), `assistant_sendDone` ("Dinero enviado"), `assistant_needsService` ("¿Qué recibo quieres pagar?"), `assistant_needsContact` ("¿A quién quieres enviarle?"), `assistant_needsAmount` ("¿Cuánto quieres enviarle a {name}?"), `assistant_billNotFound` ("No encontré un recibo de {service} pendiente. ¿Quieres ver tus recibos pendientes?"), `assistant_speechFailed` ("No te escuché bien. ¿Puedes repetir o escribirlo?"), `assistant_biometricReason` ("Confirma la operación"), `assistant_biometricFailed` ("No reconocí tu huella. Intenta de nuevo."), `assistant_confirmButton` ("Confirmar con huella"), `assistant_cancelButton` ("Cancelar"), `microphoneConsent_title` ("Permiso para escucharte"), `microphoneConsent_body` ("Para entender lo que dices, necesito usar tu micrófono. Solo lo uso mientras hablas, no grabo nada."), `microphoneConsent_accept` ("Aceptar"), `microphoneConsent_decline` ("No, prefiero escribir"), `microphoneConsent_denied` ("Puedes escribirme si prefieres no usar el micrófono."), `assistant_onlyContacts` ("Solo puedo enviar dinero a tus contactos guardados. ¿A quién de tus contactos quieres enviarle?")`. Run `flutter gen-l10n` after adding strings

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, intent parser, operation preparer, platform service wrappers, providers, and routing. MUST be complete before ANY user story.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Domain Entities (all plain Dart, @immutable from meta, manual copyWith/==/hashCode where needed, no Flutter imports)

- [ ] T005 [P] Create AssistantIntentType enum in lib/features/voice_assistant/domain/entities/assistant_intent.dart — values: `checkBalance`, `payBill`, `sendMoney`, `requestHelp`, `unknown`. Pure Dart. Also create InputSource enum in the same file: `voice`, `text`
- [ ] T006 [P] Create IntentParameters entity in lib/features/voice_assistant/domain/entities/assistant_intent.dart — @immutable. Fields: `serviceName` (String?, null if not mentioned), `contactName` (String?, null if not mentioned), `amount` (double?, null if not mentioned, must be > 0 if present). Manual ==, hashCode
- [ ] T007 [P] Create ParsedIntent entity in lib/features/voice_assistant/domain/entities/assistant_intent.dart — @immutable. Fields: `type` (AssistantIntentType, non-null), `parameters` (IntentParameters?, null if not applicable). Manual ==, hashCode
- [ ] T008 [P] Create OperationSummary entity in lib/features/voice_assistant/domain/entities/operation_summary.dart — @immutable. Fields: `type` (OperationType from 001, non-null), `amount` (double, must be > 0), `recipientName` (String, non-empty), `recipientId` (String, non-empty), `spokenSummary` (String, non-empty, ≤15 words). Invariant: amount and recipientName ALWAYS come from repository, NEVER from parser. Manual ==, hashCode
- [ ] T009 [P] Create VoiceSessionStatus enum in lib/features/voice_assistant/domain/entities/voice_session.dart — values: `idle`, `listening`, `processing`, `needsMore`, `summarizing`, `awaitingConfirmation`, `executing`, `completed`, `error`. Also create VoiceSession entity @immutable: fields `id` (String, non-empty UUID), `status` (VoiceSessionStatus, non-null), `inputText` (String?, null until input received), `inputSource` (InputSource, non-null), `parsedIntent` (ParsedIntent?, null until parsed), `operationSummary` (OperationSummary?, null if not applicable), `assistantMessage` (String?, null until response), `createdAt` (DateTime, non-null). Manual copyWith (for status transitions), ==, hashCode
- [ ] T010 [P] Create PrepareResult sealed class in lib/features/voice_assistant/domain/entities/prepare_result.dart — `sealed class PrepareResult`. Subclasses: `PrepareSuccess` (OperationSummary summary), `PrepareNeedsService` (List<Bill> pendingBills), `PrepareNeedsContact` (List<SavedContact> contacts), `PrepareNeedsAmount` (String contactName), `PrepareBillNotFound` (String serviceName), `PrepareBalanceResult` (double balance). Each @immutable

### Domain Services (Dart puro, MUST NOT import Flutter)

- [ ] T011 Create IntentParser service in lib/features/voice_assistant/domain/services/intent_parser.dart — Dart puro. Method: `ParsedIntent parse(String input)`. Normalizes input (lowercase, trim). Matches against keyword lists per contract: `checkBalance` keywords ["saldo", "cuánto tengo", "cuánto hay", "mi plata", "mi dinero", "balance", "cuenta"], `payBill` keywords ["pagar", "recibo", "servicio"] + service keywords ["luz", "agua", "gas", "teléfono", "internet", "cable", "electricidad"], `sendMoney` keywords ["enviar", "mandar", "transferir", "envía", "manda", "transfiere"], `requestHelp` keywords ["ayuda", "ayúdame", "no sé", "no entiendo", "hablar con alguien", "persona"]. Extracts parameters: monto via regex `(\d+[\.,]?\d*)\s*soles?` or standalone number in send context, contactName via words after send keywords, serviceName via service keyword match. ALWAYS returns valid ParsedIntent (never null, never throws). Empty input → `unknown`. Deterministic: same input → same output. NEVER accesses repos
- [ ] T012 Create OperationPreparer service in lib/features/voice_assistant/domain/services/operation_preparer.dart — Dart puro. Constructor receives `AccountRepository`, `BillRepository`, `ContactRepository` (from 001). Method: `Future<PrepareResult> prepare(ParsedIntent intent)`. For `checkBalance`: calls `accountRepo.getAccount()`, returns `PrepareBalanceResult(account.availableBalance)`. For `payBill`: if serviceName null → `PrepareNeedsService(await billRepo.getPendingBills())`. If serviceName present → search pendingBills for match (case-insensitive contains). Match found → `PrepareSuccess` with bill.amount and bill.serviceName from repo. No match → `PrepareBillNotFound(serviceName)`. For `sendMoney`: if contactName null → `PrepareNeedsContact(await contactRepo.getContacts())`. If contactName present → search contacts (case-insensitive contains). Single match + amount present → `PrepareSuccess` with contact.name from repo. Single match + amount null → `PrepareNeedsAmount(contact.name)`. Zero or multiple matches → `PrepareNeedsContact(matches)`. Security invariant: amount and recipientName in PrepareSuccess ALWAYS from repo data

### Data Services (Flutter wrappers for platform APIs)

- [ ] T013 [P] Create SpeechRecognitionService in lib/features/voice_assistant/data/services/speech_recognition_service.dart — wraps `speech_to_text` package. Methods: `Future<bool> initialize()` — calls `SpeechToText().initialize()`. `Future<void> listen({required void Function(String) onResult})` — listens with `localeId: 'es_PE'`, `listenMode: ListenMode.confirmation`, calls onResult with `result.recognizedWords` when `result.finalResult` is true. `Future<void> stop()`. `bool get isListening`
- [ ] T014 [P] Create TextToSpeechService in lib/features/voice_assistant/data/services/text_to_speech_service.dart — wraps `flutter_tts` package. Methods: `Future<void> initialize()` — sets language 'es-ES', speechRate 0.45, volume 1.0, pitch 1.0. `Future<void> speak(String text)`. `Future<void> stop()`. Speed 0.45 optimized for adults mayores per R2
- [ ] T015 [P] Create BiometricAuthService in lib/features/voice_assistant/data/services/biometric_auth_service.dart — wraps `local_auth` package. Method: `Future<bool> authenticate({required String reason})` — calls `LocalAuthentication().authenticate(localizedReason: reason, options: AuthenticationOptions(biometricOnly: false, stickyAuth: true))`. `biometricOnly: false` enables PIN fallback per constitution and spec

### Providers

- [ ] T016 [P] Create microphone_consent_provider in lib/features/voice_assistant/presentation/providers/microphone_consent_provider.dart — StateNotifierProvider<MicrophoneConsentNotifier, bool>. Uses SharedPreferences key `microphone_consent_granted`. Methods: `Future<void> load()` reads from prefs (default false). `Future<void> grant()` sets true and saves. `Future<void> deny()` sets false and saves. Provider also creates `sharedPreferencesProvider` (FutureProvider<SharedPreferences>) if not already in project
- [ ] T017 [P] Create speech_provider in lib/features/voice_assistant/presentation/providers/speech_provider.dart — Provider<SpeechRecognitionService> returning the service instance
- [ ] T018 [P] Create tts_provider in lib/features/voice_assistant/presentation/providers/tts_provider.dart — Provider<TextToSpeechService> returning the service instance
- [ ] T019 [P] Create biometric_provider in lib/features/voice_assistant/presentation/providers/biometric_provider.dart — Provider<BiometricAuthService> returning the service instance
- [ ] T020 Create voice_assistant_provider in lib/features/voice_assistant/presentation/providers/voice_assistant_provider.dart — StateNotifierProvider<VoiceAssistantNotifier, VoiceSession?>. Receives IntentParser, OperationPreparer, SpeechRecognitionService, TextToSpeechService, BiometricAuthService via ref. Methods: `startSession()` creates new VoiceSession with status idle. `processInput(String text, InputSource source)` — parses intent, handles each type (checkBalance, payBill, sendMoney, requestHelp, unknown). `startListening()` — checks microphone consent, activates STT. `confirmWithBiometric()` — calls BiometricAuthService, executes operation on success. State transitions follow data-model.md state machine. Between summarizing and awaitingConfirmation: calls `RiskEngine.evaluate()` (002); if alert → navigates to FraudAlertScreen. For requestHelp → delegates to 003 help flow. For unknown → sets assistantMessage with options, speaks via TTS

### Routing

- [ ] T021 Add assistant routes to lib/core/router/app_router.dart — nested under `/easy-mode`: `assistant` → VoiceAssistantScreen, `assistant/consent` → MicrophoneConsentScreen, `assistant/summary` → OperationSummaryScreen (receives OperationSummary via provider). All use `context.push()` to preserve state

### Foundational Tests

- [ ] T022 [P] Unit tests for IntentParser in test/features/voice_assistant/domain/services/intent_parser_test.dart — Dart puro: (1) "quiero pagar la luz" → payBill, serviceName "luz", (2) "pagar agua" → payBill, serviceName "agua", (3) "mándale 50 soles a Valeria" → sendMoney, contactName contains "valeria", amount 50, (4) "envía 100 a mi hija" → sendMoney, contactName contains "mi hija", amount 100, (5) "cuánto tengo" → checkBalance, (6) "mi saldo" → checkBalance, (7) "ayúdame" → requestHelp, (8) "necesito ayuda" → requestHelp, (9) "hazme eso de siempre" → unknown, (10) "cuál es la capital de Francia" → unknown, (11) "" → unknown, (12) "transferir" sin contacto → sendMoney, contactName null, (13) "pagar" sin servicio → payBill, serviceName null, (14) "mándale plata a Valeria" → sendMoney, amount null (missing)
- [ ] T023 [P] Unit tests for OperationPreparer in test/features/voice_assistant/domain/services/operation_preparer_test.dart — mock AccountRepository, BillRepository, ContactRepository: (1) payBill + serviceName "luz" + bill exists → PrepareSuccess with bill.amount from repo, (2) payBill + serviceName "cable" + not found → PrepareBillNotFound("cable"), (3) payBill + serviceName null → PrepareNeedsService with pending bills list, (4) sendMoney + "Valeria" + amount 50 → PrepareSuccess with contact name from repo, (5) sendMoney + contactName null → PrepareNeedsContact, (6) sendMoney + "Valeria" + amount null → PrepareNeedsAmount("Valeria"), (7) checkBalance → PrepareBalanceResult with account.availableBalance from repo, (8) verify amount in PrepareSuccess always comes from repo not parser

**Checkpoint**: Foundation ready — entities, IntentParser and OperationPreparer tested (≥80% coverage), platform wrappers, providers configured, routes added. User story implementation can begin.

---

## Phase 3: US6 — Consentimiento para Usar el Micrófono (Priority: P1)

**Goal**: La primera vez que el usuario intenta usar la voz, la app pide permiso en lenguaje simple. Si rechaza, puede usar el asistente por texto.

**Independent Test**: Abrir el asistente por primera vez → ver pantalla de consentimiento → aceptar o rechazar → verificar comportamiento del micrófono.

### Implementation

- [ ] T024 [US6] Create MicrophoneConsentScreen in lib/features/voice_assistant/presentation/screens/microphone_consent_screen.dart — ConsumerWidget. Shows title from ARB `microphoneConsent_title` ("Permiso para escucharte"), body from `microphoneConsent_body` explaining microphone use in simple language (Ley 29733). Two AccessibleButtons: "Aceptar" → calls `ref.read(microphoneConsentProvider.notifier).grant()`, requests platform microphone permission, pops back. "No, prefiero escribir" → calls `deny()`, pops back. ≥48dp buttons, 8dp separation, Semantics labels, 4.5:1 contrast. SemanticsService.announce title on mount
- [ ] T025 [P] [US6] Widget test for MicrophoneConsentScreen in test/features/voice_assistant/presentation/screens/microphone_consent_screen_test.dart — a11y guidelines (androidTapTargetGuideline, labeledTapTargetGuideline); verify consent explanation text appears; verify accept and decline buttons present; verify tapping decline does not enable microphone

**Checkpoint**: Microphone consent flow works. Complies with Ley 29733 (FR-011). User can proceed by text if declined.

---

## Phase 4: US3 + US4 — Consultar Saldo y Manejo de Intención Desconocida (Priority: P1) 🎯 MVP

**Goal**: Assistant screen with voice and text input. User asks "cuánto tengo" → hears balance. User says something ambiguous → assistant asks clarifying question with available options. Non-monetary flows (no biometric, no fraud check).

**Independent Test**: Say/type "cuánto tengo" → hear balance in TTS, no biometric prompt. Say "hazme eso de siempre" → assistant lists options, never executes anything.

### Implementation

- [ ] T026 [P] [US3] Create AssistantMessage widget in lib/features/voice_assistant/presentation/widgets/assistant_message.dart — StatelessWidget. Displays a text message from the assistant in a styled Card with bodyLarge text. Semantics label with the message content. liveRegion: true for screen reader announcements
- [ ] T027 [P] [US4] Create IntentOptions widget in lib/features/voice_assistant/presentation/widgets/intent_options.dart — StatelessWidget. Shows 4 option buttons (ver saldo, pagar recibo, enviar dinero, pedir ayuda) as AccessibleButtons in a Column. Each calls a callback with the corresponding AssistantIntentType. ≥48dp, 8dp separation, Semantics labels
- [ ] T028 [P] [US3] Create VoiceInputButton widget in lib/features/voice_assistant/presentation/widgets/voice_input_button.dart — ConsumerWidget. FloatingActionButton with Icons.mic, Semantics label from ARB `assistant_mic_label` ("Activar micrófono"), ≥48dp. Shows Icons.mic_off when disabled (no consent). onPressed: if consent not granted → push to `/easy-mode/assistant/consent`. If consent granted → calls `ref.read(voiceAssistantProvider.notifier).startListening()`. Visual feedback: changes icon to Icons.stop when listening, pulsing animation optional. SystemSound.play on tap
- [ ] T029 [P] [US3] Create TextInputField widget in lib/features/voice_assistant/presentation/widgets/text_input_field.dart — StatelessWidget. TextField with Semantics label from ARB `assistant_text_label` ("Escribe tu solicitud"), send button (Icons.send), ≥48dp target. onSubmitted calls callback with text + InputSource.text. Clears field after submit
- [ ] T030 [US3] Create VoiceAssistantScreen in lib/features/voice_assistant/presentation/screens/voice_assistant_screen.dart — ConsumerStatefulWidget. AppBar with title from ARB `assistant_title`. Body: Column with message area (scrollable, shows AssistantMessage widgets for conversation), IntentOptions when status is idle and lastMessage was unknown. Bottom: Row with TextInputField (expanded) and VoiceInputButton. Reads voiceAssistantProvider for session state. On mount: starts new session. When session status changes: if `processing` show loading, if `needsMore` show the question, if `completed` show success. Shows `microphoneConsent_denied` message when consent was denied. SemanticsService.announce on status changes. Route: `/easy-mode/assistant`
- [ ] T031 [US3] Implement balance flow in VoiceAssistantProvider — when ParsedIntent type is `checkBalance`: call `operationPreparer.prepare(intent)` → receive `PrepareBalanceResult(balance)`. Build assistantMessage from ARB `assistant_balance` with formatted amount (from repo). Call TTS to speak the message. Set status to `completed`. NO biometric, NO fraud check (not monetary). Announce via SemanticsService
- [ ] T032 [US4] Implement unknown intent flow in VoiceAssistantProvider — when ParsedIntent type is `unknown`: set assistantMessage from ARB `assistant_unknown` listing available options. Call TTS to speak the message. Set status to `idle` (waiting for new input). When user selects an option from IntentOptions or gives new input → process normally. For out-of-scope requests: use ARB `assistant_outOfScope`
- [ ] T033 [US3] Add "Asistente" button/card to EasyModeHomeScreen — modify lib/features/easy_mode/presentation/screens/easy_mode_home_screen.dart: add a 5th action card for "Asistente" with Icons.record_voice_over, onTap navigates to `/easy-mode/assistant`. ≥48dp, Semantics label

### Tests

- [ ] T034 [P] [US3] Widget test for VoiceAssistantScreen in test/features/voice_assistant/presentation/screens/voice_assistant_screen_test.dart — a11y guidelines (androidTapTargetGuideline, labeledTapTargetGuideline); verify mic button and text field present; verify screen title appears

**Checkpoint**: Assistant screen works. Balance check by voice/text. Unknown intent handled safely (asks, never guesses). MVP for non-monetary flows.

---

## Phase 5: US1 — Pagar Recibo por Voz (Priority: P1)

**Goal**: User says "quiero pagar la luz" → assistant finds the bill, shows summary, reads it aloud, requests biometric confirmation, executes payment. Fraud check applied before biometric.

**Independent Test**: Say "pagar la luz" → see/hear summary with real bill amount → confirm with fingerprint → payment executed. If amount triggers fraud rule → alert screen appears first.

### Implementation

- [ ] T035 [US1] Create OperationSummaryScreen in lib/features/voice_assistant/presentation/screens/operation_summary_screen.dart — ConsumerWidget. Shows operation summary: type, recipient, amount (from OperationSummary, all from repo). Reads summary aloud via TTS on mount. Shows "Confirmar con huella" AccessibleButton (≥48dp, Semantics label). On tap → calls `ref.read(voiceAssistantProvider.notifier).confirmWithBiometric()`. Shows "Cancelar" button → pops back. If biometric fails → shows error message from ARB `assistant_biometricFailed`, allows retry without cancelling. Route: `/easy-mode/assistant/summary`
- [ ] T036 [US1] Implement pay bill flow in VoiceAssistantProvider — when ParsedIntent type is `payBill`: call `operationPreparer.prepare(intent)`. Handle results: `PrepareSuccess` → set operationSummary, call TTS with spokenSummary, set status `summarizing`. After TTS → evaluate `RiskEngine` with OperationContext from summary. If alert → navigate to FraudAlertScreen (002) with continueRoute `/easy-mode/assistant/summary`. If no alert → navigate to OperationSummaryScreen, set status `awaitingConfirmation`. `PrepareNeedsService` → set assistantMessage from ARB `assistant_needsService`, show bill list or ask, status `needsMore`. `PrepareBillNotFound` → set assistantMessage from ARB `assistant_billNotFound` with service name, status `idle`. On biometric success → execute operation via OperationRepository, set status `completed`, TTS speaks `assistant_payDone`
- [ ] T037 [P] [US1] Widget test for OperationSummaryScreen in test/features/voice_assistant/presentation/screens/operation_summary_screen_test.dart — a11y guidelines; verify summary text with amount and recipient appears; verify confirm and cancel buttons present; verify ≥48dp tap targets

**Checkpoint**: Pay bill by voice works end-to-end. Fraud check integrated. Biometric confirmation required. FR-003, FR-004, FR-005, FR-006, FR-010 satisfied.

---

## Phase 6: US2 — Enviar Dinero por Voz (Priority: P1)

**Goal**: User says "mándale 50 soles a mi hija" → assistant resolves contact, prepares transfer with real data, reads summary, biometric confirmation. If contact ambiguous or amount missing → asks.

**Independent Test**: Say "mándale 50 soles a Valeria" → summary shows real contact name and amount from repo → confirm. Say "mándale plata a Valeria" → assistant asks for amount. Say "mándale plata" → assistant asks which contact.

### Implementation

- [ ] T038 [US2] Implement send money flow in VoiceAssistantProvider — when ParsedIntent type is `sendMoney`: call `operationPreparer.prepare(intent)`. Handle results: `PrepareSuccess` → same flow as payBill (TTS → fraud check → biometric → execute). `PrepareNeedsContact` → set assistantMessage from ARB `assistant_needsContact`, show contact list in UI, status `needsMore`. When user selects contact → re-process with updated parameters. `PrepareNeedsAmount` → set assistantMessage from ARB `assistant_needsAmount` with contactName, status `needsMore`. When user provides amount → re-process. On biometric success → execute via OperationRepository, TTS speaks `assistant_sendDone`. Only resolves contacts from ContactRepository (FR edge case: "solo puedo enviar a contactos guardados" message from ARB `assistant_onlyContacts`)
- [ ] T039 [US2] Handle contact disambiguation in VoiceAssistantScreen — when status is `needsMore` and assistantMessage relates to contacts: show contact list as selectable options. When user taps a contact → call provider with selected contact name and re-process intent. When status is `needsMore` for amount: show the amount question and wait for numeric input
- [ ] T040 [P] [US2] Add edge case test for contact resolution in intent_parser_test.dart — (1) "mándale plata a Valeria" → sendMoney, contactName "valeria", amount null, (2) "envía dinero" without contact → sendMoney, contactName null, amount null

**Checkpoint**: Send money by voice works. Contact resolution with disambiguation. Missing data asked for (FR-008, FR-009). Reuses OperationSummaryScreen from US1.

---

## Phase 7: US5 — Entrada por Texto (Priority: P2)

**Goal**: User types instead of speaking. Same parser, same results, same TTS output. Text input always available (even without microphone consent).

**Independent Test**: Type "pagar agua" → same result as saying it. Type "cuánto tengo" → hear balance. Text field always visible regardless of mic consent.

### Implementation

- [ ] T041 [US5] Implement text input flow in VoiceAssistantProvider — `processTextInput(String text)` method: calls `processInput(text, InputSource.text)`. Same parser, same preparer, same fraud check, same biometric. Output always includes TTS (FR: output always includes voice regardless of input channel). Verify TextInputField calls this method on submit
- [ ] T042 [US5] Verify text-only mode when microphone consent denied — in VoiceAssistantScreen: when microphoneConsent is false, mic button is disabled/hidden, text field is primary input. Show message from ARB `microphoneConsent_denied`. All flows still work via text. Add assertion test
- [ ] T043 [US5] Implement speech recognition failure handling — in VoiceAssistantProvider: when SpeechRecognitionService fails to recognize (empty result or error) → set assistantMessage from ARB `assistant_speechFailed` ("No te escuché bien. ¿Puedes repetir o escribirlo?"), speak via TTS, set status `idle`. User can retry voice or switch to text

**Checkpoint**: Text input works identically to voice. Assistant works fully without microphone. FR-001, FR-012 satisfied.

---

## Phase 8: Integration with 003 — Pedir Ayuda (Priority: P1)

**Goal**: When user says "pedir ayuda", assistant delegates to the Help flow from 003-contextual-human-help.

**Independent Test**: Say "necesito ayuda" → navigates to help contact picker screen (003). If there was an operation in progress, context is preserved.

### Implementation

- [ ] T044 [US4] Implement requestHelp intent flow in VoiceAssistantProvider — when ParsedIntent type is `requestHelp`: if session has operationSummary → update operationInProgressProvider (003) with operation data. Navigate to `/easy-mode/help/contact-picker` (003). Do NOT require biometric. Do NOT pass through fraud check. TTS announces transition (e.g., "Te conecto con ayuda")
- [ ] T045 [US4] Add help intent ARB string — add `assistant_helpRedirect` ("Te conecto con ayuda") to lib/core/l10n/arb/app_es.arb. Run `flutter gen-l10n`

**Checkpoint**: Help intent delegates correctly. Context from voice session preserved in help flow. FR-017 satisfied.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates, formatting, full validation against quickstart scenarios

- [ ] T046 [P] Run `flutter analyze`, verify 0 warnings across all voice_assistant and modified files
- [ ] T047 [P] Run `dart format` on all source files in lib/features/voice_assistant/, lib/core/router/, and test/features/voice_assistant/
- [ ] T048 [P] Verify all voice assistant ARB strings are used — no hard-coded Spanish strings in voice_assistant widgets (Principle VII)
- [ ] T049 [P] Verify IntentParser test coverage ≥80% — run `flutter test --coverage test/features/voice_assistant/domain/services/intent_parser_test.dart` and check coverage
- [ ] T050 Run quickstart.md validation scenarios VS-1 through VS-12

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **US6 (Phase 3)**: Depends on Phase 2 — microphone consent gates voice features
- **US3+US4 (Phase 4)**: Depends on Phase 2 + Phase 3 — first assistant screen MVP
- **US1 (Phase 5)**: Depends on Phase 4 — adds monetary operation flow
- **US2 (Phase 6)**: Depends on Phase 4 — adds contact resolution
- **US5 (Phase 7)**: Depends on Phase 4 — verifies text input parity
- **Help (Phase 8)**: Depends on Phase 4 — help intent delegation
- **Polish (Phase 9)**: Depends on all story phases complete

### User Story Dependencies

- **US6 (P1)**: Can start after Phase 2. Creates consent screen.
- **US3+US4 (P1)**: Can start after Phase 3. Creates main assistant screen.
- **US1 (P1)**: Can start after Phase 4. Adds OperationSummaryScreen + pay flow.
- **US2 (P1)**: Can start after Phase 4, in parallel with US1.
- **US5 (P2)**: Can start after Phase 4, in parallel with US1/US2.
- **Help (P1)**: Can start after Phase 4, in parallel with US1/US2/US5.

### Within Each Phase

- Entities before services (T005–T010 before T011–T012)
- Services before providers (T011–T015 before T016–T020)
- Repository before provider (T012 needs 001 repos)
- Providers before screens (T016–T020 before T024–T030)
- Consent screen (T024) before assistant screen (T030)
- OperationSummaryScreen (T035) before pay/send flows
- Tests alongside implementation (T022–T023 after T011–T012)

### Parallel Opportunities

- All entity tasks T005–T010 run in parallel
- T013, T014, T015 (data service wrappers) run in parallel
- T016, T017, T018, T019 (providers) run in parallel
- T026, T027, T028, T029 (widgets) run in parallel
- T022, T023 (foundational tests) run in parallel
- US1, US2, US5, Help can run in parallel after Phase 4

---

## Parallel Example: Phase 2 — Domain Layer

```bash
# Launch all entities in parallel:
Task T005: "Create AssistantIntentType + InputSource enums"
Task T006: "Create IntentParameters entity"
Task T007: "Create ParsedIntent entity"
Task T008: "Create OperationSummary entity"
Task T009: "Create VoiceSession + VoiceSessionStatus"
Task T010: "Create PrepareResult sealed class"

# Then services (depends on T005–T010):
Task T011: "Create IntentParser service"
Task T012: "Create OperationPreparer service"

# Parallel: platform wrappers (no deps on entities):
Task T013: "Create SpeechRecognitionService"
Task T014: "Create TextToSpeechService"
Task T015: "Create BiometricAuthService"
```

---

## Implementation Strategy

### MVP First (US6 + US3 + US4 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: US6 (Microphone consent)
4. Complete Phase 4: US3+US4 (Balance + Unknown = basic assistant)
5. **STOP and VALIDATE**: Assistant screen opens. "Cuánto tengo" → hears balance. Ambiguous phrase → asks. Consent works.
6. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundational → IntentParser tested, services ready
2. US6 → Consent flow → Demo (legal compliance)
3. US3+US4 → Non-monetary assistant working → Demo (MVP!)
4. US1 → Pay bill by voice with fraud + biometric → Demo
5. US2 → Send money by voice with contact resolution → Demo
6. US5 → Text input verified → Demo
7. Help integration → "Pedir ayuda" delegates to 003 → Demo (all stories complete)
8. Polish → Quality gates, quickstart validation

### Parallel Team Strategy

With multiple developers after Phase 2:
- Developer A: US6 → US3+US4 (consent + assistant screen)
- After Phase 4 complete:
  - Developer A: US1 (pay bill)
  - Developer B: US2 (send money)
  - Developer C: US5 (text input) + Help integration

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Plain Dart entities with manual copyWith/==/hashCode — NOT freezed (removed from project)
- Manual Riverpod providers — NOT codegen (riverpod_generator removed from project)
- Constitution compliance: widget tests with a11y guidelines, domain tests ≥80% coverage
- All UI text in ARB — no hard-coded Spanish strings (Principle VII)
- Frases ≤ 15 palabras, sin jerga bancaria, tono empático (Principle VI)
- 3 new dependencies: speech_to_text (MIT), flutter_tts (MIT), local_auth (BSD-3-Clause) — all approved licenses
- IntentParser is Dart puro, deterministic, keyword-based (no cloud AI) per R4
- OperationPreparer is Dart puro, receives repos as deps, always uses repo data
- Security invariant: montos and nombres ALWAYS from repository, NEVER from parser text
- Audio not stored (FR-013). Microphone consent per Ley 29733 (FR-011)
- Biometric with PIN fallback (local_auth biometricOnly: false)
- Connections to 001 (repos), 002 (RiskEngine), 003 (help flow) via existing providers
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
