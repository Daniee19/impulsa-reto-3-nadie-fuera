import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/widgets/practice_exit_dialog.dart';

/// Persistent green banner at the top during practice mode.
class PracticeBanner extends StatelessWidget {
  /// Creates the practice banner.
  const PracticeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      liveRegion: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: A11yHelpers.minTapTarget),
        color: const Color(0xFF2E7D32),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.practice_banner,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              tooltip: l10n.practice_exit_button,
              onPressed: () => showPracticeExitDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
