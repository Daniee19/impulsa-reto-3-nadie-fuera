import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/risk_alert.dart';
import 'package:meta/meta.dart';

/// State holding the current fraud alert and navigation info.
@immutable
class FraudAlertState {
  /// Creates the fraud alert state.
  const FraudAlertState({
    required this.alert,
    required this.continueRoute,
    this.continueExtra,
  });

  /// The risk alert to display.
  final RiskAlert alert;

  /// Route to navigate to when user chooses "Continue anyway".
  final String continueRoute;

  /// Optional route extra for the continue destination.
  final Object? continueExtra;
}

/// Notifier that manages the current fraud alert state.
class FraudAlertNotifier extends StateNotifier<FraudAlertState?> {
  /// Creates the notifier with no alert.
  FraudAlertNotifier() : super(null);

  /// Sets the current alert with navigation info.
  void setAlert(
    RiskAlert alert,
    String continueRoute, [
    Object? continueExtra,
  ]) {
    state = FraudAlertState(
      alert: alert,
      continueRoute: continueRoute,
      continueExtra: continueExtra,
    );
  }

  /// Clears the current alert.
  void clear() => state = null;
}

/// Provider for the fraud alert state.
final fraudAlertProvider =
    StateNotifierProvider<FraudAlertNotifier, FraudAlertState?>(
      (ref) => FraudAlertNotifier(),
    );
