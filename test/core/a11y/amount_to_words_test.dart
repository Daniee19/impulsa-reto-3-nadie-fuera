import 'package:flutter_test/flutter_test.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/amount_to_words.dart';

void main() {
  group('AmountToWords.convert', () {
    test('zero', () {
      expect(AmountToWords.convert(0), 'cero soles');
    });

    test('one sol', () {
      expect(AmountToWords.convert(1), 'un sol');
    });

    test('centimos only', () {
      expect(AmountToWords.convert(0.01), 'un céntimo');
      expect(AmountToWords.convert(0.50), 'cincuenta céntimos');
    });

    test('basic amounts', () {
      expect(AmountToWords.convert(2), 'dos soles');
      expect(AmountToWords.convert(10), 'diez soles');
      expect(AmountToWords.convert(15), 'quince soles');
      expect(AmountToWords.convert(21), 'veintiún soles');
      expect(AmountToWords.convert(50), 'cincuenta soles');
    });

    test('tens with units', () {
      expect(AmountToWords.convert(31), 'treinta y un soles');
      expect(AmountToWords.convert(42), 'cuarenta y dos soles');
      expect(AmountToWords.convert(99), 'noventa y nueve soles');
    });

    test('hundreds', () {
      expect(AmountToWords.convert(100), 'cien soles');
      expect(AmountToWords.convert(101), 'ciento un soles');
      expect(AmountToWords.convert(200), 'doscientos soles');
      expect(AmountToWords.convert(500), 'quinientos soles');
    });

    test('soles with centimos', () {
      expect(
        AmountToWords.convert(120.50),
        'ciento veinte soles con cincuenta céntimos',
      );
      expect(AmountToWords.convert(1.01), 'un sol con un céntimo');
    });

    test('thousands', () {
      expect(AmountToWords.convert(1000), 'mil soles');
      expect(
        AmountToWords.convert(2350),
        'dos mil trescientos cincuenta soles',
      );
      expect(
        AmountToWords.convert(2350.50),
        'dos mil trescientos cincuenta soles con cincuenta céntimos',
      );
    });

    test('large amounts', () {
      expect(
        AmountToWords.convert(999999.99),
        'novecientos noventa y nueve mil novecientos noventa y nueve soles '
        'con noventa y nueve céntimos',
      );
    });

    test('negative throws ArgumentError', () {
      expect(() => AmountToWords.convert(-1), throwsArgumentError);
    });
  });
}
