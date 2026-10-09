/// Converts numeric amounts to Spanish words with currency.
abstract final class AmountToWords {
  static const _units = [
    '',
    'un',
    'dos',
    'tres',
    'cuatro',
    'cinco',
    'seis',
    'siete',
    'ocho',
    'nueve',
    'diez',
    'once',
    'doce',
    'trece',
    'catorce',
    'quince',
    'dieciséis',
    'diecisiete',
    'dieciocho',
    'diecinueve',
    'veinte',
    'veintiún',
    'veintidós',
    'veintitrés',
    'veinticuatro',
    'veinticinco',
    'veintiséis',
    'veintisiete',
    'veintiocho',
    'veintinueve',
  ];

  static const _tens = [
    '',
    '',
    '',
    'treinta',
    'cuarenta',
    'cincuenta',
    'sesenta',
    'setenta',
    'ochenta',
    'noventa',
  ];

  static const _hundreds = [
    '',
    'ciento',
    'doscientos',
    'trescientos',
    'cuatrocientos',
    'quinientos',
    'seiscientos',
    'setecientos',
    'ochocientos',
    'novecientos',
  ];

  /// Converts [amount] in soles to Spanish words with currency.
  ///
  /// `120.50` → `"ciento veinte soles con cincuenta céntimos"`
  static String convert(double amount) {
    if (amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'must be non-negative');
    }

    final rounded = (amount * 100).round();
    final soles = rounded ~/ 100;
    final centimos = rounded % 100;

    if (soles == 0 && centimos == 0) return 'cero soles';

    final parts = <String>[];

    if (soles > 0) {
      parts
        ..add(_intToWords(soles))
        ..add(soles == 1 ? 'sol' : 'soles');
    }

    if (centimos > 0) {
      if (soles > 0) parts.add('con');
      parts
        ..add(_intToWords(centimos))
        ..add(centimos == 1 ? 'céntimo' : 'céntimos');
    }

    return parts.join(' ');
  }

  static String _intToWords(int n) {
    if (n == 0) return 'cero';
    if (n < 30) return _units[n];
    if (n < 100) {
      final t = n ~/ 10;
      final u = n % 10;
      return u == 0 ? _tens[t] : '${_tens[t]} y ${_units[u]}';
    }
    if (n == 100) return 'cien';
    if (n < 1000) {
      final h = n ~/ 100;
      final remainder = n % 100;
      return remainder == 0
          ? _hundreds[h]
          : '${_hundreds[h]} ${_intToWords(remainder)}';
    }
    if (n < 1000000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      final prefix = thousands == 1 ? 'mil' : '${_intToWords(thousands)} mil';
      return remainder == 0 ? prefix : '$prefix ${_intToWords(remainder)}';
    }
    return n.toString();
  }
}
