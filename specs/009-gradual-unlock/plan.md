# Implementation Plan: Desbloqueo Gradual de Funciones

**Branch**: `009-gradual-unlock` | **Date**: 2026-10-03 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/009-gradual-unlock/spec.md`

## Summary

Sistema de feature flags por usuario que extiende la pantalla principal de 001-easy-mode con funciones extra desbloqueables. Métricas de confianza (operaciones exitosas, sesiones de práctica) guardadas localmente con SharedPreferences. Funciones extra simuladas (movimientos, recarga celular, pagar con QR) que aparecen cuando se cumplen umbrales. Integración con 008-practice-mode para probar antes de activar. Las 4 acciones originales siempre son principales; extras van en sección "Más funciones".

## Technical Context

**Language/Version**: Dart 3 (null safety) / Flutter stable 3.x

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state), `go_router` (navigation), `freezed` (models), `shared_preferences` (persistencia local)

**Storage**: SharedPreferences — feature flags y métricas de confianza persisten entre sesiones

**Testing**: `flutter_test` (unit + widget), integration tests

**Target Platform**: Android (minSdk 26)

**Project Type**: Mobile app (Flutter)

**Performance Goals**: N/A — lectura de flags al inicio, no frecuente

**Constraints**: Máximo 4 acciones primarias por pantalla (constitución). Extras en sección secundaria.

**Scale/Scope**: 3 funciones extra simuladas, 2 tipos de señales de confianza

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Accessibility First | PASS | Botones extra con 48×48 dp, 4.5:1 contraste, Semantics. Propuesta anunciada por TalkBack. Máximo 4 primarias por pantalla. |
| II. Stack & Dependency | PASS | `shared_preferences` (BSD-3) ya es dependencia común de Flutter. Sin deps nuevas no permitidas. |
| III. Clean Architecture | PASS | ConfidenceTracker y UnlockEvaluator en domain (Dart puro). FeatureFlagRepository en data. |
| IV. Security & Privacy | PASS | Métricas no contienen datos personales. Feature flags son preferencias de UI, no secretos. |
| V. Testing & Quality | PASS | Unit tests para evaluator y tracker. Widget tests para propuesta y sección extra. |
| VI. UX Cognitive | PASS | Propuesta ≤ 15 palabras, sin jerga. Sin gamificación. Reversible siempre. |
| VII. Code Style & Loc | PASS | Textos en ARB, código en inglés, Conventional Commits. |

**No violations. Gate passed.**

## Project Structure

### Documentation (this feature)

```text
specs/009-gradual-unlock/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/features/gradual_unlock/
├── domain/
│   ├── entities/
│   │   ├── extra_feature.dart          # ExtraFeature enum, ExtraFeatureConfig
│   │   ├── confidence_metrics.dart     # ConfidenceMetrics
│   │   └── unlock_proposal.dart        # UnlockProposal
│   └── services/
│       └── unlock_evaluator.dart       # Evalúa métricas → propuestas (Dart puro)
├── data/
│   └── repositories/
│       └── feature_flag_repository.dart  # SharedPreferences: flags + métricas
└── presentation/
    ├── providers/
    │   ├── feature_flags_provider.dart    # Estado de flags activos
    │   └── unlock_proposal_provider.dart  # Controla propuestas pendientes
    ├── widgets/
    │   ├── unlock_proposal_card.dart      # Card de propuesta con 3 opciones
    │   └── extra_features_section.dart    # Sección "Más funciones"
    └── screens/
        ├── transaction_history_screen.dart  # Ver movimientos (simulado)
        ├── mobile_recharge_screen.dart      # Recargar celular (simulado)
        └── qr_payment_screen.dart           # Pagar con QR (simulado)
```

**Structure Decision**: Feature module propio para el sistema de desbloqueo. Las pantallas de funciones extra (movimientos, recarga, QR) viven aquí porque son simulaciones simples. La pantalla principal de 001 se extiende (no se duplica) consumiendo el `featureFlagsProvider` para decidir qué mostrar.

## Complexity Tracking

> No violations — table not needed.
