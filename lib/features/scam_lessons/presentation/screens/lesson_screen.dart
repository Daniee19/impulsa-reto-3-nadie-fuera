import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/providers/lesson_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/data/services/text_to_speech_service.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/widgets/practice_question_widget.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/tts_provider.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({required this.lessonId, super.key});

  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  bool _ttsPlaying = false;
  late final TextToSpeechService _tts;

  @override
  void initState() {
    super.initState();
    _tts = ref.read(ttsProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = ref.read(lessonRepositoryProvider);
      final lesson = repo.getLessonById(widget.lessonId);
      A11yHelpers.screenAnnounce(View.of(context), lesson.title);
      _startTts(lesson.content);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _startTts(String text) {
    final tts = ref.read(ttsProvider);
    tts.setCompletionHandler(() {
      if (mounted) setState(() => _ttsPlaying = false);
    });
    tts.speak(text);
    setState(() => _ttsPlaying = true);
  }

  void _toggleTts() {
    final tts = ref.read(ttsProvider);
    if (_ttsPlaying) {
      tts.stop();
      setState(() => _ttsPlaying = false);
    } else {
      final repo = ref.read(lessonRepositoryProvider);
      final lesson = repo.getLessonById(widget.lessonId);
      _startTts(lesson.content);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(lessonRepositoryProvider);
    final lesson = repo.getLessonById(widget.lessonId);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(lesson.content, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            AccessibleButton(
              text: _ttsPlaying ? l10n.lesson_pause : l10n.contract_resume,
              icon: _ttsPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: _toggleTts,
            ),
            const SizedBox(height: 32),
            PracticeQuestionWidget(
              question: lesson.question,
              lessonId: lesson.id,
            ),
          ],
        ),
      ),
    );
  }
}
