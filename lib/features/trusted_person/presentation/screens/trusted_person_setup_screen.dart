import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

/// Entry point for trusted person management.
class TrustedPersonSetupScreen extends ConsumerStatefulWidget {
  /// Creates the setup screen.
  const TrustedPersonSetupScreen({super.key});

  @override
  ConsumerState<TrustedPersonSetupScreen> createState() =>
      _TrustedPersonSetupScreenState();
}

class _TrustedPersonSetupScreenState
    extends ConsumerState<TrustedPersonSetupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.trustedPerson_title);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final personAsync = ref.watch(trustedPersonProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trustedPerson_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: personAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: Text(l10n.easyMode_error_generic)),
            data: (person) {
              if (person == null) {
                return _EmptyState(l10n: l10n);
              }
              return _RegisteredState(
                name: person.name,
                relationship: person.relationship,
                permissionCount: person.permissions.length,
                l10n: l10n,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person_add, size: 64),
        const SizedBox(height: 24),
        Text(
          l10n.trustedPerson_explanation,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () =>
              context.go('/easy-mode/settings/trusted-person/register'),
          icon: const Icon(Icons.person_add),
          label: Text(l10n.trustedPerson_register),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
              A11yHelpers.minTapTarget,
              A11yHelpers.minTapTarget,
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisteredState extends StatelessWidget {
  const _RegisteredState({
    required this.name,
    required this.relationship,
    required this.permissionCount,
    required this.l10n,
  });

  final String name;
  final String relationship;
  final AppLocalizations l10n;
  final int permissionCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person, size: 64),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          relationship,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          permissionCount == 0
              ? l10n.trustedPerson_noPermissions
              : l10n.trustedPerson_activePermissions(permissionCount),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () =>
              context.go('/easy-mode/settings/trusted-person/detail'),
          icon: const Icon(Icons.settings),
          label: Text(l10n.trustedPerson_viewPermissions),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(
              A11yHelpers.minTapTarget,
              A11yHelpers.minTapTarget,
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () =>
              context.go('/easy-mode/settings/trusted-person/change'),
          icon: const Icon(Icons.swap_horiz),
          label: Text(l10n.trustedPerson_change),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(
              A11yHelpers.minTapTarget,
              A11yHelpers.minTapTarget,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () =>
              context.go('/easy-mode/settings/trusted-person/remove'),
          icon: const Icon(Icons.person_remove),
          label: Text(l10n.trustedPerson_remove),
          style: TextButton.styleFrom(
            minimumSize: const Size(
              A11yHelpers.minTapTarget,
              A11yHelpers.minTapTarget,
            ),
          ),
        ),
      ],
    );
  }
}
