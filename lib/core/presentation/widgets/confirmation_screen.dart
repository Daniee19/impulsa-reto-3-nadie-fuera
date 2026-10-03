import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';

/// Generic confirmation scaffold: shows label→value items, confirm + back.
class ConfirmationScreen extends StatefulWidget {
  /// Creates a confirmation screen.
  const ConfirmationScreen({
    required this.title,
    required this.items,
    required this.onConfirm,
    required this.onBack,
    this.confirmLabel = 'Confirmar',
    this.backLabel = 'Volver',
    super.key,
  });

  /// Screen title.
  final String title;

  /// Label→value pairs to display.
  final List<({String label, String value})> items;

  /// Called when user taps confirm.
  final VoidCallback onConfirm;

  /// Called when user taps back.
  final VoidCallback onBack;

  /// Confirm button label.
  final String confirmLabel;

  /// Back button label.
  final String backLabel;

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      A11yHelpers.announceForAccessibility(
        View.of(context),
        widget.title,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in widget.items) ...[
                Text(item.label, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 4),
                Semantics(
                  label: '${item.label}: ${item.value}',
                  child: Text(
                    item.value,
                    style: theme.textTheme.displayMedium,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const Spacer(),
              AccessibleButton(
                text: widget.confirmLabel,
                icon: Icons.check_circle,
                onPressed: widget.onConfirm,
              ),
              AccessibleButton(
                text: widget.backLabel,
                icon: Icons.arrow_back,
                onPressed: widget.onBack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
