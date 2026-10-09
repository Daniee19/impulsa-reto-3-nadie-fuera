import 'package:meta/meta.dart';

/// Types of configuration the trusted person can suggest.
enum ConfigSuggestionType {
  /// Increase font size.
  fontSize,

  /// Add a saved contact.
  addContact,

  /// Remove a saved contact.
  removeContact,

  /// Add a frequent bill.
  addBill,

  /// Remove a frequent bill.
  removeBill,
}

/// Status of a configuration suggestion.
enum ConfigSuggestionStatus {
  /// Waiting for user decision.
  pending,

  /// User accepted the suggestion.
  accepted,

  /// User rejected the suggestion.
  rejected,
}

/// A configuration change proposed by the trusted person.
@immutable
class ConfigSuggestion {
  /// Creates a config suggestion.
  const ConfigSuggestion({
    required this.id,
    required this.type,
    required this.description,
    required this.status,
    required this.createdAt,
    this.suggestedValue,
    this.resolvedAt,
  });

  /// Creates from JSON map.
  factory ConfigSuggestion.fromJson(Map<String, dynamic> json) {
    return ConfigSuggestion(
      id: json['id'] as String,
      type: ConfigSuggestionType.values.byName(json['type'] as String),
      description: json['description'] as String,
      suggestedValue: json['suggestedValue'] as String?,
      status: ConfigSuggestionStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  /// Unique identifier.
  final String id;

  /// Type of configuration change.
  final ConfigSuggestionType type;

  /// Human-readable description (≤15 words).
  final String description;

  /// Suggested value (e.g. "large").
  final String? suggestedValue;

  /// Current status.
  final ConfigSuggestionStatus status;

  /// When the suggestion was created.
  final DateTime createdAt;

  /// When the user accepted or rejected (null if pending).
  final DateTime? resolvedAt;

  /// Returns a copy with the given fields replaced.
  ConfigSuggestion copyWith({
    ConfigSuggestionStatus? status,
    DateTime? resolvedAt,
  }) {
    return ConfigSuggestion(
      id: id,
      type: type,
      description: description,
      suggestedValue: suggestedValue,
      status: status ?? this.status,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'description': description,
    'suggestedValue': suggestedValue,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigSuggestion &&
          id == other.id &&
          type == other.type &&
          description == other.description &&
          suggestedValue == other.suggestedValue &&
          status == other.status &&
          createdAt == other.createdAt &&
          resolvedAt == other.resolvedAt;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    description,
    suggestedValue,
    status,
    createdAt,
    resolvedAt,
  );
}
