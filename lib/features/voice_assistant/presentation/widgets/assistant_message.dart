import 'package:flutter/material.dart';

/// Displays a message from the assistant in a styled card.
class AssistantMessage extends StatelessWidget {
  /// Creates an assistant message widget.
  const AssistantMessage({required this.message, super.key});

  /// The text to display.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}
