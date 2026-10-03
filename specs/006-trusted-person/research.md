# Research: Persona de Confianza (006-trusted-person)

## R1: Persistencia con flutter_secure_storage

**Decision**: Usar `flutter_secure_storage` para almacenar los datos de la persona de confianza (nombre, teléfono, permisos activos, registros de consentimiento) como JSON serializado bajo una clave única.

**Rationale**: La constitución (Principio IV) exige que datos sensibles se almacenen en `flutter_secure_storage`. El teléfono del familiar es dato personal bajo Ley 29733. El `flutter_secure_storage` usa Android Keystore (API 23+) para cifrado — compatible con minSdk 26.

**Patrón de almacenamiento**:
- Clave: `trusted_person_data`
- Valor: JSON serializado del objeto `TrustedPerson` (freezed + json_serializable)
- Read/Write atómico — no hay concurrencia en una app móvil single-user

**Alternatives considered**:
- SharedPreferences: no cifrado, inapropiado para datos personales. Violación de Principio IV.
- SQLite/Drift: complejidad innecesaria para un solo registro. Un JSON en secure storage es más simple.
- Hive: dependencia adicional no justificada para un solo objeto.

## R2: Modelo de permisos granulares

**Decision**: Enum `TrustedPermission` con 3 valores fijos. `TrustedPerson` contiene un `Set<TrustedPermission>` que indica permisos activos. Método helper `hasPermission(TrustedPermission)` para consultas.

**Rationale**: La spec define exactamente 3 permisos (FR-002). Un enum es type-safe, extensible si se agregan permisos en el futuro, y permite consultas O(1) con Set. El método helper es lo que 002 y 003 llaman para decidir si muestran la opción del familiar.

**Los 3 permisos**:
| Enum value | Nombre en UI (ARB) | Efecto |
|------------|---------------------|--------|
| `securityAlerts` | "Avisos de seguridad" | 002 muestra "Consultar a mi persona de confianza" en alertas |
| `helpRequests` | "Pedidos de ayuda" | 003 muestra persona de confianza como opción de contacto |
| `configHelp` | "Ayudar a configurar" | Habilita envío/recepción de sugerencias de configuración |

**Alternatives considered**:
- Map<String, bool>: pierde type safety, propenso a typos en claves.
- Campos booleanos separados (`bool alertsEnabled`, etc.): no escala, más verbose en queries.

## R3: Registro de consentimiento (Ley 29733)

**Decision**: Cada activación de permiso crea un `ConsentRecord` con: permiso, fecha/hora, acción (granted/revoked). Los records se persisten junto con la persona de confianza en `flutter_secure_storage`.

**Rationale**: FR-013 y la Ley 29733 exigen consentimiento explícito y específico por permiso. El registro de consentimiento es la evidencia de que el usuario otorgó/revocó cada permiso en un momento específico. En producción, estos records irían a un backend auditable; en el prototipo, se almacenan localmente.

**Formato**:
```dart
@freezed
class ConsentRecord {
  const factory ConsentRecord({
    required TrustedPermission permission,
    required ConsentAction action, // granted | revoked
    required DateTime timestamp,
  }) = _ConsentRecord;
}
```

**Alternatives considered**:
- No registrar consentimiento: incumple Ley 29733 y FR-013.
- Registro solo en UI (toast/snackbar): no persiste, no auditable.

## R4: Servicio público para 002 y 003

**Decision**: La interfaz `TrustedPersonRepository` en `domain/repositories/` es el contrato público. El provider `trustedPersonProvider` en `presentation/providers/` expone un `AsyncValue<TrustedPerson?>` que 002 y 003 watch'an.

**Rationale**: Siguiendo el patrón de 001-easy-mode, las features se comunican a través de providers de Riverpod que dependen de interfaces abstractas. 002 y 003 no importan la capa data de 006 — solo la interfaz y el provider.

**Flujo de consulta desde 002-fraud-shield**:
```
FraudAlertScreen → ref.watch(trustedPersonProvider) → TrustedPerson?
  → if person != null && person.hasPermission(TrustedPermission.securityAlerts)
    → mostrar opción "Consultar a [person.name]"
    → else: solo "Cancelar" y "Continuar"
```

**Alternatives considered**:
- Event bus / callbacks: acoplamiento temporal, más difícil de testear.
- Service locator (GetIt): la constitución exige Riverpod, no otro DI container.

## R5: Sugerencias de configuración simuladas

**Decision**: Modelo `ConfigSuggestion` con tipos predefinidos (`fontSize`, `addContact`, `addBill`). Las sugerencias se crean desde un mock repository que simula "el lado del familiar". Una cola de sugerencias pendientes, mostrada como notificación en la configuración del usuario.

**Rationale**: FR-006 define las configuraciones sugeribles (tamaño de letra, contactos, recibos). En el prototipo, el usuario puede triggerear una sugerencia simulada desde un botón de debug (o se precarga una). El patrón sugerencia-aprobación (FR-006) garantiza que nada se aplica sin consentimiento explícito.

**Estado de sugerencia**: `pending` → `accepted` | `rejected`. Sugerencias rechazadas no se comunican al familiar (spec: "el familiar no se entera del rechazo").

**Alternatives considered**:
- Push notifications reales: fuera del alcance del prototipo (FR-014).
- Implementar la app del familiar: fuera del alcance, el spec lo dice explícitamente.

## R6: Notificaciones al familiar simuladas

**Decision**: Las "notificaciones" al familiar (avisos de 002, pedidos de ayuda de 003) se simulan con un snackbar/dialog que muestra lo que recibiría el familiar, visible en la app del usuario. No hay comunicación real.

**Rationale**: FR-014 dice que todo lo del familiar es simulado. Para la demo, un dialog que diga "Simulación: Valeria recibiría este aviso: [contenido]" es suficiente para demostrar el concepto al panel.

**Alternatives considered**:
- SMS real: requiere permisos, API de SMS, costo. Fuera del alcance.
- Firebase Cloud Messaging: requiere backend real. Fuera del alcance.

## R7: Navegación — rutas de configuración

**Decision**: Rutas de 006 anidadas bajo `/easy-mode/settings/trusted-person`:

```
/easy-mode/settings/trusted-person           → TrustedPersonSetupScreen (entry)
/easy-mode/settings/trusted-person/register  → TrustedPersonRegisterScreen
/easy-mode/settings/trusted-person/permissions → TrustedPersonPermissionsScreen
/easy-mode/settings/trusted-person/detail    → TrustedPersonDetailScreen
/easy-mode/settings/trusted-person/change    → TrustedPersonChangeScreen
/easy-mode/settings/trusted-person/remove    → TrustedPersonRemoveScreen
/easy-mode/settings/trusted-person/suggestion → ConfigSuggestionScreen
```

**Rationale**: El spec dice que se accede desde "la configuración del Modo Fácil". Anidar bajo `/easy-mode/settings/` mantiene la jerarquía lógica y la navegación back funciona naturalmente.

**Alternatives considered**:
- Rutas de primer nivel (`/trusted-person`): pierde la jerarquía de navegación.
