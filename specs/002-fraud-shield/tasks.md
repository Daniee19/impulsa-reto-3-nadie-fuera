# Tasks: Escudo Antifraude

**Input**: Design documents from `/specs/002-fraud-shield/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/risk-engine-contract.md, research.md, quickstart.md

**Organization**: Tasks grouped by user story. Tests included per constitution (Principle V: domain ≥80% coverage, widget tests with a11y guidelines per screen).

**Note**: This project uses plain Dart entities with manual `copyWith`/`==`/`hashCode` (not freezed) and manual Riverpod providers (not codegen), consistent with 001-easy-mode implementation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Directory structure and localization strings for the fraud shield feature

- [X] T001 Create feature directory structure per plan.md: `lib/features/fraud_shield/{domain/{entities,services,repositories},data/repositories,presentation/{providers,screens,widgets}}`, `test/features/fraud_shield/{domain/services,presentation/screens}`
- [X] T002 [P] Add fraud shield ARB strings to lib/core/l10n/arb/app_es.arb — keys: `fraudShield_alert_unusualAmount` ("Este pago es mucho más alto de lo que sueles pagar."), `fraudShield_alert_newRecipient` ("Nunca le has enviado dinero a esta persona."), `fraudShield_alert_highFrequency` ("Has hecho varios pagos seguidos."), `fraudShield_alert_unusualTime` ("Estás haciendo un pago a una hora poco habitual."), `fraudShield_alert_closing` ("Solo queremos asegurarnos. ¿Qué quieres hacer?"), `fraudShield_action_cancel` ("Cancelar"), `fraudShield_action_continue` ("Continuar de todos modos"), `fraudShield_action_consultTrusted` ("Consultar a {name}"), `fraudShield_notification_sent` ("Le avisamos a {name}. Puedes esperarle o continuar."), `fraudShield_alert_title` ("Un momento"). Run `flutter gen-l10n` after adding strings.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entities, risk engine, mock history data, providers, and routing. MUST be complete before ANY user story.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Domain Entities (all plain Dart, @immutable from meta, manual copyWith/==/hashCode, no Flutter imports)

- [X] T003 [P] Create RiskRule enum in lib/features/fraud_shield/domain/entities/risk_rule.dart — values: `unusualAmount`, `newRecipient`, `highFrequency`, `unusualTime`. Pure Dart, no state, no persistence.
- [X] T004 [P] Create RiskThresholds entity in lib/features/fraud_shield/domain/entities/risk_thresholds.dart — @immutable, const constructor with defaults. Fields: `amountMultiplier` (double, default 2.0, must be >1.0), `historyWindow` (int, default 10, must be >0), `maxOpsInWindow` (int, default 3, must be >0), `windowMinutes` (int, default 10, must be >0), `safeHourStart` (int, default 7, must be ≥0 and < safeHourEnd), `safeHourEnd` (int, default 22, must be > safeHourStart and ≤24). Manual copyWith for test overrides.
- [X] T005 [P] Create OperationContext entity in lib/features/fraud_shield/domain/entities/operation_context.dart — @immutable. Fields: `type` (OperationType from lib/features/easy_mode/domain/entities/operation.dart), `amount` (double, must be >0), `recipientId` (String, non-empty), `recipientName` (String, non-empty), `timestamp` (DateTime, non-null). Pure Dart, imports OperationType from 001.
- [X] T006 [P] Create RiskAlert entity in lib/features/fraud_shield/domain/entities/risk_alert.dart — @immutable. Fields: `triggeredRules` (Set<RiskRule>, must be non-empty), `operation` (OperationContext, non-null). Computed getter: `riskLevel` returns `RiskLevel.high` if triggeredRules.length > 1, else `RiskLevel.medium`. Enum `RiskLevel { medium, high }` in same file. No state transitions, no persistence.

### Risk Engine (Dart puro, sin dependencia de Flutter)

- [X] T007 Create RiskEngine in lib/features/fraud_shield/domain/services/risk_engine.dart — Dart puro, MUST NOT import Flutter. Method: `RiskAlert? evaluate({required OperationContext operation, required List<Operation> history, RiskThresholds thresholds = const RiskThresholds()})`. Evaluates 4 rules in order: (1) `unusualAmount`: calculate average amount of last `thresholds.historyWindow` operations of same type in history; if `operation.amount > average * thresholds.amountMultiplier` → triggered; if no history of same type → do NOT trigger (benefit of the doubt per R3). (2) `newRecipient`: check if `operation.recipientName` appears in any historical operation's recipientName; if not found → triggered; only for transfers (`type == OperationType.transfer`), skip for payments. (3) `highFrequency`: count operations in history with date within last `thresholds.windowMinutes` minutes of `operation.timestamp`; if count >= `thresholds.maxOpsInWindow` → triggered. (4) `unusualTime`: if `operation.timestamp.hour < thresholds.safeHourStart` OR `>= thresholds.safeHourEnd` → triggered. Returns null if no rules triggered. Returns RiskAlert with all triggered rules if ≥1 triggered. Deterministic, stateless, no side effects.

### Data Layer (mock history)

- [X] T008 Pre-seed MockOperationRepository in lib/features/easy_mode/data/repositories/mock_operation_repository.dart with historical operations for risk engine baseline — add 15 preconfigured Operation objects to the initial `_operations` list: 10 payments (services: Luz/Enel, Agua/Sedapal, Gas/Cálidda rotating; amounts between S/ 40.00 and S/ 130.00; dates spread over last 30 days; hours between 8:00–20:00; all status: success), 5 transfers (recipients matching 001 contact names: Valeria Martínez, Carlos López, María Sánchez; amounts S/ 50.00–S/ 200.00; dates last 30 days; hours 8:00–20:00; status: success). This establishes the baseline against which risk rules evaluate anomalies.

### Trusted Person Stub (006 dependency — replace when 006-trusted-person is implemented)

- [X] T009 [P] Create TrustedPerson stub entity in lib/features/fraud_shield/domain/entities/trusted_person.dart — @immutable, minimal stub. Fields: `name` (String, non-empty), `relationship` (String, non-empty). Enum `TrustedPermission { securityAlerts }`. Method: `bool hasPermission(TrustedPermission permission)` returns true for all permissions in this stub.
- [X] T010 [P] Create trusted_person_provider stub in lib/features/fraud_shield/presentation/providers/trusted_person_provider.dart — manual Riverpod `Provider<TrustedPerson?>`. Returns `TrustedPerson(name: 'Valeria', relationship: 'Hija')` for demo. Overridable to null for edge case testing (no trusted person → 2 options only per FR-005).

### Providers & Routing

- [X] T011 [P] Create fraud_alert_provider in lib/features/fraud_shield/presentation/providers/fraud_alert_provider.dart — manual Riverpod StateNotifierProvider. State class `FraudAlertState` (@immutable): fields `alert` (RiskAlert), `continueRoute` (String — path to the confirm screen of 001), `continueExtra` (Object? — route extra for confirm screen). StateNotifier `FraudAlertNotifier` methods: `setAlert(RiskAlert alert, String continueRoute, [Object? continueExtra])`, `clear()`. Provider: `StateNotifierProvider<FraudAlertNotifier, FraudAlertState?>`.
- [X] T012 Add route `/easy-mode/fraud-alert` → FraudAlertScreen in lib/core/router/app_router.dart — nested under the existing `/easy-mode` route group
- [X] T013 Register trusted_person_provider in lib/main.dart ProviderScope overrides (if needed for mock override)

### Foundational Tests

- [X] T014 [P] Unit tests for RiskEngine in test/features/fraud_shield/domain/services/risk_engine_test.dart — exhaustive Dart-puro tests (no Flutter, no WidgetTester): (1) normal amount → null, (2) amount > 2x average of same-type history → alert with unusualAmount, (3) high amount but no history of same type → null (benefit of the doubt), (4) transfer to new recipient → alert with newRecipient, (5) transfer to known recipient → null, (6) payment to new service name → null (newRecipient only for transfers), (7) 2 historical ops in 10 min + attempting 3rd → null (count 2 < maxOpsInWindow 3), (8) 3 historical ops in 10 min + attempting 4th → alert with highFrequency, (9) operation at 3:00 AM → alert with unusualTime, (10) operation at 9:00 AM → null, (11) high amount + new recipient → alert with {unusualAmount, newRecipient}, (12) all 4 rules triggered → alert with 4 rules, (13) custom thresholds via copyWith → respects overridden values

**Checkpoint**: Foundation ready — entities, engine tested, providers configured, route added. User story implementation can begin.

---

## Phase 3: US1 + US2 — Alerta por Monto Inusual + Destinatario Nuevo (Priority: P1) 🎯 MVP

**Goal**: Toda operación monetaria pasa por el motor de reglas antes de la confirmación. Si hay riesgo, se muestra pantalla de pausa con mensaje empático y 2–3 opciones.

**Independent Test**: Pagar recibo con monto alto (>2x promedio) → pantalla de pausa aparece antes de confirmación. Enviar dinero a destinatario nuevo → pantalla de pausa. "Cancelar" vuelve sin perder datos. "Continuar" avanza a confirmación normal. "Consultar a Valeria" muestra mensaje de notificación simulada. TalkBack anuncia la alerta al aparecer.

### Implementation

- [X] T015 [P] [US1] Create RiskMessageCard widget in lib/features/fraud_shield/presentation/widgets/risk_message_card.dart — receives `Set<RiskRule>` triggered rules. Builds message from ARB strings: single rule → rule-specific message (e.g. `fraudShield_alert_unusualAmount`); 2+ rules → concatenated with " y " connector. Always appends closing: `fraudShield_alert_closing`. Text ≥18sp, contrast 4.5:1. Icon: warning_amber, size 64, color: theme.colorScheme.error. Semantics label covers full combined message for TalkBack.
- [X] T016 [US1] Create FraudAlertScreen in lib/features/fraud_shield/presentation/screens/fraud_alert_screen.dart — ConsumerStatefulWidget. Reads FraudAlertState from fraudAlertProvider. Displays: AppBar with title `fraudShield_alert_title`, RiskMessageCard with triggered rules, then AccessibleButtons: (1) `fraudShield_action_cancel` (icon: close) → `context.pop()` returns to previous screen with data preserved, (2) `fraudShield_action_continue` (icon: arrow_forward) → `context.go(state.continueRoute, extra: state.continueExtra)` + clear provider, advances to confirm screen of 001. (3) Conditional: if `ref.watch(trustedPersonProvider)` is non-null and `hasPermission(TrustedPermission.securityAlerts)` → `fraudShield_action_consultTrusted` with name (icon: person) → show SnackBar with `fraudShield_notification_sent`, then remain on screen with options 1 and 2. SemanticsService.announce alert title on first frame via A11yHelpers (FR-011). All buttons ≥48dp with 8dp separation. WCAG 4.5:1 contrast.
- [X] T017 [US1] Integrate risk evaluation into pay bill flow — modify lib/features/easy_mode/presentation/screens/pay_bill_screen.dart: when user taps a bill to pay, before navigating to `/easy-mode/pay-bill/${billId}/confirm`, build `OperationContext(type: OperationType.payment, amount: bill.amount, recipientId: bill.id, recipientName: '${bill.serviceName} - ${bill.providerName}', timestamp: DateTime.now())`. Get history via `ref.read(operationRepositoryProvider).getOperations()`. Call `RiskEngine().evaluate(operation: context, history: history)`. If alert != null → `ref.read(fraudAlertProvider.notifier).setAlert(alert, '/easy-mode/pay-bill/${billId}/confirm')` then `context.push('/easy-mode/fraud-alert')`. If null → navigate to confirm as before.
- [X] T018 [US2] Integrate risk evaluation into send money flow — modify lib/features/easy_mode/presentation/screens/send_money_screen.dart: when user confirms amount entry, before navigating to `/easy-mode/send-money/confirm`, build `OperationContext(type: OperationType.transfer, amount: enteredAmount, recipientId: contact.id, recipientName: contact.name, timestamp: DateTime.now())`. Get history. Call `RiskEngine().evaluate(...)`. If alert != null → `setAlert(alert, '/easy-mode/send-money/confirm', SendMoneyConfirmExtra(...))` then `context.push('/easy-mode/fraud-alert')`. If null → navigate to confirm as before.

### Tests

- [X] T019 [P] [US1] Widget test for FraudAlertScreen in test/features/fraud_shield/presentation/screens/fraud_alert_screen_test.dart — a11y guidelines (androidTapTargetGuideline, labeledTapTargetGuideline, textContrastGuideline); verify 3 options when trustedPersonProvider has value; verify 2 options when trustedPersonProvider is null; verify "Cancelar" triggers pop; verify SemanticsService.announce on mount; no overflow at textScaler 2.0
- [X] T020 [US1] Run `flutter gen-l10n` and `flutter analyze` — verify 0 errors after all integration changes

**Checkpoint**: Risk engine intercepts both pay and send flows. Alert screen shows empathetic message with 2–3 options. MVP for fraud protection.

---

## Phase 4: US5 — Combinación de Señales (Priority: P2)

**Goal**: Múltiples reglas activadas → una sola pantalla de pausa con mensaje combinado. No aparecen alertas separadas (FR-009).

**Independent Test**: Enviar monto alto (>2x promedio) a destinatario nuevo → UNA sola pantalla con mensaje combinado mencionando ambos riesgos. Las 3 opciones aplican a toda la operación, no a cada riesgo por separado.

### Implementation

- [X] T021 [US5] Verify and refine combined message display in lib/features/fraud_shield/presentation/widgets/risk_message_card.dart — ensure 2+ triggered rules produce a single combined message (not separate cards or sequential alerts). Test with 2, 3, and 4 triggered rules. Verify combined text reads naturally in Spanish, each sentence ≤15 words. Verify Semantics label covers full combined message for TalkBack.
- [X] T022 [P] [US5] Add combined-rules test case to test/features/fraud_shield/domain/services/risk_engine_test.dart — verify: monto alto + destinatario nuevo → single RiskAlert with `{unusualAmount, newRecipient}`; all 4 rules → single RiskAlert with 4 entries; riskLevel is `high` when >1 rule

**Checkpoint**: Combined signals display as a single screen. FR-009 satisfied.

---

## Phase 5: US3 — Alerta por Múltiples Operaciones Seguidas (Priority: P2)

**Goal**: Si el usuario ha completado ≥3 operaciones en los últimos 10 minutos, la siguiente operación muestra pantalla de pausa. Cancelar no bloquea operaciones futuras.

**Independent Test**: Completar 3 pagos/transferencias rápidamente → iniciar un 4to → pantalla de pausa: "Has hecho varios pagos seguidos." Cancelar → puede operar de nuevo sin restricción (el motor re-evalúa cada vez, sin caché).

### Implementation

- [X] T023 [US3] Verify frequency rule integration — ensure operations created via 001 flows (createOperation in MockOperationRepository) are included in the history list passed to RiskEngine.evaluate(). After 3 successful operations within 10 minutes, the next operation attempt should trigger highFrequency alert. Verify "Cancelar" does NOT block future operations (engine is stateless, re-evaluates each time). If the preconfigured history in T008 includes operations with recent timestamps, adjust dates to be >10 minutes ago so they don't interfere with frequency detection of current-session operations.

**Checkpoint**: Frequency protection active. Users protected against rapid unauthorized operations.

---

## Phase 6: US4 — Alerta por Horario Inusual (Priority: P3)

**Goal**: Operación monetaria fuera de 7:00–22:00 muestra pantalla de pausa. Señal más débil, mayor tasa de falsos positivos.

**Independent Test**: Iniciar operación con hora actual fuera del rango 7:00–22:00 → pantalla de pausa: "Estás haciendo un pago a una hora poco habitual."

### Implementation

- [X] T024 [US4] Verify unusual time rule integration — ensure OperationContext.timestamp uses `DateTime.now()` in the flow integrations (T017/T018) so real-time evaluation works. Unit tests in T014 already cover explicit timestamps. For manual testing: adjust device/emulator time to 2:00 AM or mock DateTime.now() in provider. Document in quickstart that VS-4 requires time adjustment.

**Checkpoint**: Time-based protection active. All 4 risk rules functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates, formatting, full validation against quickstart scenarios

- [X] T025 [P] Run `flutter analyze`, verify 0 warnings across all fraud_shield and modified 001 files
- [X] T026 [P] Run `dart format` on all source files in lib/features/fraud_shield/ and test/features/fraud_shield/
- [X] T027 [P] Verify all fraud shield ARB strings are used — no hard-coded Spanish strings in fraud_shield widgets (Principle VII)
- [X] T028 Run quickstart.md validation scenarios VS-1 through VS-8

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS all user stories
- **US1+US2 (Phase 3)**: Depends on Phase 2 — first deliverable MVP
- **US5 (Phase 4)**: Depends on Phase 3 — refines combined display
- **US3 (Phase 5)**: Depends on Phase 3 — verifies frequency rule in flow
- **US4 (Phase 6)**: Depends on Phase 3 — verifies time rule in flow
- **Polish (Phase 7)**: Depends on all story phases complete

### User Story Dependencies

- **US1+US2 (P1)**: Can start after Phase 2. Creates FraudAlertScreen shared by all stories.
- **US5 (P2)**: Can start after Phase 3. Refines combined message display.
- **US3 (P2)**: Can start after Phase 3, in parallel with US5.
- **US4 (P3)**: Can start after Phase 3, in parallel with US5 and US3.

### Within Each Phase

- Entities before services (T003–T006 before T007)
- Engine before providers (T007 before T011)
- Providers + route before screens (T011–T012 before T016)
- Screens before flow integration (T016 before T017/T018)

### Parallel Opportunities

- All entity tasks T003–T006 run in parallel
- T009–T010 (trusted person stubs) run in parallel
- T011, T012, T013 run in parallel with each other
- T014 (engine tests) runs in parallel with T015 (widget)
- T019 (widget test) runs in parallel with T015
- US5, US3, US4 phases can all run in parallel after Phase 3

---

## Parallel Example: Phase 2 — Domain Layer

```bash
# Launch all entities in parallel:
Task T003: "Create RiskRule enum"
Task T004: "Create RiskThresholds entity"
Task T005: "Create OperationContext entity"
Task T006: "Create RiskAlert entity"

