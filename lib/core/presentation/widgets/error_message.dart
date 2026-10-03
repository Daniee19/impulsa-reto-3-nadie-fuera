import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';

/// Plain-language error with icon and retry action.
class ErrorMessage extends StatefulWidget {
  /// Creates an error message widget.
  const ErrorMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Error message text.
  final String message;

  /// Optional action button label.
  final String? actionLabel;

  /// Optional action callback.
  final VoidCallback? onAction;

  @override
  State<ErrorMessage> createState() => _ErrorMessageState();
}

class _ErrorMessageState extends State<ErrorMessage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      A11yHelpers.announceForAccessibility(
        View.of(context),
        widget.message,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Semantics(
              liveRegion: true,
              child: Text(
                widget.message,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.actionLabel != null && widget.onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: widget.onAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    A11yHelpers.minTapTarget,
                    A11yHelpers.minTapTarget,
                  ),
                ),
                child: Text(widget.actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
