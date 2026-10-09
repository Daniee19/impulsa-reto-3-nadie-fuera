import 'package:meta/meta.dart';

/// Closed list of intents the assistant can recognize.
enum AssistantIntentType {
  /// Check account balance.
  checkBalance,

  /// Pay a pending service bill.
  payBill,

  /// Send money to a saved contact.
  sendMoney,

  /// Request human help (delegates to 003).
  requestHelp,

  /// Intent not recognized.
  unknown,
}

/// Input channel used by the user.
enum InputSource {
  /// Voice via microphone.
  voice,

  /// Text via keyboard.
  text,
}

/// Parameters extracted from the user's phrase.
@immutable
class IntentParameters {
  /// Creates intent parameters.
  const IntentParameters({this.serviceName, this.contactName, this.amount});

  /// Service name mentioned ("luz", "agua").
  final String? serviceName;

  /// Contact name or reference ("Valeria", "mi hija").
  final String? contactName;

  /// Amount mentioned, must be > 0 if present.
  final double? amount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntentParameters &&
          serviceName == other.serviceName &&
          contactName == other.contactName &&
          amount == other.amount;

  @override
  int get hashCode => Object.hash(serviceName, contactName, amount);
}

/// Result of interpreting a user phrase.
@immutable
class ParsedIntent {
  /// Creates a parsed intent.
  const ParsedIntent({required this.type, this.parameters});

  /// Identified intent type.
  final AssistantIntentType type;

  /// Extracted parameters, null if not applicable.
  final IntentParameters? parameters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedIntent &&
          type == other.type &&
          parameters == other.parameters;

  @override
  int get hashCode => Object.hash(type, parameters);
}
