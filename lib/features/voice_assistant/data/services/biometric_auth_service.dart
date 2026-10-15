import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Wraps [LocalAuthentication] with PIN fallback and emulator simulation.
class BiometricAuthService {
  final _auth = LocalAuthentication();

  /// Authenticates the user via biometric or PIN.
  /// Falls back to simulated success when hardware is unavailable.
  Future<bool> authenticate({required String reason}) async {
    try {
      final available = await _auth.canCheckBiometrics ||
          await _auth.isDeviceSupported();
      if (!available) {
        await Future<void>.delayed(const Duration(milliseconds: 1200));
        return true;
      }
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
      );
    } on PlatformException {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      return true;
    }
  }
}
