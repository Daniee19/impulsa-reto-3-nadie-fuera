import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/providers/practice_session_provider.dart';

/// Shows the practice exit confirmation dialog.
Future<void> showPracticeExitDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _PracticeExitDialog(),
  );
}

class _PracticeExitDialog extends ConsumerWidget {
  const _PracticeExitDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.practice_exit_title),
      content: Text(
        l10n.practice_exit_body,
        style: const TextStyle(fontSize: 18),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(
              A11yHelpers.minTapTarget,
              A11yHelpers.minTapTarget,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.practice_exit_cancel,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
              A11yHelpers.minTapTarget,
              A11yHelpers.minTapTarget,
            ),
          ),
          onPressed: () {
            final notifier = ref.read(practiceSessionProvider.notifier);
            Navigator.of(context).pop();
            context.go('/easy-mode');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              notifier.end();
            });
          },
          child: Text(
            l10n.practice_exit_confirm,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
