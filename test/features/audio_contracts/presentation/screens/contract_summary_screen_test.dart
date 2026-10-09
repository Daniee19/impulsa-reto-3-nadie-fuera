import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/data/repositories/mock_contract_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/presentation/providers/contract_review_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/presentation/screens/contract_summary_screen.dart';
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
      contractRepositoryProvider.overrideWithValue(
        MockContractRepository(),
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
  group('ContractSummaryScreen', () {
    testWidgets('shows first sections and title',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ContractSummaryScreen(
          contractId: 'savings_account',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Qué aceptas'), findsOneWidget);
      expect(find.text('Cuánto cuesta'), findsOneWidget);
    });

    testWidgets('shows disclaimer', (tester) async {
      await tester.pumpWidget(_wrap(
        const ContractSummaryScreen(
          contractId: 'savings_account',
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Este resumen te ayuda'),
        findsOneWidget,
      );
    });

    testWidgets('scrolling reveals remaining sections',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ContractSummaryScreen(
          contractId: 'savings_account',
        ),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Cómo cancelar'),
        200,
      );
      expect(find.text('Cómo cancelar'), findsOneWidget);
    });

    testWidgets('accept button shows disabled note',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const ContractSummaryScreen(
          contractId: 'savings_account',
        ),
      ));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('Primero escucha'),
        200,
      );
      expect(
        find.textContaining('Primero escucha'),
        findsOneWidget,
      );
    });

    testWidgets('meets a11y guidelines', (tester) async {
      await tester.pumpWidget(_wrap(
        const ContractSummaryScreen(
          contractId: 'savings_account',
        ),
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
