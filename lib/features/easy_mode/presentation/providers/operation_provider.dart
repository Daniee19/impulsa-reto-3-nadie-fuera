import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/operation_repository.dart';

/// Provider for the operation repository implementation.
final operationRepositoryProvider = Provider<OperationRepository>(
  (ref) => throw UnimplementedError('Override with mock or real repo'),
);
