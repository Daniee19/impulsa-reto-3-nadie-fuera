import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/config_suggestion.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/config_suggestion_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

/// Shows a pending config suggestion for the user to accept or reject.
class ConfigSuggestionScreen extends ConsumerStatefulWidget {
  /// Creates the suggestion screen.
  const ConfigSuggestionScreen({required this.suggestion, super.key});

  /// The suggestion to display.
  final ConfigSuggestion suggestion;

  @override
  ConsumerState<ConfigSuggestionScreen> createState() =>
      _ConfigSuggestionScreenState();
}

class _ConfigSuggestionScreenState
    extends ConsumerState<ConfigSuggestionScreen> {
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final personName =
          ref.read(trustedPersonProvider).valueOrNull?.name ?? '';
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(
        View.of(context),
        l10n.trustedPerson_suggestion_title(personName),
      );
    });
  }

  Future<void> _accept() async {
    if (_processing) return;
    setState(() => _processing = true);

    final repo = ref.read(configSuggestionRepositoryProvider);
    await repo.accept(widget.suggestion.id);
    ref.invalidate(pendingSuggestionsProvider);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.trustedPerson_suggestion_accepted),
          duration: const Duration(seconds: 5),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _reject() async {
    if (_processing) return;
    setState(() => _processing = true);

    final repo = ref.read(configSuggestionRepositoryProvider);
    await repo.reject(widget.suggestion.id);
    ref.invalidate(pendingSuggestionsProvider);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final personName = ref.watch(trustedPersonProvider).valueOrNull?.name ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trustedPerson_suggestion_title(personName)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lightbulb_outline, size: 64),
              const SizedBox(height: 24),
              Text(
                widget.suggestion.description,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _processing ? null : _accept,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    A11yHelpers.minTapTarget,
                    A11yHelpers.minTapTarget,
                  ),
                ),
                child: Text(
                  l10n.trustedPerson_suggestion_accept,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _processing ? null : _reject,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    A11yHelpers.minTapTarget,
                    A11yHelpers.minTapTarget,
                  ),
                ),
                child: Text(
                  l10n.trustedPerson_suggestion_reject,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
