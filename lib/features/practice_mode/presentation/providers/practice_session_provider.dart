import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/domain/entities/practice_session.dart';

/// Notifier for the practice session state.
class PracticeSessionNotifier extends StateNotifier<PracticeSession> {
  /// Creates the notifier.
  PracticeSessionNotifier() : super(const PracticeSession.inactive());

  /// Enters practice mode.
  void start({required bool guideEnabled}) {
    state = PracticeSession(
      active: true,
      guideEnabled: guideEnabled,
      startedAt: DateTime.now(),
    );
  }

  /// Exits practice mode.
  void end() => state = const PracticeSession.inactive();
}

/// Provider for practice session state.
final practiceSessionProvider =
    StateNotifierProvider<PracticeSessionNotifier, PracticeSession>(
      (ref) => PracticeSessionNotifier(),
    );
