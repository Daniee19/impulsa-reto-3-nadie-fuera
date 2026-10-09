import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/domain/entities/lesson.dart';

abstract class LessonRepository {
  List<Lesson> getAllLessons();
  Lesson getLessonById(String id);
  List<Lesson> getLessonsForRules(Set<RiskRule> rules);
}
