# Implementation Plan: Contratos Explicados en Audio

**Branch**: `010-audio-contracts` | **Date**: 2026-10-03 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/010-audio-contracts/spec.md`

## Summary

Pantalla de resumen de contrato con lectura TTS por secciones (reutilizando `flutter_tts` de 004) y controles de reproducción (pausar, repetir sección, 3 niveles de velocidad). Contratos de ejemplo como contenido estático en JSON/ARB con resumen en lenguaje simple de 4 secciones fijas. Botón "Aceptar" deshabilitado hasta completar la lectura por audio o scroll. Integración con el asistente (004) para preguntas. Contrato completo disponible con lectura selectiva de párrafos.

## Technical Context

**Language/Version**: Dart 3 (null safety) / Flutter stable 3.x

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state), `go_router` (navigation), `freezed` (models), `flutter_tts` (de 004)

**Storage**: N/A — contratos son contenido estático. Sesión de revisión efímera.

**Testing**: `flutter_test` (unit + widget), integration tests

**Target Platform**: Android (minSdk 26)

**Project Type**: Mobile app (Flutter)

**Performance Goals**: Resumen completo leído en < 3 minutos a velocidad normal (SC-004)

**Constraints**: Botón "Aceptar" bloqueado hasta completar revisión. Sin aceptación sin resumen.

**Scale/Scope**: 2 contratos de ejemplo (cuenta de ahorro, préstamo personal), 4 secciones cada uno

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Accessibility First | PASS | Controles TTS 48×48 dp, 4.5:1 contraste, Semantics labels, TalkBack anuncia secciones y estado de botón. |
| II. Stack & Dependency | PASS | `flutter_tts` ya presente por 004. Sin dependencias nuevas. |
| III. Clean Architecture | PASS | ContractSummary en domain (Dart puro). ContractRepository en data. TTS en presentation via service de 004. |
| IV. Security & Privacy | PASS | Contratos ficticios. Sin datos personales. |
| V. Testing & Quality | PASS | Unit tests para lógica de habilitación. Widget tests con a11y. Integration test de flujo completo. |
| VI. UX Cognitive | PASS | Resumen ≤ 15 palabras/oración, sin jerga financiera. 4 secciones claras. Controles intuitivos. |
| VII. Code Style & Loc | PASS | Textos de contratos y UI en ARB, código en inglés. |

**No violations. Gate passed.**

## Project Structure

### Documentation (this feature)

```text
specs/010-audio-contracts/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/features/audio_contracts/
├── domain/
│   ├── entities/
│   │   ├── contract_summary.dart        # ContractSummary, ContractSection
│   │   └── review_session.dart          # ReviewSession (estado de lectura)
│   └── repositories/
│       └── contract_repository.dart     # Interface abstracta
├── data/
│   ├── repositories/
│   │   └── mock_contract_repository.dart  # Implementación con datos estáticos
│   └── contracts/                        # JSON estático de contratos de ejemplo
│       ├── savings_account.json
│       └── personal_loan.json
└── presentation/
    ├── providers/
    │   └── contract_review_provider.dart  # Orquesta sesión, TTS, habilitación
    ├── widgets/
    │   ├── tts_playback_controls.dart     # Pausar, repetir, velocidad
    │   └── accept_button.dart             # Botón condicional
    └── screens/
        ├── contract_summary_screen.dart   # Resumen con TTS automático
        └── full_contract_screen.dart      # Contrato completo con lectura selectiva
```

**Structure Decision**: Feature module propio. Contratos de ejemplo como JSON en `data/contracts/`. Los textos del resumen van en ARB (localizables) pero la estructura de 4 secciones se define en el JSON. El servicio TTS de 004 se reutiliza.

## Complexity Tracking

> No violations — table not needed.
