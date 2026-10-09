import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

/// Confirmation screen before removing the trusted person.
class TrustedPersonRemoveScreen extends ConsumerStatefulWidget {
  /// Creates the remove screen.
  const TrustedPersonRemoveScreen({super.key});

  @override
  ConsumerState<TrustedPersonRemoveScreen> createState() =>
      _TrustedPersonRemoveScreenState();
}

class _TrustedPersonRemoveScreenState
    extends ConsumerState<TrustedPersonRemoveScreen> {
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.trustedPerson_remove);
    });
  }

  Future<void> _confirmRemove() async {
    if (_processing) return;
    setState(() => _processing = true);

    final repo = ref.read(trustedPersonRepositoryProvider);
    await repo.remove();
    ref.invalidate(trustedPersonProvider);

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.trustedPerson_removed),
          duration: const Duration(seconds: 5),
        ),
      );
      context.go('/easy-mode/settings/trusted-person');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final personAsync = ref.watch(trustedPersonProvider);
    final name = personAsync.valueOrNull?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trustedPerson_remove)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_remove, size: 64),
              const SizedBox(height: 24),
              Text(
                l10n.trustedPerson_remove_warning(name),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _processing ? null : _confirmRemove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  minimumSize: const Size(
                    A11yHelpers.minTapTarget,
                    A11yHelpers.minTapTarget,
                  ),
                ),
                child: Text(
                  l10n.trustedPerson_remove,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    A11yHelpers.minTapTarget,
                    A11yHelpers.minTapTarget,
                  ),
                ),
                child: Text(
                  l10n.trustedPerson_cancel,
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
