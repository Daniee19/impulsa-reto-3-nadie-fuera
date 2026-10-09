import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has granted microphone consent.
class MicrophoneConsentNotifier extends StateNotifier<bool> {
  /// Creates the notifier, initially false until [load] is called.
  MicrophoneConsentNotifier() : super(false);

  static const _key = 'microphone_consent_granted';

  /// Loads saved consent state from SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  /// Grants consent and persists.
  Future<void> grant() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = true;
  }

  /// Denies consent and persists.
  Future<void> deny() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
    state = false;
  }
}

/// Provider for microphone consent state.
final microphoneConsentProvider =
    StateNotifierProvider<MicrophoneConsentNotifier, bool>((ref) {
      final notifier = MicrophoneConsentNotifier();
      notifier.load();
      return notifier;
    });
