import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/assistant_intent.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/operation_summary.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/voice_session.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/microphone_consent_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/voice_assistant_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/screens/microphone_consent_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/screens/operation_summary_screen.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: child,
    ),
  );
}

void main() {
  group('Voice Assistant A11y', () {
    testWidgets('microphone consent screen meets a11y guidelines',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const MicrophoneConsentScreen(),
        overrides: [
          microphoneConsentProvider.overrideWith(
            (ref) => MicrophoneConsentNotifier(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('operation summary screen meets a11y guidelines',
        (tester) async {
      final session = VoiceSession(
        id: 'test',
        status: VoiceSessionStatus.awaitingConfirmation,
        inputSource: InputSource.text,
        createdAt: DateTime.now(),
        operationSummary: const OperationSummary(
          type: OperationType.transfer,
          recipientName: 'Ana García',
          recipientId: 'c1',
          amount: 50.0,
          spokenSummary: 'Enviar 50 soles a Ana García',
        ),
      );

      await tester.pumpWidget(_wrap(
        const OperationSummaryScreen(),
        overrides: [
          voiceAssistantProvider.overrideWith(
            (ref) => VoiceAssistantNotifier(ref)..state = session,
          ),
        ],
      ));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
