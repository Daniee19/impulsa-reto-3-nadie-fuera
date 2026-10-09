import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';

/// Text input field for the assistant with send button.
class TextInputField extends StatefulWidget {
  /// Creates the text input field.
  const TextInputField({required this.onSubmit, super.key});

  /// Called with the text when the user submits.
  final void Function(String) onSubmit;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: l10n.assistant_text_label,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.assistant_text_label,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
              textInputAction: TextInputAction.send,
            ),
          ),
        ),
        const SizedBox(width: A11yHelpers.minSeparation),
        SizedBox(
          height: A11yHelpers.minTapTarget,
          width: A11yHelpers.minTapTarget,
          child: IconButton(icon: const Icon(Icons.send), onPressed: _submit),
        ),
      ],
    );
  }
}
