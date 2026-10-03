import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/saved_contact.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/contact_repository.dart';

/// Provider for the contact repository implementation.
final contactRepositoryProvider = Provider<ContactRepository>(
  (ref) => throw UnimplementedError('Override with mock or real repo'),
);

/// Provider that fetches saved contacts.
final contactsProvider = FutureProvider<List<SavedContact>>((ref) {
  return ref.watch(contactRepositoryProvider).getContacts();
});
