# Tasks: Persona de Confianza con Permisos Limitados

**Input**: Design documents from `/specs/006-trusted-person/`

**Prerequisites**: plan.md (required), spec.md (required), data-model.md, contracts/trusted-person-service.md, research.md, quickstart.md

**Organization**: Tasks grouped by user story. This feature creates a new feature module `lib/features/trusted_person/` and replaces the existing stub entity/provider in `lib/features/fraud_shield/`. Entities use `@immutable` with manual `==`/`hashCode`/`copyWith` (matching existing codebase pattern, NOT freezed).

**Note**: The existing codebase has a stub `TrustedPerson` entity in `lib/features/fraud_shield/domain/entities/trusted_person.dart` and a hard-coded `trustedPersonProvider` in `lib/features/fraud_shield/presentation/providers/trusted_person_provider.dart`. This feature replaces both with a full implementation in its own feature module.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Feature directory structure, dependency, ARB strings, route stubs

- [X] T001 Add `flutter_secure_storage: ^9.2.4` to pubspec.yaml (keep dependencies sorted alphabetically). Run `flutter pub get`
- [X] T002 [P] Create feature directory structure: `lib/features/trusted_person/{domain/{entities,repositories},data/repositories,presentation/{providers,screens,widgets}}`
- [X] T003 [P] Add ARB strings to lib/core/l10n/arb/app_es.arb — keys for: `trustedPerson_title` ("Mi persona de confianza"), `trustedPerson_explanation` ("Tu persona de confianza puede ayudarte, pero no puede tocar tu dinero"), `trustedPerson_register` ("Registrar"), `trustedPerson_nameLabel` ("Nombre"), `trustedPerson_phoneLabel` ("Teléfono"), `trustedPerson_relationshipLabel` ("Relación"), `trustedPerson_permission_securityAlerts` ("Avisos de seguridad"), `trustedPerson_permission_securityAlerts_desc` ("Recibe un aviso si la app detecta algo raro"), `trustedPerson_permission_helpRequests` ("Pedidos de ayuda"), `trustedPerson_permission_helpRequests_desc` ("Cuando pidas ayuda puedes elegir a esta persona"), `trustedPerson_permission_configHelp` ("Ayudar a configurar"), `trustedPerson_permission_configHelp_desc` ("Puede sugerirte cambios pero tú decides"), `trustedPerson_confirmRegister` ("Confirmar"), `trustedPerson_change` ("Cambiar persona de confianza"), `trustedPerson_change_warning` ("Vas a quitar a {name} y registrar a otra persona"), `trustedPerson_remove` ("Quitar persona de confianza"), `trustedPerson_remove_warning` ("{name} dejará de recibir avisos y no podrá ayudarte"), `trustedPerson_removed` ("Persona de confianza eliminada"), `trustedPerson_registered` ("Persona de confianza registrada"), `trustedPerson_phoneSelf` ("No puedes registrarte a ti mismo"), `trustedPerson_phoneInvalid` ("Ingresa 9 dígitos"), `trustedPerson_noPermissions` ("Sin permisos activos"), `trustedPerson_suggestion_title` ("{name} te sugiere"), `trustedPerson_suggestion_accept` ("Aceptar"), `trustedPerson_suggestion_reject` ("No, gracias"), `trustedPerson_suggestion_accepted` ("Cambio aplicado"), `trustedPerson_suggestion_fontSize` ("Hacer la letra más grande"). Run `flutter gen-l10n`

---

## Phase 2: Foundational (Domain Entities + Repository Interfaces)

**Purpose**: Domain entities and abstract repository interfaces. MUST be complete before screens. All entities use `@immutable` with manual `==`/`hashCode` (NO freezed). Domain is pure Dart — no Flutter imports except `package:meta/meta.dart`.

