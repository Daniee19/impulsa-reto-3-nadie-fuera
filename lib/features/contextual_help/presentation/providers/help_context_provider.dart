import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/help_context.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/services/context_collector.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/navigation_context_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/presentation/providers/operation_in_progress_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/presentation/providers/friction_provider.dart';

/// Provides the current [HelpContext] from navigation and operation state.
final helpContextProvider = Provider<HelpContext>((ref) {
  final nav = ref.watch(navigationContextProvider);
  final op = ref.watch(operationInProgressProvider);
  final friction = ref.read(frictionContextProvider);
  return ContextCollector().collect(
    currentRoute: nav.currentRoute,
    screenName: nav.screenName,
    flowStep: nav.flowStep,
    operation: op,
    frictionDetail: friction?.humanReadable,
  );
});
