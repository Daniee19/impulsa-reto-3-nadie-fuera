# Tasks: Modo Fácil

**Input**: Design documents from `/specs/001-easy-mode/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/, research.md, quickstart.md

**Organization**: Tasks grouped by user story. Tests included per constitution (Principle V: domain ≥80% coverage, widget tests with a11y guidelines per screen, integration tests per critical flow).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Project scaffolding, dependencies, linter migration, localization config

- [ ] T001 Create project directory structure per plan.md: `lib/core/{theme,router,l10n/arb,a11y,presentation/widgets}`, `lib/features/easy_mode/{domain/{entities,repositories},data/repositories,presentation/{providers,screens,widgets}}`, `test/core/theme/`, `test/features/easy_mode/{domain/entities,presentation/screens}`, `integration_test/`
- [ ] T002 [P] Update pubspec.yaml — add dependencies: `flutter_riverpod`, `riverpod_annotation`, `go_router`, `freezed_annotation`, `json_annotation`, `google_fonts`, `intl`; add dev_dependencies: `freezed`, `build_runner`, `riverpod_generator`, `json_serializable`, `very_good_analysis`, `accessibility_tools`; remove `flutter_lints`
- [ ] T003 [P] Update analysis_options.yaml — change include to `package:very_good_analysis/analysis_options.yaml`, remove flutter_lints reference
- [ ] T004 [P] Configure l10n: create `l10n.yaml` (arb-dir: `lib/core/l10n/arb`, template-arb-file: `app_es.arb`, output-localization-file: `app_localizations.dart`); set `generate: true` in pubspec.yaml flutter section; create `lib/core/l10n/arb/app_es.arb` with all Modo Fácil UI strings (key convention: `easyMode_screenName_element`); create `lib/core/l10n/l10n.dart` export

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure, domain entities, repository layer, providers, routing. MUST be complete before ANY user story.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Core Infrastructure

- [ ] T005 Create accessible theme in lib/core/theme/app_theme.dart — Atkinson Hyperlegible via google_fonts; body text ≥18sp, monetary amounts ≥28sp; palette: primary #1A3C6E (>7:1 on white), error #B3261E (>5:1), surface #FFFFFF, onSurface #1C1B1F, secondary #2E7D32; MaterialTapTargetSize.padded; does NOT cap MediaQuery.textScalerOf
- [ ] T006 [P] Create a11y helpers in lib/core/a11y/a11y_helpers.dart — SemanticsService.announce wrapper for Spanish, a11y constants (minTapTarget: 48dp, minSeparation: 8dp)
- [ ] T007 [P] Create AccessibleButton widget in lib/core/presentation/widgets/accessible_button.dart — area ≥48×48dp with 8dp separation, Semantics label in Spanish, tooltip, high contrast. Params: text, icon, onPressed
- [ ] T008 [P] Create ConfirmationScreen widget in lib/core/presentation/widgets/confirmation_screen.dart — scaffold showing recipient name + amount in ≥28sp, "Confirmar" button + "Volver" button (both ≥48dp), SemanticsService.announce on load, respects textScaler 2.0 without overflow
- [ ] T009 [P] Create ErrorMessage widget in lib/core/presentation/widgets/error_message.dart — plain-language error (≤15 words, no jargon) with suggested action, SemanticsService.announce, high contrast

### Domain Entities (all Dart puro, freezed, no Flutter imports)

- [ ] T010 [P] Create Account entity (freezed) in lib/features/easy_mode/domain/entities/account.dart — fields: id (String, non-empty), holderName (String, non-empty), maskedNumber (String, format "****NNNN"), availableBalance (double, ≥0), currency (String, always "PEN")
- [ ] T011 [P] Create Bill entity + BillStatus enum (freezed) in lib/features/easy_mode/domain/entities/bill.dart — fields: id (String, non-empty), serviceName (String, non-empty, ≤15 chars), providerName (String, non-empty), amount (double, >0), dueDate (DateTime, non-null), status (BillStatus: pending | paid)
- [ ] T012 [P] Create SavedContact entity (freezed) in lib/features/easy_mode/domain/entities/saved_contact.dart — fields: id (String, non-empty), name (String, non-empty), initial (String, 1 char), maskedAccount (String, format "****NNNN")
- [ ] T013 [P] Create Operation entity + enums (freezed) in lib/features/easy_mode/domain/entities/operation.dart — fields: id (String, non-empty), type (OperationType: payment | transfer), recipientName (String, non-empty), amount (double, >0), date (DateTime, non-null), status (OperationStatus: success | failed), description (String, non-empty). No state transitions — created with final status.

### Abstract Repository Interfaces (domain layer)

- [ ] T014 [P] Create abstract AccountRepository in lib/features/easy_mode/domain/repositories/account_repository.dart — `Future<Account> getAccount()`, `Future<Account> updateBalance(String accountId, double newBalance)` throws if newBalance < 0
- [ ] T015 [P] Create abstract BillRepository in lib/features/easy_mode/domain/repositories/bill_repository.dart — `Future<List<Bill>> getBills({BillStatus? status})`, `Future<Bill> getBillById(String billId)`, `Future<Bill> payBill(String billId)` throws if already paid
- [ ] T016 [P] Create abstract ContactRepository in lib/features/easy_mode/domain/repositories/contact_repository.dart — `Future<List<SavedContact>> getContacts()`, `Future<SavedContact> getContactById(String contactId)`. Read-only in this feature.
- [ ] T017 [P] Create abstract OperationRepository in lib/features/easy_mode/domain/repositories/operation_repository.dart — `Future<Operation> createOperation({required OperationType type, required String recipientName, required double amount, required String description})` generates id+date automatically, `Future<List<Operation>> getOperations()` ordered by date desc

### Mock Repository Implementations (data layer)

- [ ] T018 [P] Implement MockAccountRepository in lib/features/easy_mode/data/repositories/mock_account_repository.dart — mock data: Rosa Martínez, ****5678, S/ 2,450.00, PEN. Future.delayed(300ms) simulated latency. updateBalance mutates in-memory state.
- [ ] T019 [P] Implement MockBillRepository in lib/features/easy_mode/data/repositories/mock_bill_repository.dart — mock data: Luz/Enel S/85.50 vence 2026-10-15, Agua/Sedapal S/42.00 vence 2026-10-20, Gas/Cálidda S/63.20 vence 2026-10-25. payBill changes status to paid in-memory. 300ms latency.
- [ ] T020 [P] Implement MockContactRepository in lib/features/easy_mode/data/repositories/mock_contact_repository.dart — mock data: Valeria Martínez V ****9012, Carlos López C ****3456, María Sánchez M ****7890. 300ms latency.
- [ ] T021 [P] Implement MockOperationRepository in lib/features/easy_mode/data/repositories/mock_operation_repository.dart — empty list at start, createOperation always returns status: success, generates UUID id and DateTime.now() date. 300ms latency.

### Providers & Routing

- [ ] T022 Create Riverpod providers (@riverpod codegen) for all repositories in lib/features/easy_mode/presentation/providers/ — account_provider.dart, bill_provider.dart, contact_provider.dart, operation_provider.dart. Each exposes abstract interface, overrideable with mock in ProviderScope.
- [ ] T023 Configure go_router in lib/core/router/app_router.dart — routes: `/easy-mode` → EasyModeHomeScreen, `/easy-mode/balance` → BalanceScreen, `/easy-mode/pay-bill` → PayBillScreen, `/easy-mode/pay-bill/:billId/confirm` → PayBillConfirmScreen, `/easy-mode/send-money` → SendMoneyScreen, `/easy-mode/send-money/confirm` → SendMoneyConfirmScreen, `/easy-mode/help` → HelpScreen, `/easy-mode/success` → OperationSuccessScreen
- [ ] T024 Create app.dart in lib/app.dart — MaterialApp.router with ProviderScope, appTheme, l10n (locale: es), override repo providers with mock implementations
- [ ] T025 Update main.dart in lib/main.dart — runApp entry point wrapping App in ProviderScope
- [ ] T026 Run `dart run build_runner build --delete-conflicting-outputs` for freezed + riverpod codegen, verify no errors

### Foundational Tests

- [ ] T027 [P] Unit tests for domain entities in test/features/easy_mode/domain/entities/ — verify freezed equality, copyWith, validation constraints (amount >0, balance ≥0, BillStatus transitions)
- [ ] T028 [P] Unit test for app_theme.dart in test/core/theme/app_theme_test.dart — verify body text ≥18sp, display text ≥28sp, primary contrast ratio

**Checkpoint**: Foundation ready — user story implementation can now begin in parallel

---

## Phase 3: User Story 1 + User Story 5 — Pantalla Principal + Ver Saldo (Priority: P1) 🎯 MVP

**Goal**: Rosa abre la app, ve 4 acciones grandes, toca "Ver mi saldo" y ve su saldo en números grandes. Luis navega la misma pantalla con TalkBack sin obstáculos.

**Independent Test**: Abrir Modo Fácil → 4 botones visibles y navegables por TalkBack. Tocar "Ver mi saldo" → saldo en ≥28sp con nombre de cuenta. TalkBack lee todo en orden lógico. Sin desbordamiento a textScaler 2.0.

### Implementation

- [ ] T029 [US1] Create ActionCard widget in lib/features/easy_mode/presentation/widgets/action_card.dart — large card for home screen actions: icon + text, ≥48×48dp tap target, Semantics label, high contrast, responsive to textScaler 2.0
- [ ] T030 [US1] Create EasyModeHomeScreen in lib/features/easy_mode/presentation/screens/easy_mode_home_screen.dart — exactly 4 ActionCard buttons: "Ver mi saldo" (icon: account_balance_wallet), "Pagar recibo" (icon: receipt_long), "Enviar dinero" (icon: send), "Pedir ayuda" (icon: help). Grid/column layout, max 4 actions per screen (FR-001). Semantics reading order: saldo → pagar → enviar → ayuda (US5). No unlabeled elements.
- [ ] T031 [US1] Create BalanceScreen in lib/features/easy_mode/presentation/screens/balance_screen.dart — watches accountProvider; shows availableBalance in ≥28sp with currency "S/", holderName, maskedNumber; Semantics labels for TalkBack reading in order (nombre → saldo → número de cuenta); handles loading state (AsyncValue); no overflow at textScaler 2.0; back button returns to home

### Tests

- [ ] T032 [P] [US1] Widget test for EasyModeHomeScreen in test/features/easy_mode/presentation/screens/easy_mode_home_screen_test.dart — a11y guidelines (androidTapTargetGuideline, labeledTapTargetGuideline, textContrastGuideline); verifies 4 buttons present; no overflow at textScaler 2.0; Semantics order (US5)
- [ ] T033 [P] [US1] Widget test for BalanceScreen in test/features/easy_mode/presentation/screens/balance_screen_test.dart — a11y guidelines; verifies saldo display ≥28sp; TalkBack reads saldo + account name; no overflow at textScaler 2.0; saldo S/ 0.00 displays without alarm (edge case)

**Checkpoint**: User can open Modo Fácil and check balance. TalkBack fully functional. MVP deliverable.

---

## Phase 4: User Story 2 — Pagar Recibo (Priority: P1)

**Goal**: Rosa toca "Pagar recibo", selecciona de una lista corta, confirma, y recibe mensaje de éxito. Máximo 3 pasos. "Volver" preserva datos.

**Independent Test**: Pagar recibo de Luz → confirmación con servicio+monto → éxito → recibo desaparece de la lista de pendientes. Back preserva selección. Lista vacía muestra mensaje. TalkBack anuncia "Pago realizado".

### Implementation

- [ ] T034 [US2] Create PayBillScreen in lib/features/easy_mode/presentation/screens/pay_bill_screen.dart — watches billProvider (status: pending); list of bills showing serviceName + amount in large text (≥18sp); tap selects bill and navigates to confirm; empty state: "No tienes recibos pendientes" + back button (edge case). Semantics labels per item.
- [ ] T035 [US2] Create PayBillConfirmScreen in lib/features/easy_mode/presentation/screens/pay_bill_confirm_screen.dart — receives billId from route param; shows serviceName, providerName, amount (≥28sp); uses ConfirmationScreen widget; "Confirmar" calls pay flow logic; "Volver" returns to list preserving state (FR-010). Reads bill data from billProvider.
- [ ] T036 [US2] Create OperationSuccessScreen in lib/features/easy_mode/presentation/screens/operation_success_screen.dart — shows success/failure message with operation summary (type, recipient, amount); SemanticsService.announce "Pago realizado" for payments or "Dinero enviado" for transfers (FR-015); button to return home. Receives operation data via route extra.
- [ ] T037 [US2] Implement pay bill flow logic — on confirm: (1) accountRepository.updateBalance(currentBalance - bill.amount), (2) billRepository.payBill(billId), (3) operationRepository.createOperation(type: payment, recipientName: bill.serviceName, amount: bill.amount). On success → navigate to /easy-mode/success. On error → show ErrorMessage "Algo salió mal. Tu dinero no se movió." Balance unchanged on error.

### Tests

- [ ] T038 [P] [US2] Widget test for pay bill flow in test/features/easy_mode/presentation/screens/pay_bill_flow_test.dart — a11y guidelines; confirm screen shows correct service + amount; back preserves state; empty list shows message; success screen announces "Pago realizado"

**Checkpoint**: User can pay bills end-to-end. US1 + US2 = functional MVP for demo.

---

## Phase 5: User Story 3 — Enviar Dinero a Contacto Guardado (Priority: P1)

**Goal**: Rosa selecciona un contacto, ingresa monto, confirma, y recibe mensaje de éxito. Máximo 3 pasos. Validación de saldo insuficiente en lenguaje simple.

**Independent Test**: Enviar S/100 a Valeria → confirmación con nombre+monto+saldo restante → éxito. Monto > saldo → "No tienes suficiente dinero". Sin contactos → mensaje. TalkBack anuncia "Dinero enviado".

### Implementation

- [ ] T039 [US3] Create SendMoneyScreen in lib/features/easy_mode/presentation/screens/send_money_screen.dart — watches contactProvider; list of contacts showing name + initial (large avatar) in large text; select contact → shows amount input (≥28sp, numeric keyboard); validates amount > 0; validates amount ≤ availableBalance → if exceeds: "No tienes suficiente dinero. Tu saldo es S/ {saldo}" (FR-011, US3-AS4, no jargon); empty contacts: "No tienes contactos guardados. Pide ayuda para agregar uno." (edge case). Semantics labels.
- [ ] T040 [US3] Create SendMoneyConfirmScreen in lib/features/easy_mode/presentation/screens/send_money_confirm_screen.dart — shows contact name, amount (≥28sp), remaining balance after transfer; uses ConfirmationScreen widget; "Confirmar" calls send flow; "Volver" returns to input preserving contact + amount (FR-010). Receives contact + amount via route extra.
- [ ] T041 [US3] Implement send money flow logic — on confirm: (1) accountRepository.updateBalance(currentBalance - amount), (2) operationRepository.createOperation(type: transfer, recipientName: contact.name, amount: amount). On success → navigate to /easy-mode/success. On error → ErrorMessage, balance unchanged.

### Tests

- [ ] T042 [P] [US3] Widget test for send money flow in test/features/easy_mode/presentation/screens/send_money_flow_test.dart — a11y guidelines; insufficient balance shows plain-language error with current balance; confirm shows correct contact + amount + remaining; empty contacts shows message; success announces "Dinero enviado"

**Checkpoint**: All 3 monetary actions work (balance, pay, send). Full P1 scope complete.

---

## Phase 6: User Story 4 — Pedir Ayuda (Priority: P2)

**Goal**: Rosa toca "Pedir ayuda" y ve opciones claras de contacto simuladas. Luis navega las opciones con TalkBack.

**Independent Test**: Tocar "Pedir ayuda" → opciones de llamada y chat con texto grande e iconos → seleccionar una → mensaje de confirmación simulado. TalkBack anuncia cada opción.

### Implementation

- [ ] T043 [US4] Create HelpScreen in lib/features/easy_mode/presentation/screens/help_screen.dart — two AccessibleButton options: "Llamar a un asesor" (icon: phone), "Escribir a un asesor" (icon: chat). Large text + descriptive icons. On tap → simulated confirmation: "Te estamos conectando con alguien que te va a ayudar" (FR-012 ≤15 words). Semantics labels: "Llamar a un asesor", "Escribir a un asesor". All elements ≥48×48dp.

### Tests

- [ ] T044 [P] [US4] Widget test for HelpScreen in test/features/easy_mode/presentation/screens/help_screen_test.dart — a11y guidelines; both options present and labeled; confirmation message appears on tap

**Checkpoint**: All 4 actions of Modo Fácil are functional: saldo, pagar, enviar, ayuda.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates, integration tests, full validation

- [ ] T045 [P] Run `flutter analyze`, verify 0 warnings
- [ ] T046 [P] Run `dart format` on all source files
- [ ] T047 [P] Verify all ARB strings are complete — every user-facing string in widgets uses l10n, no hard-coded Spanish strings
- [ ] T048 Integration test: ver saldo flow in integration_test/easy_mode_flows_test.dart — open app → tap "Ver mi saldo" → verify saldo displayed
- [ ] T049 [P] Integration test: pagar recibo flow in integration_test/easy_mode_flows_test.dart — home → "Pagar recibo" → select Luz → confirm → success
- [ ] T050 [P] Integration test: enviar dinero flow in integration_test/easy_mode_flows_test.dart — home → "Enviar dinero" → select Valeria → amount 100 → confirm → success
- [ ] T051 Run quickstart.md validation scenarios VS-1 through VS-7

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **US1+US5 (Phase 3)**: Depends on Phase 2 — first deliverable MVP
- **US2 (Phase 4)**: Depends on Phase 2. OperationSuccessScreen (T036) created here, reused by US3.
- **US3 (Phase 5)**: Depends on Phase 2. Reuses OperationSuccessScreen from Phase 4.
- **US4 (Phase 6)**: Depends on Phase 2. Independent of US2/US3.
- **Polish (Phase 7)**: Depends on all story phases being complete

### User Story Dependencies

- **US1+US5 (P1)**: Can start after Phase 2 — no dependencies on other stories
- **US2 (P1)**: Can start after Phase 2 — creates OperationSuccessScreen shared with US3
- **US3 (P1)**: Can start after Phase 2 — reuses OperationSuccessScreen from US2 (or create if US2 not yet done, adjusting T036 to whichever story runs first)
- **US4 (P2)**: Can start after Phase 2 — fully independent

### Within Each User Story

- Models before services
- Services/providers before screens
- Core implementation before integration
- Widget tests alongside or after their screens

### Parallel Opportunities

- All Setup tasks T002-T004 run in parallel
- All entity tasks T010-T013 run in parallel
- All abstract repo tasks T014-T017 run in parallel
- All mock repo tasks T018-T021 run in parallel
- All foundational test tasks T027-T028 run in parallel
- US1+US5, US2, US3, US4 can run in parallel after Phase 2 (if team capacity allows; US3 depends on OperationSuccessScreen from US2 unless created independently)
- Widget tests within each story run in parallel with each other

---

## Parallel Example: Phase 2 — Domain Layer

```bash
# Launch all entities in parallel:
Task T010: "Create Account entity in lib/features/easy_mode/domain/entities/account.dart"
Task T011: "Create Bill entity in lib/features/easy_mode/domain/entities/bill.dart"
Task T012: "Create SavedContact entity in lib/features/easy_mode/domain/entities/saved_contact.dart"
Task T013: "Create Operation entity in lib/features/easy_mode/domain/entities/operation.dart"

