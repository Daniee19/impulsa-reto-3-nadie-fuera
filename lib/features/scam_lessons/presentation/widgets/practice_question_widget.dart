import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/domain/entities/lesson.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/providers/lesson_provider.dart';

class PracticeQuestionWidget extends StatefulWidget {
  const PracticeQuestionWidget({
    required this.question,
    required this.lessonId,
    super.key,
  });

  final PracticeQuestion question;
  final String lessonId;

  @override
  State<PracticeQuestionWidget> createState() => _PracticeQuestionWidgetState();
}

class _PracticeQuestionWidgetState extends State<PracticeQuestionWidget> {
  AnswerOption? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.question.prompt, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        if (_selected == null)
          for (final option in widget.question.options)
            AccessibleButton(
              text: option.text,
              icon: Icons.radio_button_unchecked,
              onPressed: () => _answer(option),
            )
        else ...[
          Card(
            color: _selected!.isCorrect
                ? Colors.green.shade50
                : Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _selected!.feedback,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AccessibleButton(
            text: l10n.lesson_back,
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ],
    );
  }

  void _answer(AnswerOption option) {
    setState(() => _selected = option);
    markLessonCompleted(widget.lessonId);
  }
}
