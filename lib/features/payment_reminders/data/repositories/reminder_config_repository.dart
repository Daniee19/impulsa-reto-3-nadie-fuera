import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/entities/reminder_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderConfigRepository {
  static const _enabledKey = 'reminder_enabled_bill_ids';
  static const _anticipationKey = 'reminder_anticipation';
  static const _shareKey = 'reminder_share';
  static const _consentKey = 'reminder_consent';
  static const _dismissedKey = 'reminder_dismissed';

  Future<ReminderConfig> getConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final enabledList = prefs.getStringList(_enabledKey);
    final anticipationIdx = prefs.getInt(_anticipationKey);
    final share = prefs.getBool(_shareKey) ?? false;
    final consent = prefs.getBool(_consentKey) ?? false;

    return ReminderConfig(
      enabledBillIds: enabledList?.toSet() ?? const {},
      anticipationDays: anticipationIdx != null
          ? AnticipationDays.values[anticipationIdx]
          : AnticipationDays.three,
      shareWithTrusted: share && consent,
      shareConsentGranted: consent,
    );
  }

  Future<void> saveConfig(ReminderConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_enabledKey, config.enabledBillIds.toList());
    await prefs.setInt(_anticipationKey, config.anticipationDays.index);
    await prefs.setBool(_shareKey, config.shareWithTrusted);
    await prefs.setBool(_consentKey, config.shareConsentGranted);
  }

  Future<Set<String>> getDismissedBillIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dismissedKey) ?? [];
    return list.toSet();
  }

  Future<void> dismissBill(String billId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dismissedKey) ?? [];
    await prefs.setStringList(_dismissedKey, {...list, billId}.toList());
  }

  Future<void> clearDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dismissedKey);
  }
}
