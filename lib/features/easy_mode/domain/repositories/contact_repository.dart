import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/saved_contact.dart';

/// Contract for saved-contact data access (read-only in this feature).
abstract class ContactRepository {
  /// Returns all saved contacts.
  Future<List<SavedContact>> getContacts();

  /// Returns a single contact by [contactId].
  Future<SavedContact> getContactById(String contactId);
}
