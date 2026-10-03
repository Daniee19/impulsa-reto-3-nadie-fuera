# Research: Recordatorios de Pagos Recurrentes (012-payment-reminders)

## R1: flutter_local_notifications — evaluación y descarte

**Decision**: No usar `flutter_local_notifications`. Los recordatorios se muestran in-app al abrir la pantalla principal del Modo Fácil.

**Evaluación**:
- `flutter_local_notifications` requiere permisos de notificación (Android 13+: POST_NOTIFICATIONS).
- Requiere configuración de canales de notificación, íconos, y scheduling con `AndroidScheduleMode`.
- El spec dice explícitamente: "No se envían notificaciones push reales en el prototipo. Los recordatorios se muestran dentro de la app al abrirla."
- La constitución (II) exige que cada dependencia nueva tenga licencia MIT/BSD/Apache y justificación.

**Rationale**: Para el prototipo/hackathon, los recordatorios in-app cumplen todos los requisitos. Agregar `flutter_local_notifications` introduce complejidad (permisos, canales, scheduling, testing) sin beneficio para la demo. En una versión futura, se podría agregar.

**Alternatives considered**:
- `flutter_local_notifications`: funcional pero overkill para prototipo. Guardado como mejora futura.
- `awesome_notifications`: más features pero aún más complejo.
- WorkManager: para background scheduling, irrelevante para in-app only.

## R2: Reutilización de Bill de 001

**Decision**: Reutilizar la entidad `Bill` y `BillRepository` de 001. Ampliar los datos mock para incluir 4 recibos en vez de 3 (agregar teléfono y pensión, cambiar gas por teléfono).

**Cambio en 001 mock data**:
```dart
// Datos mock actuales de 001: Luz, Agua, Gas
// Propuesta para 012: Luz, Agua, Teléfono, Pensión
// Gas se reemplaza por Teléfono. Se agrega Pensión.
// Alternativa: mantener los 3 de 001 y agregar Teléfono solo en 012.
```

**Decision refinada**: No modificar los mock data de 001. En su lugar, 012 define sus propios `RecurringBill` que wrappean `Bill` de 001 agregando recurrencia. Los 3 bills de 001 (luz, agua, gas) se mapean; además se agregan teléfono como bill extra para la demo de 012.

Pero más simple: el spec dice "los recibos y fechas son simulados" y "al menos 4 recibos de ejemplo". La forma más lazy es que `BillRepository` de 001 retorne 4 recibos (añadiendo teléfono). El bill de 012 ES el bill de 001 — no hay wrapper.

**Decision final**: Agregar un 4to bill (Teléfono: S/ 60, vence el 10) al mock de 001. No se necesita entidad nueva — `Bill` ya tiene `dueDate`. El `ReminderGenerator` simplemente filtra bills por fecha vs config.

**Rationale**: Mínimo cambio. `Bill` de 001 ya tiene todo lo necesario (`serviceName`, `amount`, `dueDate`, `status`). No hay razón para duplicar.

**Alternatives considered**:
- Entidad RecurringBill separada: wrappear Bill solo para agregar recurrencia es YAGNI — los mock bills ya tienen dueDate.
- JSON de recibos en assets: duplica datos que ya están en el repo mock.

## R3: Generación de recordatorios — lógica pura en domain

**Decision**: `ReminderGenerator` es una clase Dart pura que recibe `List<Bill>`, `ReminderConfig`, `DateTime now`, y `Set<String> dismissedIds`, y retorna `List<Reminder>` ordenados por fecha.

**Implementación**:
```dart
class ReminderGenerator {
  List<Reminder> generate({
    required List<Bill> bills,
    required ReminderConfig config,
    required DateTime now,
    required Set<String> dismissedBillIds,
  }) {
    return bills
        .where((b) => b.status == BillStatus.pending)
        .where((b) => config.enabledBillIds.contains(b.id))
        .where((b) => !dismissedBillIds.contains(b.id))
        .where((b) => _isInWindow(b.dueDate, now, config.anticipationDays))
        .map((b) => Reminder(
              bill: b,
              message: _buildMessage(b, now),
              isOverdue: b.dueDate.isBefore(_startOfDay(now)),
            ))
        .toList()
      ..sort((a, b) => a.bill.dueDate.compareTo(b.bill.dueDate));
  }

  bool _isInWindow(DateTime dueDate, DateTime now, int days) {
    final start = _startOfDay(now);
    final overdueCutoff = start.subtract(const Duration(days: 3));
    final futureLimit = start.add(Duration(days: days));
    return dueDate.isAfter(overdueCutoff) && !dueDate.isAfter(futureLimit);
  }
}
```

