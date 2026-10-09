import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/entities/friction_signal.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/services/friction_detector.dart';

void main() {
  late FrictionDetector detector;

  setUp(() => detector = FrictionDetector());

  group('back navigation', () {
    test('2 backs do not fire signal', () {
      for (var i = 0; i < 2; i++) {
        expect(
          detector.onBackNavigation(
            flowId: 'pay-bill',
            stepRoute: '/easy-mode/pay-bill',
            stepName: 'Pagar recibo',
          ),
          isNull,
        );
      }
    });

    test('3 backs fire signal', () {
      for (var i = 0; i < 2; i++) {
        detector.onBackNavigation(
          flowId: 'pay-bill',
          stepRoute: '/easy-mode/pay-bill',
          stepName: 'Pagar recibo',
        );
      }
      final signal = detector.onBackNavigation(
        flowId: 'pay-bill',
        stepRoute: '/easy-mode/pay-bill',
        stepName: 'Pagar recibo',
      );
      expect(signal, isNotNull);
      expect(signal!.type, FrictionType.repeatedBackNavigation);
      expect(signal.occurrences, 3);
    });
  });

  test('resetForNewFlow clears counters', () {
    for (var i = 0; i < 2; i++) {
      detector.onBackNavigation(
        flowId: 'pay-bill',
        stepRoute: '/easy-mode/pay-bill',
        stepName: 'Pagar recibo',
      );
    }
    detector.resetForNewFlow();
    expect(
      detector.onBackNavigation(
        flowId: 'pay-bill',
        stepRoute: '/easy-mode/pay-bill',
        stepName: 'Pagar recibo',
      ),
      isNull,
    );
  });

  group('excluded screens', () {
    test('/confirm is excluded', () {
      expect(detector.isExcludedScreen('/easy-mode/pay-bill/1/confirm'), true);
    });

    test('fraud-alert is excluded', () {
      expect(detector.isExcludedScreen('/easy-mode/fraud-alert'), true);
    });

    test('/help/ is excluded', () {
      expect(detector.isExcludedScreen('/easy-mode/help/contact-picker'), true);
    });
  });

  group('active flows', () {
    test('home is NOT active flow', () {
      expect(detector.isActiveFlow('/easy-mode'), false);
    });

    test('pay-bill is active flow', () {
      expect(detector.isActiveFlow('/easy-mode/pay-bill/1'), true);
    });

    test('send-money is active flow', () {
      expect(detector.isActiveFlow('/easy-mode/send-money'), true);
    });
  });

  group('validation errors', () {
    test('2 errors do not fire', () {
      for (var i = 0; i < 2; i++) {
        expect(
          detector.onValidationError(
            flowId: 'send-money',
            stepRoute: '/easy-mode/send-money',
            stepName: 'Enviar dinero',
            fieldId: 'amount',
            errorType: 'invalid',
          ),
          isNull,
        );
      }
    });

    test('3 same errors fire signal', () {
      for (var i = 0; i < 2; i++) {
        detector.onValidationError(
          flowId: 'send-money',
          stepRoute: '/easy-mode/send-money',
          stepName: 'Enviar dinero',
          fieldId: 'amount',
          errorType: 'invalid',
        );
      }
      final signal = detector.onValidationError(
        flowId: 'send-money',
        stepRoute: '/easy-mode/send-money',
        stepName: 'Enviar dinero',
        fieldId: 'amount',
        errorType: 'invalid',
      );
      expect(signal, isNotNull);
      expect(signal!.type, FrictionType.repeatedError);
    });

    test('different errorTypes count separately', () {
      for (var i = 0; i < 2; i++) {
        detector.onValidationError(
          flowId: 'f',
          stepRoute: '/r',
          stepName: 's',
          fieldId: 'amount',
          errorType: 'invalid',
        );
      }
      expect(
        detector.onValidationError(
          flowId: 'f',
          stepRoute: '/r',
          stepName: 's',
          fieldId: 'amount',
          errorType: 'tooLarge',
        ),
        isNull,
      );
    });
  });

  test('dismissSignal prevents re-trigger', () {
    detector.dismissSignal(FrictionType.repeatedBackNavigation, 'pay-bill');
    expect(
      detector.isDismissed(FrictionType.repeatedBackNavigation, 'pay-bill'),
      true,
    );
  });

  test('custom thresholds work', () {
    final custom = FrictionDetector(
      thresholds: const FrictionThresholds(backNavigationCount: 5),
    );
    for (var i = 0; i < 4; i++) {
      expect(
        custom.onBackNavigation(flowId: 'f', stepRoute: '/r', stepName: 's'),
        isNull,
      );
    }
    expect(
      custom.onBackNavigation(flowId: 'f', stepRoute: '/r', stepName: 's'),
      isNotNull,
    );
  });
}
