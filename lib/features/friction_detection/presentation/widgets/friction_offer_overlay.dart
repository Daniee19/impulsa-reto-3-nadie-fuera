import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/entities/friction_offer.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/entities/friction_signal.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/presentation/providers/friction_provider.dart';

/// Non-modal bottom overlay offering help when friction is detected.
class FrictionOfferOverlay extends ConsumerWidget {
  /// Creates the overlay.
  const FrictionOfferOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(frictionNotifierProvider);

    if (offer.status != FrictionOfferStatus.showing) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final message = _messageForType(offer.signal?.type, l10n);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      A11yHelpers.screenAnnounce(View.of(context), message);
    });

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 8,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _OverlayButton(
                  text: l10n.friction_optionExplain,
                  icon: Icons.lightbulb_outline,
                  onPressed: () => ref
                      .read(frictionNotifierProvider.notifier)
                      .acceptExplain(),
                ),
                const SizedBox(height: A11yHelpers.minSeparation),
                _OverlayButton(
                  text: l10n.friction_optionHuman,
                  icon: Icons.person,
                  onPressed: () {
                    ref.read(frictionNotifierProvider.notifier).acceptHuman();
                    context.push('/easy-mode/help/contact-picker');
                  },
                ),
                const SizedBox(height: A11yHelpers.minSeparation),
                _OverlayButton(
                  text: l10n.friction_optionDismiss,
                  icon: Icons.close,
                  onPressed: () =>
                      ref.read(frictionNotifierProvider.notifier).dismiss(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _messageForType(FrictionType? type, AppLocalizations l10n) {
    switch (type) {
      case FrictionType.prolongedInactivity:
        return l10n.friction_offerMessageInactivity;
      case FrictionType.repeatedError:
        return l10n.friction_offerMessageField;
      case FrictionType.repeatedBackNavigation:
      case null:
        return l10n.friction_offerMessage;
    }
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: A11yHelpers.minTapTarget,
      child: Semantics(
        label: text,
        button: true,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
