import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';

/// Global floating action button for requesting help (FR-001).
class HelpFab extends StatelessWidget {
  /// Creates the help FAB.
  const HelpFab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      sortKey: const OrdinalSortKey(99),
      button: true,
      label: l10n.help_fab_label,
      child: FloatingActionButton.extended(
        heroTag: 'helpFab',
        onPressed: () {
          SystemSound.play(SystemSoundType.click);
          context.push('/easy-mode/help/contact-picker');
        },
        icon: const Icon(Icons.support_agent),
        label: Text(l10n.help_fab_label),
      ),
    );
  }
}