- [X] T004 [P] Create TrustedPermission enum in lib/features/trusted_person/domain/entities/trusted_permission.dart — values: `securityAlerts`, `helpRequests`, `configHelp`
- [X] T005 [P] Create ConsentAction enum in lib/features/trusted_person/domain/entities/consent_record.dart — values: `granted`, `revoked`. Create ConsentRecord entity in same file — fields: `TrustedPermission permission` (non-null), `ConsentAction action` (non-null), `DateTime timestamp` (non-null, UTC). `@immutable`, manual `==`/`hashCode`
- [X] T006 [P] Create ConfigSuggestionType enum in lib/features/trusted_person/domain/entities/config_suggestion.dart — values: `fontSize`, `addContact`, `removeContact`, `addBill`, `removeBill`. Create ConfigSuggestionStatus enum — values: `pending`, `accepted`, `rejected`. Create ConfigSuggestion entity in same file — fields: `String id` (non-empty), `ConfigSuggestionType type`, `String description` (non-empty, ≤15 words), `String? suggestedValue` (nullable), `ConfigSuggestionStatus status`, `DateTime createdAt` (non-null), `DateTime? resolvedAt` (null if pending). `@immutable`, manual `==`/`hashCode`, `copyWith` method for status/resolvedAt transitions
- [X] T007 Create TrustedPerson entity in lib/features/trusted_person/domain/entities/trusted_person.dart — fields: `String id` (non-empty, UUID), `String name` (non-empty, ≤100 chars), `String phone` (non-empty, 9 digits starting with 9), `String relationship` (non-empty), `Set<TrustedPermission> permissions` (0-3 values), `List<ConsentRecord> consentHistory` (append-only), `DateTime registeredAt` (non-null). `@immutable`, manual `==`/`hashCode`, `copyWith`. Method `bool hasPermission(TrustedPermission)` that checks `permissions.contains()`. Depends on T004, T005
- [X] T008 [P] Create abstract TrustedPersonRepository in lib/features/trusted_person/domain/repositories/trusted_person_repository.dart — methods per contract: `Future<TrustedPerson?> getTrustedPerson()`, `Future<TrustedPerson> register({required String name, required String phone, required String relationship, required Set<TrustedPermission> initialPermissions})`, `Future<TrustedPerson> updatePermissions(Set<TrustedPermission> permissions)`, `Future<void> remove()`, `Future<bool> hasPermission(TrustedPermission permission)`, `Stream<TrustedPerson?> watchTrustedPerson()`
- [X] T009 [P] Create abstract ConfigSuggestionRepository in lib/features/trusted_person/domain/repositories/config_suggestion_repository.dart — methods per contract: `Future<List<ConfigSuggestion>> getPendingSuggestions()`, `Future<ConfigSuggestion> accept(String suggestionId)`, `Future<ConfigSuggestion> reject(String suggestionId)`, `Future<ConfigSuggestion> createSimulated({required ConfigSuggestionType type, required String description, String? suggestedValue})`

**Checkpoint**: Domain layer complete. All entities type-safe, repository contracts defined.

---

## Phase 3: US1 — Rosa registra a Valeria como persona de confianza (Priority: P1) 🎯 MVP

**Goal**: User can register a trusted person with name, phone, relationship from easy mode settings. Data persisted in flutter_secure_storage.

**Independent Test**: Open trusted person settings → register a contact → verify saved with selected permissions.

### Implementation for US1

