# Quickstart: Desbloqueo Gradual de Funciones (009-gradual-unlock)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Feature 001-easy-mode implementada (pantalla principal y flujos)
- Feature 008-practice-mode implementada (modo práctica con ProviderScope override)
- Android emulator o dispositivo con API 26+
- TalkBack para pruebas de accesibilidad

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Validation Scenarios

### VS-1: Inicio con solo 4 acciones (FR-001, SC-001)

1. Limpiar SharedPreferences (fresh install o clear data)
2. Abrir la app → Modo Fácil
3. **Expected**: Exactamente 4 botones: "Ver mi saldo", "Pagar recibo", "Enviar dinero", "Pedir ayuda"
4. **Expected**: No hay sección "Más funciones"
5. **Expected**: No hay propuesta de nueva función

### VS-2: Propuesta aparece después de alcanzar confianza (US1 — P1)

1. Completar 5 pagos de recibo exitosos sin tocar "Pedir ayuda" durante ninguno
2. Cerrar y reabrir la app (nueva sesión)
3. **Expected**: Al abrir Modo Fácil, aparece propuesta: "Ya manejas bien tus pagos. ¿Quieres ver también tus movimientos recientes?"
4. **Expected**: 3 opciones: "Sí, actívalo", "Primero quiero practicarlo", "No, por ahora no"
5. **A11y check**: TalkBack anuncia la propuesta y las opciones

### VS-3: Activar función y ver sección extra (US1 — P1)

1. Cuando aparece la propuesta (VS-2), tocar "Sí, actívalo"
2. **Expected**: Un 5to botón "Ver movimientos" aparece en sección "Más funciones"
3. **Expected**: Las 4 acciones originales siguen en la misma posición
4. Tocar "Ver movimientos"
5. **Expected**: Pantalla con lista de transacciones ficticias

### VS-4: Practicar antes de activar (US1 — P1)

1. Cuando aparece la propuesta, tocar "Primero quiero practicarlo"
2. **Expected**: Navega al modo práctica (008) con la función "Ver movimientos" incluida
3. **Expected**: Banner "Modo práctica" visible
4. Probar "Ver movimientos" en práctica con datos ficticios
5. Salir de práctica
6. **Expected**: La función NO se activó automáticamente
7. En la próxima sesión, la propuesta vuelve a aparecer (el usuario puede activar entonces)

### VS-5: Rechazar propuesta (FR-005)

1. Cuando aparece la propuesta, tocar "No, por ahora no"
2. **Expected**: Propuesta desaparece
3. Navegar por la app, volver a pantalla principal
4. **Expected**: La propuesta NO reaparece en esta sesión
5. Cerrar y reabrir (nueva sesión)
6. **Expected**: La propuesta reaparece (primer rechazo)
7. Rechazar 3 veces en total (3 sesiones distintas)
8. **Expected**: La propuesta NO vuelve a aparecer automáticamente
9. Ir a Configuración → funciones disponibles
10. **Expected**: "Ver movimientos" aparece como activable manualmente

### VS-6: Volver a solo 4 acciones (US2 — P1)

1. Activar "Ver movimientos" y "Recargar celular" (simular métricas o activar desde config)
2. **Expected**: Pantalla principal tiene 4 primarias + sección "Más funciones" con 2 extras
3. Ir a Configuración → "Volver a solo 4 acciones"
4. **Expected**: Confirmación: "Vas a ocultar las funciones extra. Puedes volver a activarlas cuando quieras."
5. Confirmar
6. **Expected**: Solo 4 botones. Sin sección "Más funciones"
7. Ir a Configuración → funciones desbloqueadas
8. **Expected**: "Ver movimientos" y "Recargar celular" aparecen como reactivables
9. Activar "Ver movimientos" desde configuración
10. **Expected**: Reaparece sin tener que cumplir condiciones de confianza de nuevo

### VS-7: Sección "Más funciones" con muchas extras (US3 — P1)

