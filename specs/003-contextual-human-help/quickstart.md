# Quickstart: Ayuda Humana con Contexto (003-contextual-human-help)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Features 001-easy-mode y 006-trusted-person implementadas
- NavigationObserver registrado en GoRouter
- Android emulator o dispositivo con API 26+
- TalkBack para pruebas de accesibilidad

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Validation Scenarios

### VS-1: Ayuda en medio de pago con contexto (US1 — P1)

1. Ir a "Pagar recibo" → seleccionar recibo de Luz (S/ 85.50)
2. En la pantalla de confirmación, tocar FAB "Pedir ayuda"
3. **Expected**: Pantalla con opciones: "Llamar a Valeria" y "Hablar con el banco"
4. Elegir "Llamar a Valeria" → elegir "Llamar"
5. **Expected**: "Te estamos conectando con Valeria..." + contexto mostrado:
   - "Rosa está en: Confirmación de pago"
   - "Operación: Pagar recibo de Luz por S/ 85.50"
6. Volver a la app
7. **Expected**: Está de vuelta en la confirmación de pago con los datos preservados (recibo, monto)

### VS-2: Ayuda al asesor con videollamada e intérprete (US2 — P1)

1. Desde pantalla principal, tocar "Pedir ayuda"
2. Elegir "Hablar con el banco"
3. **Expected**: 3 canales: "Llamar", "Escribir", "Videollamada con intérprete de lengua de señas"
4. Elegir "Videollamada con intérprete"
5. **Expected**: "Te estamos conectando con un asesor e intérprete de lengua de señas" + contexto:
   - "Rosa está en: Pantalla principal"
   - "Sin operación en curso"
6. **A11y check**: TalkBack lee "Videollamada con intérprete de lengua de señas" claramente

### VS-3: Familiar no responde, fallback a asesor (US3 — P2)

1. Tocar "Pedir ayuda" → elegir persona de confianza → elegir canal
2. Esperar timeout (60s simulados, o botón debug "Simular no respuesta")
3. **Expected**: "No pudimos comunicarte con Valeria. ¿Quieres hablar con un asesor del banco?" con "Sí" y "Volver"
4. Tocar "Sí"
5. **Expected**: Conexión con asesor que recibe el MISMO contexto original

### VS-4: Sin persona de confianza (edge case)

1. Quitar persona de confianza (via 006)
2. Tocar "Pedir ayuda" desde cualquier pantalla
3. **Expected**: Solo aparece "Hablar con el banco". Sin espacio vacío, sin error, sin mención de persona de confianza

### VS-5: Contexto durante alerta de fraude (edge case — integración con 002)

1. Triggerear una alerta del escudo antifraude (pago con monto inusual)
2. En la pantalla de alerta, tocar "Pedir ayuda" (FAB)
3. **Expected**: Contexto incluye: "Rosa está en: Alerta de seguridad", operación que la disparó
4. El asesor/familiar sabe que Rosa vio una alerta y qué la causó

### VS-6: Ayuda sin operación en curso (US5 — P2)

1. Desde pantalla principal (sin iniciar ningún flujo), tocar "Pedir ayuda"
2. **Expected**: Contexto: "Pantalla principal, sin operación en curso"
3. Funciona igual que con operación, pero sin datos de monto/destinatario

### VS-7: Permiso helpRequests desactivado (integración con 006)

1. Desactivar permiso "Pedidos de ayuda" en configuración de persona de confianza
2. Tocar "Pedir ayuda"
3. **Expected**: Solo aparece "Hablar con el banco". Persona de confianza NO aparece como opción

### VS-8: Botón de ayuda siempre visible

1. Navegar por TODAS las pantallas del Modo Fácil: home, saldo, pagar recibo (lista), confirmación de pago, enviar dinero, confirmación de envío, éxito, ayuda, configuración
2. **Expected**: FAB "Pedir ayuda" visible en cada una
3. **A11y check**: TalkBack anuncia "Pedir ayuda" en cada pantalla al navegar con swipe

## Automated Tests

```bash
# Unit tests del colector de contexto (Dart puro)
flutter test test/features/contextual_help/domain/

# Widget tests (pantallas de ayuda + a11y + botón global)
flutter test test/features/contextual_help/presentation/

# Integration test (flujo completo)
flutter test integration_test/contextual_help_flow_test.dart
```

### Tests del ContextCollector

```
test: pantalla principal sin operación → contexto correcto
test: confirmación de pago con monto → contexto incluye monto y destinatario
test: alerta de fraude → contexto incluye "Alerta de seguridad"
test: datos sensibles filtrados → sin PIN, sin cuenta completa
test: operación en curso null → campos de operación null en contexto
```

### A11y guidelines en widget tests

```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Test específico: FAB tiene Semantics label "Pedir ayuda" en todas las pantallas.

## Definition of Done

- [ ] Botón "Pedir ayuda" visible y accesible en todas las pantallas del Modo Fácil
- [ ] NavigationObserver captura ruta actual + nombre legible de pantalla
- [ ] ContextCollector empaqueta contexto real, filtra datos sensibles
- [ ] 2 opciones de contacto: persona de confianza (si permiso activo) + asesor
- [ ] 2 canales para familiar (llamada, chat), 3 para asesor (+videollamada intérprete)
- [ ] Contexto enviado refleja pantalla actual y operación en curso
- [ ] Progreso del flujo preservado al volver de la ayuda
- [ ] Fallback a asesor cuando familiar no responde
- [ ] Reemplaza botón simulado de 001 (US4)
- [ ] Todos los textos en ARB, ≤15 palabras, sin jerga
- [ ] `flutter analyze` 0 warnings
- [ ] Tests verdes: unit (contexto), widget (a11y), integration
