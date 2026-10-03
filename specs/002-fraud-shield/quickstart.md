# Quickstart: Escudo Antifraude (002-fraud-shield)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Features 001-easy-mode y 006-trusted-person implementadas
- Historial de operaciones precargado (mock) para que las reglas tengan línea base
- Android emulator o dispositivo con API 26+
- TalkBack para pruebas de accesibilidad

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Validation Scenarios

### VS-1: Alerta por monto inusual (US1 — P1)

1. Historial precargado: pagos de luz entre S/ 40 y S/ 130 (promedio ~S/ 100)
2. Ir a "Pagar recibo" → seleccionar un recibo con monto S/ 850
3. **Expected**: Antes de la confirmación, aparece pantalla de pausa: "Este pago es mucho más alto de lo que sueles pagar. Solo queremos asegurarnos."
4. Verificar 3 opciones: "Cancelar", "Continuar de todos modos", "Consultar a Valeria"
5. Tocar "Cancelar" → vuelve a la lista de recibos con datos preservados
6. Repetir, tocar "Continuar" → avanza a la confirmación normal de 001
7. **A11y check**: TalkBack anuncia la alerta al aparecer, lee las 3 opciones en orden

### VS-2: Alerta por destinatario nuevo (US2 — P1)

1. Ir a "Enviar dinero" → seleccionar un contacto al que nunca se ha enviado (si todos tienen historial, agregar uno nuevo en mock)
2. Ingresar monto normal (S/ 50)
3. **Expected**: Pantalla de pausa: "Nunca le has enviado dinero a esta persona."
4. TalkBack lee la alerta completa
5. Tocar "Consultar a Valeria" → aparece mensaje: "Le avisamos a Valeria. Puedes esperarle o continuar."

### VS-3: Alerta por frecuencia alta (US3 — P2)

1. Completar 3 pagos/transferencias rápidamente (en menos de 10 minutos)
2. Iniciar una 4ta operación
3. **Expected**: Pantalla de pausa: "Has hecho varios pagos seguidos. ¿Está todo bien?"
4. Tocar "Cancelar" → vuelve sin restricción para operaciones futuras

### VS-4: Alerta por horario inusual (US4 — P3)

1. Configurar hora del dispositivo/emulador a las 2:00 AM (o mockear timestamp en el provider)
2. Iniciar cualquier operación monetaria
3. **Expected**: Pantalla de pausa: "Estás haciendo un pago a una hora poco habitual."

### VS-5: Combinación de señales (US5 — P2)

1. Enviar monto alto (>2x promedio) a destinatario nuevo
2. **Expected**: UNA sola pantalla de pausa con mensaje combinado: "Nunca le has enviado dinero a esta persona y el monto es más alto de lo habitual."
3. **Key check**: NO aparecen dos alertas separadas
4. Las 3 opciones aplican a toda la operación

### VS-6: Sin persona de confianza (edge case)

1. Quitar persona de confianza (via 006)
2. Triggerear cualquier regla de riesgo
3. **Expected**: Pantalla de pausa con solo 2 opciones: "Cancelar" y "Continuar de todos modos". NO aparece opción de consultar.

### VS-7: Operación sin riesgo (happy path)

1. Pagar un recibo con monto normal, a servicio habitual, en horario normal, sin frecuencia alta
2. **Expected**: Flujo directo a la confirmación de 001. Sin pantalla de pausa. El escudo es transparente.

### VS-8: Permiso de seguridad desactivado (integración con 006)

1. Con persona de confianza registrada, desactivar permiso "Avisos de seguridad"
2. Triggerear regla de riesgo
3. **Expected**: Pantalla de pausa con solo 2 opciones. "Consultar" NO aparece aunque hay persona registrada.

## Automated Tests

```bash
# Unit tests del motor de reglas (Dart puro, rápidos)
flutter test test/features/fraud_shield/domain/

# Widget tests (pantalla de alerta + a11y)
flutter test test/features/fraud_shield/presentation/

# Integration test (flujo completo)
flutter test integration_test/fraud_shield_flow_test.dart
```

### Tests del motor de reglas (cobertura exhaustiva)

```
test: monto normal → no alert
test: monto > 2x promedio → alert con unusualAmount
test: monto > 2x pero sin historial → no alert (beneficio de la duda)
test: destinatario nuevo → alert con newRecipient
test: destinatario conocido → no alert
test: 4 ops en 10 min → alert con highFrequency
test: 3 ops en 10 min → no alert (umbral es >3)
test: operación a las 3 AM → alert con unusualTime
test: operación a las 9 AM → no alert
test: monto alto + destinatario nuevo → alert con ambas reglas
test: las 4 reglas juntas → alert con 4 reglas
test: umbrales custom (copyWith) → respeta override
```

### A11y guidelines en widget tests

```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Test específico: `SemanticsService.announce` se llama al mostrar la alerta (FR-011).

## Definition of Done

- [ ] Motor de reglas evalúa las 4 reglas, Dart puro, sin dependencias de Flutter
- [ ] Umbrales configurables via `RiskThresholds`
- [ ] Toda operación monetaria pasa por el motor antes de confirmación
- [ ] Pantalla de pausa con mensaje empático ≤15 palabras
- [ ] 3 opciones con persona de confianza, 2 sin ella
- [ ] Múltiples reglas → una sola pantalla combinada
- [ ] "Cancelar" preserva datos del formulario
- [ ] "Continuar" avanza a confirmación normal de 001
- [ ] Mensajes en ARB, sin jerga
- [ ] `flutter analyze` 0 warnings
- [ ] Tests verdes: unit motor ≥90%, widget a11y, integration
