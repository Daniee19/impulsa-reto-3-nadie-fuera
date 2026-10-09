import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/config_suggestion_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/widgets/permission_toggle.dart';

/// Shows trusted person details and editable permissions.
class TrustedPersonDetailScreen extends ConsumerStatefulWidget {
  /// Creates the detail screen.
  const TrustedPersonDetailScreen({super.key});

  @override
  ConsumerState<TrustedPersonDetailScreen> createState() =>
      _TrustedPersonDetailScreenState();
}

class _TrustedPersonDetailScreenState
    extends ConsumerState<TrustedPersonDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(
        View.of(context),
        l10n.trustedPerson_viewPermissions,
      );
    });
  }

  Future<void> _togglePermission(
    TrustedPermission permission, {
    required bool active,
    required Set<TrustedPermission> current,
  }) async {
    final updated = Set<TrustedPermission>.from(current);
    if (active) {
      updated.add(permission);
    } else {
      updated.remove(permission);
    }
    final repo = ref.read(trustedPersonRepositoryProvider);
    await repo.updatePermissions(updated);
    ref.invalidate(trustedPersonProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final personAsync = ref.watch(trustedPersonProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trustedPerson_viewPermissions)),
      body: SafeArea(
        child: personAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.easyMode_error_generic)),
          data: (person) {
            if (person == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.go('/easy-mode/settings/trusted-person');
                }
              });
              return const SizedBox.shrink();
            }

            final masked = '${'*' * 6}${person.phone.substring(6)}';

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${person.relationship} · $masked',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  PermissionToggle(
                    label: l10n.trustedPerson_permission_securityAlerts,
                    description:
                        l10n.trustedPerson_permission_securityAlerts_desc,
                    value: person.hasPermission(
                      TrustedPermission.securityAlerts,
                    ),
                    onChanged: (v) => _togglePermission(
                      TrustedPermission.securityAlerts,
                      active: v,
                      current: person.permissions,
                    ),
                  ),
                  PermissionToggle(
                    label: l10n.trustedPerson_permission_helpRequests,
                    description:
                        l10n.trustedPerson_permission_helpRequests_desc,
                    value: person.hasPermission(TrustedPermission.helpRequests),
                    onChanged: (v) => _togglePermission(
                      TrustedPermission.helpRequests,
                      active: v,
                      current: person.permissions,
                    ),
                  ),
                  PermissionToggle(
                    label: l10n.trustedPerson_permission_configHelp,
                    description: l10n.trustedPerson_permission_configHelp_desc,
                    value: person.hasPermission(TrustedPermission.configHelp),
                    onChanged: (v) => _togglePermission(
                      TrustedPermission.configHelp,
                      active: v,
                      current: person.permissions,
                    ),
                  ),
                  if (person.hasPermission(TrustedPermission.configHelp))
                    _SuggestionBanner(name: person.name),
                  const Spacer(),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(
                        '/easy-mode/settings/trusted-person/change',
                      ),
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(l10n.trustedPerson_change),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          A11yHelpers.minTapTarget,
                          A11yHelpers.minTapTarget,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.go(
                        '/easy-mode/settings/trusted-person/remove',
                      ),
                      icon: const Icon(Icons.person_remove),
                      label: Text(l10n.trustedPerson_remove),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(
                          A11yHelpers.minTapTarget,
                          A11yHelpers.minTapTarget,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SuggestionBanner extends ConsumerWidget {
  const _SuggestionBanner({required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final suggestions = ref.watch(pendingSuggestionsProvider);

    return suggestions.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.lightbulb),
              title: Text(l10n.trustedPerson_suggestion_pending(name)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(
                '/easy-mode/settings/trusted-person'
                '/suggestion',
                extra: list.first,
              ),
            ),
          ),
        );
      },
    );
  }
}
