import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/data/repositories/mock_lesson_repository.dart';

void main() {
  late MockLessonRepository repo;

  setUp(() => repo = MockLessonRepository());

  group('MockLessonRepository', () {
    test('getAllLessons returns 5', () {
      expect(repo.getAllLessons(), hasLength(5));
    });

    test('getLessonById returns correct lesson', () {
      final lesson = repo.getLessonById('fake_yape');
      expect(lesson.id, 'fake_yape');
      expect(lesson.title, 'El Yape falso');
    });

    test(
      'getLessonsForRules with newRecipient returns '
      'fake_yape + fake_relative',
      () {
        final lessons = repo.getLessonsForRules(
          {RiskRule.newRecipient},
        );
        final ids = lessons.map((l) => l.id).toSet();
        expect(ids, containsAll(['fake_yape', 'fake_relative']));
        expect(ids, hasLength(2));
      },
    );

    test(
      'getLessonsForRules with no matching rule returns empty',
      () {
        final lessons = repo.getLessonsForRules(<RiskRule>{});
        expect(lessons, isEmpty);
      },
    );

    test('each lesson has exactly one correct option', () {
      for (final lesson in repo.getAllLessons()) {
        final correctCount = lesson.question.options
            .where((o) => o.isCorrect)
            .length;
        expect(correctCount, 1,
            reason: '${lesson.id} should have 1 correct option');
      }
    });
  });
}
