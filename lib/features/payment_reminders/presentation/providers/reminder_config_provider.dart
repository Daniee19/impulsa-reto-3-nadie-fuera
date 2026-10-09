import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/data/repositories/reminder_config_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/entities/reminder_config.dart';

final reminderConfigRepositoryProvider = Provider<ReminderConfigRepository>(
  (ref) => ReminderConfigRepository(),
);

final reminderConfigProvider =
    StateNotifierProvider<ReminderConfigNotifier, ReminderConfig>(
      ReminderConfigNotifier.new,
    );

class ReminderConfigNotifier extends StateNotifier<ReminderConfig> {
  ReminderConfigNotifier(this._ref) : super(const ReminderConfig()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final repo = _ref.read(reminderConfigRepositoryProvider);
    state = await repo.getConfig();
  }

  Future<void> update(ReminderConfig config) async {
    state = config;
    await _ref.read(reminderConfigRepositoryProvider).saveConfig(config);
  }
}
