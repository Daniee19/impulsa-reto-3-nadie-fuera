import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/assistant_intent.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/services/intent_parser.dart';

void main() {
  final parser = IntentParser();

  test('pagar la luz → payBill, serviceName luz', () {
    final result = parser.parse('quiero pagar la luz');
    expect(result.type, AssistantIntentType.payBill);
    expect(result.parameters?.serviceName, 'luz');
  });

  test('pagar agua → payBill, serviceName agua', () {
    final result = parser.parse('pagar agua');
    expect(result.type, AssistantIntentType.payBill);
    expect(result.parameters?.serviceName, 'agua');
  });

  test('mándale 50 soles a Valeria → sendMoney', () {
    final result = parser.parse('mándale 50 soles a Valeria');
    expect(result.type, AssistantIntentType.sendMoney);
    expect(result.parameters?.amount, 50);
    expect(result.parameters?.contactName, isNotNull);
    expect(result.parameters!.contactName!.toLowerCase(), contains('valeria'));
  });

  test('envía 100 a mi hija → sendMoney with amount', () {
    final result = parser.parse('envía 100 a mi hija');
    expect(result.type, AssistantIntentType.sendMoney);
    expect(result.parameters?.amount, 100);
    expect(result.parameters!.contactName!.toLowerCase(), contains('mi hija'));
  });

  test('cuánto tengo → checkBalance', () {
    final result = parser.parse('cuánto tengo');
    expect(result.type, AssistantIntentType.checkBalance);
  });

  test('mi saldo → checkBalance', () {
    final result = parser.parse('mi saldo');
    expect(result.type, AssistantIntentType.checkBalance);
  });

  test('ayúdame → requestHelp', () {
    final result = parser.parse('ayúdame');
    expect(result.type, AssistantIntentType.requestHelp);
  });

  test('necesito ayuda → requestHelp', () {
    final result = parser.parse('necesito ayuda');
    expect(result.type, AssistantIntentType.requestHelp);
  });

  test('hazme eso de siempre → unknown', () {
    final result = parser.parse('hazme eso de siempre');
    expect(result.type, AssistantIntentType.unknown);
  });

  test('capital de Francia → unknown', () {
    final result = parser.parse('cuál es la capital de Francia');
    expect(result.type, AssistantIntentType.unknown);
  });

  test('empty string → unknown', () {
    final result = parser.parse('');
    expect(result.type, AssistantIntentType.unknown);
  });

  test('transferir sin contacto → sendMoney, contactName null', () {
    final result = parser.parse('transferir');
    expect(result.type, AssistantIntentType.sendMoney);
    expect(result.parameters?.contactName, isNull);
  });

  test('pagar sin servicio → payBill, serviceName null', () {
    final result = parser.parse('pagar');
    expect(result.type, AssistantIntentType.payBill);
    expect(result.parameters?.serviceName, isNull);
  });

  test('mándale plata a Valeria → sendMoney, amount null', () {
    final result = parser.parse('mándale plata a Valeria');
    expect(result.type, AssistantIntentType.sendMoney);
    expect(result.parameters?.amount, isNull);
    expect(result.parameters!.contactName!.toLowerCase(), contains('valeria'));
  });
}
