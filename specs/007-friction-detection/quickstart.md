# Quickstart: Detección de Fricción (007-friction-detection)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Features 001-easy-mode, 003-contextual-human-help y 004-voice-text-assistant implementadas
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

### VS-1: Retroceso repetido ofrece ayuda (US1 — P1)

1. Ir a "Pagar recibo" → seleccionar recibo de Luz (S/ 120)
2. En la pantalla de confirmación, tocar "Volver"
3. Volver a llegar a confirmación, tocar "Volver" otra vez
4. Volver a llegar a confirmación, tocar "Volver" la tercera vez
5. **Expected**: Aparece overlay en la parte inferior: "Parece que necesitas ayuda con este paso." con 3 opciones
6. Tocar "Sí, explícame"
7. **Expected**: TTS lee una explicación breve del paso actual. Overlay desaparece

### VS-2: Inactividad de 20 segundos ofrece ayuda (US2 — P1)

1. Ir a "Enviar dinero" → llegar al paso de ingresar monto
2. No tocar nada durante 20 segundos
3. **Expected**: Aparece overlay "¿Necesitas ayuda con este paso?" con 3 opciones
4. Tocar "Hablar con alguien"
5. **Expected**: Navega a pantalla de contacto de 003. El contexto incluye: "Estuvo sin interactuar en Ingresar monto"

### VS-3: Error repetido ofrece ayuda (US3 — P2)

1. Ir a "Enviar dinero" → en el campo de monto, escribir "abc" → submit
2. **Expected**: Error de validación
3. Borrar, escribir "xyz" → submit
4. **Expected**: Error de validación (mismo tipo: formato inválido)
5. Borrar, escribir "!!!" → submit
6. **Expected**: Error + overlay "Parece que hay un problema con este campo. ¿Te ayudo?" con 3 opciones

### VS-4: NO se ofrece ayuda en confirmación de pago (US4 — P1)

1. Ir a "Pagar recibo" → seleccionar recibo → llegar a pantalla de confirmación
2. Esperar 25 segundos sin tocar nada
3. **Expected**: NO aparece overlay. La pantalla de confirmación está excluida
4. Verificar también: esperar 25 segundos en alerta de fraude → NO aparece overlay

### VS-5: Contexto de fricción llega a ayuda humana (US5 — P2)

1. En un flujo, triggerear retroceso 3 veces (como VS-1)
2. En el overlay, tocar "Hablar con alguien"
3. Elegir persona de confianza → elegir canal
4. **Expected**: En la pantalla de conexión, el contexto muestra:
   - Contexto normal de 003 (pantalla, operación, monto)
   - **Más**: "Retrocedió 3 veces en la confirmación del pago"

### VS-6: "No, estoy bien" no se repite (FR-004)

1. Triggerear retroceso 3 veces en un flujo de pago
2. Tocar "No, estoy bien" en el overlay
3. **Expected**: Overlay desaparece
4. Seguir retrocediendo en el mismo flujo
5. **Expected**: NO vuelve a aparecer overlay para retrocesos en esta operación
6. Iniciar un nuevo flujo de pago (operación distinta)
7. Retroceder 3 veces
8. **Expected**: SÍ aparece overlay (nueva operación, reset)

### VS-7: Múltiples señales = un solo ofrecimiento (FR-005)

1. En un paso de un flujo, estar inactivo 19 segundos
2. En el segundo 19, retroceder 3 veces rápidamente
3. **Expected**: Aparece UN solo overlay, no dos superpuestos

### VS-8: Inactividad solo en flujos activos (FR-006)

1. En pantalla principal de Modo Fácil, esperar 25 segundos
2. **Expected**: NO aparece overlay (no es un flujo activo)
3. En pantalla de "Ver saldo", esperar 25 segundos
4. **Expected**: NO aparece overlay (no es un flujo activo)

### VS-9: Interacción reinicia timer (FR-007)

1. Ir a un paso de "Enviar dinero"
2. Esperar 15 segundos
3. Tocar la pantalla (cualquier lugar)
4. Esperar otros 15 segundos
5. **Expected**: NO aparece overlay (timer se reinició al tocar en el segundo 15)

## Automated Tests

```bash
# Unit tests del detector (Dart puro, domain)
flutter test test/features/friction_detection/domain/

# Widget tests (overlay + a11y)
flutter test test/features/friction_detection/presentation/

# Integration test (flujo completo)
flutter test integration_test/friction_detection_flow_test.dart
```

### Tests del FrictionDetector (unit, Dart puro)

```
test: 2 retrocesos no disparan señal, 3 sí
test: cambio de flujo resetea contador de retrocesos
test: inactividad timeout produce señal en flujo activo
test: ruta de confirmación es pantalla excluida
test: ruta de alerta de fraude es pantalla excluida
test: pantalla principal NO es flujo activo
test: 2 errores no disparan señal, 3 del mismo tipo sí
test: errores de distinto tipo se cuentan separado
test: dismiss impide re-trigger para esa señal+flujo
test: resetForNewFlow limpia dismissed y contadores
test: umbrales personalizados se respetan
```

### Tests del FrictionProvider (unit, con Riverpod)

```
test: escucha navigationContextProvider y detecta retrocesos
test: timer de inactividad se reinicia con onUserInteraction
test: onValidationError delega al detector y actualiza state
test: acceptExplain reproduce TTS y oculta overlay
test: acceptHuman navega a 003 y publica FrictionContext
test: dismiss registra señal como descartada
test: no muestra overlay si ya hay uno visible
```

### A11y guidelines en widget tests

```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Tests específicos:
- Overlay tiene Semantics label en cada botón
- `SemanticsService.announce` se llama al mostrar overlay
- Botones tienen área mínima 48×48 dp

## Definition of Done

- [ ] FrictionDetector en domain: detecta 3 señales con umbrales configurables
- [ ] Pantallas excluidas: confirmación, fraude, consentimiento, ayuda — nunca disparan
- [ ] FrictionOfferOverlay: aparece con mensaje amable y 3 opciones
- [ ] "Sí, explícame": lee explicación predefinida por TTS (de 004)
- [ ] "Hablar con alguien": navega a 003 con contexto de fricción enriquecido
- [ ] "No, estoy bien": descarta y no reaparece para esa señal + operación
- [ ] Señales múltiples: un solo overlay, no se apilan
- [ ] Timer de inactividad: solo en flujos activos, se reinicia con interacción
- [ ] Errores de voz (004) no cuentan como error repetido
- [ ] Overlay accesible: TalkBack, contraste, 48×48 dp, announce
- [ ] Todos los textos en ARB, ≤ 15 palabras, sin jerga
- [ ] `flutter analyze` 0 warnings
- [ ] Tests verdes: unit (detector), widget (overlay + a11y), integration