# Then engine (depends on T003–T006):
Task T007: "Create RiskEngine service"

# Parallel with engine: stubs and providers
Task T009: "Create TrustedPerson stub entity"
Task T010: "Create trusted_person_provider stub"
Task T011: "Create fraud_alert_provider"
```

---

## Implementation Strategy

### MVP First (US1+US2 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: US1+US2 (alert system for pay + send)
4. **STOP and VALIDATE**: Pay bill with high amount → alert appears. Send to new contact → alert appears. Cancel and continue both work.
5. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundational → Engine tested, providers ready
2. US1+US2 → Alert system for both flows → Demo (MVP!)
3. US5 → Combined signals verified → Demo
4. US3 → Frequency protection active → Demo
5. US4 → Time protection active → Demo (all 4 rules complete)
6. Polish → Quality gates, quickstart validation

### Parallel Team Strategy

With multiple developers after Phase 2:
- Developer A: US1+US2 (alert screen + flow integration)
- After Phase 3 complete:
  - Developer A: US5 (combined signals)
  - Developer B: US3 (frequency verification)
  - Developer C: US4 (time verification)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Plain Dart entities with manual copyWith/==/hashCode — NOT freezed (removed from project due to Dart 3.13 incompatibility)
- Manual Riverpod providers — NOT codegen (riverpod_generator removed from project)
- Constitution compliance: widget tests with a11y guidelines, domain tests ≥80% coverage
- All UI text in ARB — no hard-coded Spanish strings (Principle VII)
- Frases ≤ 15 palabras, sin jerga bancaria, tono empático (Principle VI)
- TrustedPerson is a stub for 006 — replace when 006-trusted-person is implemented
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
