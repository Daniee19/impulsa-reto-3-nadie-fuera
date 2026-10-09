import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/contract_summary.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/review_session.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/presentation/providers/contract_review_provider.dart';

/// TTS playback controls: pause/resume, repeat, speed.
class TtsPlaybackControls extends ConsumerWidget {
  /// Creates TTS playback controls.
  const TtsPlaybackControls({
    required this.onPause,
    required this.onResume,
    required this.onRepeat,
    required this.onSpeedChange,
    super.key,
  });

  /// Called when user taps pause.
  final VoidCallback onPause;

  /// Called when user taps resume.
  final VoidCallback onResume;

  /// Called when user taps repeat.
  final VoidCallback onRepeat;

  /// Called with new speed when user taps speed button.
  final ValueChanged<PlaybackSpeed> onSpeedChange;

  PlaybackSpeed _nextSpeed(PlaybackSpeed current) {
    return switch (current) {
      PlaybackSpeed.normal => PlaybackSpeed.slow,
      PlaybackSpeed.slow => PlaybackSpeed.slower,
      PlaybackSpeed.slower => PlaybackSpeed.slower,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(contractReviewProvider);
    if (session == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final isPlaying = session.ttsState == TtsState.playing;
    final atMinSpeed = session.speed == PlaybackSpeed.slower;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AccessibleButton(
          text: isPlaying ? l10n.contract_pause : l10n.contract_resume,
          icon: isPlaying ? Icons.pause : Icons.play_arrow,
          onPressed: isPlaying ? onPause : onResume,
        ),
        AccessibleButton(
          text: l10n.contract_repeatSection,
          icon: Icons.replay,
          onPressed: onRepeat,
        ),
        if (session.speed != PlaybackSpeed.normal)
          AccessibleButton(
            text: l10n.contract_normalSpeed,
            icon: Icons.speed,
            onPressed: () => onSpeedChange(PlaybackSpeed.normal),
          ),
        AccessibleButton(
          text: atMinSpeed ? l10n.contract_speedMin : l10n.contract_slower,
          icon: Icons.slow_motion_video,
          onPressed: atMinSpeed
              ? null
              : () => onSpeedChange(_nextSpeed(session.speed)),
        ),
      ],
    );
  }
}