- [X] T010 [US1] Create SecureStorageTrustedPersonRepository in lib/features/trusted_person/data/repositories/secure_storage_trusted_person_repository.dart — implements TrustedPersonRepository. Key: `trusted_person_data`. JSON serialization with `dart:convert`. `watchTrustedPerson()` uses a `StreamController<TrustedPerson?>` that emits on register/update/remove. `register()` throws StateError if person already exists. Creates ConsentRecord(granted) for each initialPermission. Phone validation: 9 digits, starts with 9
- [X] T011 [US1] Create trustedPersonRepositoryProvider in lib/features/trusted_person/presentation/providers/trusted_person_provider.dart — `Provider<TrustedPersonRepository>` returning SecureStorageTrustedPersonRepository. Create `trustedPersonProvider` as `StreamProvider<TrustedPerson?>` watching `repo.watchTrustedPerson()`. This provider replaces the existing stub in lib/features/fraud_shield/presentation/providers/trusted_person_provider.dart
- [X] T012 [US1] Create PermissionToggle widget in lib/features/trusted_person/presentation/widgets/permission_toggle.dart — takes `TrustedPermission permission`, `String label`, `String description`, `bool value`, `ValueChanged<bool> onChanged`. Renders a SwitchListTile with title (label) and subtitle (description). Min 48dp tap target, 4.5:1 contrast. Semantics label includes permission name and state ("activado"/"desactivado")
- [X] T013 [US1] Create TrustedPersonSetupScreen in lib/features/trusted_person/presentation/screens/trusted_person_setup_screen.dart — entry point at `/easy-mode/settings/trusted-person`. If no person registered: shows explanation text (ARB `trustedPerson_explanation`) and "Registrar" button. If person registered: shows name, relationship, and active permissions, with "Cambiar" and "Quitar" buttons. screenAnnounce on mount
- [X] T014 [US1] Create TrustedPersonRegisterScreen in lib/features/trusted_person/presentation/screens/trusted_person_register_screen.dart — at `/easy-mode/settings/trusted-person/register`. TextFormFields for name (≤100 chars), phone (9 digits, format peruano starting with 9, validation error: `trustedPerson_phoneInvalid`), relationship. Self-registration check: if phone matches user's phone → error `trustedPerson_phoneSelf`. "Siguiente" button navigates to permissions screen. 48dp tap targets, 18sp text
- [X] T015 [US1] Create TrustedPersonPermissionsScreen in lib/features/trusted_person/presentation/screens/trusted_person_permissions_screen.dart — at `/easy-mode/settings/trusted-person/permissions`. Shows 3 PermissionToggle widgets (securityAlerts, helpRequests, configHelp). "Confirmar" button calls repository.register() with selected permissions and navigates back to setup screen. SnackBar ≥5s confirming registration. Zero permissions is valid (edge case)
- [X] T016 [US1] Add routes to lib/core/router/app_router.dart — add under `/easy-mode` routes: `settings/trusted-person` → TrustedPersonSetupScreen, `settings/trusted-person/register` → TrustedPersonRegisterScreen, `settings/trusted-person/permissions` → TrustedPersonPermissionsScreen (receives name/phone/relationship via `extra`). Also add routes for detail, change, remove, suggestion screens (builders can be placeholder until those screens are implemented in later phases)
- [X] T017 [US1] Add "Mi persona de confianza" action to EasyModeHomeScreen in lib/features/easy_mode/presentation/screens/easy_mode_home_screen.dart — add an ActionCard or ElevatedButton navigating to `/easy-mode/settings/trusted-person`. Icon: Icons.person, label from ARB `trustedPerson_title`
- [X] T018 [US1] Update imports in 002/003 — change `import` of `TrustedPerson` and `TrustedPermission` from `lib/features/fraud_shield/domain/entities/trusted_person.dart` to `lib/features/trusted_person/domain/entities/trusted_person.dart` and `lib/features/trusted_person/domain/entities/trusted_permission.dart`. Change `trustedPersonProvider` import from `lib/features/fraud_shield/presentation/providers/trusted_person_provider.dart` to `lib/features/trusted_person/presentation/providers/trusted_person_provider.dart`. Delete the old stub files: `lib/features/fraud_shield/domain/entities/trusted_person.dart` and `lib/features/fraud_shield/presentation/providers/trusted_person_provider.dart`. Update all files that import these (fraud_alert_screen.dart, help_contact_picker_screen.dart, help_channel_picker_screen.dart, test files)

**Checkpoint**: User can register a trusted person. 002/003 now consume the real provider instead of the stub.

---

## Phase 4: US2 — Rosa elige los permisos de Valeria (Priority: P1)

**Goal**: User can activate/deactivate each of 3 permissions independently. Effects are immediate in 002 and 003.

**Independent Test**: Toggle each permission on/off → verify 002 and 003 show/hide the trusted person option accordingly.

### Implementation for US2

- [X] T019 [US2] Create TrustedPersonDetailScreen in lib/features/trusted_person/presentation/screens/trusted_person_detail_screen.dart — at `/easy-mode/settings/trusted-person/detail`. Shows name, phone (masked: `***XXX`), relationship. Lists 3 PermissionToggle widgets reflecting current permissions. Toggling a permission calls `repository.updatePermissions()` with the new set and creates ConsentRecord (granted/revoked). Changes take effect immediately — 002/003 providers react
- [X] T020 [US2] Update TrustedPersonSetupScreen (T013) — when person is registered, navigate to detail screen instead of showing inline. Or show summary with "Ver permisos" link to detail screen

**Checkpoint**: Permissions are editable post-registration. Toggling securityAlerts off hides "Consultar a [name]" in fraud alert. Toggling helpRequests off hides trusted person from help contact picker.

---

## Phase 5: US3 — Valeria sugiere un cambio de configuración (Priority: P2)

**Goal**: Simulated config suggestions from the trusted person. User approves or rejects. Nothing auto-applies.

**Independent Test**: With configHelp permission active, trigger a simulated suggestion → verify user sees it → accept/reject → verify effect.

### Implementation for US3

