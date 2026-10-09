import 'package:local_auth/local_auth.dart';

/// Wraps [LocalAuthentication] with PIN fallback enabled.
class BiometricAuthService {
  final _auth = LocalAuthentication();

  /// Authenticates the user via biometric or PIN.
  Future<bool> authenticate({required String reason}) {
    return _auth.authenticate(localizedReason: reason, biometricOnly: false);
  }
}
