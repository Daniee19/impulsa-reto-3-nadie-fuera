import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_channel.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_request.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_target.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/help_session_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';

/// Shows connection status and context sent to helper (FR-005, FR-006).
class HelpConnectingScreen extends ConsumerStatefulWidget {
  /// Creates the connecting screen.
  const HelpConnectingScreen({super.key});

  @override
  ConsumerState<HelpConnectingScreen> createState() =>
      _HelpConnectingScreenState();
}

class _HelpConnectingScreenState extends ConsumerState<HelpConnectingScreen> {
  Timer? _connectTimer;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final request = ref.read(helpSessionProvider);
      if (request == null) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(
        View.of(context),
        l10n.announceHelpConnecting(request.targetName),
      );
    });
    _startConnection();
  }

  void _startConnection() {
    _connectTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final request = ref.read(helpSessionProvider);
      if (request == null) return;

      if (request.target == HelpTarget.trustedPerson) {
        _fallbackTimer = Timer(const Duration(seconds: 10), () {
          if (!mounted) return;
          ref.read(helpSessionProvider.notifier).markNoResponse();
          context.push<void>('/easy-mode/help/fallback');
        });
      }
      ref.read(helpSessionProvider.notifier).markConnected();
    });
  }

  @override
  void dispose() {
    _connectTimer?.cancel();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final request = ref.watch(helpSessionProvider);
    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.help_title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isConnected = request.status == HelpRequestStatus.connected;
    final connectingMessage = _connectingMessage(l10n, request);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.help_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isConnected) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    connectingMessage,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.help_connected_title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _ContextCard(request: request, l10n: l10n),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.help_back_button),
                style: ElevatedButton.styleFrom(
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

  String _connectingMessage(AppLocalizations l10n, HelpRequest request) {
    if (request.channel == HelpChannel.videoWithInterpreter) {
      return l10n.help_connecting_videoInterpreter;
    }
    if (request.target == HelpTarget.trustedPerson) {
      return l10n.help_connecting_trustedPerson(request.targetName);
    }
    return l10n.help_connecting_bankAdvisor;
  }

  void _goBack() {
    _fallbackTimer?.cancel();
    ref.read(helpSessionProvider.notifier).endSession();
    var count = 0;
    Navigator.of(context).popUntil((route) {
      count++;
      final name = route.settings.name ?? '';
      return !name.contains('/help/') || count > 5;
    });
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.request, required this.l10n});

  final HelpRequest request;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ctx = request.context;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.help_connected_contextSent(request.targetName),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (request.includeContext) ...[
              Text(
                l10n.help_context_screen(ctx.screenName),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              if (ctx.operationType != null)
                Text(
                  l10n.help_context_operation(
                    ctx.operationType == OperationType.payment
                        ? l10n.easyMode_payBill_title
                        : l10n.easyMode_sendMoney_title,
                    ctx.operationAmount?.toStringAsFixed(2) ?? '0',
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              else
                Text(
                  l10n.help_context_noOperation,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
            ] else
              Text(
                l10n.help_context_minimalMessage('Rosa'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}
