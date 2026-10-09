import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/assistant_intent.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/operation_summary.dart';
import 'package:meta/meta.dart';

/// Status of the voice assistant session state machine.
enum VoiceSessionStatus {
  /// Waiting for user input.
  idle,

  /// Microphone active, listening.
  listening,

  /// Interpreting the phrase.
  processing,

  /// Missing a required parameter, asking the user.
  needsMore,

  /// Reading operation summary aloud.
  summarizing,

  /// Waiting for biometric confirmation.
  awaitingConfirmation,

  /// Executing the operation.
  executing,

  /// Operation completed successfully.
  completed,

  /// Error in some step.
  error,
}

/// Complete state of one assistant session (ephemeral, not persisted).
@immutable
class VoiceSession {
  /// Creates a voice session.
  const VoiceSession({
    required this.id,
    required this.status,
    required this.inputSource,
    required this.createdAt,
    this.inputText,
    this.parsedIntent,
    this.operationSummary,
    this.assistantMessage,
  });

  /// UUID of the session.
  final String id;

  /// Current state.
  final VoiceSessionStatus status;

  /// Recognized text (voice) or typed text.
  final String? inputText;

  /// Input channel.
  final InputSource inputSource;

  /// Interpreted intent.
  final ParsedIntent? parsedIntent;

  /// Prepared operation summary.
  final OperationSummary? operationSummary;

  /// Last message from the assistant.
  final String? assistantMessage;

  /// Session start time.
  final DateTime createdAt;

  /// Returns a copy with updated fields.
  VoiceSession copyWith({
    VoiceSessionStatus? status,
    String? inputText,
    ParsedIntent? parsedIntent,
    OperationSummary? operationSummary,
    String? assistantMessage,
  }) => VoiceSession(
    id: id,
    status: status ?? this.status,
    inputSource: inputSource,
    createdAt: createdAt,
    inputText: inputText ?? this.inputText,
    parsedIntent: parsedIntent ?? this.parsedIntent,
    operationSummary: operationSummary ?? this.operationSummary,
    assistantMessage: assistantMessage ?? this.assistantMessage,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceSession && id == other.id && status == other.status;

  @override
  int get hashCode => Object.hash(id, status);
}
