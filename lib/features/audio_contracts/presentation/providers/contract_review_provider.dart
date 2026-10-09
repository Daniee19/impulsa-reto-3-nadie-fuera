import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/data/repositories/mock_contract_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/contract_summary.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/review_session.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/repositories/contract_repository.dart';

final contractRepositoryProvider = Provider<ContractRepository>(
  (ref) => MockContractRepository(),
);

final contractReviewProvider =
    StateNotifierProvider<ContractReviewNotifier, ReviewSession?>(
      (ref) => ContractReviewNotifier(),
    );

class ContractReviewNotifier extends StateNotifier<ReviewSession?> {
  ContractReviewNotifier() : super(null);

  void startReview(String contractId) {
    state = ReviewSession(contractId: contractId);
  }

  void markSectionHeard(ContractSectionType type) {
    if (state == null) return;
    state = state!.copyWith(sectionsHeard: {...state!.sectionsHeard, type});
  }

  void setCurrentSection(ContractSectionType? section) {
    state = state?.copyWith(currentSection: () => section);
  }

  void markScrolledToEnd() {
    state = state?.copyWith(scrolledToEnd: true);
  }

  void setSpeed(PlaybackSpeed speed) {
    state = state?.copyWith(speed: speed);
  }

  void setTtsState(TtsState ttsState) {
    state = state?.copyWith(ttsState: ttsState);
  }

  void clear() {
    state = null;
  }
}
