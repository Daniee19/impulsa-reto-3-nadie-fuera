import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/data/repositories/mock_config_suggestion_repository.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/config_suggestion.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/repositories/config_suggestion_repository.dart';

/// Provides the ConfigSuggestionRepository implementation.
final configSuggestionRepositoryProvider = Provider<ConfigSuggestionRepository>(
  (ref) => MockConfigSuggestionRepository(),
);

/// Pending config suggestions from the trusted person.
final pendingSuggestionsProvider = FutureProvider<List<ConfigSuggestion>>((
  ref,
) {
  final repo = ref.watch(configSuggestionRepositoryProvider);
  return repo.getPendingSuggestions();
});