- [X] T021 [US3] Create MockConfigSuggestionRepository in lib/features/trusted_person/data/repositories/mock_config_suggestion_repository.dart — implements ConfigSuggestionRepository. Stores suggestions in memory (List). `createSimulated()` adds a new pending suggestion. `accept()` sets status to accepted and resolvedAt to now. `reject()` sets status to rejected and resolvedAt to now. Pre-loads one suggestion: type `fontSize`, description "Hacer la letra más grande", suggestedValue "large", status pending
- [X] T022 [US3] Create configSuggestionRepositoryProvider and configSuggestionProvider in lib/features/trusted_person/presentation/providers/config_suggestion_provider.dart — `Provider<ConfigSuggestionRepository>` returning MockConfigSuggestionRepository. `FutureProvider<List<ConfigSuggestion>>` for pending suggestions
- [X] T023 [US3] Create ConfigSuggestionScreen in lib/features/trusted_person/presentation/screens/config_suggestion_screen.dart — at `/easy-mode/settings/trusted-person/suggestion`. Shows suggestion from trusted person: "{name} te sugiere: {description}". Two buttons: "Aceptar" (calls accept, applies config change, shows SnackBar ≥5s `trustedPerson_suggestion_accepted`), "No, gracias" (calls reject, navigates back silently — familiar does not know about rejection). Only accessible if configHelp permission is active. 48dp targets, 18sp text, screenAnnounce on mount
- [X] T024 [US3] Add suggestion notification to TrustedPersonDetailScreen or TrustedPersonSetupScreen — if pending suggestions exist and configHelp is active, show a banner/card: "Tienes una sugerencia de {name}" linking to ConfigSuggestionScreen

**Checkpoint**: Config suggestion flow complete. Suggestions require explicit approval. Rejected suggestions are silent.

---

## Phase 6: US4 — Rosa cambia de persona de confianza (Priority: P2)

**Goal**: User can replace the current trusted person with a new one. Old person loses all permissions immediately.

**Independent Test**: With person registered → change → verify old person gone, new person active with chosen permissions.

### Implementation for US4

- [X] T025 [US4] Create TrustedPersonChangeScreen in lib/features/trusted_person/presentation/screens/trusted_person_change_screen.dart — at `/easy-mode/settings/trusted-person/change`. Shows warning: "Vas a quitar a {name}. {name} dejará de recibir avisos y no podrá ayudarte" (ARB keys). "Continuar" button calls `repository.remove()` then navigates to register screen. "Cancelar" goes back. Confirmation required before proceeding (FR-009). screenAnnounce on mount

**Checkpoint**: User can replace trusted person. Previous person loses all permissions immediately.

---

## Phase 7: US5 — Rosa quita a su persona de confianza (Priority: P3)

**Goal**: User can remove the trusted person entirely. 002/003 stop showing the familiar option.

**Independent Test**: Remove trusted person → verify 002 only shows cancel/continue, 003 only shows bank advisor.

### Implementation for US5

- [X] T026 [US5] Create TrustedPersonRemoveScreen in lib/features/trusted_person/presentation/screens/trusted_person_remove_screen.dart — at `/easy-mode/settings/trusted-person/remove`. Shows consequences: "{name} dejará de recibir avisos y no podrá ayudarte" (ARB key). "Quitar" button calls `repository.remove()`, shows SnackBar ≥5s `trustedPerson_removed`, navigates back to setup screen (which now shows empty state). "Cancelar" goes back. FR-009 confirmation required. screenAnnounce on mount

**Checkpoint**: User has full control. Can remove trusted person at any time. 002/003 react immediately.

---

## Phase 8: Tests

**Purpose**: Unit tests for domain, widget tests with a11y guidelines for screens

- [X] T027 [P] Create unit tests in test/features/trusted_person/domain/entities/trusted_person_test.dart — test: construction with valid fields, `hasPermission()` returns true for active permission, `hasPermission()` returns false for inactive permission, `copyWith` preserves other fields, `==` and `hashCode` correct, phone validation (9 digits starting with 9), name ≤100 chars
- [X] T028 [P] Create unit tests in test/features/trusted_person/domain/entities/config_suggestion_test.dart — test: construction, status transitions (pending→accepted, pending→rejected), `resolvedAt` null when pending and non-null when resolved, `copyWith` for status change
- [X] T029 [P] Create widget test in test/features/trusted_person/presentation/screens/trusted_person_register_screen_test.dart — test: form validation (empty name rejected, invalid phone rejected, phone starting with non-9 rejected, self-registration rejected), successful registration navigates. meetsGuideline for androidTapTargetGuideline, labeledTapTargetGuideline
- [X] T030 [P] Create widget test in test/features/trusted_person/presentation/screens/trusted_person_permissions_screen_test.dart — test: 3 toggles visible with labels and descriptions, toggling changes state, confirming with zero permissions is allowed. meetsGuideline for androidTapTargetGuideline, labeledTapTargetGuideline
- [X] T031 [P] Create widget test in test/features/trusted_person/presentation/screens/config_suggestion_screen_test.dart — test: suggestion text displayed, accept applies change, reject dismisses silently. meetsGuideline for androidTapTargetGuideline, labeledTapTargetGuideline

