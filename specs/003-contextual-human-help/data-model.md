# Data Model: Ayuda Humana con Contexto (003-contextual-human-help)

## Entities

### HelpContext (Paquete de contexto)

Información recopilada automáticamente cuando el usuario pide ayuda. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `screenName` | `String` | Nombre legible de la pantalla actual | Non-empty, en español |
| `screenRoute` | `String` | Ruta técnica (para debug) | Non-empty |
| `flowStep` | `String?` | Paso dentro del flujo (ej: "Paso 2 de 3") | Null si no hay flujo |
| `operationType` | `OperationType?` | Tipo de operación en curso | Null si no hay operación |
| `operationAmount` | `double?` | Monto de la operación | Null si no aplica |
| `operationRecipient` | `String?` | Nombre del destinatario | Null si no aplica |
| `timestamp` | `DateTime` | Momento de la solicitud | Non-null, UTC |

**Security filter** (FR-016): HelpContext NUNCA contiene:
- Contraseñas o PIN
- Datos biométricos
- Número de cuenta completo (solo últimos 4 dígitos si aplica)
- Nombre completo del titular (solo primer nombre)

**Mapa de pantallas**:
| Route pattern | screenName |
|---------------|------------|
| `/easy-mode` | "Pantalla principal" |
| `/easy-mode/balance` | "Ver mi saldo" |
| `/easy-mode/pay-bill` | "Elegir recibo para pagar" |
| `/easy-mode/pay-bill/:id/confirm` | "Confirmación de pago" |
| `/easy-mode/send-money` | "Enviar dinero" |
| `/easy-mode/send-money/confirm` | "Confirmación de envío" |
| `/easy-mode/fraud-alert` | "Alerta de seguridad" |
| `/easy-mode/help/*` | "Pidiendo ayuda" |
| `/easy-mode/settings/*` | "Configuración" |

### HelpChannel (Canal de comunicación)

Enum de canales disponibles.

| Value | UI Label (ARB) | Available for |
|-------|---------------|---------------|
| `call` | "Llamar" | Familiar + Asesor |
| `chat` | "Escribir" | Familiar + Asesor |
| `videoWithInterpreter` | "Videollamada con intérprete de lengua de señas" | Solo Asesor |

### HelpTarget (A quién contactar)

Enum de destinos de ayuda.

| Value | Description |
|-------|-------------|
| `trustedPerson` | Persona de confianza registrada (de 006) |
| `bankAdvisor` | Asesor del banco |

### HelpRequest (Solicitud de ayuda)

Solicitud completa generada al iniciar una sesión de ayuda. Freezed.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | UUID de la solicitud | Non-empty |
| `target` | `HelpTarget` | A quién se contacta | Non-null |
| `targetName` | `String` | Nombre del contacto | Non-empty |
| `channel` | `HelpChannel` | Canal elegido | Non-null |
| `context` | `HelpContext` | Contexto capturado | Non-null |
| `includeContext` | `bool` | Si se comparte contexto (consentimiento) | true para asesor, depende de permiso para familiar |
| `status` | `HelpRequestStatus` | Estado de la solicitud | Non-null |
| `createdAt` | `DateTime` | Fecha de creación | Non-null |

**Enum `HelpRequestStatus`**: `connecting`, `connected`, `noResponse`, `completed`, `cancelled`

**State transitions**:
```
connecting ──→ connected    (simulado: después de 2s delay)
connecting ──→ noResponse   (familiar: después de 60s timeout)
connecting ──→ cancelled    (usuario cancela antes de conectar)
noResponse ──→ connecting   (usuario acepta fallback a asesor, nueva request)
connected  ──→ completed    (usuario vuelve a la app)
```

### NavigationState (Estado de navegación)

Estado mantenido por el observer de go_router. No freezed — es un StateNotifier simple.

| Field | Type | Description |
|-------|------|-------------|
| `currentRoute` | `String` | Path de la ruta actual |
| `screenName` | `String` | Nombre legible de la pantalla |
| `flowStep` | `String?` | Paso del flujo si aplica |

### OperationInProgress (Operación en curso)

Estado mantenido por los flows de 001 cuando hay operación activa. Nullable.

| Field | Type | Description |
|-------|------|-------------|
| `type` | `OperationType` | Pago o transferencia |
| `amount` | `double` | Monto |
| `recipientName` | `String` | Nombre del destinatario |
| `recipientId` | `String` | ID del recibo o contacto |

## Relationships

```
User ──→ "Pedir ayuda" ──→ HelpRequest
                              ├── HelpTarget (quién)
                              ├── HelpChannel (cómo)
                              └── HelpContext (contexto)
                                    ├── NavigationState (de go_router observer)
                                    └── OperationInProgress? (de provider de 001)

HelpRequest ──→ ref.watch(trustedPersonProvider) de 006
                  └── Si helpRequests permission activo → mostrar opción familiar
```

El paquete de contexto es efímero — no se persiste. Se construye en el momento de la solicitud y se descarta al cerrar la sesión.

## Validation Rules (from spec)

1. **Contexto siempre real** (FR-006): HelpContext refleja la pantalla y operación actuales, no datos hardcodeados.
2. **Sin datos sensibles** (FR-016): el ContextCollector filtra contraseñas, PIN, biométricos, cuentas completas.
3. **Sin persona de confianza = solo asesor** (edge case): si `trustedPersonProvider` es null o no tiene `helpRequests`, solo aparece asesor.
4. **Progreso preservado** (FR-011): push/pop navigation, datos en providers de Riverpod.
5. **Máximo 2 toques** (SC-001): FAB (toque 1) → elegir contacto (toque 2) → elegir canal (toque 3, pero canal puede ser default si solo hay uno).
6. **Familiar sin consentimiento = sin contexto** (FR-007): si `helpRequests` off, HelpRequest.includeContext = false, el familiar solo ve "Rosa necesita ayuda".
7. **Videollamada solo para asesor** (FR-004): HelpChannel.videoWithInterpreter no aparece para persona de confianza.
