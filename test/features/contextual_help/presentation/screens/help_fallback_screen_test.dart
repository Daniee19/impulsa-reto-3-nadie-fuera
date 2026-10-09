import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_channel.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_request.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/repositories/help_session_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/help_session_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/screens/help_fallback_screen.dart';

final _testContext = HelpContext(
  screenName: 'Enviar dinero',
  screenRoute: '/easy-mode/send-money',
  timestamp: DateTime(2026, 10, 3, 14),
);

final _testRequest = HelpRequest(
  id: 'req-1',
  target: HelpTarget.trustedPerson,
  targetName: 'Valeria',
  channel: HelpChannel.call,
  context: _testContext,
  includeContext: true,
  status: HelpRequestStatus.noResponse,
  createdAt: DateTime(2026, 10, 3, 14),
);

class _TestNotifier extends HelpSessionNotifier {
  _TestNotifier({HelpRequest? initial}) : super(_NoOpRepo()) {
    if (initial != null) state = initial;
  }
}

Widget buildTestWidget({HelpRequest? request}) {
  return ProviderScope(
    overrides: [
      helpSessionProvider.overrideWith(
        (ref) => _TestNotifier(initial: request),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('es'),
      home: HelpFallbackScreen(),
    ),
  );
}

class _NoOpRepo implements HelpSessionRepository {
  @override
  Future<HelpRequest> startSession({
    required HelpTarget target,
    required String targetName,
    required HelpChannel channel,
    required HelpContext context,
    required bool includeContext,
  }) async {
    return _testRequest;
  }

  @override
  Future<void> endSession(String requestId) async {}
}

void main() {
  group('HelpFallbackScreen', () {
    testWidgets('shows fallback message with name', (tester) async {
      await tester.pumpWidget(buildTestWidget(request: _testRequest));
      await tester.pumpAndSettle();

      expect(find.textContaining('Valeria'), findsOneWidget);
    });

    testWidgets('shows yes and back buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget(request: _testRequest));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('meets a11y tap target guidelines', (tester) async {
      await tester.pumpWidget(buildTestWidget(request: _testRequest));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });

    testWidgets('meets labeled tap target guidelines', (tester) async {
      await tester.pumpWidget(buildTestWidget(request: _testRequest));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
