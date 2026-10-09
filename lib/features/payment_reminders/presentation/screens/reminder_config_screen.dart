import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/presentation/providers/bill_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/entities/reminder_config.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/presentation/providers/reminder_config_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

class ReminderConfigScreen extends ConsumerStatefulWidget {
  const ReminderConfigScreen({super.key});

  @override
  ConsumerState<ReminderConfigScreen> createState() =>
      _ReminderConfigScreenState();
}

class _ReminderConfigScreenState extends ConsumerState<ReminderConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(View.of(context), l10n.reminder_configTitle);
    });
  }

  void _updateConfig(ReminderConfig config) {
    ref.read(reminderConfigProvider.notifier).update(config);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(reminderConfigProvider);
    final billsAsync = ref.watch(pendingBillsProvider);
    final trustedPerson = ref.watch(trustedPersonProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reminder_configTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            billsAsync.when(
              data: (bills) => Column(
                children: [
                  for (final bill in bills)
                    SwitchListTile(
                      title: Text(bill.serviceName),
                      value: config.enabledBillIds.contains(bill.id),
                      onChanged: (enabled) {
                        final ids = {...config.enabledBillIds};
                        if (enabled) {
                          ids.add(bill.id);
                        } else {
                          ids.remove(bill.id);
                        }
                        _updateConfig(config.copyWith(enabledBillIds: ids));
                      },
                    ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.reminder_anticipation,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RadioGroup<AnticipationDays>(
              groupValue: config.anticipationDays,
              onChanged: (v) {
                if (v != null) {
                  _updateConfig(config.copyWith(anticipationDays: v));
                }
              },
              child: Column(
                children: [
                  for (final option in AnticipationDays.values)
                    RadioListTile<AnticipationDays>(
                      title: Text(_anticipationLabel(option, l10n)),
                      value: option,
                    ),
                ],
              ),
            ),
            if (trustedPerson != null) ...[
              const SizedBox(height: 24),
              SwitchListTile(
                title: Text(l10n.reminder_shareWithTrusted),
                value: config.shareWithTrusted,
                onChanged: (enabled) {
                  if (enabled && !config.shareConsentGranted) {
                    _showConsentDialog(trustedPerson.name);
                  } else {
                    _updateConfig(config.copyWith(shareWithTrusted: enabled));
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _anticipationLabel(AnticipationDays option, AppLocalizations l10n) {
    return switch (option) {
      AnticipationDays.one => l10n.reminder_anticipation_1,
      AnticipationDays.three => l10n.reminder_anticipation_3,
      AnticipationDays.five => l10n.reminder_anticipation_5,
    };
  }

  void _showConsentDialog(String name) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.reminder_consentTitle),
        content: Text(l10n.reminder_shareConsent(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.reminder_consentReject),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.reminder_consentAccept),
          ),
        ],
      ),
    ).then((accepted) {
      if (accepted ?? false) {
        final config = ref.read(reminderConfigProvider);
        _updateConfig(
          config.copyWith(shareConsentGranted: true, shareWithTrusted: true),
        );
      }
    });
  }
}
