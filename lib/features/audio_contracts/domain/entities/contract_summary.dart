import 'package:meta/meta.dart';

/// The 4 mandatory sections of a contract summary.
enum ContractSectionType {
  /// What the user is accepting.
  whatYouAccept,

  /// Costs and fees.
  cost,

  /// Risks and protections.
  risks,

  /// How to cancel.
  howToCancel,
}

/// TTS playback speed.
enum PlaybackSpeed {
  /// 100% (rate 0.45 — base for elderly).
  normal(1),

  /// 75%.
  slow(0.75),

  /// 50%.
  slower(0.5);

  const PlaybackSpeed(this.rate);

  /// Multiplier applied to base TTS rate.
  final double rate;
}

/// One section of a contract summary.
@immutable
class ContractSection {
  /// Creates a contract section.
  const ContractSection({
    required this.type,
    required this.title,
    required this.content,
  });

  /// Section type.
  final ContractSectionType type;

  /// Localized title.
  final String title;

  /// Plain-language content.
  final String content;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractSection &&
          type == other.type &&
          title == other.title &&
          content == other.content;

  @override
  int get hashCode => Object.hash(type, title, content);
}

/// Complete summary of a contract with 4 sections.
@immutable
class ContractSummary {
  /// Creates a contract summary.
  const ContractSummary({
    required this.id,
    required this.title,
    required this.sections,
    required this.fullContractParagraphs,
  });

  /// Contract identifier.
  final String id;

  /// Localized title.
  final String title;

  /// The 4 summary sections.
  final List<ContractSection> sections;

  /// Paragraphs of the full contract text.
  final List<String> fullContractParagraphs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContractSummary && id == other.id && title == other.title;

  @override
  int get hashCode => Object.hash(id, title);
}
