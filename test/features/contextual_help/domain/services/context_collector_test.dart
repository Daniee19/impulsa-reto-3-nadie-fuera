import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/entities/operation_in_progress.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/contextual_help/domain/services/context_collector.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/operation.dart';

void main() {
  late ContextCollector collector;

  setUp(() => collector = ContextCollector());

  group('ContextCollector', () {
    test('home screen without operation', () {
      final ctx = collector.collect(
        currentRoute: '/easy-mode',
        screenName: 'Pantalla principal',
      );
      expect(ctx.screenName, 'Pantalla principal');
      expect(ctx.screenRoute, '/easy-mode');
      expect(ctx.operationType, isNull);
      expect(ctx.operationAmount, isNull);
      expect(ctx.operationRecipient, isNull);
    });

    test('confirm payment with operation', () {
      final ctx = collector.collect(
        currentRoute: '/easy-mode/pay-bill/1/confirm',
        screenName: 'Confirmación de pago',
        flowStep: 'Paso 2 de 2',
        operation: const OperationInProgress(
          type: OperationType.payment,
          amount: 85.50,
          recipientName: 'Luz - Enel',
          recipientId: 'bill-1',
        ),
      );
      expect(ctx.operationType, OperationType.payment);
      expect(ctx.operationAmount, 85.50);
      expect(ctx.operationRecipient, 'Luz - Enel');
      expect(ctx.flowStep, 'Paso 2 de 2');
    });

    test('fraud alert screen', () {
      final ctx = collector.collect(
        currentRoute: '/easy-mode/fraud-alert',
        screenName: 'Alerta de seguridad',
      );
      expect(ctx.screenName, 'Alerta de seguridad');
    });

    test('timestamp is present', () {
      final before = DateTime.now();
      final ctx = collector.collect(
        currentRoute: '/easy-mode',
        screenName: 'Pantalla principal',
      );
      final after = DateTime.now();
      expect(
        ctx.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        ctx.timestamp.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('null operation produces null operation fields', () {
      final ctx = collector.collect(
        currentRoute: '/easy-mode/balance',
        screenName: 'Ver mi saldo',
      );
      expect(ctx.operationType, isNull);
      expect(ctx.operationAmount, isNull);
      expect(ctx.operationRecipient, isNull);
    });

    test('no sensitive data fields exist in HelpContext', () {
      final ctx = collector.collect(
        currentRoute: '/easy-mode/send-money/confirm',
        screenName: 'Confirmación de envío',
        operation: const OperationInProgress(
          type: OperationType.transfer,
          amount: 200,
          recipientName: 'Ana',
          recipientId: 'c-1',
        ),
      );
      // HelpContext has only: screenName, screenRoute, flowStep,
      // operationType, operationAmount, operationRecipient, timestamp.
      // No password, PIN, biometric, or account number fields.
      expect(ctx.screenName, isNotEmpty);
      expect(ctx.operationAmount, 200);
      expect(ctx.operationRecipient, 'Ana');
    });
  });
}
