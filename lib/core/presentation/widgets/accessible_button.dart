import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';

/// Large accessible button with icon, ≥48dp tap target, semantics label.
class AccessibleButton extends StatelessWidget {
  /// Creates an accessible button.
  const AccessibleButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  /// Button label text.
  final String text;

  /// Button icon.
  final IconData icon;

  /// Tap callback.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(A11yHelpers.minSeparation),
      child: Semantics(
        button: true,
        label: text,
        child: Tooltip(
          message: text,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 24),
            label: Text(text),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(
                A11yHelpers.minTapTarget,
                A11yHelpers.minTapTarget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
