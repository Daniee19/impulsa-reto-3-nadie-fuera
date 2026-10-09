import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

/// Confirmation screen before changing the trusted person.
class TrustedPersonChangeScreen extends ConsumerStatefulWidget {
  /// Creates the change screen.
  const TrustedPersonChangeScreen({super.key});

  @override
  ConsumerState<TrustedPersonChangeScreen> createState() =>
      _TrustedPersonChangeScreenState();
}

class _TrustedPersonChangeScreenState
    extends ConsumerState<TrustedPersonChangeScreen> {
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.trustedPerson_change);
    });
  }

  Future<void> _confirmChange() async {
    if (_processing) return;
    setState(() => _processing = true);

    final repo = ref.read(trustedPersonRepositoryProvider);
    await repo.remove();
    ref.invalidate(trustedPersonProvider);

    if (mounted) {
      context.go('/easy-mode/settings/trusted-person/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final personAsync = ref.watch(trustedPersonProvider);
    final name = personAsync.valueOrNull?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trustedPerson_change)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, size: 64),
              const SizedBox(height: 24),
              Text(
                l10n.trustedPerson_change_warning(name),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.trustedPerson_remove_warning(name),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _processing ? null : _confirmChange,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    A11yHelpers.minTapTarget,
                    A11yHelpers.minTapTarget,
                  ),
                ),
                child: Text(
                  l10n.trustedPerson_continue,
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
