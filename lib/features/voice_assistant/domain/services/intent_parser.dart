import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/assistant_intent.dart';

/// Keyword-based intent parser. Pure Dart, deterministic, no cloud AI.
class IntentParser {
  static const _balanceKeywords = [
    'saldo',
    'cuanto tengo',
    'cuanto hay',
    'mi plata',
    'mi dinero',
    'balance',
    'ver cuenta',
    'mi cuenta',
    'disponible',
  ];

  static const _payKeywords = [
    'pagar',
    'pago',
    'pagale',
    'recibo',
    'servicio',
    'factura',
    'deuda',
    'cobro',
  ];

  static const _serviceKeywords = [
    'luz',
    'agua',
    'gas',
    'telefono',
    'internet',
    'cable',
    'electricidad',
    'enel',
    'sedapal',
    'calidda',
    'movistar',
    'claro',
    'entel',
    'bitel',
  ];

  static const _sendKeywords = [
    'enviar',
    'enviale',
    'envia',
    'mandar',
    'mandale',
    'manda',
    'transferir',
    'transfiere',
    'transferencia',
    'depositar',
    'deposita',
    'pasale',
    'pasarle',
  ];

  static const _helpKeywords = [
    'ayuda',
    'ayudame',
    'no se',
    'no entiendo',
    'hablar con alguien',
    'persona',
    'asesor',
  ];

  static const _numberWords = {
    'uno': 1.0,
    'dos': 2.0,
    'tres': 3.0,
    'cuatro': 4.0,
    'cinco': 5.0,
    'seis': 6.0,
    'siete': 7.0,
    'ocho': 8.0,
    'nueve': 9.0,
    'diez': 10.0,
    'quince': 15.0,
    'veinte': 20.0,
    'veinticinco': 25.0,
    'treinta': 30.0,
    'cuarenta': 40.0,
    'cincuenta': 50.0,
    'sesenta': 60.0,
    'setenta': 70.0,
    'ochenta': 80.0,
    'noventa': 90.0,
    'cien': 100.0,
    'doscientos': 200.0,
    'trescientos': 300.0,
    'quinientos': 500.0,
    'mil': 1000.0,
  };

  // Noise words to strip when matching services/contacts
  static const _noiseWords = [
    'el',
    'la',
    'los',
    'las',
    'del',
    'de',
    'mi',
    'un',
    'una',
    'recibo',
    'servicio',
    'pago',
    'factura',
    'quiero',
    'quisiera',
    'por favor',
    'pagar',
    'ese',
    'esa',
    'este',
    'esta',
  ];

  static final _amountRegex = RegExp(
    r'(\d+[\.,]?\d*)\s*(?:soles?|sol|lucas|pe)?',
  );
  static final _standaloneNumberRegex = RegExp(r'\b(\d+[\.,]?\d*)\b');

  /// Parses user input into a [ParsedIntent]. Never null, never throws.
  ParsedIntent parse(String input) {
    if (input.trim().isEmpty) {
      return const ParsedIntent(type: AssistantIntentType.unknown);
    }

    final normalized = _normalize(input);

    if (_matchesAny(normalized, _helpKeywords)) {
      return const ParsedIntent(
        type: AssistantIntentType.requestHelp,
      );
    }

    if (_matchesAny(normalized, _balanceKeywords)) {
      return const ParsedIntent(
        type: AssistantIntentType.checkBalance,
      );
    }

    if (_matchesAny(normalized, _payKeywords) ||
        _matchesAny(normalized, _serviceKeywords)) {
      return ParsedIntent(
        type: AssistantIntentType.payBill,
        parameters: IntentParameters(
          serviceName: _extractService(normalized),
        ),
      );
    }

    if (_matchesAny(normalized, _sendKeywords)) {
      return ParsedIntent(
        type: AssistantIntentType.sendMoney,
        parameters: IntentParameters(
          contactName: _extractContact(normalized),
          amount: extractAmount(normalized),
        ),
      );
    }

    return const ParsedIntent(type: AssistantIntentType.unknown);
  }

  /// Extracts a service name from free text, stripping noise.
  String? extractService(String input) {
    final normalized = _normalize(input);
    final found = _extractService(normalized);
    if (found != null) return found;

    // Strip noise and try to match what remains
    final cleaned = _stripNoise(normalized);
    if (cleaned.isNotEmpty) {
      for (final service in _serviceKeywords) {
        if (cleaned.contains(service)) return service;
      }
      // Return cleaned text as-is for fuzzy matching in preparer
      return cleaned;
    }
    return null;
  }

  /// Extracts a contact name from free text, stripping noise.
  String? extractContact(String input) {
    final normalized = _normalize(input);

    // Try structured extraction first
    final structured = _extractContact(normalized);
    if (structured != null) return structured;

    // Strip noise and prepositions
    var cleaned = normalized;
    for (final word in ['a ', 'para ', 'la ', 'el ']) {
      if (cleaned.startsWith(word)) {
        cleaned = cleaned.substring(word.length);
      }
    }
    cleaned = cleaned.trim();
    if (cleaned.isNotEmpty) return cleaned;
    return null;
  }

  /// Extracts a numeric amount from text (digits or words).
  double? extractAmount(String text) {
    final normalized = _normalize(text);

    // Try digit-based patterns first
    final solesMatch = _amountRegex.firstMatch(normalized);
    if (solesMatch != null) {
      final value = double.tryParse(
        solesMatch.group(1)!.replaceAll(',', '.'),
      );
      if (value != null && value > 0) return value;
    }

    final numberMatch =
        _standaloneNumberRegex.firstMatch(normalized);
    if (numberMatch != null) {
      final value = double.tryParse(
        numberMatch.group(1)!.replaceAll(',', '.'),
      );
      if (value != null && value > 0) return value;
    }

    // Try word-based numbers
    for (final entry in _numberWords.entries) {
      if (normalized.contains(entry.key)) return entry.value;
    }

    return null;
  }

  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  String? _extractService(String text) {
    for (final service in _serviceKeywords) {
      if (text.contains(service)) return service;
    }
    return null;
  }

  String _stripNoise(String text) {
    var result = text;
    for (final word in _noiseWords) {
      result = result.replaceAll(RegExp('\\b$word\\b'), '');
    }
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static const _accentMap = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };

  String _normalize(String text) {
    return _removeAccents(text.toLowerCase().trim());
  }

  String _removeAccents(String text) {
    return text.replaceAllMapped(
      RegExp('[áéíóúüñ]'),
      (m) => _accentMap[m.group(0)!] ?? m.group(0)!,
    );
  }

  String? _extractContact(String text) {
    for (final keyword in _sendKeywords) {
      final idx = text.indexOf(keyword);
      if (idx < 0) continue;
      var rest = text.substring(idx + keyword.length).trim();
      rest = rest.replaceAll(_amountRegex, '').trim();
      rest =
          rest.replaceAll(_standaloneNumberRegex, '').trim();
      if (rest.startsWith('a ')) {
        rest = rest.substring(2).trim();
      }
      if (rest.startsWith('para ')) {
        rest = rest.substring(5).trim();
      }
      if (rest.isNotEmpty) return rest;
    }
    return null;
  }
}
