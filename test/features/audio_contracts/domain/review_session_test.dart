import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/contract_summary.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/review_session.dart';

void main() {
  group('ReviewSession', () {
    test('reviewCompleted is false initially', () {
      const session = ReviewSession(contractId: 'test');
      expect(session.reviewCompleted, isFalse);
    });

    test('reviewCompleted is true after all 4 sections heard', () {
      const session = ReviewSession(
        contractId: 'test',
        sectionsHeard: {
          ContractSectionType.whatYouAccept,
          ContractSectionType.cost,
          ContractSectionType.risks,
          ContractSectionType.howToCancel,
        },
      );
      expect(session.reviewCompleted, isTrue);
    });

    test('reviewCompleted is true after scrolledToEnd', () {
      const session = ReviewSession(
        contractId: 'test',
        scrolledToEnd: true,
      );
      expect(session.reviewCompleted, isTrue);
    });

    test('copyWith preserves fields', () {
      const session = ReviewSession(
        contractId: 'test',
        speed: PlaybackSpeed.slow,
        ttsState: TtsState.playing,
      );
      final updated = session.copyWith(
        scrolledToEnd: true,
      );
      expect(updated.contractId, 'test');
      expect(updated.speed, PlaybackSpeed.slow);
      expect(updated.ttsState, TtsState.playing);
      expect(updated.scrolledToEnd, isTrue);
    });

    test('speed transitions work correctly', () {
      expect(PlaybackSpeed.normal.rate, 1);
      expect(PlaybackSpeed.slow.rate, 0.75);
      expect(PlaybackSpeed.slower.rate, 0.5);
    });

    test('copyWith nullable currentSection via factory', () {
      const session = ReviewSession(
        contractId: 'test',
        currentSection: ContractSectionType.cost,
      );
      final cleared =
          session.copyWith(currentSection: () => null);
      expect(cleared.currentSection, isNull);
    });

    test('equality works', () {
      const a = ReviewSession(contractId: 'test');
      const b = ReviewSession(contractId: 'test');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
