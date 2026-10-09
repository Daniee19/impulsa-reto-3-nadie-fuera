import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/data/repositories/mock_lesson_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/providers/lesson_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/scam_lessons/presentation/screens/lesson_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/data/services/text_to_speech_service.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/tts_provider.dart';

class _FakeTts extends TextToSpeechService {
  @override
  Future<void> speak(String text) async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> setSpeechRate(double rate) async {}
  @override
  void setCompletionHandler(void Function() handler) {}
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      ttsProvider.overrideWithValue(_FakeTts()),
      lessonRepositoryProvider.overrideWithValue(
        MockLessonRepository(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates:
          AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: child,
    ),
  );
}

void main() {
  group('LessonScreen', () {
    testWidgets('shows lesson content', (tester) async {
      await tester.pumpWidget(_wrap(
        const LessonScreen(lessonId: 'fake_yape'),
      ));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Alguien te escribe'),
        findsOneWidget,
      );
    });

    testWidgets('shows practice question', (tester) async {
      await tester.pumpWidget(_wrap(
        const LessonScreen(lessonId: 'fake_yape'),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('¿Qué haces?'),
        200,
      );
      expect(
        find.textContaining('¿Qué haces?'),
        findsOneWidget,
      );
    });

    testWidgets('correct answer shows positive feedback',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const LessonScreen(lessonId: 'fake_yape'),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('Reviso mi saldo real'),
        200,
      );
      await tester.tap(
        find.textContaining('Reviso mi saldo real'),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('¡Bien hecho!'),
        findsOneWidget,
      );
    });

    testWidgets(
      'incorrect answer shows kind feedback without '
      '"Incorrecto"',
      (tester) async {
        await tester.pumpWidget(_wrap(
          const LessonScreen(lessonId: 'fake_yape'),
        ));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.textContaining('Devuelvo el dinero'),
          200,
        );
        await tester.tap(
          find.textContaining('Devuelvo el dinero'),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Cuidado'),
          findsOneWidget,
        );
        expect(find.textContaining('Incorrecto'), findsNothing);
        expect(find.textContaining('Error'), findsNothing);
        expect(find.textContaining('Mal'), findsNothing);
      },
    );

    testWidgets('meets a11y guidelines', (tester) async {
      await tester.pumpWidget(_wrap(
        const LessonScreen(lessonId: 'fake_yape'),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        tester,
        meetsGuideline(androidTapTargetGuideline),
      );
      await expectLater(
        tester,
        meetsGuideline(labeledTapTargetGuideline),
      );
    });
  });
}
