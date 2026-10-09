import 'dart:math';

import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_channel.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_request.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/repositories/help_session_repository.dart';

/// Simulated help session repository for the prototype.
class MockHelpSessionRepository implements HelpSessionRepository {
  final _random = Random();

  @override
  Future<HelpRequest> startSession({
    required HelpTarget target,
    required String targetName,
    required HelpChannel channel,
    required HelpContext context,
    required bool includeContext,
  }) async {
    return HelpRequest(
      id: 'help-${_random.nextInt(99999)}',
      target: target,
      targetName: targetName,
      channel: channel,
      context: context,
      includeContext: includeContext,
      status: HelpRequestStatus.connecting,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> endSession(String requestId) async {}
}
