import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/data/services/biometric_auth_service.dart';

class PracticeBiometricAuth extends BiometricAuthService {
  @override
  Future<bool> authenticate({required String reason}) async => true;
}
