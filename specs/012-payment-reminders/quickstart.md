# Quickstart: Recordatorios de Pagos Recurrentes (012-payment-reminders)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Feature 001-easy-mode implementada (pantalla principal, flujo de pago, BillRepository)
- Feature 004-voice-text-assistant implementada (TtsService)
- Feature 006-trusted-person implementada (trustedPersonProvider)
- Android emulator o dispositivo con API 26+
- TalkBack para pruebas de accesibilidad

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Validation Scenarios

### VS-1: Recordatorio visible al abrir la app (US1 — P1, FR-001)

1. Configurar mock data para que un recibo venza dentro de 3 días (default)
2. Abrir la app → Modo Fácil
3. **Expected**: Recordatorio visible en la pantalla principal
4. **Expected**: Mensaje en lenguaje natural: "Tu recibo de luz vence el viernes: 85 soles"
5. **Expected**: Dos botones: "Pagar ahora" y "Ya lo sé, gracias"
6. **Expected**: TTS lee el recordatorio automáticamente
7. **A11y check**: TalkBack anuncia el recordatorio completo + opciones

### VS-2: "Pagar ahora" navega al flujo de pago prellenado (US1 — P1, FR-003, SC-003)

1. Desde el recordatorio de luz, tocar "Pagar ahora"
2. **Expected**: Se abre el flujo de pago de recibos (001)
3. **Expected**: Recibo de luz preseleccionado
4. **Expected**: Monto prellenado (S/ 85.50)
5. **Expected**: Solo falta confirmar (confirmación + biometría)
6. Completar el pago
7. Volver a pantalla principal
8. **Expected**: El recordatorio de luz ya no aparece (bill pagado)

### VS-3: "Ya lo sé, gracias" descarta el recordatorio (US1 — P1, FR-003)

1. Desde un recordatorio, tocar "Ya lo sé, gracias"
2. **Expected**: Recordatorio desaparece
3. Navegar por la app, volver a pantalla principal
4. **Expected**: El recordatorio NO reaparece (descartado para esa fecha)

### VS-4: Configurar qué recibos avisar (US2 — P1, FR-005, SC-004)

1. Ir a Configuración → "Mis recordatorios"
2. **Expected**: Lista de 4 recibos con interruptor: Luz, Agua, Teléfono, Pensión
3. **Expected**: Todos activos por defecto
4. Desactivar "Teléfono"
5. Volver a pantalla principal
6. **Expected**: Si teléfono estaba próximo a vencer, su recordatorio NO aparece
7. Reactivar "Teléfono"
8. **Expected**: Recordatorio de teléfono reaparece (si está en ventana)

### VS-5: Cambiar días de anticipación (US2 — P1, FR-006)

1. Ir a Configuración → "Mis recordatorios"
2. **Expected**: Opción de anticipación con 3 opciones: 1 día, 3 días (default), 5 días
3. Cambiar de 3 a 1 día
4. Volver a pantalla principal
5. **Expected**: Recibos que vencen en 2-3 días ya NO generan recordatorio
6. **Expected**: Solo recibos que vencen mañana o hoy generan recordatorio

### VS-6: Compartir con persona de confianza (US3 — P2, FR-008, FR-009, FR-010)

1. Prerequisito: persona de confianza registrada (006)
2. Ir a Configuración → "Mis recordatorios"
3. **Expected**: Opción "Avisar también a {nombre de persona de confianza}"
4. Activar la opción
5. **Expected**: Dialog de consentimiento explicando qué datos se comparten
6. Aceptar consentimiento
7. Volver a pantalla principal con recordatorio activo
8. **Expected**: Badge "También se avisó a {nombre}" en el recordatorio
9. **Verify**: El aviso NO incluye monto, saldo ni datos de cuenta (SC-007)

### VS-7: Sin persona de confianza (edge case)

1. Sin persona de confianza registrada
2. Ir a Configuración → "Mis recordatorios"
3. **Expected**: La opción "Avisar a persona de confianza" NO aparece

### VS-8: Varios recordatorios simultáneos (US5 — P2, FR-004)

1. Configurar mock data para que 2+ recibos venzan esta semana
2. Abrir la app
3. **Expected**: Ambos recordatorios visibles, ordenados por fecha (más próximo primero)
4. **Expected**: TTS lee solo el primero (más urgente)
5. **Expected**: Cada uno tiene su botón "Pagar ahora" independiente
6. Tocar "Pagar ahora" en el segundo
7. **Expected**: Flujo de pago para ese recibo específico, el primero sigue visible

