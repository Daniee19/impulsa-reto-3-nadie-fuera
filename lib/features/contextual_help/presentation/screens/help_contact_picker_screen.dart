import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

/// Screen to choose who to contact for help (FR-002).
class HelpContactPickerScreen extends ConsumerStatefulWidget {
  /// Creates the contact picker screen.
  const HelpContactPickerScreen({super.key});

  @override
  ConsumerState<HelpContactPickerScreen> createState() =>
      _HelpContactPickerScreenState();
}

class _HelpContactPickerScreenState
    extends ConsumerState<HelpContactPickerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.announceForAccessibility(View.of(context), l10n.help_title);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trustedPerson = ref.watch(trustedPersonProvider).valueOrNull;
    final showTrusted =
        trustedPerson != null &&
        trustedPerson.hasPermission(TrustedPermission.helpRequests);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.help_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showTrusted)
                Padding(
                  padding: const EdgeInsets.all(A11yHelpers.minSeparation),
                  child: Semantics(
                    button: true,
                    label: l10n.help_contact_trustedPerson(trustedPerson.name),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SystemSound.play(SystemSoundType.click);
                        context.push(
                          '/easy-mode/help/channel-picker',
                          extra: HelpTarget.trustedPerson,
                        );
                      },
                      icon: const Icon(Icons.person),
                      label: Text(
                        l10n.help_contact_trustedPerson(trustedPerson.name),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          A11yHelpers.minTapTarget,
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(A11yHelpers.minSeparation),
                child: Semantics(
                  button: true,
                  label: l10n.help_contact_bankAdvisor,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      SystemSound.play(SystemSoundType.click);
                      context.push(
                        '/easy-mode/help/channel-picker',
                        extra: HelpTarget.bankAdvisor,
                      );
                    },
                    icon: const Icon(Icons.support_agent),
                    label: Text(l10n.help_contact_bankAdvisor),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        A11yHelpers.minTapTarget,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.easyMode_back_button),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  minimumSize: const Size(
                    double.infinity,
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
