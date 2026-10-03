# Data Model: Escudo Antifraude (002-fraud-shield)

## Entities

### RiskRule (Regla de riesgo)

Enum que define los tipos de riesgo evaluables.

| Value | Description | Trigger condition |
|-------|-------------|-------------------|
| `unusualAmount` | Monto inusual | `amount > avgLast10 * amountMultiplier` |
| `newRecipient` | Destinatario nuevo | Recipient ID not in operation history |
| `highFrequency` | Frecuencia alta | `≥ maxOpsInWindow` ops in last `windowMinutes` |
| `unusualTime` | Horario inusual | `hour < safeHourStart \|\| hour >= safeHourEnd` |

No tiene estado ni persistencia — es un tipo puro.

### RiskThresholds (Umbrales configurables)

Configuración de umbrales para el motor de reglas. Freezed con valores por defecto.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `amountMultiplier` | `double` | `2.0` | Factor sobre promedio para considerar monto inusual |
| `historyWindow` | `int` | `10` | Últimas N operaciones para calcular promedio |
| `maxOpsInWindow` | `int` | `3` | Máximo de operaciones antes de alerta de frecuencia |
| `windowMinutes` | `int` | `10` | Ventana temporal para frecuencia (minutos) |
| `safeHourStart` | `int` | `7` | Hora de inicio del rango "seguro" (inclusive) |
| `safeHourEnd` | `int` | `22` | Hora de fin del rango "seguro" (exclusive) |

**Validation**: `amountMultiplier > 1.0`, `historyWindow > 0`, `maxOpsInWindow > 0`, `windowMinutes > 0`, `0 <= safeHourStart < safeHourEnd <= 24`.

### OperationContext (Contexto de operación)

Datos de la operación que se va a evaluar. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `type` | `OperationType` | `payment` o `transfer` | From 001 |
| `amount` | `double` | Monto de la operación | > 0 |
| `recipientId` | `String` | ID del destinatario (contacto o servicio) | Non-empty |
| `recipientName` | `String` | Nombre del destinatario | Non-empty |
| `timestamp` | `DateTime` | Momento de la operación | Non-null |

Reutiliza `OperationType` de 001-easy-mode.

### RiskAlert (Alerta de riesgo)

Resultado de la evaluación del motor. Freezed.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `triggeredRules` | `Set<RiskRule>` | Reglas activadas | Non-empty (si se crea, hay riesgo) |
| `operation` | `OperationContext` | Operación evaluada | Non-null |

**Computed property**: `riskLevel` — `high` si >1 regla activada, `medium` si 1 regla. Informativo para UX (mismo flujo en ambos casos).

**No state transitions**: un `RiskAlert` se crea, se presenta al usuario, y se descarta cuando el usuario toma una decisión. No se persiste.

## Relationships

```
OperationContext ────→ RiskEngine.evaluate() ────→ RiskAlert?
                              ↑
                    List<Operation> (historial de 001)
                    RiskThresholds (umbrales)

RiskAlert 1 ──── 1..4 RiskRule   (reglas activadas)
RiskAlert 1 ──── 1 OperationContext (operación evaluada)

FraudAlertScreen ──── ref.watch(trustedPersonProvider) de 006
```

El escudo no tiene entidades persistidas propias. Consume datos de 001 (historial) y de 006 (persona de confianza) para tomar decisiones.

## Validation Rules (from spec)

1. **Toda operación monetaria se evalúa** (FR-001): el motor corre para cada pago y transferencia, sin excepción. "Ver saldo" y "Pedir ayuda" no pasan por el motor.
2. **Nunca más de una pantalla de pausa** (FR-009): el motor retorna UN `RiskAlert` con todas las reglas activadas. La presentación muestra UNA pantalla.
3. **Nunca bloquear sin explicación** (FR-012): si hay `RiskAlert`, siempre hay al menos 2 opciones (cancelar + continuar). Nunca se muestra alerta sin opciones.
4. **Sin persona de confianza = 2 opciones** (FR-005): si `trustedPersonProvider` es null o no tiene `securityAlerts`, solo "Cancelar" y "Continuar".
5. **Cancelar no aprueba** (edge case): si el usuario cancela y reintenta, el motor se evalúa de nuevo. No hay caché de "ya revisado".
6. **Historial insuficiente no bloquea** (R3): si no hay historial para calcular promedio, la regla `unusualAmount` no se activa (no se penaliza al usuario nuevo).
