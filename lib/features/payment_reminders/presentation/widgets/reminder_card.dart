import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/domain/entities/reminder.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/payment_reminders/presentation/providers/reminder_config_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/presentation/providers/trusted_person_provider.dart';

class ReminderCard extends ConsumerWidget {
  const ReminderCard({required this.reminder, super.key});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final config = ref.watch(reminderConfigProvider);
    final trustedPerson = ref.watch(trustedPersonProvider).valueOrNull;
    final showShared = config.shareWithTrusted && trustedPerson != null;

    return Card(
      color: reminder.isOverdue ? Colors.red.shade50 : Colors.amber.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                reminder.message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (showShared) ...[
              const SizedBox(height: 8),
              Text(
                l10n.reminder_sharedNotification(trustedPerson.name),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            AccessibleButton(
              text: l10n.reminder_payNow,
              icon: Icons.payment,
              onPressed: () =>
                  context.go('/easy-mode/pay-bill/${reminder.billId}/confirm'),
            ),
            AccessibleButton(
              text: l10n.reminder_dismiss,
              icon: Icons.check,
              onPressed: () => ref
                  .read(reminderConfigRepositoryProvider)
                  .dismissBill(reminder.billId),
            ),
          ],
        ),
      ),
    );
  }
}
