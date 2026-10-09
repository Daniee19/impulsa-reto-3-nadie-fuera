import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/operation_in_progress.dart';

/// Notifier for the currently active operation.
class OperationInProgressNotifier extends StateNotifier<OperationInProgress?> {
  /// Creates the notifier with no active operation.
  OperationInProgressNotifier() : super(null);

  /// Sets the current in-progress operation.
  // ignore: use_setters_to_change_properties
  void set(OperationInProgress op) => state = op;

  /// Clears the current operation.
  void clear() => state = null;
}

/// Provides the current in-progress operation, if any.
final operationInProgressProvider =
    StateNotifierProvider<OperationInProgressNotifier, OperationInProgress?>(
      (ref) => OperationInProgressNotifier(),
    );
