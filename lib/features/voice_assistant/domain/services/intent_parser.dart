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
    'cuenta',
  ];

  static const _payKeywords = ['pagar', 'recibo', 'servicio'];

  static const _serviceKeywords = [
    'luz',
    'agua',
    'gas',
    'telefono',
    'internet',
    'cable',
    'electricidad',
  ];

  static const _sendKeywords = [
    'enviar',
    'mandar',
    'transferir',
    'envia',
    'manda',
    'transfiere',
  ];

  static const _helpKeywords = [
    'ayuda',
    'ayudame',
    'no se',
    'no entiendo',
    'hablar con alguien',
    'persona',
  ];

  static final _amountRegex = RegExp(r'(\d+[\.,]?\d*)\s*soles?');
  static final _standaloneNumberRegex = RegExp(r'\b(\d+[\.,]?\d*)\b');

  /// Parses user input into a [ParsedIntent]. Never null, never throws.
  ParsedIntent parse(String input) {
    if (input.trim().isEmpty) {
      return const ParsedIntent(type: AssistantIntentType.unknown);
    }

    final normalized = _removeAccents(input.toLowerCase().trim());

    if (_matchesAny(normalized, _helpKeywords)) {
      return const ParsedIntent(type: AssistantIntentType.requestHelp);
    }

    if (_matchesAny(normalized, _balanceKeywords)) {
      return const ParsedIntent(type: AssistantIntentType.checkBalance);
    }

    if (_matchesAny(normalized, _payKeywords)) {
      return ParsedIntent(
        type: AssistantIntentType.payBill,
        parameters: IntentParameters(serviceName: _extractService(normalized)),
      );
    }

    if (_matchesAny(normalized, _sendKeywords)) {
      return ParsedIntent(
        type: AssistantIntentType.sendMoney,
        parameters: IntentParameters(
          contactName: _extractContact(normalized),
          amount: _extractAmount(normalized),
        ),
      );
    }

    return const ParsedIntent(type: AssistantIntentType.unknown);
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

  double? _extractAmount(String text) {
    final solesMatch = _amountRegex.firstMatch(text);
    if (solesMatch != null) {
      return double.tryParse(solesMatch.group(1)!.replaceAll(',', '.'));
    }
    final numberMatch = _standaloneNumberRegex.firstMatch(text);
    if (numberMatch != null) {
      final value = double.tryParse(numberMatch.group(1)!.replaceAll(',', '.'));
      if (value != null && value > 0) return value;
    }
    return null;
  }

  static const _accentMap = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
  };

  String _removeAccents(String text) {
    return text.replaceAllMapped(
      RegExp('[áéíóúü]'),
      (m) => _accentMap[m.group(0)!] ?? m.group(0)!,
    );
  }

  String? _extractContact(String text) {
    for (final keyword in _sendKeywords) {
      final idx = text.indexOf(keyword);
      if (idx < 0) continue;
      var rest = text.substring(idx + keyword.length).trim();
      // Remove amount patterns
      rest = rest.replaceAll(_amountRegex, '').trim();
      rest = rest.replaceAll(_standaloneNumberRegex, '').trim();
      // Remove preposition "a" at start
      if (rest.startsWith('a ')) rest = rest.substring(2).trim();
      if (rest.isNotEmpty) return rest;
    }
    return null;
  }
}
