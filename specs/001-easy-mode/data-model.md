# Data Model: Modo Fácil (001-easy-mode)

## Entities

### Account (Cuenta)

Representa la cuenta bancaria del usuario. Datos simulados.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | Identificador único | Non-empty |
| `holderName` | `String` | Nombre del titular | Non-empty |
| `maskedNumber` | `String` | Número enmascarado (ej: `****1234`) | Formato `****NNNN` |
| `availableBalance` | `double` | Saldo disponible en soles | ≥ 0 |
| `currency` | `String` | Moneda (siempre `PEN`) | `PEN` |

**Mock data**: Rosa Martínez, ****5678, S/ 2,450.00

### Bill (Recibo)

Recibo pendiente de pago de un servicio. Datos simulados, precargados.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | Identificador único | Non-empty |
| `serviceName` | `String` | Nombre del servicio (ej: "Luz") | Non-empty, ≤ 15 chars |
| `providerName` | `String` | Empresa (ej: "Enel") | Non-empty |
| `amount` | `double` | Monto a pagar | > 0 |
| `dueDate` | `DateTime` | Fecha de vencimiento | Non-null |
| `status` | `BillStatus` | Estado | `pending` / `paid` |

**Enum `BillStatus`**: `pending`, `paid`

**Mock data**:
- Luz (Enel): S/ 85.50, vence 2026-10-15
- Agua (Sedapal): S/ 42.00, vence 2026-10-20
- Gas (Cálidda): S/ 63.20, vence 2026-10-25

### SavedContact (Contacto guardado)

Persona a la que el usuario puede enviar dinero. Precargados, no editables en esta feature.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | Identificador único | Non-empty |
| `name` | `String` | Nombre completo | Non-empty |
| `initial` | `String` | Inicial para avatar | 1 char |
| `maskedAccount` | `String` | Cuenta destino enmascarada | Formato `****NNNN` |

**Mock data**:
- Valeria Martínez, V, ****9012
- Carlos López, C, ****3456
- María Sánchez, M, ****7890

### Operation (Operación)

Registro de un pago o transferencia completada.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | Identificador único | Non-empty |
| `type` | `OperationType` | Tipo de operación | `payment` / `transfer` |
| `recipientName` | `String` | Destinatario | Non-empty |
| `amount` | `double` | Monto | > 0 |
| `date` | `DateTime` | Fecha/hora | Non-null |
| `status` | `OperationStatus` | Estado | `success` / `failed` |
| `description` | `String` | Resumen legible | Non-empty |

**Enum `OperationType`**: `payment`, `transfer`

**Enum `OperationStatus`**: `success`, `failed`

**State transitions**: No hay transiciones — una operación se crea con su estado final después de la confirmación. En el mock, siempre es `success` excepto si se simula error de conexión.

## Relationships

```
Account 1 ──── * Bill          (una cuenta tiene N recibos pendientes)
Account 1 ──── * SavedContact  (una cuenta tiene N contactos guardados)
Account 1 ──── * Operation     (una cuenta tiene N operaciones completadas)
Bill    1 ───── 0..1 Operation  (un recibo pagado genera una operación)
SavedContact 1 ── * Operation  (un contacto puede recibir N transferencias)
```

Para el prototipo, las relaciones son implícitas (todo pertenece a la única cuenta mock). No hay foreign keys explícitas — los repositorios resuelven las relaciones por filtrado en memoria.

## Validation Rules (from spec)

1. **Monto de envío ≤ saldo disponible** (FR-003, US3-AS4): si `amount > account.availableBalance`, mostrar "No tienes suficiente dinero" con saldo actual.
2. **Monto > 0**: no se permiten transferencias o pagos de S/ 0.00.
3. **Recibo en estado `pending`**: solo se pueden pagar recibos pendientes.
4. **Saldo cero**: se muestra S/ 0.00 sin alarmas ni mensajes confusos (edge case del spec).
