import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/domain/entities/practice_guide_step.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/providers/practice_session_provider.dart';

/// Tracks which guide step the user is on.
class PracticeGuideNotifier extends StateNotifier<PracticeGuideStep?> {
  /// Creates the notifier.
  PracticeGuideNotifier(this._ref) : super(null);

  final Ref _ref;
  int _completedSteps = 0;

  static const _totalSteps = 8;

  /// Updates the current step based on the route.
  void onRouteChanged(String route) {
    final session = _ref.read(practiceSessionProvider);
    if (!session.active || !session.guideEnabled) {
      state = null;
      return;
    }

    final step = _stepForRoute(route);
    if (step != null) state = step;
  }

  /// Advances to the next step.
  void advanceStep() {
    _completedSteps++;
    if (_completedSteps >= _totalSteps) {
      state = null;
    }
  }

  /// Resets the guide.
  void reset() {
    _completedSteps = 0;
    state = null;
  }

  PracticeGuideStep? _stepForRoute(String route) {
    if (route == '/easy-mode') {
      if (_completedSteps < 1) {
        return const PracticeGuideStep(
          routePattern: '/easy-mode',
          instruction: 'practice_guide_balance',
          stepNumber: 1,
          totalSteps: _totalSteps,
        );
      }
      if (_completedSteps >= 4 && _completedSteps < 5) {
        return const PracticeGuideStep(
          routePattern: '/easy-mode',
          instruction: 'practice_guide_sendMoney',
          stepNumber: 5,
          totalSteps: _totalSteps,
        );
      }
      return null;
    }
    if (route == '/easy-mode/balance') {
      return const PracticeGuideStep(
        routePattern: '/easy-mode/balance',
        instruction: 'practice_guide_payBill',
        stepNumber: 2,
        totalSteps: _totalSteps,
      );
    }
    if (route == '/easy-mode/pay-bill') {
      return const PracticeGuideStep(
        routePattern: '/easy-mode/pay-bill',
        instruction: 'practice_guide_selectBill',
        stepNumber: 3,
        totalSteps: _totalSteps,
      );
    }
    if (route.contains('/pay-bill/') && route.endsWith('/confirm')) {
      return const PracticeGuideStep(
        routePattern: '/easy-mode/pay-bill/.*/confirm',
        instruction: 'practice_guide_confirmPay',
        stepNumber: 4,
        totalSteps: _totalSteps,
      );
    }
    if (route == '/easy-mode/send-money') {
      return const PracticeGuideStep(
        routePattern: '/easy-mode/send-money',
        instruction: 'practice_guide_selectContact',
        stepNumber: 6,
        totalSteps: _totalSteps,
      );
    }
    if (route == '/easy-mode/send-money/confirm') {
      return const PracticeGuideStep(
        routePattern: '/easy-mode/send-money/confirm',
        instruction: 'practice_guide_confirmSend',
        stepNumber: 8,
        totalSteps: _totalSteps,
      );
    }
    if (route.contains('/fraud-alert')) {
      return const PracticeGuideStep(
        routePattern: '/easy-mode/fraud-alert',
        instruction: 'practice_guide_fraudAlert',
        stepNumber: 0,
        totalSteps: _totalSteps,
      );
    }
    return null;
  }
}

/// Provider for the current guide step.
final practiceGuideProvider =
    StateNotifierProvider<PracticeGuideNotifier, PracticeGuideStep?>(
      (ref) => PracticeGuideNotifier(ref),
    );
