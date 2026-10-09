import 'package:meta/meta.dart';

@immutable
class ConfidenceMetrics {
  const ConfidenceMetrics({
    this.successfulOpsWithoutHelp = 0,
    this.practiceSessionsCompleted = 0,
  });

  final int successfulOpsWithoutHelp;
  final int practiceSessionsCompleted;

  ConfidenceMetrics copyWith({
    int? successfulOpsWithoutHelp,
    int? practiceSessionsCompleted,
  }) {
    return ConfidenceMetrics(
      successfulOpsWithoutHelp:
          successfulOpsWithoutHelp ?? this.successfulOpsWithoutHelp,
      practiceSessionsCompleted:
          practiceSessionsCompleted ?? this.practiceSessionsCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfidenceMetrics &&
          other.successfulOpsWithoutHelp == successfulOpsWithoutHelp &&
          other.practiceSessionsCompleted == practiceSessionsCompleted;

  @override
  int get hashCode =>
      Object.hash(successfulOpsWithoutHelp, practiceSessionsCompleted);
}
