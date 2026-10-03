# Data Model: Recordatorios de Pagos Recurrentes (012-payment-reminders)

## Entities

### Reminder (Recordatorio)

Aviso de un pago próximo o vencido. Freezed, Dart puro. Efímero — generado en runtime, no persistido.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `bill` | `Bill` | Recibo asociado (de 001) | Non-null |
| `message` | `String` | Mensaje localizado en lenguaje natural | Non-empty |
| `isOverdue` | `bool` | Si el recibo ya venció | — |

**Propiedad derivada**:
```dart
String get billId => bill.id;
DateTime get dueDate => bill.dueDate;
double get amount => bill.amount;
String get serviceName => bill.serviceName;
```

No tiene estado propio. El "descarte" se maneja como un set de IDs descartados en SharedPreferences.

### AnticipationDays (Días de anticipación)

Enum de opciones de anticipación. Dart puro.

| Value | Days | UI Label (ARB) |
|-------|------|---------------|
| `one` | `1` | "1 día antes" |
| `three` | `3` | "3 días antes" |
| `five` | `5` | "5 días antes" |

### ReminderConfig (Configuración de recordatorios)

Preferencias del usuario. Freezed, Dart puro.

| Field | Type | Default | Description | Validation |
|-------|------|---------|-------------|------------|
| `enabledBillIds` | `Set<String>` | Todos los IDs | Bills con recordatorio activo | Subset of available bills |
| `anticipationDays` | `AnticipationDays` | `three` | Días de anticipación | Valid enum |
| `shareWithTrusted` | `bool` | `false` | Compartir con persona de confianza | — |
| `shareConsentGranted` | `bool` | `false` | Consentimiento otorgado | — |

**Invariant**: `shareWithTrusted` solo puede ser `true` si `shareConsentGranted` es `true`.

### ReminderGenerator (Servicio domain)

Clase Dart pura. Genera `List<Reminder>` a partir de bills, config y fecha actual.

**Contract**:
```dart
class ReminderGenerator {
  List<Reminder> generate({
    required List<Bill> bills,
    required ReminderConfig config,
    required DateTime now,
    required Set<String> dismissedBillIds,
  });
}
```

**Reglas de generación**:
1. Solo bills con `status == BillStatus.pending`.
2. Solo bills en `config.enabledBillIds`.
3. No bills en `dismissedBillIds`.
4. Bill dentro de la ventana: `dueDate >= now - 3 días` AND `dueDate <= now + anticipationDays`.
5. Ordenados por `dueDate` ascendente (más próximo primero).
6. Si vencido (dueDate < hoy): `isOverdue = true`, mensaje en pasado.

### Formato de fecha natural

| Difference | Format | Example |
|-----------|--------|---------|
| 0 days | "hoy" | "Tu recibo de luz vence hoy" |
| +1 day | "mañana" | "Tu recibo de agua vence mañana" |
| +2 to +6 days | "el {weekday}" | "Tu recibo de luz vence el viernes" |
| +7+ days | "el {day} de {month}" | "Tu recibo de agua vence el 20 de octubre" |
| -1 day | "ayer" | "Tu recibo de luz venció ayer" |
| -2 to -3 days | "el {weekday}" | "Tu recibo de luz venció el martes" |

### Mock Bills (ampliados de 001)

| ID | Service | Provider | Amount | Due day |
|----|---------|----------|--------|---------|
| `bill_luz` | Luz | Enel | S/ 85.50 | 15 |
| `bill_agua` | Agua | Sedapal | S/ 42.00 | 20 |
| `bill_telefono` | Teléfono | Movistar | S/ 60.00 | 10 |
| `bill_pension` | Pensión | Colegio San Martín | S/ 150.00 | 5 |

Due dates se calculan en el mes actual para la demo (siempre hay al menos 1 próximo).

## Relationships

```
Bill (de 001)
  └── ReminderGenerator.generate(bills, config, now, dismissed)
        └── List<Reminder> (efímeros, ordenados por dueDate)

ReminderConfig (SharedPreferences)
  ├── enabledBillIds → filtra qué bills generan recordatorios
  ├── anticipationDays → ventana temporal
  ├── shareWithTrusted → flag para aviso a persona de confianza
  └── shareConsentGranted → Ley 29733

TrustedPerson (de 006)
  └── Si existe y shareWithTrusted → badge "También se avisó a {nombre}"

EasyModeHomeScreen (de 001)
  ├── ref.watch(activeRemindersProvider) → List<Reminder>
  ├── Hasta 3 ReminderCards en pantalla principal
  ├── TTS lee el primer recordatorio automáticamente
  └── "Pagar ahora" → context.push('/easy-mode/pay-bill', extra: {preselectedBillId})

BillRepository (de 001)
  └── Al pagar (status → paid) → recordatorio desaparece (bill filtrado)

dismissedBillIds (SharedPreferences, efímero por ciclo de vencimiento)
  └── "Ya lo sé, gracias" → agrega billId al set
```

## Reuse from Other Features

| Component | Source | How it's used in 012 |
|-----------|--------|---------------------|
| `Bill`, `BillStatus` | 001 | Entidad base del recordatorio |
| `BillRepository` | 001 | Fuente de recibos pendientes |
| Pay bill flow | 001 | "Pagar ahora" navega al flujo existente |
| `TrustedPerson`, `trustedPersonProvider` | 006 | Persona de confianza para aviso compartido |
| `TtsService`, `ttsServiceProvider` | 004 | Lectura automática del recordatorio |
| `EasyModeHomeScreen` | 001 | Punto de inserción de ReminderCards |
| `AccessibleButton` | 001 (core) | Botones de acciones |

## Validation Rules (from spec)

1. **Recordatorio solo para pendientes activos** (FR-001, SC-001): `status == pending` AND `enabledBillIds.contains(id)`.
2. **Ventana temporal** (FR-006): Solo si `dueDate` está dentro de `now - 3 días` hasta `now + anticipationDays`.
3. **Lectura automática del más urgente** (FR-002): Solo el primer recordatorio (ordenado por fecha).
4. **"Pagar ahora" prellenado** (FR-003, SC-003): Navega a flujo de 001 con `preselectedBillId`.
5. **"Ya lo sé" descarta** (FR-003): Agrega a `dismissedBillIds`. No vuelve para esa fecha de vencimiento.
6. **Hasta 3 visibles** (FR-004): Los demás accesibles scrolleando.
7. **Ordenados por urgencia** (FR-004): `dueDate` ascendente.
8. **Default: todos activos, 3 días** (FR-007).
9. **Persona de confianza opcional** (FR-008, FR-009): Solo si existe. Requiere consentimiento.
10. **Aviso sin monto** (FR-010, SC-007): Solo servicio + fecha.
11. **Vencidos hasta 3 días** (FR-011): Mensaje en pasado, botón sigue disponible.
12. **Desaparece al pagar** (FR-012): `status → paid` filtra el bill.
13. **Nunca interrumpe** (FR-013, SC-005): Solo en pantalla principal, no modal.
14. **Accesibilidad** (FR-014, SC-006): 48×48 dp, 4.5:1, TalkBack.
15. **4 recibos** (FR-015): Luz, agua, teléfono, pensión.
