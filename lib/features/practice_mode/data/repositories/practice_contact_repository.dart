import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/saved_contact.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/contact_repository.dart';

class PracticeContactRepository implements ContactRepository {
  static const _contacts = [
    SavedContact(
      id: 'p-contact-1',
      name: 'Ana García',
      initial: 'A',
      maskedAccount: '****1111',
    ),
    SavedContact(
      id: 'p-contact-2',
      name: 'Pedro Ruiz',
      initial: 'P',
      maskedAccount: '****2222',
    ),
    SavedContact(
      id: 'p-contact-3',
      name: 'Lucía Torres',
      initial: 'L',
      maskedAccount: '****3333',
    ),
  ];

  @override
  Future<List<SavedContact>> getContacts() async => _contacts;

  @override
  Future<SavedContact> getContactById(String contactId) async {
    return _contacts.firstWhere((c) => c.id == contactId);
  }
}
