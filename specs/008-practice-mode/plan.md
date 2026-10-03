# Implementation Plan: Modo Práctica

**Branch**: `008-practice-mode` | **Date**: 2026-10-03 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/008-practice-mode/spec.md`

## Summary

Modo sandbox que reutiliza las pantallas y flujos existentes de 001-easy-mode sin duplicarlos, intercambiando los repositorios por implementaciones de práctica via un Riverpod provider scope override. Variante visual del tema (color de acento + banner permanente) y anuncios TTS al entrar/salir. Simula una alerta del escudo antifraude (002) con explicación educativa. Guía paso a paso opcional superpuesta. Tests garantizan aislamiento total de datos reales.

## Technical Context

**Language/Version**: Dart 3 (null safety) / Flutter stable 3.x

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state), `go_router` (navigation), `freezed` (models)

**Storage**: N/A — estado efímero en providers de Riverpod. No persiste entre sesiones.

**Testing**: `flutter_test` (unit + widget), integration tests

**Target Platform**: Android (minSdk 26)

**Project Type**: Mobile app (Flutter)

**Performance Goals**: N/A — mismos flujos que 001, sin requisitos adicionales de rendimiento

**Constraints**: Aislamiento total: ninguna operación de práctica toca repositorios reales

**Scale/Scope**: Mismas ~50 pantallas que 001, con overlay de guía y variante visual

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Accessibility First | PASS | Banner con contraste 4.5:1, announce TTS al entrar/salir/navegar, áreas 48×48 dp. FR-015/FR-016. |
| II. Stack & Dependency | PASS | Sin dependencias nuevas. Reutiliza riverpod, go_router, freezed (ya instalados). |
| III. Clean Architecture | PASS | PracticeSession en domain. Repositorios de práctica implementan mismas interfaces abstractas de 001. Provider overrides en presentation. |
| IV. Security & Privacy | PASS | Datos ficticios completamente aislados. Sin datos reales accesibles en modo práctica. |
| V. Testing & Quality | PASS | Unit tests para aislamiento de datos. Widget tests con a11y. Integration test que verifica que repo real nunca se llama en modo práctica. |
| VI. UX Cognitive | PASS | Frases ≤ 15 palabras, sin jerga. Guía en lenguaje simple. Sin gamificación. |
| VII. Code Style & Loc | PASS | Textos en ARB, código en inglés, Conventional Commits. |

**No violations. Gate passed.**

## Project Structure

### Documentation (this feature)

```text
specs/008-practice-mode/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/features/practice_mode/
├── domain/
│   ├── entities/
│   │   └── practice_session.dart       # PracticeSession, PracticeGuideStep
│   └── services/
│       └── (vacío — la lógica vive en el provider override, no en un service nuevo)
├── data/
│   └── repositories/
│       ├── practice_account_repository.dart   # Implementa AccountRepository con datos ficticios
│       ├── practice_bill_repository.dart       # Implementa BillRepository con datos ficticios
│       ├── practice_contact_repository.dart    # Implementa ContactRepository con datos ficticios
│       └── practice_operation_repository.dart  # Implementa OperationRepository (descarta ops)
└── presentation/
    ├── providers/
    │   └── practice_mode_provider.dart        # Controla sesión activa, guía, tema
    ├── widgets/
    │   ├── practice_banner.dart               # Banner permanente "Modo práctica"
    │   └── practice_guide_overlay.dart        # Instrucciones paso a paso superpuestas
    └── screens/
        └── practice_entry_screen.dart         # Pantalla de entrada (anuncia, ofrece guía)
```

**Structure Decision**: Repositorios de práctica en `data/repositories/` implementan las mismas interfaces abstractas de `lib/features/easy_mode/domain/repositories/`. El ProviderScope override en la ruta de práctica los inyecta. No se duplican screens de 001 — se reutilizan con datos distintos. Las rutas de práctica son sub-rutas bajo `/easy-mode/practice/`.

## Complexity Tracking

> No violations — table not needed.
