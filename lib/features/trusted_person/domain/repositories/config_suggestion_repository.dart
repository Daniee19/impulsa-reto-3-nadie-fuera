import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/config_suggestion.dart';

/// Repository for managing configuration suggestions from the trusted person.
abstract class ConfigSuggestionRepository {
  /// Returns all pending suggestions.
  Future<List<ConfigSuggestion>> getPendingSuggestions();

  /// Accepts a suggestion and returns the updated record.
  Future<ConfigSuggestion> accept(String suggestionId);

  /// Rejects a suggestion silently (familiar is not notified).
  Future<ConfigSuggestion> reject(String suggestionId);

  /// Creates a simulated suggestion for demo/debug.
  Future<ConfigSuggestion> createSimulated({
    required ConfigSuggestionType type,
    required String description,
    String? suggestedValue,
  });
}
