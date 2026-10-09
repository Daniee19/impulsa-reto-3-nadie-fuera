import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/account_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/bill_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/contact_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/services/risk_engine.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/assistant_intent.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/operation_summary.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/prepare_result.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/voice_session.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/services/intent_parser.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/services/operation_preparer.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/biometric_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/microphone_consent_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/speech_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/tts_provider.dart';

/// Callback for navigating to a route from the provider layer.
typedef NavigateCallback = void Function(String route, {Object? extra});

/// Orchestrates the voice assistant state machine.
class VoiceAssistantNotifier extends StateNotifier<VoiceSession?> {
  /// Creates the notifier with all required dependencies.
  VoiceAssistantNotifier(this._ref) : super(null);

  final Ref _ref;
  final _parser = IntentParser();
  NavigateCallback? _navigate;

  /// Sets the navigation callback (called from the screen).
  void setNavigate(NavigateCallback navigate) => _navigate = navigate;

  /// Starts a new session.
  void startSession() {
    state = VoiceSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      status: VoiceSessionStatus.idle,
      inputSource: InputSource.text,
      createdAt: DateTime.now(),
    );
  }

  /// Starts listening via microphone.
  Future<void> startListening() async {
    final hasConsent = _ref.read(microphoneConsentProvider);
    if (!hasConsent) return;

    state = state?.copyWith(status: VoiceSessionStatus.listening);
    final speech = _ref.read(speechRecognitionProvider);
    await speech.initialize();
    await speech.listen(
      onResult: (text) => processInput(text, InputSource.voice),
    );
  }

  /// Stops listening.
  Future<void> stopListening() async {
    await _ref.read(speechRecognitionProvider).stop();
    if (state?.status == VoiceSessionStatus.listening) {
      state = state?.copyWith(status: VoiceSessionStatus.idle);
    }
  }

  /// Processes user input (voice or text).
  Future<void> processInput(String text, InputSource source) async {
    if (text.trim().isEmpty) return;

    state = state?.copyWith(
      status: VoiceSessionStatus.processing,
      inputText: text,
    );

    final intent = _parser.parse(text);
    state = state?.copyWith(parsedIntent: intent);

    final preparer = OperationPreparer(
      accountRepo: _ref.read(accountRepositoryProvider),
      billRepo: _ref.read(billRepositoryProvider),
      contactRepo: _ref.read(contactRepositoryProvider),
    );

    switch (intent.type) {
      case AssistantIntentType.checkBalance:
        await _handleBalance(preparer, intent);
      case AssistantIntentType.payBill:
        await _handlePayBill(preparer, intent);
      case AssistantIntentType.sendMoney:
        await _handleSendMoney(preparer, intent);
      case AssistantIntentType.requestHelp:
        await _handleHelp();
      case AssistantIntentType.unknown:
        await _handleUnknown();
    }
  }

  /// Confirms the current operation with biometric authentication.
  Future<void> confirmWithBiometric(String reason) async {
    final summary = state?.operationSummary;
    if (summary == null) return;

    state = state?.copyWith(status: VoiceSessionStatus.executing);

    final bio = _ref.read(biometricProvider);
    final success = await bio.authenticate(reason: reason);

    if (!success) {
      state = state?.copyWith(status: VoiceSessionStatus.awaitingConfirmation);
      return;
    }

    final opRepo = _ref.read(operationRepositoryProvider);
    await opRepo.createOperation(
      type: summary.type,
      recipientName: summary.recipientName,
      amount: summary.amount,
      description: summary.spokenSummary,
    );

    state = state?.copyWith(status: VoiceSessionStatus.completed);
  }

  Future<void> _handleBalance(
    OperationPreparer preparer,
    ParsedIntent intent,
  ) async {
    final result = await preparer.prepare(intent);
    if (result is PrepareBalanceResult) {
      final msg = 'Tienes S/ ${result.balance.toStringAsFixed(2)} disponibles';
      state = state?.copyWith(
        status: VoiceSessionStatus.completed,
        assistantMessage: msg,
      );
      await _speak(msg);
    }
  }

  Future<void> _handlePayBill(
    OperationPreparer preparer,
    ParsedIntent intent,
  ) async {
    final result = await preparer.prepare(intent);
    switch (result) {
      case PrepareSuccess(:final summary):
        await _prepareConfirmation(summary);
      case PrepareNeedsService():
        state = state?.copyWith(
          status: VoiceSessionStatus.needsMore,
          assistantMessage: '¿Qué recibo quieres pagar?',
        );
        await _speak('¿Qué recibo quieres pagar?');
      case PrepareBillNotFound(:final serviceName):
        final msg = 'No encontré un recibo de $serviceName pendiente';
        state = state?.copyWith(
          status: VoiceSessionStatus.idle,
          assistantMessage: msg,
        );
        await _speak(msg);
      default:
        break;
    }
  }

  Future<void> _handleSendMoney(
    OperationPreparer preparer,
    ParsedIntent intent,
  ) async {
    final result = await preparer.prepare(intent);
    switch (result) {
      case PrepareSuccess(:final summary):
        await _prepareConfirmation(summary);
      case PrepareNeedsContact():
        state = state?.copyWith(
          status: VoiceSessionStatus.needsMore,
          assistantMessage: '¿A quién quieres enviarle?',
        );
        await _speak('¿A quién quieres enviarle?');
      case PrepareNeedsAmount(:final contactName):
        final msg = '¿Cuánto quieres enviarle a $contactName?';
        state = state?.copyWith(
          status: VoiceSessionStatus.needsMore,
          assistantMessage: msg,
        );
        await _speak(msg);
      default:
        break;
    }
  }

  Future<void> _handleHelp() async {
    const msg = 'Te conecto con ayuda';
    state = state?.copyWith(
      status: VoiceSessionStatus.completed,
      assistantMessage: msg,
    );
    await _speak(msg);
    _navigate?.call('/easy-mode/help/contact-picker');
  }

  Future<void> _handleUnknown() async {
    const msg =
        'No estoy seguro. ¿Quieres ver tu saldo, pagar un recibo, '
        'enviar dinero o pedir ayuda?';
    state = state?.copyWith(
      status: VoiceSessionStatus.idle,
      assistantMessage: msg,
    );
    await _speak(msg);
  }

  Future<void> _prepareConfirmation(OperationSummary summary) async {
    state = state?.copyWith(
      status: VoiceSessionStatus.summarizing,
      operationSummary: summary,
    );
    await _speak(summary.spokenSummary);

    // Fraud check
    final history = await _ref
        .read(operationRepositoryProvider)
        .getOperations();
    final riskEngine = RiskEngine();
    final alert = riskEngine.evaluate(
      operation: OperationContext(
        type: summary.type,
        amount: summary.amount,
        recipientId: summary.recipientId,
        recipientName: summary.recipientName,
        timestamp: DateTime.now(),
      ),
      history: history,
    );

    if (alert != null) {
      _navigate?.call('/easy-mode/fraud-alert', extra: alert);
      return;
    }

    state = state?.copyWith(status: VoiceSessionStatus.awaitingConfirmation);
    _navigate?.call('/easy-mode/assistant/summary');
  }

  Future<void> _speak(String text) async {
    final tts = _ref.read(ttsProvider);
    await tts.initialize();
    await tts.speak(text);
  }
}

/// Provider for the voice assistant state machine.
final voiceAssistantProvider =
    StateNotifierProvider<VoiceAssistantNotifier, VoiceSession?>(
      (ref) => VoiceAssistantNotifier(ref),
    );
