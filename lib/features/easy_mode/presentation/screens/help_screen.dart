import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';

/// Help screen with contact options (call, chat) — simulated.
class HelpScreen extends StatefulWidget {
  /// Creates the help screen.
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  bool _showConfirmation = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_showConfirmation) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.easyMode_help_title)),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 64,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.easyMode_help_connecting,
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(l10n.easyMode_back_button),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        A11yHelpers.minTapTarget,
                        A11yHelpers.minTapTarget,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.easyMode_help_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AccessibleButton(
                text: l10n.easyMode_help_callAdvisor,
                icon: Icons.phone,
                onPressed: () => setState(() => _showConfirmation = true),
              ),
              const SizedBox(height: 16),
              AccessibleButton(
                text: l10n.easyMode_help_chatAdvisor,
                icon: Icons.chat,
                onPressed: () => setState(() => _showConfirmation = true),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.easyMode_back_button),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(
                    A11yHelpers.minTapTarget,
                    A11yHelpers.minTapTarget,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
