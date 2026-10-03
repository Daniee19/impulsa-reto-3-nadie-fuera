# Implementation Plan: Asistente de Voz y Texto

**Branch**: `004-voice-text-assistant` | **Date**: 2026-10-02 | **Spec**: `specs/004-voice-text-assistant/spec.md`

**Input**: Feature specification from `/specs/004-voice-text-assistant/spec.md`

## Summary

Asistente que acepta entrada por voz (micrófono) y texto (teclado) en español peruano. Interpreta frases naturales y las mapea a una lista cerrada de 4 intenciones (consultar saldo, pagar recibo, enviar dinero, pedir ayuda) o "no entendí". Nunca ejecuta operaciones: solo prepara la operación, lee un resumen en voz alta con datos reales (nunca generados por IA), y pide confirmación biométrica. Toda operación monetaria pasa por el escudo antifraude (002) antes de ejecutarse. El audio no se almacena. Consentimiento explícito de micrófono (Ley 29733).

## Technical Context

**Language/Version**: Flutter stable 3.x / Dart 3 (null safety), SDK ^3.13.4

**Primary Dependencies (3 nuevas)**:
| Package | Version | License | Purpose |
|---------|---------|---------|---------|
| `speech_to_text` | ^7.5.0 | MIT | Reconocimiento de voz en español en el dispositivo |
| `flutter_tts` | ^4.2.5 | MIT | Síntesis de voz en español |
| `local_auth` | ^3.0.2 | BSD-3-Clause | Confirmación biométrica (huella + PIN fallback) |

**Reutiliza de 001**: Arquitectura, theme, router, widgets accesibles, repositorios mock (Account, Bill, Contact, Operation).

**Consume de 002**: `RiskEngine.evaluate()` para interceptar operaciones monetarias antes de confirmación.

**Consume de 003**: `HelpFab` / flujo de ayuda cuando la intención es "pedir ayuda".

**Storage**: Consentimiento de micrófono en `SharedPreferences` (no es dato sensible — solo un bool). Audio NO se almacena.

**Testing**: Unit tests para IntentParser (Dart puro, ≥80% coverage). Widget tests con a11y para pantallas del asistente. Integration test: voz → intención → preparar operación → fraude → confirmación biométrica.

**Target Platform**: Android first (minSdk 26)

**Project Type**: Feature module dentro de la app Flutter existente

**Constraints**: Lista cerrada de intenciones. IA no ejecuta operaciones. Datos reales del repositorio, nunca generados por IA. Consentimiento de micrófono obligatorio. Audio efímero.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Estado | Notas |
|-----------|--------|-------|
| I. Accessibility First | ✅ PASS | Botón de activación 48dp con Semantics label. Respuestas leídas en voz alta (TTS). Controles de confirmación accesibles. Campo de texto alternativo si no hay micrófono. Announce en cambios de estado |
| II. Stack & Dependency Governance | ✅ PASS | 3 nuevas dependencias: speech_to_text (MIT), flutter_tts (MIT), local_auth (BSD-3-Clause). Todas con licencias aprobadas. local_auth ya mencionada en la constitución |
| III. Clean Architecture by Feature | ✅ PASS | IntentParser en `domain/services/` (Dart puro). Pantallas en `presentation/`. Integración con 001/002/003 via providers |
| IV. Security & Privacy | ✅ PASS | IA recibe datos anonimizados. Intenciones de lista cerrada. IA no ejecuta transacciones. Montos del repositorio, nunca de IA. Audio no almacenado. Consentimiento micrófono (Ley 29733). Biometría via local_auth con PIN fallback |
| V. Testing & Quality Gates | ✅ PASS | Unit tests IntentParser ≥80%. Widget tests a11y. Integration test flujo completo |
| VI. UX for Cognitive Accessibility | ✅ PASS | ≤15 palabras en respuestas. Sin jerga. Resumen leído en voz alta antes de confirmar. Si no entiende, pregunta en vez de adivinar |
| VII. Code Style & Localization | ✅ PASS | Textos en ARB. snake_case. Conventional Commits |

**Resultado**: Todos los gates pasan.

## Project Structure

### Documentation (this feature)

```text
specs/004-voice-text-assistant/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── assistant-service-contract.md
└── tasks.md             # (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/voice_assistant/
├── domain/
│   ├── entities/
│   │   ├── assistant_intent.dart            # Enum de intenciones + ParsedIntent (freezed)
│   │   ├── voice_session.dart               # Sesión del asistente (freezed)
│   │   └── operation_summary.dart           # Resumen de operación para TTS (freezed)
│   └── services/
│       ├── intent_parser.dart               # Interpreta frases → intención (Dart puro)
│       └── operation_preparer.dart          # Prepara operación con datos reales (Dart puro)
├── data/
│   └── services/
│       ├── speech_recognition_service.dart  # Wrapper de speech_to_text
│       ├── text_to_speech_service.dart       # Wrapper de flutter_tts
│       └── biometric_auth_service.dart      # Wrapper de local_auth
└── presentation/
    ├── providers/
    │   ├── voice_assistant_provider.dart     # Orquesta el flujo completo
    │   ├── speech_provider.dart             # Estado de speech_to_text
    │   └── microphone_consent_provider.dart # Consentimiento de micrófono
    ├── screens/
    │   ├── voice_assistant_screen.dart       # Pantalla principal del asistente
    │   ├── microphone_consent_screen.dart   # Consentimiento primera vez
    │   └── operation_summary_screen.dart    # Resumen + confirmación biométrica
    └── widgets/
        ├── voice_input_button.dart          # Botón de micrófono
        ├── text_input_field.dart            # Campo de texto alternativo
        ├── assistant_message.dart           # Burbuja de respuesta del asistente
        └── intent_options.dart              # Lista de opciones cuando no entiende

test/features/voice_assistant/
├── domain/
│   └── services/
│       ├── intent_parser_test.dart          # Unit tests del parser (Dart puro)
│       └── operation_preparer_test.dart     # Unit tests del preparador
└── presentation/
    └── screens/
        ├── voice_assistant_screen_test.dart
        └── operation_summary_screen_test.dart

integration_test/
└── voice_assistant_flow_test.dart
```

**Integración con 001**: Usa AccountRepository, BillRepository, ContactRepository para resolver datos reales. Usa OperationRepository para ejecutar la operación tras confirmación.

**Integración con 002**: Llama `RiskEngine.evaluate()` después de preparar la operación y antes de la confirmación biométrica. Si hay alerta, navega a FraudAlertScreen (002).

**Integración con 003**: Si la intención es "pedir ayuda", delega al flujo de HelpFab/HelpContactPickerScreen (003).

**Ruta del asistente**: `/easy-mode/assistant` como acción adicional accesible desde la pantalla principal.

## Complexity Tracking

No hay violaciones que justificar.
