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

/// A single message in the chat history.
@immutable
class ChatMessage {
  /// Creates a chat message.
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.source = InputSource.text,
  });

  /// The message text.
  final String text;

  /// Whether this message is from the user (true) or assistant (false).
  final bool isUser;

  /// When this message was created.
  final DateTime timestamp;

  /// How the user sent this message (voice or text).
  final InputSource source;
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
    this.messages = const [],
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

  /// Chat history.
  final List<ChatMessage> messages;

  /// Returns a copy with updated fields.
  VoiceSession copyWith({
    VoiceSessionStatus? status,
    String? inputText,
    ParsedIntent? parsedIntent,
    OperationSummary? operationSummary,
    String? assistantMessage,
    List<ChatMessage>? messages,
  }) => VoiceSession(
    id: id,
    status: status ?? this.status,
    inputSource: inputSource,
    createdAt: createdAt,
    inputText: inputText ?? this.inputText,
    parsedIntent: parsedIntent ?? this.parsedIntent,
    operationSummary: operationSummary ?? this.operationSummary,
    assistantMessage: assistantMessage ?? this.assistantMessage,
    messages: messages ?? this.messages,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceSession &&
          id == other.id &&
          status == other.status &&
          messages.length == other.messages.length;

  @override
  int get hashCode => Object.hash(id, status, messages.length);
}
