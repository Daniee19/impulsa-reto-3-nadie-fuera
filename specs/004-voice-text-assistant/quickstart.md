# Quickstart: Asistente de Voz y Texto (004-voice-text-assistant)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Features 001-easy-mode y 002-fraud-shield implementadas
- Dependencias agregadas: `speech_to_text`, `flutter_tts`, `local_auth`
- Android emulator o dispositivo con API 26+ y Google Speech Services instalado
- Micrófono habilitado en el emulador (o dispositivo físico para pruebas de voz reales)

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Validation Scenarios

### VS-1: "Quiero pagar la luz" — flujo completo por voz (US1 — P1)

1. Ir a pantalla principal → tocar "Asistente"
2. Primera vez: **Expected**: Pantalla de consentimiento de micrófono con texto claro
3. Aceptar consentimiento → tocar botón de micrófono
4. Decir "quiero pagar la luz"
5. **Expected**: El asistente identifica intención "pagar recibo", busca recibo de luz en pendientes
6. **Expected**: Muestra resumen: "Vas a pagar tu recibo de luz por S/ 85.50"
7. **Expected**: Lee el resumen en voz alta (TTS)
8. Confirmar con huella/PIN
9. **Expected**: "Pago realizado" leído en voz alta + pantalla de éxito
10. **A11y check**: TalkBack anuncia cada paso del flujo

### VS-2: "Mándale 50 soles a Valeria" — transferencia por voz (US2 — P1)

1. Tocar botón de micrófono → decir "mándale 50 soles a Valeria"
2. **Expected**: Identifica intención "enviar dinero", resuelve "Valeria" en contactos guardados
3. **Expected**: Resumen: "Vas a enviar S/ 50 a Valeria" (monto y nombre del repo, no del texto)
4. **Expected**: Lee resumen en voz alta → pide huella
5. Confirmar → **Expected**: "Dinero enviado" en voz alta

### VS-3: "Cuánto tengo" — consulta de saldo (US3 — P1)

1. Decir "cuánto tengo"
2. **Expected**: Identifica intención "ver saldo"
3. **Expected**: Lee en voz alta "Tienes S/ 2,450 disponibles" (monto del AccountRepository)
4. **Expected**: NO pide confirmación biométrica (no mueve dinero)
5. **Expected**: NO pasa por escudo antifraude

### VS-4: Frase ambigua — "hazme eso de siempre" (US4 — P1)

1. Decir "hazme eso de siempre"
2. **Expected**: El asistente NO ejecuta nada
3. **Expected**: Responde con opciones: "No estoy seguro de lo que necesitas. ¿Quieres ver tu saldo, pagar un recibo, enviar dinero o pedir ayuda?"
4. **Expected**: Lee la pregunta en voz alta
5. Decir "pagar mi recibo"
6. **Expected**: Continúa el flujo de pago normalmente

### VS-5: Entrada por texto — "pagar agua" (US5 — P2)

1. En el asistente, escribir "pagar agua" en el campo de texto
2. **Expected**: Mismo resultado que por voz: busca recibo de agua, muestra resumen
3. **Expected**: Lee resumen en voz alta (el canal de entrada es texto, pero la salida incluye voz)

### VS-6: Consentimiento de micrófono rechazado (US6 — P1)

1. Abrir asistente por primera vez → rechazar consentimiento de micrófono
2. **Expected**: Solo campo de texto visible. Botón de micrófono deshabilitado o ausente
3. **Expected**: Mensaje: "Puedes escribirme si prefieres no usar el micrófono"
4. Escribir "cuánto tengo" → **Expected**: Funciona normalmente por texto

### VS-7: Operación activa escudo antifraude (integración con 002)

1. Decir "mándale 5000 soles a Valeria" (monto inusualmente alto)
2. **Expected**: Asistente prepara la transferencia y lee resumen
3. **Expected**: Antes de pedir huella, aparece pantalla de alerta del escudo antifraude
4. **Expected**: 3 opciones: cancelar, continuar, consultar persona de confianza
5. Elegir "Continuar" → **Expected**: Ahora sí pide huella → ejecuta

