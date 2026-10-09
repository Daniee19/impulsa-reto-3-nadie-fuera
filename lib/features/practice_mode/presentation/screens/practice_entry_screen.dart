import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/practice_mode/presentation/providers/practice_session_provider.dart';

/// Entry screen explaining practice mode before starting.
class PracticeEntryScreen extends ConsumerStatefulWidget {
  /// Creates the practice entry screen.
  const PracticeEntryScreen({super.key});

  @override
  ConsumerState<PracticeEntryScreen> createState() =>
      _PracticeEntryScreenState();
}

class _PracticeEntryScreenState extends ConsumerState<PracticeEntryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.practice_title);
    });
  }

  void _start({required bool guideEnabled}) {
    ref
        .read(practiceSessionProvider.notifier)
        .start(guideEnabled: guideEnabled);
    context.go('/easy-mode');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.practice_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.school, size: 64),
              const SizedBox(height: 24),
              Text(
                l10n.practice_entry_heading,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.practice_entry_body,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AccessibleButton(
                text: l10n.practice_entry_withGuide,
                icon: Icons.school,
                onPressed: () => _start(guideEnabled: true),
              ),
              const SizedBox(height: A11yHelpers.minSeparation),
              AccessibleButton(
                text: l10n.practice_entry_withoutGuide,
                icon: Icons.explore,
                onPressed: () => _start(guideEnabled: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