# Then all abstract repos in parallel:
Task T014: "Create abstract AccountRepository"
Task T015: "Create abstract BillRepository"
Task T016: "Create abstract ContactRepository"
Task T017: "Create abstract OperationRepository"

# Then all mock repos in parallel:
Task T018: "Implement MockAccountRepository"
Task T019: "Implement MockBillRepository"
Task T020: "Implement MockContactRepository"
Task T021: "Implement MockOperationRepository"
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: US1+US5 (pantalla principal + ver saldo)
4. **STOP and VALIDATE**: 4 buttons visible, saldo works, TalkBack works
5. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. US1+US5 → Pantalla principal + ver saldo → Demo (MVP!)
3. US2 → Pagar recibo end-to-end → Demo
4. US3 → Enviar dinero end-to-end → Demo
5. US4 → Pedir ayuda → Demo (all 4 actions complete)
6. Polish → Quality gates, integration tests

### Parallel Team Strategy

With multiple developers after Phase 2:
- Developer A: US1+US5 (home + balance)
- Developer B: US2 (pay bill + success screen)
- Developer C: US3 (send money — creates own success screen or waits for B)
- Developer D: US4 (help — fully independent)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Constitution compliance: every screen has widget test with a11y guidelines; domain tests ≥80% coverage
- All UI text must be in ARB — no hard-coded Spanish strings in widgets (Principle VII)
- Frases ≤ 15 palabras, sin jerga bancaria ("token", "validar dispositivo", "autenticación" prohibidos)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
