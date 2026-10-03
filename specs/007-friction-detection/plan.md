# Implementation Plan: Detección de Fricción

**Branch**: `007-friction-detection` | **Date**: 2026-10-03 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/007-friction-detection/spec.md`

## Summary

Detector de fricción en capa domain que observa tres señales — retrocesos repetidos (3+), inactividad prolongada (20+ s) y errores repetidos (3+ del mismo tipo) — dentro de flujos activos del Modo Fácil. Reutiliza el NavigationObserver y el provider de contexto de 003. Cuando detecta fricción, muestra un ofrecimiento no intrusivo con tres opciones que delegan a 004 (explicación por voz) o a 003 (ayuda humana con contexto enriquecido). Nunca se activa en pantallas de confirmación de pago, alertas de fraude ni consentimientos.

## Technical Context

**Language/Version**: Dart 3 (null safety) / Flutter stable 3.x

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state), `go_router` (navigation), `freezed` (models)

**Storage**: N/A — estado efímero en providers de Riverpod

**Testing**: `flutter_test` (unit + widget), integration tests

**Target Platform**: Android (minSdk 26)

**Project Type**: Mobile app (Flutter)

**Performance Goals**: Ofrecimiento aparece en < 2 s tras detectar señal (SC-003)

**Constraints**: Sin interrupciones en pantallas de confirmación de pago/fraude/consentimiento

**Scale/Scope**: ~50 pantallas Modo Fácil, 3 señales de fricción

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Accessibility First | PASS | Touch targets 48×48 dp, contraste 4.5:1, Semantics labels, SemanticsService.announce para ofrecimiento. FR-010/FR-012. |
| II. Stack & Dependency | PASS | Solo usa riverpod, go_router, freezed (ya instalados). Sin dependencias nuevas. |
| III. Clean Architecture | PASS | FrictionDetector en domain (Dart puro). Presentación: overlay widget. Providers en presentation. |
| IV. Security & Privacy | PASS | No persiste datos. Contexto de fricción pasa por ContextCollector de 003 (filtra datos sensibles). |
| V. Testing & Quality | PASS | Unit tests para detector (domain). Widget tests con a11y guidelines. Integration test de flujo completo. |
| VI. UX Cognitive | PASS | Frases ≤ 15 palabras, sin jerga, lenguaje empático. "Parece que necesitas ayuda con este paso." |
| VII. Code Style & Loc | PASS | Textos en ARB, código en inglés, Conventional Commits. |

**No violations. Gate passed.**

## Project Structure

### Documentation (this feature)

```text
specs/007-friction-detection/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/features/friction_detection/
├── domain/
│   ├── entities/
│   │   ├── friction_signal.dart        # FrictionSignal, FrictionType enum
│   │   └── friction_offer.dart         # FrictionOffer (ofrecimiento)
│   └── services/
│       └── friction_detector.dart      # FrictionDetector (Dart puro, umbrales configurables)
├── data/
│   └── (sin datasources — estado efímero en providers)
└── presentation/
    ├── providers/
    │   └── friction_provider.dart       # Orquesta detector + observer + exclusiones
    ├── widgets/
    │   └── friction_offer_overlay.dart  # Overlay con las 3 opciones
    └── (sin screens — el overlay aparece sobre la pantalla actual)
```

**Structure Decision**: Feature module dentro de `lib/features/`. El detector vive en domain (Dart puro, sin imports de Flutter). El overlay se inyecta via el ShellRoute existente de 003 (que ya envuelve las pantallas del Modo Fácil). Sin screens propias — el ofrecimiento es un widget overlay, no una ruta nueva.

## Complexity Tracking

> No violations — table not needed.
