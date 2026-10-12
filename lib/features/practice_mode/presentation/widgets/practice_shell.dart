import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/account_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/bill_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/contact_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/operation_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/presentation/providers/risk_engine_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/repositories/practice_account_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/repositories/practice_bill_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/repositories/practice_contact_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/repositories/practice_operation_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/services/practice_biometric_auth.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/data/services/practice_risk_engine.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/providers/practice_theme.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/widgets/practice_banner.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/widgets/practice_exit_dialog.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/widgets/practice_guide_overlay.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/biometric_provider.dart';

/// Wraps child in practice ProviderScope, theme, banner, and guide.
class PracticeShell extends StatefulWidget {
  /// Creates the practice shell.
  const PracticeShell({required this.child, super.key});

  /// The child route content.
  final Widget child;

  @override
  State<PracticeShell> createState() => _PracticeShellState();
}

class _PracticeShellState extends State<PracticeShell> {
  late final PracticeAccountRepository _accountRepo;
  late final PracticeBillRepository _billRepo;
  late final PracticeContactRepository _contactRepo;
  late final PracticeOperationRepository _operationRepo;
  late final PracticeRiskEngine _riskEngine;
  late final PracticeBiometricAuth _biometricAuth;

  @override
  void initState() {
    super.initState();
    _accountRepo = PracticeAccountRepository();
    _billRepo = PracticeBillRepository();
    _contactRepo = PracticeContactRepository();
    _operationRepo = PracticeOperationRepository();
    _riskEngine = PracticeRiskEngine();
    _biometricAuth = PracticeBiometricAuth();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        accountRepositoryProvider.overrideWithValue(_accountRepo),
        billRepositoryProvider.overrideWithValue(_billRepo),
        contactRepositoryProvider.overrideWithValue(_contactRepo),
        operationRepositoryProvider.overrideWithValue(_operationRepo),
        riskEngineProvider.overrideWithValue(_riskEngine),
        biometricProvider.overrideWithValue(_biometricAuth),
      ],
      child: Theme(
        data: practiceTheme(Theme.of(context)),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            final location = GoRouterState.of(context).uri.path;
            if (location == '/easy-mode' || location == '/easy-mode/') {
              showPracticeExitDialog(context);
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Column(
            children: [
              const PracticeBanner(),
              Expanded(
                child: Stack(
                  children: [widget.child, const PracticeGuideOverlay()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
