import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/data/services/biometric_auth_service.dart';

/// Provider for the biometric authentication service.
final biometricProvider = Provider<BiometricAuthService>(
  (ref) => BiometricAuthService(),
);
