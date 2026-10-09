# Tasks: Auditoría de Accesibilidad para Lector de Pantalla

**Input**: Design documents from `/specs/005-screen-reader-audit/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/a11y-utilities-contract.md, research.md, quickstart.md

**Organization**: Tasks grouped by user story. This is a cross-cutting feature — no new screens, modifies existing screens in 001-004 and adds core utilities + tests.

**Note**: This project already uses `A11yHelpers.announceForAccessibility(FlutterView, String)` in `lib/core/a11y/a11y_helpers.dart`. This feature adds `AmountToWords.convert()` for money-as-words and a convenience `screenAnnounce()` wrapper, then audits all existing screens.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Test directories and ARB strings for announce messages

- [X] T001 Create test directories: `test/core/a11y/` and `test/a11y/`
- [X] T002 [P] Add announce ARB strings to lib/core/l10n/arb/app_es.arb — keys: `announceHomeScreen` ("Pantalla principal"), `announceBalance` ("Tu saldo es {amount}"), `announcePaymentSuccess` ("Pago realizado. Pagaste {amount} al recibo de {service}"), `announceTransferSuccess` ("Dinero enviado. Enviaste {amount} a {name}"), `announceFraudAlert` ("Alerta de seguridad. {riskMessage}"), `announceHelpConnecting` ("Te estamos conectando con {name}"), `announceHelpConnected` ("Conectado con {name}"), `announceHelpNoResponse` ("No pudimos comunicarte con {name}"), `announceAssistantResponse` ("{response}"), `announceError` ("{errorMessage}"). Run `flutter gen-l10n`

---

## Phase 2: Foundational (Core Utilities)

**Purpose**: AmountToWords converter and screenAnnounce helper. MUST be complete before screen modifications.

- [X] T003 Create AmountToWords in lib/core/a11y/amount_to_words.dart — static `String convert(double amount)`. Dart puro, no Flutter imports. Range 0-999,999.99. Rules: `0` → "cero soles", `1` → "un sol", `0.01` → "un céntimo", `0.50` → "cincuenta céntimos", `120.50` → "ciento veinte soles con cincuenta céntimos", `2350` → "dos mil trescientos cincuenta soles". "soles" plural / "sol" singular. "céntimos" plural / "céntimo" singular. "con" separates. Negative → ArgumentError. Round to 2 decimals
- [X] T004 [P] Add screenAnnounce convenience function to lib/core/a11y/a11y_helpers.dart — `static Future<void> screenAnnounce(FlutterView view, String message)` that calls `SemanticsService.sendAnnouncement(view, message, TextDirection.ltr)`. Reuse existing pattern
- [X] T005 [P] Unit tests for AmountToWords in test/core/a11y/amount_to_words_test.dart — test: 0→"cero soles", 1→"un sol", 0.01→"un céntimo", 0.50→"cincuenta céntimos", 21→"veintiún soles", 100→"cien soles", 101→"ciento un soles", 120.50→"ciento veinte soles con cincuenta céntimos", 1000→"mil soles", 2350→"dos mil trescientos cincuenta soles", 999999.99→correct, negative→ArgumentError

**Checkpoint**: AmountToWords tested, screenAnnounce ready. Screen modifications can begin.

---

## Phase 3: US2 — Montos se Leen en Palabras (Priority: P1)

**Goal**: All money amounts use AmountToWords in Semantics labels so TalkBack reads "ciento veinte soles" not "S/ 120".

- [X] T006 [US2] Modify BalanceScreen in lib/features/easy_mode/presentation/screens/balance_screen.dart — wrap balance amount Text in `Semantics(label: AmountToWords.convert(amount), excludeSemantics: true)` instead of current "S/ {amount}" label. Add screenAnnounce on data load with ARB `announceBalance` using AmountToWords
- [X] T007 [US2] Modify PayBillScreen in lib/features/easy_mode/presentation/screens/pay_bill_screen.dart — change bill item Semantics label from `'S/ ${bill.amount.toStringAsFixed(2)}'` to `AmountToWords.convert(bill.amount)`. Wrap each bill card with MergeSemantics so service name + amount read as one unit
- [X] T008 [US2] Modify ConfirmationScreen in lib/core/presentation/widgets/confirmation_screen.dart — detect amount values (containing "S/ ") in items and provide Semantics with AmountToWords conversion. Items with "S/ " prefix should have Semantics label using words
- [X] T009 [US2] Modify OperationSuccessScreen in lib/features/easy_mode/presentation/screens/operation_success_screen.dart — wrap amount Text in `Semantics(label: AmountToWords.convert(amount), excludeSemantics: true)`. Update announce to include amount in words using ARB `announcePaymentSuccess`/`announceTransferSuccess`

**Checkpoint**: All money displays read in words via TalkBack. FR-004, FR-005 satisfied.

---

## Phase 4: US1 + US3 — Labels y Anuncios Automáticos (Priority: P1)

**Goal**: Every interactive/informative element has a descriptive Spanish label. Every screen transition announces automatically.

- [X] T010 [US1] [US3] Modify EasyModeHomeScreen in lib/features/easy_mode/presentation/screens/easy_mode_home_screen.dart — add screenAnnounce "Pantalla principal" on mount via StatefulWidget conversion. Already has labels via ActionCard, verify all are descriptive
- [X] T011 [US1] [US3] Modify FraudAlertScreen in lib/features/fraud_shield/presentation/screens/fraud_alert_screen.dart — update announce to include risk explanation from ARB `announceFraudAlert`. Add AmountToWords for any amount in the alert message
- [X] T012 [US1] [US3] Modify HelpConnectingScreen in lib/features/contextual_help/presentation/screens/help_connecting_screen.dart — verify announce uses ARB `announceHelpConnecting` with name. Verify all labels descriptive
- [X] T013 [US1] [US3] Modify HelpFallbackScreen in lib/features/contextual_help/presentation/screens/help_fallback_screen.dart — verify announce uses ARB `announceHelpNoResponse` with name

**Checkpoint**: All screens announce on load/transition. All labels descriptive. FR-001, FR-002, FR-003, FR-006 satisfied.

---

## Phase 5: US4 — Sin Gestos Complejos ni Imágenes sin Descripción (Priority: P1)

**Goal**: No complex gestures required. Decorative images excluded from semantics. Icon actions describe the action, not the icon.

- [X] T014 [US4] Add Semantics sortKey to HelpFab in lib/features/contextual_help/presentation/widgets/help_fab.dart — wrap in `Semantics(sortKey: OrdinalSortKey(99))` so it reads at the end, not in the middle of content
- [X] T015 [US4] Audit icon semantics across 001-004 — verify all IconButton/Icon widgets with actions have labels describing the action ("Pagar recibo" not "icono de billete"). Check: action_card.dart, help_fab.dart, success screen check_circle icon. Add ExcludeSemantics to purely decorative icons (check_circle in success screen is informative — label "Operación exitosa")
- [X] T016 [US4] Verify all SnackBar durations ≥5 seconds across codebase — check fraud_alert_screen.dart (already 5s), pay_bill_confirm_screen.dart, send_money_confirm_screen.dart. Fix any <5s durations

**Checkpoint**: All flows completable with simple taps. No decorative images read by TalkBack. FR-007, FR-008, FR-009, FR-012 satisfied.

---

## Phase 6: US5 — Guion de Prueba Manual con TalkBack (Priority: P2)

**Goal**: Create TalkBack test checklist document covering all 7 flows.

- [X] T017 [US5] Create docs/talkback_test_checklist.md — structured markdown with sections: Preparación (activate TalkBack, close eyes, 10 min timer), 7 flows (ver saldo, pagar recibo, enviar dinero, pedir ayuda, alerta de fraude, asistente de voz, conectar con ayuda humana). Each flow: steps, expected TalkBack output, checkbox for pass/fail, space for issues. Target: ≤10 min total

---

## Phase 7: A11y Widget Tests

**Purpose**: Automated a11y tests per feature verifying androidTapTargetGuideline, labeledTapTargetGuideline, textContrastGuideline

- [X] T018 [P] Create test/a11y/easy_mode_a11y_test.dart — widget tests for: home screen, balance screen, pay bill screen, pay bill confirm, send money screen, send money confirm, operation success. Each: meetsGuideline for 3 guidelines
- [X] T019 [P] Create test/a11y/fraud_shield_a11y_test.dart — widget test for FraudAlertScreen: 3 guidelines
- [X] T020 [P] Create test/a11y/contextual_help_a11y_test.dart — widget tests for: help contact picker, help channel picker, help connecting, help fallback. 3 guidelines each
- [ ] T021 [P] Create test/a11y/voice_assistant_a11y_test.dart — widget tests for: voice assistant screen, microphone consent screen, operation summary screen. 3 guidelines each (depends on 004 screens existing)

---

## Phase 8: Polish & Cross-Cutting

- [X] T022 [P] Run `dart format` on all modified files
- [X] T023 [P] Run `flutter analyze`, verify 0 warnings across modified files
- [X] T024 [P] Verify no hard-coded amount strings remain in Semantics — grep for `'S/ '` in Semantics labels across lib/
- [ ] T025 Run quickstart.md validation scenarios VS-1 through VS-8

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: No dependencies, but T003 (AmountToWords) BLOCKS Phase 3
- **US2 (Phase 3)**: Depends on T003 (AmountToWords)
- **US1+US3 (Phase 4)**: Depends on T002 (ARB strings) + T004 (screenAnnounce)
- **US4 (Phase 5)**: Independent of Phases 3-4
- **US5 (Phase 6)**: Independent — documentation only
- **Tests (Phase 7)**: Depends on Phases 3-5 (screens must be modified first)
- **Polish (Phase 8)**: Depends on all prior phases

### Parallel Opportunities

- T002, T003, T004, T005 run in parallel (setup + foundational)
- T006, T007, T008, T009 can run in parallel (different files)
- T010-T013 can run in parallel (different files)
- T014-T016 can run in parallel
- T018-T021 can run in parallel (different test files)
- T022-T024 run in parallel

---

## Implementation Strategy

### MVP (US2 only)

1. Phase 1 + Phase 2 → AmountToWords working
2. Phase 3 → All montos in words
3. STOP: Montos read correctly via TalkBack

### Full Feature

1. Phases 1-2 → Foundational
2. Phases 3-5 → All US modifications
3. Phase 6 → TalkBack checklist
4. Phase 7 → Automated tests
5. Phase 8 → Polish

---

## Notes

- Cross-cutting feature: modifies existing screens, no new screens
- No new dependencies — uses flutter_test built-in guidelines
- AmountToWords is ~100 lines of Dart puro, fully testeable
- Existing `A11yHelpers.announceForAccessibility` already handles announces — this feature audits completeness
- Constitution Principle I (Accessibility First) is the driver
- WCAG 2.2 AA + Ley 29973 compliance
- Snackbar duration ≥5s per FR-012
- 004 screens may not exist yet — T021 can be deferred
