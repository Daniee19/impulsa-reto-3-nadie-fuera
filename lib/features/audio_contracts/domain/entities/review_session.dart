import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/contract_summary.dart';
import 'package:meta/meta.dart';

/// TTS playback state.
enum TtsState {
  /// Not playing.
  idle,

  /// Reading active section.
  playing,

  /// Paused by user.
  paused,

  /// All sections read.
  completed,
}

/// Ephemeral state of a contract review in progress.
@immutable
class ReviewSession {
  /// Creates a review session.
  const ReviewSession({
    required this.contractId,
    this.sectionsHeard = const {},
    this.currentSection,
    this.scrolledToEnd = false,
    this.speed = PlaybackSpeed.normal,
    this.ttsState = TtsState.idle,
  });

  /// Contract being reviewed.
  final String contractId;

  /// Sections the user has listened to.
  final Set<ContractSectionType> sectionsHeard;

  /// Currently playing section.
  final ContractSectionType? currentSection;

  /// Whether user scrolled to the end of the summary.
  final bool scrolledToEnd;

  /// Current TTS speed.
  final PlaybackSpeed speed;

  /// Current TTS state.
  final TtsState ttsState;

  /// True when the user has reviewed enough to accept.
  bool get reviewCompleted =>
      sectionsHeard.length == ContractSectionType.values.length ||
      scrolledToEnd;

  /// Returns a copy with updated fields.
  ReviewSession copyWith({
    Set<ContractSectionType>? sectionsHeard,
    ContractSectionType? Function()? currentSection,
    bool? scrolledToEnd,
    PlaybackSpeed? speed,
    TtsState? ttsState,
  }) {
    return ReviewSession(
      contractId: contractId,
      sectionsHeard: sectionsHeard ?? this.sectionsHeard,
      currentSection: currentSection != null
          ? currentSection()
          : this.currentSection,
      scrolledToEnd: scrolledToEnd ?? this.scrolledToEnd,
      speed: speed ?? this.speed,
      ttsState: ttsState ?? this.ttsState,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewSession &&
          contractId == other.contractId &&
          sectionsHeard.length == other.sectionsHeard.length &&
          sectionsHeard.containsAll(other.sectionsHeard) &&
          currentSection == other.currentSection &&
          scrolledToEnd == other.scrolledToEnd &&
          speed == other.speed &&
          ttsState == other.ttsState;

  @override
  int get hashCode => Object.hash(
    contractId,
    Object.hashAll(sectionsHeard.toList()..sort((a, b) => a.index - b.index)),
    currentSection,
    scrolledToEnd,
    speed,
    ttsState,
  );
}
