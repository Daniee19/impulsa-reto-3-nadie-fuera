# Implementation Plan: Microlecciones contra Estafas

**Branch**: `011-scam-lessons` | **Date**: 2026-10-03 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/011-scam-lessons/spec.md`

## Summary

Microlecciones educativas sobre fraudes comunes en Perú (3-5 lecciones estáticas en JSON). Cada lección tiene texto simple, audio TTS (reutilizando `flutter_tts` de 004), y una pregunta de práctica con opciones y retroalimentación diferenciada. Se sugieren contextualmente después de una alerta del Escudo antifraude (002) mapeando tipo de alerta → lección relevante. Nunca interrumpen operaciones. Accesibles desde lista en ayuda/configuración. Sin gamificación.

## Technical Context

**Language/Version**: Dart 3 (null safety) / Flutter stable 3.x

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state), `go_router` (navigation), `freezed` (models), `flutter_tts` (de 004)

**Storage**: `SharedPreferences` para estado de lecciones (completada/no vista) y contador de rechazos. No son datos sensibles.

**Testing**: `flutter_test` (unit + widget), integration tests

**Target Platform**: Android (minSdk 26)

**Project Type**: Mobile app (Flutter)

**Performance Goals**: Cada lección consumible en < 1 minuto (FR-002). Texto ≤ 150 palabras, audio ≤ 60 segundos.

**Constraints**: Sugerencias solo post-operación (nunca durante). Máximo una sugerencia por evento de alerta. 3 rechazos consecutivos = dejar de sugerir.

**Scale/Scope**: 3-5 lecciones estáticas para hackathon (FR-014)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Accessibility First | PASS | Opciones de pregunta 48×48 dp, 4.5:1 contraste, Semantics labels en español. TalkBack anuncia sugerencia, contenido y retroalimentación. |
| II. Stack & Dependency | PASS | `flutter_tts` ya presente por 004. SharedPreferences permitido. Sin deps nuevas. |
| III. Clean Architecture | PASS | Lesson, PracticeQuestion en domain (Dart puro). LessonRepository abstracto. Providers en presentation. |
| IV. Security & Privacy | PASS | Contenido educativo ficticio. Sin datos personales. Estado binario (vista/no vista). |
| V. Testing & Quality | PASS | Unit tests para lógica de sugerencia y evaluación de respuestas. Widget tests con a11y. |
| VI. UX Cognitive | PASS | ≤ 15 palabras/oración. Sin jerga. Tono amable en retroalimentación (sin "Incorrecto"/"Error"). |
| VII. Code Style & Loc | PASS | Textos de lecciones en ARB. Código en inglés. |

**No violations. Gate passed.**

## Project Structure

### Documentation (this feature)

```text
specs/011-scam-lessons/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/features/scam_lessons/
├── domain/
│   ├── entities/
│   │   ├── lesson.dart                # Lesson, PracticeQuestion, AnswerOption
│   │   └── lesson_suggestion.dart     # LessonSuggestion, SuggestionTrigger
│   └── repositories/
│       └── lesson_repository.dart     # Interface abstracta
├── data/
│   └── repositories/
│       └── mock_lesson_repository.dart  # Datos estáticos desde ARB
└── presentation/
    ├── providers/
    │   ├── lesson_provider.dart         # Estado de lección activa + TTS
    │   └── lesson_suggestion_provider.dart  # Lógica de sugerencia contextual
    ├── widgets/
    │   ├── lesson_suggestion_card.dart  # Card de sugerencia post-alerta
    │   ├── practice_question_widget.dart # Pregunta + opciones + retroalimentación
    │   └── lesson_list_tile.dart        # Item de la lista de lecciones
    └── screens/
        ├── lesson_screen.dart           # Contenido + audio + pregunta
        └── lesson_list_screen.dart      # Lista de todas las lecciones
```

**Structure Decision**: Feature module propio. Contenido de lecciones como constantes en el repositorio mock con textos de ARB. El mapeo alerta→lección es estático (constante en domain).

## Complexity Tracking

> No violations — table not needed.
