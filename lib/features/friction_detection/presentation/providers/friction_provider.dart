import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/navigation_context_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/entities/friction_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/entities/friction_offer.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/entities/friction_signal.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/services/friction_detector.dart';

/// Orchestrates friction detection and help offer state.
class FrictionNotifier extends StateNotifier<FrictionOffer> {
  /// Creates the notifier.
  FrictionNotifier(this._ref) : super(const FrictionOffer.hidden()) {
    _detector = FrictionDetector();
    _previousRoute = _ref.read(navigationContextProvider).currentRoute;

    _ref.listen<NavigationState>(navigationContextProvider, (prev, next) {
      _onRouteChanged(prev?.currentRoute ?? '', next.currentRoute);
    });
  }

  final Ref _ref;
  late final FrictionDetector _detector;
  late String _previousRoute;
  Timer? _inactivityTimer;

  String get _flowId {
    final route = _ref.read(navigationContextProvider).currentRoute;
    if (route.startsWith('/easy-mode/pay-bill')) return 'pay-bill';
    if (route.startsWith('/easy-mode/send-money')) return 'send-money';
    return 'unknown';
  }

  void _onRouteChanged(String oldRoute, String newRoute) {
    _cancelTimer();

    if (!_detector.isActiveFlow(newRoute)) {
      if (_detector.isActiveFlow(oldRoute)) {
        _detector.resetForNewFlow();
        state = const FrictionOffer.hidden();
      }
      return;
    }

    if (_detector.isExcludedScreen(newRoute)) return;

    // Detect back navigation (new route is "shorter" or same as previous)
    if (_isBackNavigation(oldRoute, newRoute)) {
      final nav = _ref.read(navigationContextProvider);
      final signal = _detector.onBackNavigation(
        flowId: _flowId,
        stepRoute: newRoute,
        stepName: nav.screenName,
      );
      if (signal != null && !_detector.isDismissed(signal.type, _flowId)) {
        state = FrictionOffer.showing(signal);
      }
    }

    _startInactivityTimer();
    _previousRoute = newRoute;
  }

  bool _isBackNavigation(String oldRoute, String newRoute) {
    return oldRoute.startsWith(newRoute) && oldRoute != newRoute;
  }

  void _startInactivityTimer() {
    _cancelTimer();
    final route = _ref.read(navigationContextProvider).currentRoute;
    if (!_detector.isActiveFlow(route) || _detector.isExcludedScreen(route)) {
      return;
    }

    _inactivityTimer = Timer(
      Duration(seconds: _detector.thresholds.inactivitySeconds),
      _onInactivityDetected,
    );
  }

  void _onInactivityDetected() {
    final nav = _ref.read(navigationContextProvider);
    final signal = _detector.onInactivityTimeout(
      flowId: _flowId,
      stepRoute: nav.currentRoute,
      stepName: nav.screenName,
    );
    if (signal != null && !_detector.isDismissed(signal.type, _flowId)) {
      state = FrictionOffer.showing(signal);
    }
  }

  /// Called on user interaction to reset inactivity timer.
  void onUserInteraction() => _startInactivityTimer();

  /// Reports a validation error.
  void onValidationError(String fieldId, String errorType) {
    final nav = _ref.read(navigationContextProvider);
    final signal = _detector.onValidationError(
      flowId: _flowId,
      stepRoute: nav.currentRoute,
      stepName: nav.screenName,
      fieldId: fieldId,
      errorType: errorType,
    );
    if (signal != null && !_detector.isDismissed(signal.type, _flowId)) {
      state = FrictionOffer.showing(signal);
    }
  }

  /// User dismissed the offer.
  void dismiss() {
    final signal = state.signal;
    if (signal != null) {
      _detector.dismissSignal(signal.type, _flowId);
    }
    state = const FrictionOffer.hidden();
  }

  /// User chose "explain".
  void acceptExplain() {
    state = const FrictionOffer.hidden();
  }

  /// User chose "talk to someone". Sets friction context.
  void acceptHuman() {
    final signal = state.signal;
    if (signal != null) {
      _ref.read(frictionContextProvider.notifier).state = FrictionContext(
        signalType: signal.type,
        occurrences: signal.occurrences,
        stepName: signal.stepName,
        humanReadable: FrictionContext.buildHumanReadable(
          signal.type,
          signal.occurrences,
          signal.stepName,
        ),
      );
    }
    state = const FrictionOffer.hidden();
  }

  void _cancelTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}

/// Provider for friction offer state.
final frictionNotifierProvider =
    StateNotifierProvider<FrictionNotifier, FrictionOffer>(
      (ref) => FrictionNotifier(ref),
    );

/// Provider for friction context sent to help flow.
final frictionContextProvider = StateProvider<FrictionContext?>((ref) => null);
