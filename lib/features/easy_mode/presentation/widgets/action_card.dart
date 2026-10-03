import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';

/// Large action card for the easy mode home screen.
class ActionCard extends StatelessWidget {
  /// Creates an action card with icon, label, and tap handler.
  const ActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
    super.key,
  });

  /// The text label displayed on the card.
  final String label;

  /// The icon displayed on the card.
  final IconData icon;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: A11yHelpers.minSeparation / 2,
      ),
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: theme.colorScheme.surface,
          elevation: 2,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 80,
                minWidth: A11yHelpers.minTapTarget,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
