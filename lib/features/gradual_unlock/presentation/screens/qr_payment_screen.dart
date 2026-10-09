import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';

/// Simulated QR payment screen.
class QrPaymentScreen extends StatefulWidget {
  /// Creates the QR payment screen.
  const QrPaymentScreen({super.key});

  @override
  State<QrPaymentScreen> createState() => _QrPaymentScreenState();
}

class _QrPaymentScreenState extends State<QrPaymentScreen> {
  bool _scanned = false;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.unlock_feature_qr);
    });
  }

  Future<void> _simulateScan() async {
    setState(() => _scanning = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _scanning = false;
        _scanned = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.unlock_feature_qr)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _scanned ? _buildResult(theme, l10n) : _buildScanner(theme),
        ),
      ),
    );
  }

  Widget _buildScanner(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.qr_code_2,
            size: 120,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          if (_scanning)
            const CircularProgressIndicator()
          else
            AccessibleButton(
              text: 'Escanear código',
              icon: Icons.qr_code_scanner,
              onPressed: _simulateScan,
            ),
        ],
      ),
    );
  }

  Widget _buildResult(ThemeData theme, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Bodega Don Pedro', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Semantics(
                  label: 'veinticinco soles',
                  excludeSemantics: true,
                  child: Text('S/ 25.00', style: theme.textTheme.displayMedium),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        AccessibleButton(
          text: l10n.easyMode_confirm_button,
          icon: Icons.check,
          onPressed: () => context.go('/easy-mode'),
        ),
      ],
    );
  }
}
