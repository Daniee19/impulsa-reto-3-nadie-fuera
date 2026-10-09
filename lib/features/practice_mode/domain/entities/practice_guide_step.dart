import 'package:meta/meta.dart';

@immutable
class PracticeGuideStep {
  const PracticeGuideStep({
    required this.routePattern,
    required this.instruction,
    required this.stepNumber,
    required this.totalSteps,
  });

  final String routePattern;
  final String instruction;
  final int stepNumber;
  final int totalSteps;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PracticeGuideStep &&
          routePattern == other.routePattern &&
          instruction == other.instruction &&
          stepNumber == other.stepNumber &&
          totalSteps == other.totalSteps;

  @override
  int get hashCode =>
      Object.hash(routePattern, instruction, stepNumber, totalSteps);
}
