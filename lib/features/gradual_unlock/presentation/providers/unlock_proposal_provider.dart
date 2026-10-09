import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/extra_feature.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/unlock_proposal.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/services/unlock_evaluator.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/presentation/providers/feature_flags_provider.dart';

class UnlockProposalNotifier extends StateNotifier<UnlockProposal?> {
  UnlockProposalNotifier(this._ref) : super(null);

  final Ref _ref;
  final _evaluator = UnlockEvaluator();
  bool _proposalShownThisSession = false;

  Future<void> evaluate() async {
    if (_proposalShownThisSession) return;

    final repo = _ref.read(featureFlagRepositoryProvider);
    final metrics = await repo.getMetrics();
    final states = await repo.getStates();
    final rejections = await repo.getRejections();

    state = _evaluator.evaluate(
      metrics: metrics,
      states: states,
      rejections: rejections,
    );

    if (state != null) _proposalShownThisSession = true;
  }

  Future<void> accept(ExtraFeature feature) async {
    final repo = _ref.read(featureFlagRepositoryProvider);
    await repo.setState(feature, FeatureState.active);
    state = null;
    _ref.invalidate(featureStatesProvider);
  }

  Future<void> reject(ExtraFeature feature) async {
    final repo = _ref.read(featureFlagRepositoryProvider);
    await repo.incrementRejection(feature);
    state = null;
  }

  void dismiss() {
    state = null;
  }
}

final unlockProposalProvider =
    StateNotifierProvider<UnlockProposalNotifier, UnlockProposal?>(
      (ref) => UnlockProposalNotifier(ref),
    );
