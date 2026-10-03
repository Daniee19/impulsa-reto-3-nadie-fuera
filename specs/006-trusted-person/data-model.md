# Data Model: Persona de Confianza (006-trusted-person)

## Entities

### TrustedPerson (Persona de confianza)

Familiar registrado por el usuario. Máximo una por usuario.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | Identificador único (UUID) | Non-empty |
| `name` | `String` | Nombre completo del familiar | Non-empty, ≤ 100 chars |
| `phone` | `String` | Teléfono del familiar | Non-empty, formato peruano (9 dígitos) |
| `relationship` | `String` | Relación con el usuario (informativo) | Non-empty (ej: "Hija", "Sobrino") |
| `permissions` | `Set<TrustedPermission>` | Permisos activos | 0 a 3 permisos |
| `consentHistory` | `List<ConsentRecord>` | Historial de consentimientos | Append-only |
| `registeredAt` | `DateTime` | Fecha de registro | Non-null |

**Persisted in**: `flutter_secure_storage` como JSON bajo clave `trusted_person_data`.

**Mock data**: Valeria Martínez, 987654321, "Hija", permisos: {securityAlerts, helpRequests, configHelp}.

### TrustedPermission (Permiso)

Enum que define los permisos granulares.

| Value | UI Label (ARB key) | Description | Consumer |
|-------|---------------------|-------------|----------|
| `securityAlerts` | `trustedPerson_permission_securityAlerts` | "Avisos de seguridad: Valeria recibe un aviso si la app detecta algo raro" | 002-fraud-shield |
| `helpRequests` | `trustedPerson_permission_helpRequests` | "Pedidos de ayuda: cuando pidas ayuda puedes elegir a Valeria" | 003-contextual-human-help |
| `configHelp` | `trustedPerson_permission_configHelp` | "Ayudar a configurar: Valeria puede sugerirte cambios pero tú siempre decides" | 006 (this feature) |

Cada label tiene ≤ 15 palabras (FR-012, constitución Principio VI).

### ConsentRecord (Registro de consentimiento)

Registro inmutable de cada otorgamiento o revocación de permiso. Cumple Ley 29733.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `permission` | `TrustedPermission` | Permiso afectado | Valid enum value |
| `action` | `ConsentAction` | Acción realizada | `granted` / `revoked` |
| `timestamp` | `DateTime` | Fecha/hora exacta | Non-null, UTC |

**Enum `ConsentAction`**: `granted`, `revoked`

**Behavior**: Append-only. Nunca se borran. Al quitar la persona de confianza, se agrega un `revoked` para cada permiso activo antes de eliminar.

### ConfigSuggestion (Sugerencia de configuración)

Propuesta del familiar para cambiar un ajuste.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | Identificador único | Non-empty |
| `type` | `ConfigSuggestionType` | Tipo de cambio | Valid enum value |
| `description` | `String` | Descripción legible para el usuario | Non-empty, ≤ 15 words |
| `suggestedValue` | `String?` | Valor sugerido (ej: "grande") | Nullable |
| `status` | `ConfigSuggestionStatus` | Estado | `pending` / `accepted` / `rejected` |
| `createdAt` | `DateTime` | Fecha de creación | Non-null |
| `resolvedAt` | `DateTime?` | Fecha de resolución | Null if pending |

**Enum `ConfigSuggestionType`**: `fontSize`, `addContact`, `removeContact`, `addBill`, `removeBill`

**Enum `ConfigSuggestionStatus`**: `pending`, `accepted`, `rejected`

**State transitions**:
```
pending ──→ accepted   (usuario toca "Aceptar" → cambio se aplica)
pending ──→ rejected   (usuario toca "No, gracias" → sin efecto)
```

No hay transición de regreso. Una vez resuelta, la sugerencia es inmutable.

**Mock data** (sugerencia precargada):
- type: `fontSize`, description: "Hacer la letra más grande", suggestedValue: "large", status: `pending`

## Relationships

```
User 1 ──── 0..1 TrustedPerson     (máximo una persona de confianza)
TrustedPerson 1 ──── * ConsentRecord  (historial de consentimientos, append-only)
TrustedPerson 1 ──── * ConfigSuggestion (sugerencias enviadas por el familiar)
```

`TrustedPerson` no tiene relación directa con `Account`, `Bill`, ni `Operation` (de 001). La persona de confianza no accede a datos financieros. La relación con 002 y 003 es a través de permisos consultados via provider, no via modelo de datos.

## Validation Rules (from spec)

1. **Una sola persona de confianza** (FR-001): registrar una nueva cuando ya existe requiere confirmar cambio primero (US4).
2. **No auto-registro** (edge case): el teléfono de la persona de confianza no puede ser el mismo que el del usuario.
3. **Teléfono válido**: 9 dígitos, formato peruano (empieza con 9).
4. **Sin permisos es válido** (edge case): se puede registrar persona de confianza sin activar ningún permiso.
5. **Consentimiento antes de activar** (FR-013): cada activación de permiso crea un ConsentRecord.
6. **Revocación inmediata** (FR-007, FR-008): al desactivar un permiso, al cambiar o quitar persona de confianza, el efecto es inmediato en 002/003.
7. **Sugerencias requieren aprobación** (FR-006): nunca se aplican automáticamente. ConfigSuggestionStatus.pending hasta que el usuario decide.
