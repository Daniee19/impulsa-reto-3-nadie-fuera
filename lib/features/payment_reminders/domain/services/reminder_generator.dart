import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/entities/reminder.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/entities/reminder_config.dart';

const _weekdays = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

const _months = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

class ReminderGenerator {
  List<Reminder> generate({
    required List<Bill> bills,
    required ReminderConfig config,
    required DateTime now,
    required Set<String> dismissedBillIds,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final windowStart = today.subtract(const Duration(days: 3));
    final windowEnd = today.add(Duration(days: config.anticipationDays.days));

    final reminders = <Reminder>[];

    for (final bill in bills) {
      if (bill.status != BillStatus.pending) continue;
      if (!config.enabledBillIds.contains(bill.id)) continue;
      if (dismissedBillIds.contains(bill.id)) continue;

      final due = DateTime(
        bill.dueDate.year,
        bill.dueDate.month,
        bill.dueDate.day,
      );
      if (due.isBefore(windowStart) || due.isAfter(windowEnd)) {
        continue;
      }

      final diff = due.difference(today).inDays;
      final isOverdue = diff < 0;
      final message = _buildMessage(bill.serviceName, bill.amount, diff, due);

      reminders.add(
        Reminder(bill: bill, message: message, isOverdue: isOverdue),
      );
    }

    reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return reminders;
  }

  String _buildMessage(String service, double amount, int diff, DateTime due) {
    final amountStr = amount.toStringAsFixed(0);

    if (diff == 0) {
      return 'Tu recibo de $service vence hoy: '
          '$amountStr soles';
    } else if (diff == 1) {
      return 'Tu recibo de $service vence mañana: '
          '$amountStr soles';
    } else if (diff >= 2 && diff <= 6) {
      final wd = _weekdays[due.weekday - 1];
      return 'Tu recibo de $service vence el $wd: '
          '$amountStr soles';
    } else if (diff >= 7) {
      final day = due.day;
      final month = _months[due.month - 1];
      return 'Tu recibo de $service vence el $day '
          'de $month: $amountStr soles';
    } else if (diff == -1) {
      return 'Tu recibo de $service venció ayer. '
          'Aún puedes pagarlo.';
    } else {
      final wd = _weekdays[due.weekday - 1];
      return 'Tu recibo de $service venció el $wd. '
          'Aún puedes pagarlo.';
    }
  }
}
