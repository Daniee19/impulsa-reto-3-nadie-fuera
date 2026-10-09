import 'package:meta/meta.dart';

enum AnticipationDays {
  one(1),
  three(3),
  five(5);

  const AnticipationDays(this.days);
  final int days;
}

@immutable
class ReminderConfig {
  const ReminderConfig({
    this.enabledBillIds = const {},
    this.anticipationDays = AnticipationDays.three,
    this.shareWithTrusted = false,
    this.shareConsentGranted = false,
  }) : assert(
         !shareWithTrusted || shareConsentGranted,
         'shareWithTrusted requires consent',
       );

  final Set<String> enabledBillIds;
  final AnticipationDays anticipationDays;
  final bool shareWithTrusted;
  final bool shareConsentGranted;

  ReminderConfig copyWith({
    Set<String>? enabledBillIds,
    AnticipationDays? anticipationDays,
    bool? shareWithTrusted,
    bool? shareConsentGranted,
  }) {
    return ReminderConfig(
      enabledBillIds: enabledBillIds ?? this.enabledBillIds,
      anticipationDays: anticipationDays ?? this.anticipationDays,
      shareWithTrusted: shareWithTrusted ?? this.shareWithTrusted,
      shareConsentGranted: shareConsentGranted ?? this.shareConsentGranted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderConfig &&
          enabledBillIds.length == other.enabledBillIds.length &&
          enabledBillIds.containsAll(other.enabledBillIds) &&
          anticipationDays == other.anticipationDays &&
          shareWithTrusted == other.shareWithTrusted &&
          shareConsentGranted == other.shareConsentGranted;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(enabledBillIds.toList()..sort()),
    anticipationDays,
    shareWithTrusted,
    shareConsentGranted,
  );
}
