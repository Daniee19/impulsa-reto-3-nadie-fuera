import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/data/repositories/mock_help_session_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_channel.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_request.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/repositories/help_session_repository.dart';

/// Provides the help session repository.
final helpSessionRepositoryProvider = Provider<HelpSessionRepository>(
  (ref) => MockHelpSessionRepository(),
);

/// Manages the current help session.
class HelpSessionNotifier extends StateNotifier<HelpRequest?> {
  /// Creates the notifier with a repository.
  HelpSessionNotifier(this._repo) : super(null);

  final HelpSessionRepository _repo;

  /// Starts a new help session.
  Future<void> startSession({
    required HelpTarget target,
    required String targetName,
    required HelpChannel channel,
    required HelpContext context,
    required bool includeContext,
  }) async {
    final request = await _repo.startSession(
      target: target,
      targetName: targetName,
      channel: channel,
      context: context,
      includeContext: includeContext,
    );
    state = request;
  }

  /// Marks the session as connected.
  void markConnected() {
    if (state != null) {
      state = state!.copyWith(status: HelpRequestStatus.connected);
    }
  }

  /// Marks the session as no response (triggers fallback).
  void markNoResponse() {
    if (state != null) {
      state = state!.copyWith(status: HelpRequestStatus.noResponse);
    }
  }

  /// Ends the current session.
  void endSession() {
    state = null;
  }
}

/// Provides the current help session state.
final helpSessionProvider =
    StateNotifierProvider<HelpSessionNotifier, HelpRequest?>((ref) {
      final repo = ref.watch(helpSessionRepositoryProvider);
      return HelpSessionNotifier(repo);
    });
