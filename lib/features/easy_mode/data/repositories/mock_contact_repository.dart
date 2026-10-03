import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/entities/saved_contact.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/easy_mode/domain/repositories/contact_repository.dart';

/// In-memory mock of [ContactRepository] with simulated latency.
class MockContactRepository implements ContactRepository {
  final _contacts = const [
    SavedContact(
      id: 'contact-001',
      name: 'Valeria Martínez',
      initial: 'V',
      maskedAccount: '****9012',
    ),
    SavedContact(
      id: 'contact-002',
      name: 'Carlos López',
      initial: 'C',
      maskedAccount: '****3456',
    ),
    SavedContact(
      id: 'contact-003',
      name: 'María Sánchez',
      initial: 'M',
      maskedAccount: '****7890',
    ),
  ];

  @override
  Future<List<SavedContact>> getContacts() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _contacts;
  }

  @override
  Future<SavedContact> getContactById(String contactId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => throw StateError('Contact $contactId not found'),
    );
  }
}
