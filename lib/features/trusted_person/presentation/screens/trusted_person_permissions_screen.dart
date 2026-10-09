import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/screens/trusted_person_register_screen.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/widgets/permission_toggle.dart';

/// Screen to select permissions during registration.
class TrustedPersonPermissionsScreen extends ConsumerStatefulWidget {
  /// Creates the permissions screen.
  const TrustedPersonPermissionsScreen({required this.data, super.key});

  /// Registration data from the register screen.
  final TrustedPersonRegistrationData data;

  @override
  ConsumerState<TrustedPersonPermissionsScreen> createState() =>
      _TrustedPersonPermissionsScreenState();
}

class _TrustedPersonPermissionsScreenState
    extends ConsumerState<TrustedPersonPermissionsScreen> {
  final _permissions = <TrustedPermission>{};
  bool _registering = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      A11yHelpers.screenAnnounce(
        View.of(context),
        AppLocalizations.of(context)!.trustedPerson_permission_securityAlerts,
      );
    });
  }

  Future<void> _register() async {
    if (_registering) return;
    setState(() => _registering = true);

    try {
      final repo = ref.read(trustedPersonRepositoryProvider);
      await repo.register(
        name: widget.data.name,
        phone: widget.data.phone,
        relationship: widget.data.relationship,
        initialPermissions: _permissions,
      );
      ref.invalidate(trustedPersonProvider);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.trustedPerson_registered),
            duration: const Duration(seconds: 5),
          ),
        );
        context.go('/easy-mode/settings/trusted-person');
      }
    } catch (_) {
      setState(() => _registering = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.easyMode_error_generic),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trustedPerson_viewPermissions)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PermissionToggle(
                label: l10n.trustedPerson_permission_securityAlerts,
                description: l10n.trustedPerson_permission_securityAlerts_desc,
                value: _permissions.contains(TrustedPermission.securityAlerts),
                onChanged: (v) => setState(() {
                  if (v) {
                    _permissions.add(TrustedPermission.securityAlerts);
                  } else {
                    _permissions.remove(TrustedPermission.securityAlerts);
                  }
                }),
              ),
              PermissionToggle(
                label: l10n.trustedPerson_permission_helpRequests,
                description: l10n.trustedPerson_permission_helpRequests_desc,
                value: _permissions.contains(TrustedPermission.helpRequests),
                onChanged: (v) => setState(() {
                  if (v) {
                    _permissions.add(TrustedPermission.helpRequests);
                  } else {
                    _permissions.remove(TrustedPermission.helpRequests);
                  }
                }),
              ),
              PermissionToggle(
                label: l10n.trustedPerson_permission_configHelp,
                description: l10n.trustedPerson_permission_configHelp_desc,
                value: _permissions.contains(TrustedPermission.configHelp),
                onChanged: (v) => setState(() {
                  if (v) {
                    _permissions.add(TrustedPermission.configHelp);
                  } else {
                    _permissions.remove(TrustedPermission.configHelp);
                  }
                }),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _registering ? null : _register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    A11yHelpers.minTapTarget,
                    A11yHelpers.minTapTarget,
                  ),
                ),
                child: Text(
                  _registering ? '...' : l10n.trustedPerson_confirmRegister,
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
