import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/domain/entities/lesson.dart';

class LessonListTile extends StatelessWidget {
  const LessonListTile({
    required this.lesson,
    required this.isCompleted,
    required this.onTap,
    super.key,
  });

  final Lesson lesson;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = isCompleted ? l10n.lesson_completed : l10n.lesson_notSeen;

    return Semantics(
      button: true,
      label: '${lesson.title}. $status',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: A11yHelpers.minSeparation,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: A11yHelpers.minTapTarget,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    status,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: isCompleted
                      ? const Color(0xFF2E7D32)
                      : Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