### VS-8: "Pedir ayuda" — delega a 003 (integración con 003)

1. Decir "necesito ayuda"
2. **Expected**: Identifica intención "pedir ayuda"
3. **Expected**: Navega a pantalla de selección de contacto de ayuda (003)
4. **Expected**: No pide huella, no pasa por fraude (no es operación monetaria)

### VS-9: Recibo no encontrado (edge case)

1. Decir "pagar el cable"
2. **Expected** (si no hay recibo de cable en pendientes): "No encontré un recibo de cable pendiente. ¿Quieres ver tus recibos pendientes?"

### VS-10: Contacto ambiguo (edge case)

1. Decir "mándale plata a mi amiga"
2. **Expected**: Si no resuelve un contacto único: "¿A quién quieres enviarle?" + lista de contactos

### VS-11: Monto faltante (edge case)

1. Decir "mándale plata a Valeria"
2. **Expected**: "¿Cuánto quieres enviarle a Valeria?" (no asume monto)

### VS-12: Huella falla (edge case)

1. Completar flujo hasta confirmación biométrica
2. Cancelar la huella
3. **Expected**: "No reconocí tu huella. Intenta de nuevo." (operación no se cancela, puede reintentar)

## Automated Tests

```bash
# Unit tests del parser de intenciones (Dart puro)
flutter test test/features/voice_assistant/domain/

# Widget tests (pantallas del asistente + a11y)
flutter test test/features/voice_assistant/presentation/

# Integration test (flujo completo)
flutter test integration_test/voice_assistant_flow_test.dart
```

### Tests del IntentParser

```
test: "quiero pagar la luz" → payBill con serviceName "luz"
test: "pagar agua" → payBill con serviceName "agua"
test: "mándale 50 soles a Valeria" → sendMoney con contactName "Valeria", amount 50
test: "envía 100 a mi hija" → sendMoney con contactName "mi hija", amount 100
test: "cuánto tengo" → checkBalance
test: "mi saldo" → checkBalance
test: "ayúdame" → requestHelp
test: "necesito ayuda" → requestHelp
test: "hazme eso de siempre" → unknown
test: "cuál es la capital de Francia" → unknown
test: "" → unknown
test: "transferir" sin contacto → sendMoney con contactName null
test: "pagar" sin servicio → payBill con serviceName null
```

### Tests del OperationPreparer

```
test: payBill + serviceName "luz" + recibo existe → PrepareSuccess con monto del recibo
test: payBill + serviceName "cable" + recibo no existe → PrepareBillNotFound
test: payBill + serviceName null → PrepareNeedsService con lista de recibos
test: sendMoney + contactName "Valeria" + amount 50 → PrepareSuccess
test: sendMoney + contactName null → PrepareNeedsContact
test: sendMoney + contactName "Valeria" + amount null → PrepareNeedsAmount
test: checkBalance → PrepareBalanceResult con saldo real
test: monto en summary siempre viene del repo, no del parser
```

### A11y guidelines en widget tests

```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Test específico: botón de micrófono tiene Semantics label "Activar micrófono". Campo de texto tiene Semantics label "Escribe tu solicitud".

## Definition of Done

- [ ] IntentParser identifica correctamente las 4 intenciones + unknown con las frases de prueba
- [ ] OperationPreparer resuelve datos reales del repositorio, nunca del parser
- [ ] Entrada por voz (speech_to_text) funciona en español
- [ ] Entrada por texto funciona con las mismas reglas
- [ ] TTS lee resumen en voz alta antes de confirmación
- [ ] Confirmación biométrica (local_auth) con PIN fallback
- [ ] Consentimiento de micrófono antes del primer uso
- [ ] Operaciones monetarias pasan por RiskEngine (002)
- [ ] Intención "pedir ayuda" delega a 003
- [ ] Si no entiende, pregunta (nunca adivina)
- [ ] Si falta dato, pregunta (nunca asume)
- [ ] Audio no se almacena
- [ ] Todos los textos en ARB, ≤15 palabras, sin jerga
- [ ] `flutter analyze` 0 warnings
- [ ] Tests verdes: unit (parser, preparer), widget (a11y), integration
