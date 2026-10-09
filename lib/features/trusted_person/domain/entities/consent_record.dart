import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:meta/meta.dart';

/// Action taken on a consent record.
enum ConsentAction {
  /// Permission was granted.
  granted,

  /// Permission was revoked.
  revoked,
}

/// Immutable record of a consent grant or revocation (Ley 29733).
@immutable
class ConsentRecord {
  /// Creates a consent record.
  const ConsentRecord({
    required this.permission,
    required this.action,
    required this.timestamp,
  });

  /// Creates from JSON map.
  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    return ConsentRecord(
      permission: TrustedPermission.values.byName(json['permission'] as String),
      action: ConsentAction.values.byName(json['action'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// The permission affected.
  final TrustedPermission permission;

  /// Whether it was granted or revoked.
  final ConsentAction action;

  /// When this action occurred (UTC).
  final DateTime timestamp;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
    'permission': permission.name,
    'action': action.name,
    'timestamp': timestamp.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsentRecord &&
          permission == other.permission &&
          action == other.action &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(permission, action, timestamp);
}
