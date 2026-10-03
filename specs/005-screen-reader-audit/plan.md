# Implementation Plan: Auditoría de Accesibilidad para Lector de Pantalla

**Branch**: `005-screen-reader-audit` | **Date**: 2026-10-02 | **Spec**: `specs/005-screen-reader-audit/spec.md`

**Input**: Feature specification from `/specs/005-screen-reader-audit/spec.md`

## Summary

Feature transversal que establece estándares de accesibilidad para todas las pantallas de 001 a 004. No agrega pantallas nuevas. Agrega/corrige `Semantics` en español, fija el orden de lectura lógico (título → información → acciones), implementa anuncios automáticos de cambio de pantalla via `SemanticsService.announce`, convierte montos a palabras en español para TalkBack, y define tests automáticos (a11y guidelines de flutter_test) y un guion de prueba manual con TalkBack.

## Technical Context

**Language/Version**: Flutter stable 3.x / Dart 3 (null safety), SDK ^3.13.4

**Primary Dependencies**: Ninguna nueva. Usa `flutter_test` (built-in) para tests de accesibilidad.

**Storage**: N/A

**Testing**: Widget tests con `androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline` para cada pantalla. Tests del conversor de montos a palabras (Dart puro).

**Target Platform**: Android first (minSdk 26), TalkBack como lector de pantalla objetivo

**Project Type**: Feature transversal (cross-cutting) que modifica pantallas existentes de 001-004

**Constraints**: Ley 29973 (accesibilidad para personas con discapacidad en Perú). WCAG 2.2 AA. Constitución Principio I: Accessibility First.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Estado | Notas |
|-----------|--------|-------|
| I. Accessibility First | ✅ PASS | Esta feature ES la implementación directa de este principio. Semantics en español, orden lógico, 48dp, 4.5:1, announce |
| II. Stack & Dependency Governance | ✅ PASS | Sin dependencias nuevas |
| III. Clean Architecture by Feature | ✅ PASS | Utilities en `lib/core/a11y/`. Tests distribuidos por feature |
| IV. Security & Privacy | ✅ PASS | Los montos leídos en voz alta son datos que ya están en pantalla. Sin datos sensibles nuevos |
| V. Testing & Quality Gates | ✅ PASS | Tests automáticos de a11y en cada pantalla. Guion de prueba manual TalkBack |
| VI. UX for Cognitive Accessibility | ✅ PASS | Etiquetas en lenguaje simple (≤15 palabras). Montos en palabras completas con moneda |
| VII. Code Style & Localization | ✅ PASS | Etiquetas de Semantics via ARB. snake_case. Conventional Commits |

**Resultado**: Todos los gates pasan.

## Project Structure

### Documentation (this feature)

```text
specs/005-screen-reader-audit/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── a11y-utilities-contract.md
└── tasks.md             # (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/core/a11y/
├── amount_to_words.dart             # Convierte montos a palabras en español
├── screen_announce.dart             # Helper para SemanticsService.announce
└── semantics_constants.dart         # Constantes de Semantics labels reutilizables

lib/core/l10n/
└── (ARB files)                      # Nuevas entradas para Semantics labels

test/core/a11y/
├── amount_to_words_test.dart        # Unit tests del conversor (Dart puro)
└── screen_announce_test.dart        # Tests del helper de announce

test/a11y/
├── easy_mode_a11y_test.dart         # Widget tests a11y de todas las pantallas 001
├── fraud_shield_a11y_test.dart      # Widget tests a11y de pantallas 002
├── contextual_help_a11y_test.dart   # Widget tests a11y de pantallas 003
└── voice_assistant_a11y_test.dart   # Widget tests a11y de pantallas 004

docs/
└── talkback_test_checklist.md       # Guion de prueba manual con TalkBack
```

**No hay `lib/features/screen_reader_audit/`**: Esta feature no tiene lógica de dominio ni pantallas propias. Es transversal — agrega utilities en `core/` y tests que verifican las pantallas de otras features.

**Modificaciones a pantallas existentes**: Los widgets de 001-004 se modifican para agregar/corregir `Semantics`, `MergeSemantics`, `ExcludeSemantics`, `SemanticsService.announce`, y `Semantics.sortKey` donde sea necesario.

## Complexity Tracking

No hay violaciones que justificar.
