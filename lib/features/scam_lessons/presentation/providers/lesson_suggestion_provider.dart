import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_rule.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/domain/entities/lesson_suggestion.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/providers/lesson_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _rejectionsKey = 'scam_lessons_rejections';

final lessonSuggestionProvider =
    StateNotifierProvider<LessonSuggestionNotifier, LessonSuggestion?>(
      (ref) => LessonSuggestionNotifier(ref),
    );

class LessonSuggestionNotifier extends StateNotifier<LessonSuggestion?> {
  LessonSuggestionNotifier(this._ref) : super(null);

  final Ref _ref;

  Future<void> triggerFromAlert(Set<RiskRule> rules) async {
    final prefs = await SharedPreferences.getInstance();
    final rejections = prefs.getInt(_rejectionsKey) ?? 0;
    if (rejections >= 3) return;

    final completed = await _ref.read(lessonProgressProvider.future);
    final repo = _ref.read(lessonRepositoryProvider);

    final candidateIds = <String>{};
    for (final rule in rules) {
      final ids = alertToLessonMap[rule];
      if (ids != null) candidateIds.addAll(ids);
    }

    for (final id in candidateIds) {
      if (!completed.contains(id)) {
        state = LessonSuggestion(
          lesson: repo.getLessonById(id),
          triggeredRules: rules,
        );
        return;
      }
    }
  }

  Future<void> dismiss() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_rejectionsKey) ?? 0;
    await prefs.setInt(_rejectionsKey, current + 1);
  }

  void acceptSuggestion() {
    state = null;
  }
}
