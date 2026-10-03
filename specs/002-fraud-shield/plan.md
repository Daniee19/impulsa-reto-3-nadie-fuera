# Implementation Plan: Escudo Antifraude

**Branch**: `002-fraud-shield` | **Date**: 2026-10-02 | **Spec**: `specs/002-fraud-shield/spec.md`

**Input**: Feature specification from `/specs/002-fraud-shield/spec.md`

## Summary

Motor de reglas de riesgo en Dart puro (domain layer, sin dependencia de Flutter) que evalúa cada pago o transferencia del Modo Fácil contra 4 reglas configurables: monto inusual, destinatario nuevo, frecuencia alta y horario inusual. Si se detecta riesgo, se interrumpe el flujo antes de la confirmación con una pantalla de pausa que explica el riesgo en lenguaje simple y ofrece 3 opciones (cancelar, continuar, consultar persona de confianza). Integra 006-trusted-person para la opción del familiar. Múltiples reglas se combinan en un solo mensaje.

## Technical Context

**Language/Version**: Flutter stable 3.x / Dart 3 (null safety), SDK ^3.13.4

**Primary Dependencies**: Ninguna nueva. Reutiliza todo de 001-easy-mode. Consume `trustedPersonProvider` de 006-trusted-person.

**Storage**: Historial de operaciones simulado en memoria (mock, reutiliza `OperationRepository` de 001). Umbrales de riesgo como constantes configurables en un objeto `RiskThresholds`.

**Testing**: Unit tests exhaustivos para el motor de reglas (Dart puro, sin widgets). Widget tests con a11y para la pantalla de alerta. Integration test: flujo pago → alerta → cancelar/continuar/consultar.

**Target Platform**: Android first (minSdk 26)

**Project Type**: Feature module dentro de la app Flutter existente

**Constraints**: Reglas simples con umbrales fijos. Datos ficticios. Tono empático, no alarmista.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Estado | Notas |
|-----------|--------|-------|
| I. Accessibility First | ✅ PASS | FR-010/011: pantalla de alerta con 48dp, 4.5:1, TalkBack announce al aparecer, opciones navegables |
| II. Stack & Dependency Governance | ✅ PASS | Sin dependencias nuevas. Motor de reglas en Dart puro |
| III. Clean Architecture by Feature | ✅ PASS | Motor de reglas en `domain/` (Dart puro). Pantalla en `presentation/`. Cross-feature via providers de 006 |
| IV. Security & Privacy | ✅ PASS | Sin datos sensibles adicionales. Historial es simulado. Aviso al familiar es simulado |
| V. Testing & Quality Gates | ✅ PASS | Motor de reglas 100% testeable sin UI. Widget tests a11y. Integration test por flujo |
| VI. UX for Cognitive Accessibility | ✅ PASS | FR-004/014: frases ≤15 palabras, lenguaje empático, sin jerga, nunca bloquea sin explicar |
| VII. Code Style & Localization | ✅ PASS | Mensajes de riesgo en ARB. Reglas nombradas en inglés (código). UI en español |

**Resultado**: Todos los gates pasan. Sin violaciones.

## Project Structure

### Documentation (this feature)

```text
specs/002-fraud-shield/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── risk-engine-contract.md
└── tasks.md             # (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/fraud_shield/
├── domain/
│   ├── entities/
│   │   ├── risk_rule.dart              # Enum de reglas de riesgo
│   │   ├── risk_alert.dart             # Resultado: reglas activadas + mensaje (freezed)
│   │   ├── risk_thresholds.dart        # Umbrales configurables (freezed)
│   │   └── operation_context.dart      # Contexto de operación a evaluar (freezed)
│   ├── services/
│   │   └── risk_engine.dart            # Motor de reglas — Dart puro, sin Flutter
│   └── repositories/
│       └── operation_history_repository.dart  # Interfaz para historial (reutiliza 001)
├── data/
│   └── repositories/
│       └── mock_operation_history_repository.dart  # Historial precargado
└── presentation/
    ├── providers/
    │   ├── risk_evaluation_provider.dart    # Evalúa riesgo para operación actual
    │   └── fraud_alert_provider.dart       # Estado de la alerta (reglas, opciones)
    ├── screens/
    │   └── fraud_alert_screen.dart         # Pantalla de pausa con 2-3 opciones
    └── widgets/
        └── risk_message_card.dart          # Card con mensaje de riesgo combinado

test/features/fraud_shield/
├── domain/
│   └── services/
│       └── risk_engine_test.dart           # Tests exhaustivos del motor (Dart puro)
└── presentation/
    └── screens/
        └── fraud_alert_screen_test.dart    # Widget test + a11y

integration_test/
└── fraud_shield_flow_test.dart
```

**Integración con 001-easy-mode**:
El motor se ejecuta en los providers de `pay_bill` y `send_money` de 001, ANTES de navegar a la pantalla de confirmación:
```
Usuario toca "Confirmar" en PayBillScreen/SendMoneyScreen
  → Provider evalúa riesgo via RiskEngine
  → Si riesgo detectado → navegar a FraudAlertScreen
  → Si sin riesgo → navegar a ConfirmScreen (flujo normal de 001)
```

**Integración con 006-trusted-person**:
```
FraudAlertScreen:
  final person = ref.watch(trustedPersonProvider).valueOrNull;
  if (person != null && person.hasPermission(TrustedPermission.securityAlerts)):
    mostrar 3 opciones (cancelar, continuar, consultar a [person.name])
  else:
    mostrar 2 opciones (cancelar, continuar)
```

**Structure Decision**: Feature module en `lib/features/fraud_shield/`. El motor de reglas (`RiskEngine`) vive en `domain/services/` como clase Dart pura sin dependencias de Flutter, totalmente testeable con unit tests. La pantalla de alerta es la única pieza de presentación.

## Complexity Tracking

No hay violaciones que justificar.
