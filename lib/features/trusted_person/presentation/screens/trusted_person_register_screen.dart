import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';

/// Registration data passed to the permissions screen.
class TrustedPersonRegistrationData {
  /// Creates registration data.
  const TrustedPersonRegistrationData({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  /// Full name.
  final String name;

  /// Phone number.
  final String phone;

  /// Relationship.
  final String relationship;
}

/// Form to enter trusted person name, phone, and relationship.
class TrustedPersonRegisterScreen extends StatefulWidget {
  /// Creates the register screen.
  const TrustedPersonRegisterScreen({super.key});

  @override
  State<TrustedPersonRegisterScreen> createState() =>
      _TrustedPersonRegisterScreenState();
}

class _TrustedPersonRegisterScreenState
    extends State<TrustedPersonRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.trustedPerson_register);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.go(
      '/easy-mode/settings/trusted-person/permissions',
      extra: TrustedPersonRegistrationData(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trustedPerson_register)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.trustedPerson_explanation,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.trustedPerson_nameLabel,
                    labelStyle: const TextStyle(fontSize: 18),
                  ),
                  style: const TextStyle(fontSize: 18),
                  maxLength: 100,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.trustedPerson_nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: l10n.trustedPerson_phoneLabel,
                    labelStyle: const TextStyle(fontSize: 18),
                  ),
                  style: const TextStyle(fontSize: 18),
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  validator: (v) {
                    final phone = v?.trim() ?? '';
                    if (phone.length != 9 || !phone.startsWith('9')) {
                      return l10n.trustedPerson_phoneInvalid;
                    }
                    if (!RegExp(r'^\d{9}$').hasMatch(phone)) {
                      return l10n.trustedPerson_phoneInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _relationshipController,
                  decoration: InputDecoration(
                    labelText: l10n.trustedPerson_relationshipLabel,
                    labelStyle: const TextStyle(fontSize: 18),
                  ),
                  style: const TextStyle(fontSize: 18),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.trustedPerson_relationshipRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(
                      A11yHelpers.minTapTarget,
                      A11yHelpers.minTapTarget,
                    ),
                  ),
                  child: Text(
                    l10n.trustedPerson_next,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
