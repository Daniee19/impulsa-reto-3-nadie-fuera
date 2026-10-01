<!--
Sync Impact Report
Version change: (none) → 1.0.0
Added sections:
  - Principle I: Accessibility First (NON-NEGOTIABLE)
  - Principle II: Stack & Dependency Governance
  - Principle III: Clean Architecture by Feature
  - Principle IV: Security & Privacy
  - Principle V: Testing & Quality Gates
  - Principle VI: UX for Cognitive Accessibility
  - Principle VII: Code Style & Localization
  - Section: Priority Hierarchy
  - Section: Development Workflow
  - Governance
Removed sections: (none)
Deferred items: (none)
-->

# Nadie Fuera — Banca Móvil Accesible Constitution

## Core Principles

### I. Accessibility First (NON-NEGOTIABLE)

WCAG 2.2 AA compliance is mandatory for every screen and interaction.

- Touch targets MUST be at least 48×48 dp with a minimum 8 dp separation.
- Base text MUST be at least 18 sp; monetary amounts MUST be at least 28 sp.
- Text contrast MUST meet 4.5:1; icon and border contrast MUST meet 3:1.
- The UI MUST render without overflow at `textScaler` 2.0 and MUST NOT cap system font scaling.
- Every interactive or informative element MUST carry a `Semantics` label in Spanish with a logical reading order for TalkBack.
- No action may depend solely on gestures, color, or images.
- Time limits MUST be absent or user-extensible.
- State changes MUST be announced via `SemanticsService.announce`.
- Maximum 4 primary actions per screen; one task per screen.

### II. Stack & Dependency Governance

The project runs on Flutter stable 3.x with Dart 3 (null safety), targeting Android first (minSdk 26).

- State management: `flutter_riverpod` with `riverpod_annotation` (codegen). No other state manager. `setState` is permitted only inside purely visual leaf widgets.
- Navigation: `go_router`.
- Models: `freezed` for immutable data classes.
- Every new dependency MUST have an MIT, BSD, or Apache 2.0 license, verified on pub.dev, and recorded in `THIRD_PARTY_LICENSES.md`.

### III. Clean Architecture by Feature

Source is organized as `lib/core/` (theme, router, a11y, errors, utils) and `lib/features/<feature>/{domain, data, presentation}`.

- **Domain**: pure Dart only — entities, abstract repositories, use cases. MUST NOT import Flutter or the data layer.
- **Data**: implements repositories with mock or remote datasources.
- **Presentation**: widgets and providers only; no business logic.
- Dependencies always point inward toward domain and are injected via providers.
- File limit: 300 lines. Widget limit: 150 lines.

### IV. Security & Privacy

- Zero secrets in the repository; use `--dart-define` or a `.env` file listed in `.gitignore`.
- Credentials and session data MUST be stored only in `flutter_secure_storage`.
- Biometric auth via `local_auth` with PIN fallback; biometric data MUST NOT be persisted by the app.
- All network communication MUST use HTTPS.
- Session MUST auto-expire after 5 minutes of inactivity.
- Logs MUST NOT contain personal data (DNI, account numbers, amounts, names).
- Only fictitious data; never real customer data.
- AI receives anonymized data, selects intents from a closed list, and MUST NOT execute transactions. Amounts and balances MUST always come from the repository, never from AI-generated text.
- Microphone use requires explicit consent per Ley 29733 (Peru).

### V. Testing & Quality Gates

- Domain unit tests MUST achieve at least 80 % coverage.
- Each screen MUST have a widget test validating `androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`, and no overflow at `textScaler` 2.0.
- One integration test per critical flow: check balance, pay a service, transfer to a contact.
- Every PR MUST pass: `flutter analyze` with 0 warnings, `dart format` applied, all tests green, and manual TalkBack verification for UI changes.

### VI. UX for Cognitive Accessibility

- Easy-read language: sentences MUST NOT exceed 15 words; no jargon.
- Banned terms in user-facing text: "token", "validar dispositivo", "autenticación".
- Every monetary operation MUST include a confirmation screen displaying amount and recipient, readable by TTS, with a back action that preserves entered data.
- Error messages MUST explain what went wrong and how to fix it.

### VII. Code Style & Localization

- Linter: `very_good_analysis`.
- Code, identifiers, branch names, and commits in English using Conventional Commits.
- UI text in neutral Peruvian Spanish, centralized in ARB files via `flutter_localizations`. Hard-coded strings in widgets are forbidden.
- Documentation and specs in Spanish.
- Files in `snake_case`, classes in `PascalCase`.
- Public widgets MUST have a single-line `///` doc comment stating their purpose.

## Priority Hierarchy

When requirements conflict, resolve in this order:

1. Accessibility
2. Stable demo
3. Development speed
4. New features

A feature that breaks accessibility MUST NOT ship. A feature that destabilizes the demo MUST be reverted or gated.

## Development Workflow

- `flutter analyze` and `dart format` run before every commit.
- PRs require all tests green plus a manual TalkBack check for any UI change.
- Conventional Commits format: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`.
- Every PR MUST reference the principle it upholds if it touches accessibility or security.

## Governance

This constitution supersedes all other development practices for the Nadie Fuera project. Amendments require:

1. A written proposal describing the change and its rationale.
2. Review by at least one team member.
3. An updated version number following semantic versioning (MAJOR for principle removals or redefinitions, MINOR for additions or material expansions, PATCH for clarifications).
4. An updated `LAST_AMENDED_DATE`.

All code reviews and PRs MUST verify compliance with these principles. Non-compliance MUST be flagged and resolved before merge.

**Version**: 1.0.0 | **Ratified**: 2026-10-01 | **Last Amended**: 2026-10-01
