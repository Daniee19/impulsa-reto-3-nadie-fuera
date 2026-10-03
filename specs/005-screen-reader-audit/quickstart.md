# Quickstart: Auditoría de Accesibilidad para Lector de Pantalla (005-screen-reader-audit)

Guía de validación para verificar que los estándares de accesibilidad se cumplen en todas las pantallas.

## Prerequisites

- Features 001 a 004 implementadas
- Android emulator o dispositivo con API 26+ y TalkBack instalado
- No requiere dependencias adicionales

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Validation Scenarios

### VS-1: Montos se leen en palabras (US2 — P1)

1. Navegar a pantalla de saldo
2. Activar TalkBack
3. **Expected**: TalkBack lee "Saldo disponible: dos mil cuatrocientos cincuenta soles" (no "S/ 2,450")
4. Navegar a confirmación de pago de recibo de luz (S/ 85.50)
5. **Expected**: TalkBack lee "ochenta y cinco soles con cincuenta céntimos"

### VS-2: Orden de lectura lógico en pantalla principal (US1 — P1)

1. Activar TalkBack en pantalla principal
2. Deslizar dedo de izquierda a derecha repetidamente
3. **Expected**: Lee en orden: título de pantalla → información de cuenta → botones de acción (Ver saldo, Pagar recibo, Enviar dinero, Pedir ayuda)
4. **Expected**: HelpFab se lee al final, no en medio del contenido

### VS-3: Anuncio automático de cambio de pantalla (US3 — P1)

1. Con TalkBack activo, completar un pago
2. **Expected**: Al llegar a pantalla de éxito, TalkBack anuncia automáticamente "Pago realizado. Pagaste [monto en palabras] al recibo de [servicio]" SIN tocar la pantalla
3. Triggerear una alerta de fraude
4. **Expected**: TalkBack anuncia automáticamente "Alerta de seguridad" + explicación

### VS-4: Sin gestos complejos ni imágenes sin descripción (US4 — P1)

1. Completar flujo de "Ver saldo" solo con toques simples (un dedo, un toque)
2. **Expected**: Ningún paso requiere arrastrar, pellizcar, o doble toque largo
3. Repetir para "Pagar recibo", "Enviar dinero", "Pedir ayuda"
4. **Expected**: Todos los flujos completables con toques simples
5. Verificar que los iconos dicen la acción ("Pagar recibo"), no el icono ("icono de billete")

### VS-5: Todas las pantallas pasan tests automáticos de a11y

```bash
# Tests automáticos de accesibilidad
flutter test test/a11y/
```

**Expected**: 0 fallos. Cada test verifica:
- `androidTapTargetGuideline` — áreas táctiles ≥48dp
- `labeledTapTargetGuideline` — todo interactivo tiene label
- `textContrastGuideline` — contraste ≥4.5:1

### VS-6: Prueba manual completa con TalkBack (US5 — P2)

1. Abrir `docs/talkback_test_checklist.md`
2. Activar TalkBack, cerrar ojos, poner timer de 10 minutos
3. Seguir el guion: navegar los 7 flujos principales
4. **Expected**: Completar los 7 flujos en ≤10 minutos
5. **Expected**: Cada elemento tiene etiqueta clara, ninguno mudo, ninguno confuso

### VS-7: AmountToWords — conversor de montos

```bash
flutter test test/core/a11y/amount_to_words_test.dart
```

**Expected**: Todos los casos pasan:
- `0.00` → "cero soles"
- `1.00` → "un sol"
- `0.01` → "un céntimo"
- `0.50` → "cincuenta céntimos"
- `50.00` → "cincuenta soles"
- `120.50` → "ciento veinte soles con cincuenta céntimos"
- `2350.00` → "dos mil trescientos cincuenta soles"
- `999999.99` → texto correcto

### VS-8: Etiquetas únicas — no hay dos iguales adyacentes (FR-010)

1. Con TalkBack, navegar cada pantalla
2. **Expected**: Nunca hay dos botones seguidos con la misma etiqueta
3. Ej: Si hay dos "Confirmar" → debe ser "Confirmar pago" y "Confirmar envío"

## Automated Tests

```bash
# Unit tests del conversor de montos (Dart puro)
flutter test test/core/a11y/

# Tests de accesibilidad de todas las pantallas
flutter test test/a11y/

# Todos los tests
flutter test
```

### Tests del AmountToWords

```
test: 0 → "cero soles"
test: 1 → "un sol"
test: 0.01 → "un céntimo"
test: 0.50 → "cincuenta céntimos"
test: 21 → "veintiún soles"
test: 100 → "cien soles"
test: 101 → "ciento un soles"
test: 120.50 → "ciento veinte soles con cincuenta céntimos"
test: 1000 → "mil soles"
test: 2350 → "dos mil trescientos cincuenta soles"
test: negativo → ArgumentError
```

### A11y guidelines por feature

```
test/a11y/easy_mode_a11y_test.dart:
  test: home screen meets 3 guidelines
  test: balance screen meets 3 guidelines
  test: pay bill list screen meets 3 guidelines
  test: pay bill confirm screen meets 3 guidelines
  test: send money screen meets 3 guidelines
  test: success screen meets 3 guidelines
  test: no overflow at textScaler 2.0 for all screens

test/a11y/fraud_shield_a11y_test.dart:
  test: fraud alert screen meets 3 guidelines

test/a11y/contextual_help_a11y_test.dart:
  test: help contact picker meets 3 guidelines
  test: help channel picker meets 3 guidelines
  test: help connecting meets 3 guidelines
  test: help fab has "Pedir ayuda" label

test/a11y/voice_assistant_a11y_test.dart:
  test: voice assistant screen meets 3 guidelines
  test: microphone consent screen meets 3 guidelines
  test: operation summary screen meets 3 guidelines
```

## Definition of Done

- [ ] `AmountToWords.convert()` implementado y testeado para rango 0-999,999
- [ ] `screenAnnounce()` helper implementado
- [ ] Todas las pantallas de 001-004 tienen Semantics labels en español
- [ ] Montos usan AmountToWords en Semantics (no "S/ 120")
- [ ] Orden de lectura lógico (título → info → acciones) en todas las pantallas
- [ ] Anuncios automáticos en todas las transiciones de pantalla/estado
- [ ] Imágenes decorativas excluidas con ExcludeSemantics
- [ ] Iconos describen la acción, no el icono
- [ ] No hay dos interactivos adyacentes con la misma etiqueta
- [ ] Sin gestos complejos — todo con toque simple en ≥48dp
- [ ] Toasts/banners ≥5 segundos
- [ ] Tests automáticos pasan para todas las pantallas (3 guidelines + overflow)
- [ ] Guion de prueba manual TalkBack creado en `docs/talkback_test_checklist.md`
- [ ] Prueba manual ejecutada y documentada
- [ ] `flutter analyze` 0 warnings