---

## Phase 9: Polish & Cross-Cutting

- [X] T032 [P] Run `dart format` on all new and modified files
- [X] T033 [P] Run `flutter analyze`, verify 0 issues
- [X] T034 [P] Verify all UI strings come from ARB — grep for hard-coded Spanish strings in lib/features/trusted_person/
- [X] T035 Run quickstart.md validation scenarios VS-1 through VS-6

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on T001 (pub get). T007 depends on T004, T005
- **US1 (Phase 3)**: Depends on Phase 2 (entities + interfaces). T018 (import migration) depends on T011 (new provider)
- **US2 (Phase 4)**: Depends on US1 (registration must work)
- **US3 (Phase 5)**: Depends on Phase 2 (ConfigSuggestion entity). Can run parallel to US2
- **US4 (Phase 6)**: Depends on US1 (must have person registered to change)
- **US5 (Phase 7)**: Depends on US1 (must have person registered to remove)
- **Tests (Phase 8)**: Depends on Phases 2-7 (entities + screens must exist)
- **Polish (Phase 9)**: Depends on all prior phases

### User Story Dependencies

- **US1 (P1)**: Blocks US2, US4, US5. Foundation for everything.
- **US2 (P1)**: Depends on US1. Independent of US3, US4, US5.
- **US3 (P2)**: Depends on Phase 2 entities. Can parallelize with US2.
- **US4 (P2)**: Depends on US1. Independent of US2, US3, US5.
- **US5 (P3)**: Depends on US1. Independent of US2, US3, US4.

### Parallel Opportunities

- T002, T003 run in parallel (setup)
- T004, T005, T006, T008, T009 run in parallel (different entity/interface files)
- T012 can run parallel with T010 (different files)
- US3 (T021-T024) can run parallel with US2 (T019-T020)
- US4 (T025) and US5 (T026) can run parallel
- All test tasks T027-T031 run in parallel

---

## Parallel Example: Phase 2

```bash
# Launch all entity files together:
Task: "Create TrustedPermission enum in domain/entities/trusted_permission.dart"
Task: "Create ConsentRecord entity in domain/entities/consent_record.dart"
Task: "Create ConfigSuggestion entity in domain/entities/config_suggestion.dart"

# After T004+T005 complete, launch T007 (TrustedPerson depends on TrustedPermission + ConsentRecord)

# Interfaces can run parallel with entities:
Task: "Create TrustedPersonRepository in domain/repositories/"
Task: "Create ConfigSuggestionRepository in domain/repositories/"
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Phase 1: Setup (deps, ARB, structure)
2. Phase 2: Domain entities + interfaces
3. Phase 3: US1 — register trusted person + migrate 002/003 imports
4. **STOP**: User can register, 002/003 consume real provider

### Full Feature

1. Phases 1-2 → Foundation
2. Phase 3 (US1) → Registration working, stubs replaced
3. Phase 4 (US2) → Granular permissions editable
4. Phases 5-7 (US3-US5) → Suggestions, change, remove
5. Phase 8 → Tests
6. Phase 9 → Polish

---

## Notes

- Entities use `@immutable` + manual `==`/`hashCode`/`copyWith` (existing codebase pattern, NOT freezed despite plan.md mention)
- Existing stub `TrustedPerson` in fraud_shield/ gets deleted and replaced (T018)
- `trustedPersonProvider` type changes from `Provider<TrustedPerson?>` (sync, hardcoded) to `StreamProvider<TrustedPerson?>` (async, reactive) — callers in 002/003 may need `.valueOrNull` instead of direct read
- `flutter_secure_storage` stores JSON under key `trusted_person_data`
- Phone validation: 9 digits, starts with 9 (Peruvian mobile format)
- No auto-registration: phone must differ from user's phone
- ConsentRecord is append-only — never deleted, only added
- Config suggestions are simulated (mock repo), never auto-apply
- All text ≤15 words, ARB-sourced, 48dp targets, 4.5:1 contrast
- Constitution Principle IV drives secure storage choice
- Constitution Principle VI drives ≤15 word explanations
