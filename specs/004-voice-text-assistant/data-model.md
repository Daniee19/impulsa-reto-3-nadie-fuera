# Data Model: Asistente de Voz y Texto (004-voice-text-assistant)

## Entities

### AssistantIntentType (Tipo de intención)

Enum cerrado de intenciones que el asistente puede reconocer. Dart puro.

| Value | Description | Requires biometric | Passes fraud check |
|-------|-------------|-------------------|-------------------|
| `checkBalance` | Consultar saldo de la cuenta | No | No |
| `payBill` | Pagar un recibo de servicio pendiente | Sí | Sí |
| `sendMoney` | Enviar dinero a un contacto guardado | Sí | Sí |
| `requestHelp` | Pedir ayuda (delega a 003) | No | No |
| `unknown` | No se pudo identificar la intención | No | No |

### ParsedIntent (Intención interpretada)

Resultado de interpretar una frase del usuario. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `type` | `AssistantIntentType` | Intención identificada | Non-null |
| `parameters` | `IntentParameters?` | Parámetros extraídos | Null si no aplica |

### IntentParameters (Parámetros extraídos)

Parámetros opcionales extraídos de la frase del usuario. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `serviceName` | `String?` | Nombre del servicio mencionado ("luz", "agua") | Null si no mencionó |
| `contactName` | `String?` | Nombre o referencia al contacto ("Valeria", "mi hija") | Null si no mencionó |
| `amount` | `double?` | Monto mencionado | Null si no mencionó, > 0 si presente |

**Nota**: Estos son datos extraídos de la frase, no datos definitivos. El `OperationPreparer` los resuelve contra los repositorios para obtener los datos reales.

### OperationSummary (Resumen de operación)

Resumen construido con datos reales del repositorio, listo para leer en voz alta y confirmar. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `type` | `OperationType` | Pago o transferencia (de 001) | Non-null |
| `amount` | `double` | Monto real del repositorio | > 0 |
| `recipientName` | `String` | Nombre del destinatario/servicio | Non-empty |
| `recipientId` | `String` | ID del recibo o contacto | Non-empty |
| `spokenSummary` | `String` | Texto para leer en voz alta (ARB) | Non-empty, ≤15 palabras |

**Invariante de seguridad**: `amount` y `recipientName` SIEMPRE provienen del repositorio (Bill, Contact, Account), NUNCA del texto interpretado por el parser. El parser solo identifica la intención y sugiere parámetros; el `OperationPreparer` los valida contra datos reales.

### VoiceSession (Sesión del asistente)

Estado completo de una sesión con el asistente. Freezed.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | UUID de la sesión | Non-empty |
| `status` | `VoiceSessionStatus` | Estado actual del flujo | Non-null |
| `inputText` | `String?` | Texto reconocido (voz) o escrito | Null hasta recibir input |
| `inputSource` | `InputSource` | Canal de entrada | Non-null |
| `parsedIntent` | `ParsedIntent?` | Intención interpretada | Null hasta parsear |
| `operationSummary` | `OperationSummary?` | Resumen preparado | Null si no aplica |
| `assistantMessage` | `String?` | Último mensaje del asistente | Null hasta responder |
| `createdAt` | `DateTime` | Inicio de la sesión | Non-null |

**Enum `VoiceSessionStatus`**:
| Value | Description |
|-------|-------------|
| `idle` | Esperando input del usuario |
| `listening` | Micrófono activo, escuchando |
| `processing` | Interpretando la frase |
| `needsMore` | Falta un dato, preguntando al usuario |
| `summarizing` | Leyendo resumen en voz alta |
| `awaitingConfirmation` | Esperando huella/PIN |
| `executing` | Ejecutando la operación |
| `completed` | Operación exitosa |
| `error` | Error en algún paso |

**State transitions**:
```
idle ──→ listening         (usuario toca botón de micrófono)
idle ──→ processing        (usuario envía texto)
listening ──→ processing   (reconocimiento finalizado)
listening ──→ idle         (reconocimiento falló, asistente pide repetir)
processing ──→ needsMore   (falta parámetro obligatorio)
processing ──→ summarizing (operación monetaria lista, leyendo resumen)
processing ──→ completed   (consulta de saldo, lee resultado en voz alta)
processing ──→ idle        (intención unknown, muestra opciones)
needsMore ──→ processing   (usuario da el dato faltante)
summarizing ──→ awaitingConfirmation  (resumen leído, pedir huella)
awaitingConfirmation ──→ executing    (huella/PIN exitoso)
awaitingConfirmation ──→ awaitingConfirmation  (huella falló, reintentar)
executing ──→ completed    (operación exitosa)
executing ──→ error        (operación falló)
```

**Nota sobre fraude**: entre `summarizing` y `awaitingConfirmation`, el provider evalúa `RiskEngine`. Si hay alerta, navega a `FraudAlertScreen` (002) en vez de pedir huella directamente. Si el usuario continúa desde la alerta, vuelve a `awaitingConfirmation`.

**Enum `InputSource`**: `voice`, `text`

### MicrophoneConsent (Consentimiento de micrófono)

No es una entidad freezed — es un valor simple en SharedPreferences.

| Key | Type | Description |
|-----|------|-------------|
| `microphone_consent_granted` | `bool` | Si el usuario aceptó usar micrófono |

Lógica: si `false` o no existe → mostrar `MicrophoneConsentScreen` antes de activar micrófono. Si rechazó → solo entrada por texto.

## Relationships

```
User ──→ VoiceAssistantScreen ──→ VoiceSession
                                     ├── InputSource (voice/text)
                                     ├── ParsedIntent
                                     │    ├── AssistantIntentType
                                     │    └── IntentParameters?
                                     └── OperationSummary?
                                          └── datos de AccountRepo / BillRepo / ContactRepo (001)

VoiceSession ──→ RiskEngine.evaluate() (002) ──→ FraudAlertScreen?
VoiceSession ──→ BiometricAuthService (local_auth) ──→ ejecutar operación
VoiceSession ──→ (si requestHelp) ──→ HelpContactPickerScreen (003)
```

La sesión es efímera — no se persiste. Cada vez que el usuario abre el asistente, inicia una nueva sesión.

## Validation Rules (from spec)

1. **Lista cerrada** (FR-002): IntentParser solo retorna valores del enum AssistantIntentType. No puede inventar intenciones.
2. **IA no ejecuta** (FR-003): ParsedIntent prepara, OperationSummary muestra, biometría confirma. Tres pasos separados antes de ejecutar.
3. **Datos reales** (FR-006): OperationSummary.amount y .recipientName vienen del repositorio. El parser solo sugiere.
4. **No adivinar** (FR-007): Si type == unknown, el asistente pregunta. Nunca ejecuta con baja confianza.
5. **Parámetros faltantes** (FR-009): Si amount == null en sendMoney, status pasa a needsMore. Pregunta, no asume.
6. **Fraude** (FR-010): Toda operación monetaria pasa por RiskEngine antes de awaitingConfirmation.
7. **Consentimiento** (FR-011): Micrófono requiere consentimiento explícito antes del primer uso.
8. **Audio efímero** (FR-013): El texto reconocido se usa en la sesión y se descarta. No se almacena audio.
9. **Datos anonimizados** (FR-014): El IntentParser recibe solo el texto de la frase. No recibe DNI, cuentas, ni datos personales del repositorio.
10. **Solo contactos guardados** (edge case): sendMoney solo funciona con contactos existentes en ContactRepository.
