import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/entities/friction_signal.dart';
import 'package:meta/meta.dart';

/// Context sent to human help when friction triggers the request.
@immutable
class FrictionContext {
  /// Creates friction context.
  const FrictionContext({
    required this.signalType,
    required this.occurrences,
    required this.stepName,
    required this.humanReadable,
  });

  /// What friction was detected.
  final FrictionType signalType;

  /// How many times it occurred.
  final int occurrences;

  /// Step name where it happened.
  final String stepName;

  /// Human-readable description (max 15 words).
  final String humanReadable;

  /// Builds a human-readable description from signal data.
  static String buildHumanReadable(
    FrictionType type,
    int occurrences,
    String stepName,
  ) {
    switch (type) {
      case FrictionType.repeatedBackNavigation:
        return 'Retrocedió $occurrences veces en $stepName';
      case FrictionType.prolongedInactivity:
        return 'Estuvo sin interactuar en $stepName';
      case FrictionType.repeatedError:
        return 'Cometió el mismo error $occurrences veces en $stepName';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrictionContext &&
          signalType == other.signalType &&
          occurrences == other.occurrences &&
          stepName == other.stepName;

  @override
  int get hashCode => Object.hash(signalType, occurrences, stepName);
}
