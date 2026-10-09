import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/config_suggestion.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/repositories/config_suggestion_repository.dart';

/// In-memory mock implementation of ConfigSuggestionRepository.
class MockConfigSuggestionRepository implements ConfigSuggestionRepository {
  final _suggestions = <ConfigSuggestion>[
    ConfigSuggestion(
      id: 'suggestion-1',
      type: ConfigSuggestionType.fontSize,
      description: 'Hacer la letra más grande',
      suggestedValue: 'large',
      status: ConfigSuggestionStatus.pending,
      createdAt: DateTime.now().toUtc(),
    ),
  ];

  int _nextId = 2;

  @override
  Future<List<ConfigSuggestion>> getPendingSuggestions() async {
    return _suggestions
        .where((s) => s.status == ConfigSuggestionStatus.pending)
        .toList();
  }

  @override
  Future<ConfigSuggestion> accept(String suggestionId) async {
    final index = _suggestions.indexWhere((s) => s.id == suggestionId);
    if (index == -1) throw StateError('Suggestion not found: $suggestionId');

    final updated = _suggestions[index].copyWith(
      status: ConfigSuggestionStatus.accepted,
      resolvedAt: DateTime.now().toUtc(),
    );
    _suggestions[index] = updated;
    return updated;
  }

  @override
  Future<ConfigSuggestion> reject(String suggestionId) async {
    final index = _suggestions.indexWhere((s) => s.id == suggestionId);
    if (index == -1) throw StateError('Suggestion not found: $suggestionId');

    final updated = _suggestions[index].copyWith(
      status: ConfigSuggestionStatus.rejected,
      resolvedAt: DateTime.now().toUtc(),
    );
    _suggestions[index] = updated;
    return updated;
  }

  @override
  Future<ConfigSuggestion> createSimulated({
    required ConfigSuggestionType type,
    required String description,
    String? suggestedValue,
  }) async {
    final suggestion = ConfigSuggestion(
      id: 'suggestion-${_nextId++}',
      type: type,
      description: description,
      suggestedValue: suggestedValue,
      status: ConfigSuggestionStatus.pending,
      createdAt: DateTime.now().toUtc(),
    );
    _suggestions.add(suggestion);
    return suggestion;
  }
}
