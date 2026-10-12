import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_channel.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/help_context_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/help_session_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/presentation/providers/friction_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

/// Screen to choose communication channel (FR-003, FR-004).
class HelpChannelPickerScreen extends ConsumerWidget {
  /// Creates the channel picker screen.
  const HelpChannelPickerScreen({required this.target, super.key});

  /// Who is being contacted.
  final HelpTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final trustedPerson = ref.watch(trustedPersonProvider).valueOrNull;
    final targetName = target == HelpTarget.trustedPerson
        ? (trustedPerson?.name ?? '')
        : 'Asesor';

    final includeContext =
        target == HelpTarget.bankAdvisor ||
        (trustedPerson != null &&
            trustedPerson.hasPermission(TrustedPermission.helpRequests));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.help_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ChannelButton(
                label: l10n.help_channel_call,
                icon: Icons.phone,
                onPressed: () => _startSession(
                  context,
                  ref,
                  HelpChannel.call,
                  targetName,
                  includeContext,
                ),
              ),
              _ChannelButton(
                label: l10n.help_channel_chat,
                icon: Icons.chat,
                onPressed: () => _startSession(
                  context,
                  ref,
                  HelpChannel.chat,
                  targetName,
                  includeContext,
                ),
              ),
              if (target == HelpTarget.bankAdvisor)
                _ChannelButton(
                  label: l10n.help_channel_video,
                  icon: Icons.videocam,
                  onPressed: () => _startSession(
                    context,
                    ref,
                    HelpChannel.videoWithInterpreter,
                    targetName,
                    includeContext,
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

  Future<void> _startSession(
    BuildContext context,
    WidgetRef ref,
    HelpChannel channel,
    String targetName,
    bool includeContext,
  ) async {
    await SystemSound.play(SystemSoundType.click);
    final helpContext = ref.read(helpContextProvider);
    ref.read(frictionContextProvider.notifier).state = null;
    await ref
        .read(helpSessionProvider.notifier)
        .startSession(
          target: target,
          targetName: targetName,
          channel: channel,
          context: helpContext,
          includeContext: includeContext,
        );
    if (!context.mounted) return;
    await context.push<void>('/easy-mode/help/connecting');
  }
}

class _ChannelButton extends StatelessWidget {
  const _ChannelButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(A11yHelpers.minSeparation),
      child: Semantics(
        button: true,
        label: label,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, A11yHelpers.minTapTarget),
          ),
        ),
      ),
    );
  }
}
