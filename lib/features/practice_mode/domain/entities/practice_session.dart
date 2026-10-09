import 'package:meta/meta.dart';

@immutable
class PracticeSession {
  const PracticeSession({
    required this.active,
    required this.guideEnabled,
    this.startedAt,
  });

  const PracticeSession.inactive()
    : active = false,
      guideEnabled = false,
      startedAt = null;

  final bool active;
  final bool guideEnabled;
  final DateTime? startedAt;

  PracticeSession copyWith({
    bool? active,
    bool? guideEnabled,
    DateTime? startedAt,
  }) {
    return PracticeSession(
      active: active ?? this.active,
      guideEnabled: guideEnabled ?? this.guideEnabled,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PracticeSession &&
          active == other.active &&
          guideEnabled == other.guideEnabled &&
          startedAt == other.startedAt;

  @override
  int get hashCode => Object.hash(active, guideEnabled, startedAt);
}
