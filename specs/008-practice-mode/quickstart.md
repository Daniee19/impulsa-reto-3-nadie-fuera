# Quickstart: Modo Práctica (008-practice-mode)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Feature 001-easy-mode implementada (pantallas y repositorios)
- Feature 002-fraud-shield implementada (RiskEngine y FraudAlertScreen)
- NavigationObserver registrado en GoRouter (de 003)
- Android emulator o dispositivo con API 26+
- TalkBack para pruebas de accesibilidad

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Validation Scenarios

### VS-1: Entrar al modo práctica (US1 — P1)

1. En pantalla principal del Modo Fácil, tocar "Practicar"
2. **Expected**: Pantalla de entrada con anuncio TTS: "Entraste al modo práctica. Aquí usas dinero de mentira. Nada de lo que hagas toca tu cuenta real."
3. **Expected**: Banner verde permanente "Modo práctica - dinero de prueba" en la parte superior
4. **Expected**: Color de acento cambiado de azul a verde
5. **A11y check**: TalkBack anuncia que se está en modo práctica

### VS-2: Pagar recibo con guía (US2 — P1)

1. En modo práctica, la app pregunta "¿Quieres que te guíe paso a paso?"
2. Elegir "Sí, guíame"
3. Tocar "Pagar recibo"
4. **Expected**: Instrucción superpuesta: "Elige el recibo que quieres pagar."
5. Seleccionar "Luz ficticia" (S/ 95.00)
6. **Expected**: Pantalla de confirmación con botón "Confirmar práctica" (NO huella)
7. **Expected**: Instrucción: "Revisa el monto y toca Confirmar práctica."
8. Tocar "Confirmar práctica"
9. **Expected**: Mensaje de éxito con datos ficticios + "Practicar otra vez" / "Volver al modo real"
10. **Expected**: Banner "Modo práctica" visible en TODOS los pasos

### VS-3: Alerta simulada del escudo antifraude (US3 — P2)

1. En modo práctica, tocar "Enviar dinero"
2. Seleccionar "Ana García"
3. Ingresar monto: S/ 600 (> umbral de S/ 500)
4. Avanzar a confirmación
5. **Expected**: Pantalla de alerta del escudo antifraude con mensaje "Este envío es más alto de lo habitual. ¿Quieres continuar?"
6. **Expected**: Misma apariencia que la alerta real (3 opciones)
7. **Expected** (si guía activa): Nota educativa adicional: "Esta alerta aparece cuando algo parece inusual. Es para protegerte."
8. Elegir "Continuar de todos modos"
9. **Expected**: Avanza a "Confirmar práctica" → éxito con datos ficticios

### VS-4: Salir del modo práctica (US4 — P1)

1. En cualquier pantalla del modo práctica, tocar "Salir de práctica"
2. **Expected**: TTS anuncia: "Saliste del modo práctica. Ahora estás en tu cuenta real."
3. **Expected**: Banner verde desaparece. Color vuelve a azul.
4. **Expected**: Está de vuelta en pantalla principal del Modo Fácil real
5. Tocar "Ver mi saldo"
6. **Expected**: Muestra saldo REAL (S/ 2,450.00), NO el de práctica (S/ 5,000.00)

### VS-5: Práctica sin guía (US5 — P2)

1. Entrar a modo práctica, elegir "No, ya sé" en la pregunta de guía
2. Tocar "Enviar dinero"
3. **Expected**: Flujo funciona igual que en modo real pero con contactos ficticios (Ana García, Pedro Ruiz, Lucía Torres) y sin instrucciones superpuestas
4. **Expected**: Banner "Modo práctica" sigue visible
5. Completar operación → datos ficticios usados

### VS-6: Aislamiento de datos (SC-001 — crítico)

