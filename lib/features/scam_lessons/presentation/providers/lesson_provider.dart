import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/data/repositories/mock_lesson_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/domain/entities/lesson.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/domain/repositories/lesson_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _completedKey = 'scam_lessons_completed';

final lessonRepositoryProvider = Provider<LessonRepository>(
  (ref) => MockLessonRepository(),
);

final allLessonsProvider = Provider<List<Lesson>>((ref) {
  return ref.read(lessonRepositoryProvider).getAllLessons();
});

final lessonProgressProvider = FutureProvider<Set<String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_completedKey) ?? [];
  return list.toSet();
});

final isLessonCompletedProvider = FutureProvider.family<bool, String>((
  ref,
  lessonId,
) async {
  final completed = await ref.watch(lessonProgressProvider.future);
  return completed.contains(lessonId);
});

Future<void> markLessonCompleted(String lessonId) async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_completedKey) ?? [];
  final updated = {...list, lessonId}.toList();
  await prefs.setStringList(_completedKey, updated);
}
