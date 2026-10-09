import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_channel.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';
import 'package:meta/meta.dart';

/// Status of a help session.
enum HelpRequestStatus {
  /// Attempting to connect.
  connecting,

  /// Successfully connected.
  connected,

  /// Trusted person did not respond (triggers fallback).
  noResponse,

  /// Session completed normally.
  completed,

  /// User cancelled before connecting.
  cancelled,
}

/// A complete help request with target, channel, and context.
@immutable
class HelpRequest {
  /// Creates a help request.
  const HelpRequest({
    required this.id,
    required this.target,
    required this.targetName,
    required this.channel,
    required this.context,
    required this.includeContext,
    required this.status,
    required this.createdAt,
  });

  /// Unique request identifier.
  final String id;

  /// Who is being contacted.
  final HelpTarget target;

  /// Display name of the contact.
  final String targetName;

  /// Communication channel.
  final HelpChannel channel;

  /// Captured session context.
  final HelpContext context;

  /// Whether to share context details (consent-dependent for trusted person).
  final bool includeContext;

  /// Current session status.
  final HelpRequestStatus status;

  /// When the request was created.
  final DateTime createdAt;

  /// Returns a copy with the given status.
  HelpRequest copyWith({HelpRequestStatus? status}) => HelpRequest(
    id: id,
    target: target,
    targetName: targetName,
    channel: channel,
    context: context,
    includeContext: includeContext,
    status: status ?? this.status,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HelpRequest && id == other.id && status == other.status;

  @override
  int get hashCode => Object.hash(id, status);
}
