import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_channel.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_request.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';

/// Interface for managing help sessions.
abstract class HelpSessionRepository {
  /// Starts a simulated help session.
  Future<HelpRequest> startSession({
    required HelpTarget target,
    required String targetName,
    required HelpChannel channel,
    required HelpContext context,
    required bool includeContext,
  });

  /// Ends a session.
  Future<void> endSession(String requestId);
}
