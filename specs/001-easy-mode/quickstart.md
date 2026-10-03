# Quickstart: Modo Fácil (001-easy-mode)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Flutter SDK ≥ 3.13.4 (`flutter --version`)
- Android emulator o dispositivo con API 26+ (`flutter devices`)
- TalkBack habilitado en el dispositivo/emulator para pruebas de accesibilidad

## Setup

```bash
# Instalar dependencias
flutter pub get

# Generar código (freezed models, riverpod providers, l10n)
dart run build_runner build --delete-conflicting-outputs

# Verificar que no hay errores de análisis
flutter analyze
```

## Run

```bash
# Ejecutar en dispositivo/emulator Android
flutter run

# Con accessibility_tools visible (solo debug)
# El overlay se activa automáticamente en modo debug
```

## Validation Scenarios

### VS-1: Ver saldo (US1 — 1 paso)

1. Abrir la app → pantalla principal del Modo Fácil con 4 botones
2. Tocar "Ver mi saldo"
3. **Expected**: Saldo "S/ 2,450.00" en números ≥28sp, nombre "Rosa Martínez", nombre de cuenta
4. **A11y check**: TalkBack lee saldo y nombre de cuenta en orden lógico
5. **Scaling check**: Con letra del sistema al 200%, no hay desbordamiento

### VS-2: Pagar recibo (US2 — 3 pasos)

1. Desde home, tocar "Pagar recibo"
2. **Expected**: Lista de 3 recibos (Luz S/ 85.50, Agua S/ 42.00, Gas S/ 63.20) en texto grande
3. Seleccionar "Luz"
4. **Expected**: Pantalla de confirmación con "Luz - Enel", "S/ 85.50", botón "Confirmar", botón "Volver"
5. Tocar "Confirmar"
6. **Expected**: Mensaje "Pago realizado" con resumen. TalkBack anuncia "Pago realizado"
7. **Back test**: Repetir hasta paso 4, tocar "Volver" → regresa a lista sin perder selección

### VS-3: Enviar dinero (US3 — 3 pasos)

1. Desde home, tocar "Enviar dinero"
2. **Expected**: Lista de contactos (Valeria, Carlos, María) con nombre e inicial grande
3. Seleccionar "Valeria Martínez", ingresar monto "100"
4. **Expected**: Confirmación con "Valeria Martínez", "S/ 100.00", saldo restante "S/ 2,350.00"
5. Tocar "Confirmar"
6. **Expected**: Mensaje "Dinero enviado". TalkBack anuncia "Dinero enviado"

### VS-4: Enviar dinero — saldo insuficiente (US3-AS4)

1. Desde "Enviar dinero", seleccionar contacto, ingresar monto "99999"
2. **Expected**: Mensaje "No tienes suficiente dinero" con saldo actual. Sin jerga técnica.

### VS-5: Pedir ayuda (US4 — 1 paso)

1. Desde home, tocar "Pedir ayuda"
2. **Expected**: Opciones de contacto (llamada, chat) con texto grande e iconos
3. Seleccionar una opción
4. **Expected**: Mensaje "Te estamos conectando con alguien que te va a ayudar"
5. **A11y check**: TalkBack anuncia cada opción ("Llamar a un asesor", "Escribir a un asesor")

### VS-6: Pantalla principal con TalkBack (US5)

1. Activar TalkBack, abrir Modo Fácil
2. Navegar con swipe por los 4 botones
3. **Expected**: TalkBack lee en orden: "Ver mi saldo", "Pagar recibo", "Enviar dinero", "Pedir ayuda"
4. Ningún elemento sin etiqueta, ningún código ni jerga

### VS-7: Edge cases

- **Sin recibos pendientes**: Pagar todos los recibos, volver a "Pagar recibo" → "No tienes recibos pendientes" + opción de volver
- **Saldo cero**: Después de gastar todo → saldo "S/ 0.00" sin alarma
- **Error de conexión**: (simulado si se implementa) → "Algo salió mal. Tu dinero no se movió."

## Automated Tests

```bash
# Unit tests (dominio)
flutter test test/features/easy_mode/domain/

# Widget tests con guidelines de accesibilidad
flutter test test/features/easy_mode/presentation/

# Integration tests
flutter test integration_test/

# Verificar cobertura de dominio ≥ 80%
flutter test --coverage test/features/easy_mode/domain/
```

### A11y guidelines verificadas en widget tests

Cada screen test incluye:
```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Y prueba de no-overflow con `MediaQuery.textScalerOf` a 2.0.

## Definition of Done

Referencia: [spec.md](spec.md) Success Criteria y [data-model.md](data-model.md) Validation Rules.

- [ ] Las 4 acciones se completan en ≤ 3 pasos
- [ ] Confirmación antes de mover dinero en todos los flujos
- [ ] TalkBack lee todos los elementos en orden lógico
- [ ] Texto ≥ 18sp base, montos ≥ 28sp
- [ ] Sin desbordamiento a textScaler 2.0
- [ ] Contraste ≥ 4.5:1 (texto), ≥ 3:1 (iconos/bordes)
- [ ] Áreas táctiles ≥ 48x48dp
- [ ] Frases ≤ 15 palabras, sin jerga
- [ ] `flutter analyze` con 0 warnings
- [ ] Tests verdes: unit (dominio ≥ 80%), widget (a11y), integration
