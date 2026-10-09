import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/presentation/providers/contract_review_provider.dart';

/// Accept button that is disabled until review is completed.
class AcceptButton extends ConsumerWidget {
  /// Creates an accept button.
  const AcceptButton({required this.onAccept, super.key});

  /// Called when user taps accept after review is complete.
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(contractReviewProvider);
    final completed = session?.reviewCompleted ?? false;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!completed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l10n.contract_acceptDisabled,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        AccessibleButton(
          text: l10n.contract_accept,
          icon: Icons.check_circle,
          onPressed: completed ? onAccept : null,
        ),
      ],
    );
  }
}
