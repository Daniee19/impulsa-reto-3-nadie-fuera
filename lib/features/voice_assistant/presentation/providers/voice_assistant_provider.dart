import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/account_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/bill_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/contact_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/operation_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/fraud_alert_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/risk_engine_provider.dart';
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

  /// Starts a new session, preserving chat history from previous session.
  void startSession() {
    final previousMessages = state?.messages ?? [];
    state = VoiceSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      status: VoiceSessionStatus.idle,
      inputSource: InputSource.text,
      createdAt: DateTime.now(),
      messages: previousMessages,
    );
  }

  void _addUserMessage(String text, InputSource source) {
    final msgs = <ChatMessage>[
      ...state?.messages ?? <ChatMessage>[],
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
        source: source,
      ),
    ];
    state = state?.copyWith(messages: msgs);
  }

  void _addAssistantMessage(String text) {
    final msgs = <ChatMessage>[
      ...state?.messages ?? <ChatMessage>[],
      ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
    state = state?.copyWith(
      messages: msgs,
      assistantMessage: text,
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

    final wasNeedsMore =
        state?.status == VoiceSessionStatus.needsMore;
    final prev = state?.parsedIntent;

    _addUserMessage(text, source);
    state = state?.copyWith(
      status: VoiceSessionStatus.processing,
      inputText: text,
    );

    try {
      print('[VA] wasNeedsMore=$wasNeedsMore prev=${prev?.type}');
      if (wasNeedsMore && prev != null && _waitsForMore(prev)) {
        print('[VA] entering _handleFollowUp');
        await _handleFollowUp(text, prev);
        print('[VA] _handleFollowUp done');
        return;
      }

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
    } catch (e, st) {
      print('[VA] ERROR: $e\n$st');
      const msg = 'Algo salió mal. Intenta de nuevo.';
      _addAssistantMessage(msg);
      state = state?.copyWith(status: VoiceSessionStatus.idle);
      await _speak(msg);
    }
  }

  bool _waitsForMore(ParsedIntent prev) {
    if (prev.type == AssistantIntentType.payBill &&
        prev.parameters?.serviceName == null) {
      return true;
    }
    if (prev.type == AssistantIntentType.sendMoney &&
        (prev.parameters?.contactName == null ||
            prev.parameters?.amount == null)) {
      return true;
    }
    return false;
  }

  Future<void> _handleFollowUp(
    String text,
    ParsedIntent prev,
  ) async {
    final preparer = OperationPreparer(
      accountRepo: _ref.read(accountRepositoryProvider),
      billRepo: _ref.read(billRepositoryProvider),
      contactRepo: _ref.read(contactRepositoryProvider),
    );

    if (prev.type == AssistantIntentType.payBill) {
      final service = _parser.extractService(text) ??
          text.trim().toLowerCase();
      print('[VA] extracted service=$service');
      final updated = ParsedIntent(
        type: AssistantIntentType.payBill,
        parameters: IntentParameters(serviceName: service),
      );
      state = state?.copyWith(parsedIntent: updated);
      print('[VA] calling _handlePayBill');
      await _handlePayBill(preparer, updated);
      print('[VA] _handlePayBill returned');
      return;
    }

    if (prev.type == AssistantIntentType.sendMoney) {
      final params = prev.parameters;
      if (params?.contactName == null) {
        final contact = _parser.extractContact(text) ??
            text.trim();
        final updated = ParsedIntent(
          type: AssistantIntentType.sendMoney,
          parameters: IntentParameters(
            contactName: contact,
            amount: params?.amount,
          ),
        );
        state = state?.copyWith(parsedIntent: updated);
        await _handleSendMoney(preparer, updated);
        return;
      }
      if (params?.amount == null) {
        final amount = _parser.extractAmount(text);
        if (amount == null) {
          const msg = 'No entendí el monto. '
              '¿Cuánto quieres enviar? '
              'Puedes decir un número como 50 o cincuenta.';
          _addAssistantMessage(msg);
          state = state?.copyWith(
            status: VoiceSessionStatus.needsMore,
            parsedIntent: prev,
          );
          await _speak(msg);
          return;
        }
        final updated = ParsedIntent(
          type: AssistantIntentType.sendMoney,
          parameters: IntentParameters(
            contactName: params?.contactName,
            amount: amount,
          ),
        );
        state = state?.copyWith(parsedIntent: updated);
        await _handleSendMoney(preparer, updated);
        return;
      }
    }

    await _handleUnknown();
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
      final msg =
          'Tienes S/ ${result.balance.toStringAsFixed(2)} disponibles';
      _addAssistantMessage(msg);
      state = state?.copyWith(status: VoiceSessionStatus.completed);
      await _speak(msg);
    }
  }

  Future<void> _handlePayBill(
    OperationPreparer preparer,
    ParsedIntent intent,
  ) async {
    print('[VA] _handlePayBill: preparing...');
    final result = await preparer.prepare(intent);
    print('[VA] _handlePayBill: result=${result.runtimeType}');
    switch (result) {
      case PrepareSuccess(:final summary):
        print('[VA] PrepareSuccess, calling _prepareConfirmation');
        await _prepareConfirmation(summary);
      case PrepareNeedsService():
        const msg = '¿Qué recibo quieres pagar?';
        _addAssistantMessage(msg);
        state = state?.copyWith(status: VoiceSessionStatus.needsMore);
        await _speak(msg);
      case PrepareBillNotFound(:final serviceName):
        final msg =
            'No encontré un recibo de $serviceName pendiente';
        _addAssistantMessage(msg);
        state = state?.copyWith(status: VoiceSessionStatus.idle);
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
        const msg = '¿A quién quieres enviarle?';
        _addAssistantMessage(msg);
        state = state?.copyWith(status: VoiceSessionStatus.needsMore);
        await _speak(msg);
      case PrepareNeedsAmount(:final contactName):
        final msg = '¿Cuánto quieres enviarle a $contactName?';
        _addAssistantMessage(msg);
        state = state?.copyWith(status: VoiceSessionStatus.needsMore);
        await _speak(msg);
      default:
        break;
    }
  }

  Future<void> _handleHelp() async {
    const msg = 'Te conecto con ayuda';
    _addAssistantMessage(msg);
    state = state?.copyWith(status: VoiceSessionStatus.completed);
    await _speak(msg);
    _navigate?.call('/easy-mode/help/contact-picker');
  }

  Future<void> _handleUnknown() async {
    const msg =
        'No estoy seguro. ¿Quieres ver tu saldo, pagar un recibo, '
        'enviar dinero o pedir ayuda?';
    _addAssistantMessage(msg);
    state = state?.copyWith(status: VoiceSessionStatus.idle);
    await _speak(msg);
  }

  Future<void> _prepareConfirmation(OperationSummary summary) async {
    print('[VA] _prepareConfirmation: start');
    _addAssistantMessage(summary.spokenSummary);
    state = state?.copyWith(
      status: VoiceSessionStatus.summarizing,
      operationSummary: summary,
    );
    print('[VA] _prepareConfirmation: speaking...');
    await _speak(summary.spokenSummary);
    print('[VA] _prepareConfirmation: speak done, fraud check...');

    // Fraud check
    final history = await _ref
        .read(operationRepositoryProvider)
        .getOperations();
    final alert = _ref
        .read(riskEngineProvider)
        .evaluate(
          operation: OperationContext(
            type: summary.type,
            amount: summary.amount,
            recipientId: summary.recipientId,
            recipientName: summary.recipientName,
            timestamp: DateTime.now(),
          ),
          history: history,
        );

    print('[VA] fraud check result: alert=${alert != null}');
    if (alert != null) {
      _ref.read(fraudAlertProvider.notifier).setAlert(
            alert,
            '/easy-mode/assistant/summary',
          );
      _navigate?.call('/easy-mode/fraud-alert');
      return;
    }

    print('[VA] navigating to summary');
    state = state?.copyWith(status: VoiceSessionStatus.awaitingConfirmation);
    _navigate?.call('/easy-mode/assistant/summary');
    print('[VA] _prepareConfirmation: done');
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