1. En modo REAL, anotar el saldo actual (S/ 2,450.00)
2. Entrar a modo práctica
3. Ver saldo → **Expected**: S/ 5,000.00 (ficticio)
4. Pagar "Luz ficticia" (S/ 95.00)
5. Ver saldo → **Expected**: S/ 4,905.00 (5000 - 95)
6. Salir de práctica
7. Ver saldo en modo REAL → **Expected**: S/ 2,450.00 (sin cambios)
8. Ver recibos pendientes → **Expected**: Los mismos 3 recibos reales (Luz, Agua, Gas), ninguno marcado como pagado por la práctica

### VS-7: Reiniciar datos de práctica (FR-014)

1. En modo práctica, pagar 2 recibos y enviar dinero
2. Ver saldo → debería haber bajado
3. Tocar "Reiniciar práctica"
4. **Expected**: Saldo vuelve a S/ 5,000.00
5. **Expected**: Todos los recibos ficticios vuelven a "pendiente"

### VS-8: No persiste entre sesiones (FR-013)

1. Entrar a modo práctica, hacer operaciones
2. Cerrar la app completamente (kill process)
3. Abrir la app
4. **Expected**: Está en modo REAL (pantalla principal Modo Fácil)
5. **Expected**: No hay indicador de práctica

### VS-9: Botón "Pedir ayuda" en práctica (edge case)

1. En modo práctica, tocar "Pedir ayuda"
2. **Expected**: Funciona simulado (muestra mensaje de confirmación)
3. **Expected**: Banner de práctica visible

## Automated Tests

```bash
# Unit tests de repositorios de práctica (Dart puro)
flutter test test/features/practice_mode/data/

# Widget tests (banner, guía, tema, a11y)
flutter test test/features/practice_mode/presentation/

# Integration test de aislamiento (CRÍTICO)
flutter test integration_test/practice_mode_isolation_test.dart

# Integration test de flujo completo
flutter test integration_test/practice_mode_flow_test.dart
```

### Tests de aislamiento (unit)

```
test: PracticeAccountRepository no referencia repos reales
test: PracticeAccountRepository.reset() restaura saldo a 5000
test: PracticeBillRepository.payBill() no afecta BillRepository real
test: PracticeOperationRepository.createOperation() solo muta lista interna
test: PracticeRiskEngine activa alerta para montos > 500
test: PracticeRiskEngine no activa alerta para montos ≤ 500
```

### Test de aislamiento end-to-end (integration)

```
test: sesión completa de práctica nunca llama a repos reales (mock + verifyNever)
test: saldo real no cambia después de operaciones en práctica
test: recibos reales no cambian después de pagos en práctica
```

### A11y guidelines en widget tests

```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Tests específicos:
- PracticeBanner tiene Semantics label
- SemanticsService.announce se llama al entrar y salir
- TalkBack anuncia modo práctica en cada pantalla
- Botón "Salir de práctica" tiene área ≥ 48×48 dp

## Definition of Done

- [ ] ProviderScope override inyecta repos ficticios en rutas de práctica
- [ ] Pantallas de 001 reutilizadas sin modificación
- [ ] Banner "Modo práctica - dinero de prueba" visible en todas las pantallas
- [ ] Color verde distinguible del azul real, contraste 4.5:1
- [ ] Anuncio TTS al entrar y salir del modo práctica
- [ ] Guía paso a paso opcional con instrucciones ≤ 15 palabras
- [ ] "Confirmar práctica" reemplaza biometría en confirmaciones
- [ ] Alerta simulada de fraude para montos > S/ 500 (nota educativa si guía activa)
- [ ] Datos de práctica reiniciables con "Reiniciar práctica"
- [ ] Modo práctica no persiste entre sesiones de la app
- [ ] Test de aislamiento: repos reales nunca llamados en sesión de práctica
- [ ] Saldo y recibos reales intactos después de operaciones en práctica
- [ ] Sin gamificación (sin puntos, niveles ni insignias)
- [ ] Todos los textos en ARB, ≤ 15 palabras, sin jerga
- [ ] `flutter analyze` 0 warnings
- [ ] Tests verdes: unit (repos, risk engine), widget (banner, guía, a11y), integration (aislamiento + flujo)
