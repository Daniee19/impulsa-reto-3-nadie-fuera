import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/domain/entities/lesson_suggestion.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/providers/lesson_suggestion_provider.dart';

class LessonSuggestionCard extends ConsumerStatefulWidget {
  const LessonSuggestionCard({required this.suggestion, super.key});

  final LessonSuggestion suggestion;

  @override
  ConsumerState<LessonSuggestionCard> createState() =>
      _LessonSuggestionCardState();
}

class _LessonSuggestionCardState extends ConsumerState<LessonSuggestionCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(
        View.of(context),
        '${l10n.lesson_suggestion_prefix} '
        '${widget.suggestion.lesson.title}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lesson = widget.suggestion.lesson;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l10n.lesson_suggestion_prefix} '
              '${lesson.title}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            AccessibleButton(
              text: l10n.lesson_viewLesson,
              icon: Icons.school,
              onPressed: () {
                ref.read(lessonSuggestionProvider.notifier).acceptSuggestion();
                context.go('/easy-mode/lessons/${lesson.id}');
              },
            ),
            AccessibleButton(
              text: l10n.lesson_notNow,
              icon: Icons.close,
              onPressed: () =>
                  ref.read(lessonSuggestionProvider.notifier).dismiss(),
            ),
          ],
        ),
      ),
    );
  }
}
