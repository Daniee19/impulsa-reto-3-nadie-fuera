import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/bill.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/bill_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/entities/reminder.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/services/reminder_generator.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/presentation/providers/reminder_config_provider.dart';

final activeRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final bills = await ref.watch(
    billRepositoryProvider.select(
      (repo) => repo.getBills(status: BillStatus.pending),
    ),
  );
  final config = ref.watch(reminderConfigProvider);
  final configRepo = ref.read(reminderConfigRepositoryProvider);
  final dismissed = await configRepo.getDismissedBillIds();

  final effectiveConfig = config.enabledBillIds.isEmpty
      ? config.copyWith(enabledBillIds: bills.map((b) => b.id).toSet())
      : config;

  return ReminderGenerator().generate(
    bills: bills,
    config: effectiveConfig,
    now: DateTime.now(),
    dismissedBillIds: dismissed,
  );
}, dependencies: [billRepositoryProvider]);