1. Activar las 3 funciones extra (7 totales = 4 primarias + 3 extras)
2. **Expected**: 4 primarias en la parte superior, nunca desplazadas
3. **Expected**: Sección "Más funciones" con 3 botones debajo
4. **Expected**: Todos los botones cumplen 48×48 dp, contraste 4.5:1

### VS-8: Propuesta accesible con TalkBack (US4 — P2)

1. Activar TalkBack
2. Simular condiciones de confianza y abrir Modo Fácil
3. **Expected**: TalkBack anuncia la propuesta completa + opciones
4. Navegar las 3 opciones con swipe
5. **Expected**: Cada opción se anuncia claramente
6. Seleccionar una opción
7. **Expected**: Flujo continúa correctamente

### VS-9: Solo una propuesta por sesión (FR-006)

1. Simular condiciones para 2 funciones (ej: transactionHistory y mobileRecharge)
2. Abrir Modo Fácil
3. **Expected**: Solo aparece propuesta para "Ver movimientos" (prioridad 1)
4. Aceptar la propuesta
5. **Expected**: NO aparece propuesta para "Recargar celular" en esta sesión
6. Cerrar y reabrir
7. **Expected**: Ahora aparece propuesta para "Recargar celular"

## Automated Tests

```bash
# Unit tests del evaluator (Dart puro)
flutter test test/features/gradual_unlock/domain/

# Unit tests del repository (SharedPreferences mock)
flutter test test/features/gradual_unlock/data/

# Widget tests (propuesta, sección extra, a11y)
flutter test test/features/gradual_unlock/presentation/

# Integration test (flujo completo)
flutter test integration_test/gradual_unlock_flow_test.dart
```

### Tests del UnlockEvaluator (unit, Dart puro)

```
test: métricas bajo umbral → no propone
test: 5 ops sin ayuda → propone transactionHistory (prioridad 1)
test: 3 sesiones práctica → propone (condición OR)
test: feature ya active → skip, propone siguiente
test: feature con 3 rechazos → skip, propone siguiente
test: todas desbloqueadas → null
test: proposalShownThisSession = true → null
test: prioridad respetada (enum order)
```

### Tests del FeatureFlagRepository (unit)

```
test: getState sin datos → locked
test: setState persiste y se lee correctamente
test: incrementOpsWithoutHelp acumula
test: resetToBasicView cambia active → unlockedHidden, no toca locked
test: getAllStates retorna mapa completo
```

### A11y guidelines en widget tests

```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Tests específicos:
- UnlockProposalCard anuncia con SemanticsService.announce
- Botones extra tienen Semantics labels
- Sección "Más funciones" es navegable con TalkBack

## Definition of Done

- [ ] Usuario nuevo empieza con exactamente 4 acciones
- [ ] UnlockEvaluator propone funciones por métricas de confianza (5 ops o 3 prácticas)
- [ ] Propuesta no intrusiva con 3 opciones: activar, practicar, rechazar
- [ ] "Practicar primero" navega a 008 con función incluida
- [ ] "No, por ahora no" no repite en la misma sesión; 3 rechazos = solo manual
- [ ] Una propuesta por sesión, orden de prioridad respetado
- [ ] Funciones extra en sección "Más funciones", 4 primarias siempre principales
- [ ] "Volver a solo 4 acciones" oculta extras, reactivables desde configuración
- [ ] 3 funciones extra simuladas: movimientos, recarga, QR con datos ficticios
- [ ] Flags y métricas persisten en SharedPreferences entre sesiones
- [ ] Sin gamificación (sin puntos, niveles, insignias)
- [ ] Todos los textos en ARB, ≤ 15 palabras, sin jerga
- [ ] Accesibilidad: TalkBack, contraste 4.5:1, 48×48 dp
- [ ] `flutter analyze` 0 warnings
- [ ] Tests verdes: unit (evaluator, repo), widget (propuesta, extras, a11y), integration
