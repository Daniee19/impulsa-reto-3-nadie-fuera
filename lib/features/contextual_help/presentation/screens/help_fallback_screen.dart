import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_channel.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/help_session_provider.dart';

/// Fallback screen when trusted person doesn't respond (FR-010).
class HelpFallbackScreen extends ConsumerStatefulWidget {
  /// Creates the fallback screen.
  const HelpFallbackScreen({super.key});

  @override
  ConsumerState<HelpFallbackScreen> createState() => _HelpFallbackScreenState();
}

class _HelpFallbackScreenState extends ConsumerState<HelpFallbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = ref.read(helpSessionProvider);
      if (request != null) {
        final l10n = AppLocalizations.of(context)!;
        A11yHelpers.announceForAccessibility(
          View.of(context),
          l10n.help_fallback_title(request.targetName),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final request = ref.watch(helpSessionProvider);
    final targetName = request?.targetName ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.help_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_missed,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.help_fallback_title(targetName),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.help_fallback_question,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(A11yHelpers.minSeparation),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await SystemSound.play(SystemSoundType.click);
                    if (request == null) return;
                    await ref
                        .read(helpSessionProvider.notifier)
                        .startSession(
                          target: HelpTarget.bankAdvisor,
                          targetName: 'Asesor',
                          channel: HelpChannel.call,
                          context: request.context,
                          includeContext: true,
                        );
                    if (!context.mounted) return;
                    await context.push<void>('/easy-mode/help/connecting');
                  },
                  icon: const Icon(Icons.check),
                  label: Text(l10n.help_fallback_yes),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      double.infinity,
                      A11yHelpers.minTapTarget,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(A11yHelpers.minSeparation),
                child: ElevatedButton.icon(
                  onPressed: () {
                    SystemSound.play(SystemSoundType.click);
                    ref.read(helpSessionProvider.notifier).endSession();
                    var count = 0;
                    Navigator.of(context).popUntil((route) {
                      count++;
                      final name = route.settings.name ?? '';
                      return !name.contains('/help/') || count > 5;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.help_fallback_back),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(
                      double.infinity,
                      A11yHelpers.minTapTarget,
                    ),
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
