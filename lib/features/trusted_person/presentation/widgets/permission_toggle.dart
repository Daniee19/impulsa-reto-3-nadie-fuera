import 'package:flutter/material.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';

/// Toggle switch for a trusted person permission with description.
class PermissionToggle extends StatelessWidget {
  /// Creates a permission toggle.
  const PermissionToggle({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Permission name shown as title.
  final String label;

  /// One-line explanation shown as subtitle.
  final String description;

  /// Whether the permission is active.
  final bool value;

  /// Called when the user toggles.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stateLabel = value
        ? l10n.trustedPerson_permissionOn
        : l10n.trustedPerson_permissionOff;

    return Semantics(
      label: '$label: $description. $stateLabel',
      toggled: value,
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontSize: 18)),
        subtitle: Text(description),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        controlAffinity: ListTileControlAffinity.trailing,
        visualDensity: VisualDensity.standard,
      ),
    );
  }
}