**Rationale**: Dart puro, sin dependencias de Flutter ni Riverpod. Testeable con unit tests triviales. Inyectar `DateTime now` permite testing con fechas fijas.

**Alternatives considered**:
- Lógica en el provider: mezcla business logic con state management.
- Timer/cron: YAGNI, los recordatorios se calculan al abrir la app.

## R4: Fechas en lenguaje natural

**Decision**: Función pura `formatDueDate(DateTime dueDate, DateTime now)` que retorna texto en español:

| Condition | Output |
|-----------|--------|
| Same day | "hoy" |
| Tomorrow | "mañana" |
| Same week (future) | "el {día de la semana}" (ej: "el viernes") |
| Next week | "el {día} de {mes}" (ej: "el 15 de octubre") |
| Yesterday | "ayer" |
| 2-3 days ago | "el {día de la semana}" (pasado, ej: "el martes") |

**Implementación**:
```dart
String formatDueDate(DateTime dueDate, DateTime now, AppLocalizations l10n) {
  final diff = _dayDifference(dueDate, now);
  return switch (diff) {
    0 => l10n.reminderDateToday,
    1 => l10n.reminderDateTomorrow,
    -1 => l10n.reminderDateYesterday,
    _ when diff > 1 && diff <= 6 => l10n.reminderDateWeekday(_weekdayName(dueDate)),
    _ when diff < -1 && diff >= -3 => l10n.reminderDatePastWeekday(_weekdayName(dueDate)),
    _ => l10n.reminderDateFull(dueDate.day, _monthName(dueDate)),
  };
}
```

Textos en ARB para localización.

**Rationale**: Lenguaje natural es más comprensible que "15/10/2026" para el target (constitución VI).

**Alternatives considered**:
- `intl` DateFormat: retorna fechas formales, no "mañana" o "el viernes".
- `timeago` package: para tiempos relativos pasados, no para fechas futuras.

## R5: Mensaje del recordatorio

**Decision**: Template en ARB con 3 slots: servicio, fecha, monto.

**Ejemplos**:
- Futuro: "Tu recibo de {servicio} vence {fecha}: {monto} soles"
- Vencido: "Tu recibo de {servicio} venció {fecha}. Aún puedes pagarlo"

```dart
// ARB keys:
// reminderMessageFuture: "Tu recibo de {service} vence {date}: {amount} soles"
// reminderMessageOverdue: "Tu recibo de {service} venció {date}. Aún puedes pagarlo"

String buildMessage(Bill bill, DateTime now, AppLocalizations l10n) {
  final date = formatDueDate(bill.dueDate, now, l10n);
  if (bill.dueDate.isBefore(_startOfDay(now))) {
    return l10n.reminderMessageOverdue(bill.serviceName, date);
  }
  return l10n.reminderMessageFuture(bill.serviceName, date, bill.amount.toStringAsFixed(0));
}
```

**Rationale**: ARB cumple constitución VII. Mensajes ≤ 15 palabras cada frase.

**Alternatives considered**:
- Mensaje hardcoded: viola constitución VII (ARB obligatorio).

## R6: Configuración de recordatorios — SharedPreferences

**Decision**: SharedPreferences con prefijo `reminder_`.

**Keys**:
| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `reminder_enabled_bills` | `StringList` | Todos los IDs | Bills con recordatorio activo |
| `reminder_anticipation_days` | `int` | `3` | Días de anticipación (1, 3, o 5) |
| `reminder_share_with_trusted` | `bool` | `false` | Compartir con persona de confianza |
| `reminder_share_consent_granted` | `bool` | `false` | Consentimiento otorgado |
| `reminder_dismissed_{billId}` | `bool` | `false` | Recordatorio descartado para ese bill |

**Default**: Todos los recibos activos, 3 días de anticipación, sin compartir.

**Rationale**: Key-value simples. No son datos sensibles. SharedPreferences es suficiente.

