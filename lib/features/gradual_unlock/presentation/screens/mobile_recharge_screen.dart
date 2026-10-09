import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';

/// Simulated mobile recharge screen.
class MobileRechargeScreen extends StatefulWidget {
  /// Creates the mobile recharge screen.
  const MobileRechargeScreen({super.key});

  @override
  State<MobileRechargeScreen> createState() => _MobileRechargeScreenState();
}

class _MobileRechargeScreenState extends State<MobileRechargeScreen> {
  final _phoneController = TextEditingController();
  double? _selectedAmount;
  String? _phoneError;

  static const _amounts = [5.0, 10.0, 20.0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(
        View.of(context),
        l10n.unlock_feature_recharge,
      );
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = _phoneController.text.trim();
    if (phone.length != 9 || !phone.startsWith('9')) {
      setState(() => _phoneError = 'Ingresa 9 dígitos que empiecen con 9');
      return;
    }
    if (_selectedAmount == null) return;

    context.go('/easy-mode');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.unlock_feature_recharge)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 9,
                style: theme.textTheme.titleLarge,
                decoration: InputDecoration(
                  labelText: l10n.trustedPerson_phoneLabel,
                  errorText: _phoneError,
                  prefixIcon: const Icon(Icons.phone_android),
                ),
                onChanged: (_) => setState(() => _phoneError = null),
              ),
              const SizedBox(height: 24),
              Text('Monto', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _amounts.map((amount) {
                  final selected = _selectedAmount == amount;
                  return Semantics(
                    selected: selected,
                    label: 'S/ ${amount.toStringAsFixed(0)}',
                    child: ChoiceChip(
                      label: Text(
                        'S/ ${amount.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium,
                      ),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedAmount = amount),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              AccessibleButton(
                text: l10n.unlock_feature_recharge,
                icon: Icons.phone_android,
                onPressed: _selectedAmount != null ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
