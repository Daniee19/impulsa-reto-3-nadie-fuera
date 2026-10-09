import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/providers/lesson_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/widgets/lesson_list_tile.dart';

class LessonListScreen extends ConsumerStatefulWidget {
  const LessonListScreen({super.key});

  @override
  ConsumerState<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends ConsumerState<LessonListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.lesson_listTitle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lessons = ref.watch(allLessonsProvider);
    final progressAsync = ref.watch(lessonProgressProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lesson_listTitle)),
      body: SafeArea(
        child: progressAsync.when(
          data: (completed) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return LessonListTile(
                lesson: lesson,
                isCompleted: completed.contains(lesson.id),
                onTap: () => context.go('/easy-mode/lessons/${lesson.id}'),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