**Alternatives considered**:
- flutter_secure_storage: para secretos, no para preferencias.
- Base de datos: overkill para ~10 keys.

## R7: Integración con flujo de pago de 001

**Decision**: "Pagar ahora" navega a la pantalla de pago de 001 con el bill preseleccionado.

**Implementación**:
```dart
// En ReminderCard, botón "Pagar ahora":
context.push('/easy-mode/pay-bill', extra: {'preselectedBillId': reminder.bill.id});
```

El flujo de pago de 001 lee el `extra` para preseleccionar el recibo y prellenar el monto. El flujo completo se ejecuta (confirmación, escudo antifraude si aplica, biometría).

**Al completar pago**: El `BillRepository` de 001 cambia el bill a `paid`. El `ReminderProvider` re-evalúa y el recordatorio desaparece (bill ya no es `pending`).

**Rationale**: Reutilización completa del flujo de 001. Un solo punto de cambio en 001 (leer `extra` para preseleccionar). Sin flujo de pago alternativo.

**Alternatives considered**:
- Pago directo sin confirmación: viola constitución VI (confirmación obligatoria).
- Nuevo flujo de pago: duplica 001, contradice el spec.

## R8: Aviso a persona de confianza (simulado)

**Decision**: Cuando `shareWithTrusted == true` y se genera un recordatorio, se muestra un badge/texto confirmando que "También se avisó a {nombre}". En el prototipo, no se envía notificación real — solo la confirmación visual.

**Datos compartidos** (FR-010): Solo nombre del servicio + fecha. NUNCA monto, saldo, ni datos de cuenta.

**Consentimiento** (FR-009): Al activar "Avisar a mi persona de confianza", dialog de consentimiento:
```
"Vamos a enviar a {nombre} un aviso con el nombre del recibo y la fecha.
No incluye tu saldo ni datos de tu cuenta. ¿Estás de acuerdo?"
```

**Requiere persona de confianza**: Si `trustedPersonProvider` retorna null, la opción no se muestra en configuración.

**Rationale**: El aviso simulado cumple el spec sin complejidad de envío real (SMS, push, etc.). El consentimiento cumple Ley 29733.

**Alternatives considered**:
- SMS real: fuera del alcance del prototipo. Requiere SMS gateway.
- Push notification a otro dispositivo: requiere backend, fuera del alcance.

## R9: Lectura TTS automática

**Decision**: Al mostrar recordatorios en la pantalla principal, TTS (de 004) lee el recordatorio más urgente automáticamente. Solo el primero, para no abrumar (FR-002).

**Implementación**:
```dart
// En EasyModeHomeScreen, después de construir reminders:
ref.listen(activeRemindersProvider, (_, reminders) {
  if (reminders.isNotEmpty) {
    final tts = ref.read(ttsServiceProvider);
    tts.speak(reminders.first.message);
  }
});
```

**Rationale**: El spec dice "la app lee el aviso en voz alta automáticamente". Solo el primero por coherencia con FR-002 ("Si hay varios, solo lee el primero").

**Alternatives considered**:
- Leer todos: puede ser confuso y largo.
- No leer automáticamente: contradice el spec.

## R10: Bills mock ampliados — 4 recibos

**Decision**: Agregar un 4to bill al mock de `BillRepository` de 001:

| Service | Provider | Amount | Due date |
|---------|----------|--------|----------|
| Luz | Enel | S/ 85.50 | 15 del mes |
| Agua | Sedapal | S/ 42.00 | 20 del mes |
| Teléfono | Movistar | S/ 60.00 | 10 del mes |
| Pensión | Colegio San Martín | S/ 150.00 | 5 del mes |

Las fechas de vencimiento se ajustan al mes actual del hackathon para que siempre haya recibos próximos a vencer. El mock de 001 originalmente tiene 3 (Luz, Agua, Gas) — se reemplaza Gas por Teléfono y se agrega Pensión.

**Rationale**: 4 recibos son el mínimo del spec (FR-015). Teléfono y pensión son más relevantes para adultos mayores que gas.

**Alternatives considered**:
- Mantener gas + agregar los 2 nuevos (5 total): el spec pide "al menos 4", 5 es innecesario.
- Repos separados: duplica datos innecesariamente.
