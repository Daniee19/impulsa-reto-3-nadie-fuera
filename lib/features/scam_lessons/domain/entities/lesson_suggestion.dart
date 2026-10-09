import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/domain/entities/lesson.dart';
import 'package:meta/meta.dart';

const alertToLessonMap = <RiskRule, List<String>>{
  RiskRule.newRecipient: ['fake_yape', 'fake_relative'],
  RiskRule.unusualAmount: ['bank_call_scam'],
  RiskRule.unusualTime: ['bank_call_scam', 'sms_phishing'],
  RiskRule.highFrequency: ['fake_prize'],
};

@immutable
class LessonSuggestion {
  const LessonSuggestion({required this.lesson, required this.triggeredRules});

  final Lesson lesson;
  final Set<RiskRule> triggeredRules;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonSuggestion && lesson == other.lesson;

  @override
  int get hashCode => lesson.hashCode;
}
