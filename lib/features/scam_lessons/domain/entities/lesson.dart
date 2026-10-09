import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:meta/meta.dart';

@immutable
class AnswerOption {
  const AnswerOption({
    required this.text,
    required this.isCorrect,
    required this.feedback,
  });

  final String text;
  final bool isCorrect;
  final String feedback;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnswerOption &&
          text == other.text &&
          isCorrect == other.isCorrect &&
          feedback == other.feedback;

  @override
  int get hashCode => Object.hash(text, isCorrect, feedback);
}

@immutable
class PracticeQuestion {
  const PracticeQuestion({required this.prompt, required this.options});

  final String prompt;
  final List<AnswerOption> options;

  AnswerOption get correctOption => options.firstWhere((o) => o.isCorrect);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PracticeQuestion && prompt == other.prompt;

  @override
  int get hashCode => prompt.hashCode;
}

@immutable
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.relatedRiskRules,
    required this.question,
  });

  final String id;
  final String title;
  final String content;
  final Set<RiskRule> relatedRiskRules;
  final PracticeQuestion question;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Lesson && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