### VS-9: Recibo vencido (edge case, FR-011)

1. Configurar mock data para que un recibo haya vencido ayer
2. Abrir la app
3. **Expected**: Recordatorio con mensaje en pasado: "Tu recibo de agua venció ayer. Aún puedes pagarlo"
4. **Expected**: Card con fondo de color diferente (error container)
5. **Expected**: "Pagar ahora" sigue disponible
6. Configurar recibo vencido hace 4 días
7. **Expected**: NO aparece recordatorio (> 3 días de vencimiento)

### VS-10: Accesibilidad con TalkBack (US4 — P2, FR-014, SC-006)

1. Activar TalkBack
2. Abrir la app con recordatorio activo
3. **Expected**: TalkBack anuncia el recordatorio (servicio, fecha, monto)
4. Navegar opciones con swipe
5. **Expected**: "Pagar ahora" y "Ya lo sé, gracias" anunciados
6. Elegir "Pagar ahora"
7. **Expected**: Flujo de pago navegable por TalkBack con recibo preseleccionado
8. **Expected**: Todos los botones ≥ 48×48 dp

## Automated Tests

```bash
# Unit tests del ReminderGenerator (Dart puro)
flutter test test/features/payment_reminders/domain/

# Unit tests del ReminderConfigRepository (SharedPreferences mock)
flutter test test/features/payment_reminders/data/

# Widget tests (card, config screen, a11y)
flutter test test/features/payment_reminders/presentation/

# Integration test (flujo completo: recordatorio → pago)
flutter test integration_test/payment_reminders_flow_test.dart
```

### Tests de ReminderGenerator (unit, Dart puro)

```
test: bill pendiente dentro de ventana → genera reminder
test: bill pagado → no genera reminder
test: bill deshabilitado en config → no genera reminder
test: bill descartado → no genera reminder
test: bill fuera de ventana (> anticipation days) → no genera
test: bill vencido ayer → genera con isOverdue = true
test: bill vencido hace 4 días → no genera
test: múltiples bills → ordenados por dueDate asc
test: formatDueDate hoy → "hoy"
test: formatDueDate mañana → "mañana"
test: formatDueDate +3 días → "el {weekday}"
test: formatDueDate ayer → "ayer"
```

### Tests de ReminderConfigRepository (unit)

```
test: getConfig sin datos → defaults (todos activos, 3 días, no compartir)
test: setEnabledBills persiste y se lee
test: setAnticipationDays persiste y se lee
test: dismissBill agrega al set
test: clearDismissed vacía el set
test: shareWithTrusted solo true si consent granted
```

### A11y guidelines en widget tests

```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Tests específicos:
- ReminderCard: Semantics label con mensaje completo
- ReminderCard: botones ≥ 48dp
- ReminderConfigScreen: toggles y opciones navegables por TalkBack

## Definition of Done

- [ ] 4 recibos mock: luz, agua, teléfono, pensión con fechas simuladas
- [ ] Recordatorios in-app en pantalla principal del Modo Fácil
- [ ] Mensaje en lenguaje natural (hoy, mañana, día de la semana, fecha)
- [ ] TTS automático del recordatorio más urgente (reutiliza 004)
- [ ] "Pagar ahora" navega a flujo de 001 con recibo preseleccionado y monto prellenado
- [ ] "Ya lo sé, gracias" descarta para esa fecha de vencimiento
- [ ] Ordenados por urgencia (hasta 3 en pantalla, scroll para más)
- [ ] Desaparece al pagar (bill → paid)
- [ ] Configuración: activar/desactivar por recibo, anticipación 1/3/5 días
- [ ] Default: todos activos, 3 días
- [ ] Persona de confianza: aviso simulado sin monto, con consentimiento
- [ ] Recibos vencidos: mensaje en pasado, hasta 3 días después
- [ ] Nunca interrumpe operaciones (solo en pantalla principal)
- [ ] Textos en ARB, código en inglés
- [ ] Accesibilidad: TalkBack, 4.5:1, 48×48 dp, Semantics labels
- [ ] `flutter analyze` 0 warnings
- [ ] Tests verdes: unit (generator, config repo, formatDueDate), widget (card, config, a11y), integration
