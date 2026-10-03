# Implementation Plan: Recordatorios de Pagos Recurrentes

**Branch**: `012-payment-reminders` | **Date**: 2026-10-03 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/012-payment-reminders/spec.md`

## Summary

Recordatorios de pagos recurrentes mostrados in-app en la pantalla principal del Modo Fácil. Reutiliza `Bill` de 001 (con datos mock ampliados a 4 recibos) y la persona de confianza de 006 (aviso simulado opcional). Configuración por usuario: qué recibos avisar y anticipación (1/3/5 días). Lectura TTS automática del recordatorio más urgente. Botón "Pagar ahora" navega al flujo de pago de 001 con recibo preseleccionado. Para el hackathon, fechas simuladas y notificaciones in-app (no push).

## Technical Context

**Language/Version**: Dart 3 (null safety) / Flutter stable 3.x

**Primary Dependencies**: `flutter_riverpod` + `riverpod_annotation` (state), `go_router` (navigation), `freezed` (models), `flutter_tts` (de 004)

**Storage**: `SharedPreferences` para configuración de recordatorios (qué recibos, anticipación, compartir). No son datos sensibles.

**Testing**: `flutter_test` (unit + widget), integration tests

**Target Platform**: Android (minSdk 26)

**Project Type**: Mobile app (Flutter)

**Performance Goals**: Del recordatorio al pago completado en < 60 segundos (SC-003)

**Constraints**: Nunca interrumpe operaciones. Fechas simuladas para hackathon. Sin notificaciones push.

**Scale/Scope**: 4 recibos simulados (luz, agua, teléfono, pensión)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Accessibility First | PASS | Botones 48×48 dp, 4.5:1 contraste, Semantics labels, TalkBack anuncia recordatorio + opciones. Lectura TTS automática. |
| II. Stack & Dependency | PASS | Sin deps nuevas. `flutter_tts` de 004, SharedPreferences permitido. `flutter_local_notifications` evaluado y descartado (ver research). |
| III. Clean Architecture | PASS | ReminderConfig en domain (Dart puro). ReminderConfigRepository en data. Providers en presentation. |
| IV. Security & Privacy | PASS | Datos ficticios. Aviso a persona de confianza sin monto/saldo (FR-010, Ley 29733). Consentimiento explícito. |
| V. Testing & Quality | PASS | Unit tests para lógica de generación. Widget tests con a11y. |
| VI. UX Cognitive | PASS | Fechas en lenguaje natural ("mañana", "el viernes"). ≤ 15 palabras. Sin jerga. |
| VII. Code Style & Loc | PASS | Textos en ARB. Código en inglés. |

**No violations. Gate passed.**

## Project Structure

### Documentation (this feature)

```text
specs/012-payment-reminders/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/features/payment_reminders/
├── domain/
│   ├── entities/
│   │   ├── reminder.dart              # Reminder, ReminderState
│   │   └── reminder_config.dart       # ReminderConfig, AnticipationDays
│   └── services/
│       └── reminder_generator.dart    # Genera recordatorios desde bills + config
├── data/
│   └── repositories/
│       └── reminder_config_repository.dart  # SharedPreferences implementation
└── presentation/
    ├── providers/
    │   ├── reminder_provider.dart          # Active reminders for home screen
    │   └── reminder_config_provider.dart   # Configuration state
    ├── widgets/
    │   ├── reminder_card.dart             # Card con "Pagar ahora" / "Ya lo sé"
    │   └── reminder_config_tile.dart      # Toggle per-bill en configuración
    └── screens/
        └── reminder_config_screen.dart    # "Mis recordatorios" en configuración
```

**Structure Decision**: Feature module propio. Reutiliza `Bill` y `BillRepository` de 001 (no duplica datos de recibos). `ReminderGenerator` es Dart puro en domain — recibe bills, config y fecha actual, retorna lista de reminders.

## Complexity Tracking

> No violations — table not needed.
