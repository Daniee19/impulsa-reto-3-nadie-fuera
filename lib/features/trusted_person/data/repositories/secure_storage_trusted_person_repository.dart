import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/consent_record.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_permission.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/entities/trusted_person.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/trusted_person/domain/repositories/trusted_person_repository.dart';

/// Persists the trusted person in flutter_secure_storage as JSON.
class SecureStorageTrustedPersonRepository implements TrustedPersonRepository {
  /// Creates the repository with optional storage override (for testing).
  SecureStorageTrustedPersonRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'trusted_person_data';

  final FlutterSecureStorage _storage;
  final _controller = StreamController<TrustedPerson?>.broadcast();
  TrustedPerson? _cached;
  bool _loaded = false;

  Future<TrustedPerson?> _load() async {
    if (_loaded) return _cached;
    final raw = await _storage.read(key: _key);
    if (raw != null) {
      _cached = TrustedPerson.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    _loaded = true;
    return _cached;
  }

  Future<void> _save(TrustedPerson? person) async {
    _cached = person;
    if (person == null) {
      await _storage.delete(key: _key);
    } else {
      await _storage.write(key: _key, value: jsonEncode(person.toJson()));
    }
    _controller.add(person);
  }

  String _uuid() {
    final r = Random();
    return '${_hex(r, 8)}-${_hex(r, 4)}'
        '-4${_hex(r, 3)}-${_hex(r, 4)}'
        '-${_hex(r, 12)}';
  }

  String _hex(Random r, int length) =>
      List.generate(length, (_) => r.nextInt(16).toRadixString(16)).join();

  @override
  Future<TrustedPerson?> getTrustedPerson() => _load();

  @override
  Future<TrustedPerson> register({
    required String name,
    required String phone,
    required String relationship,
    required Set<TrustedPermission> initialPermissions,
  }) async {
    final existing = await _load();
    if (existing != null) {
      throw StateError(
        'A trusted person is already registered. '
        'Remove the current one first.',
      );
    }

    final now = DateTime.now().toUtc();
    final consent = initialPermissions
        .map(
          (p) => ConsentRecord(
            permission: p,
            action: ConsentAction.granted,
            timestamp: now,
          ),
        )
        .toList();

    final person = TrustedPerson(
      id: _uuid(),
      name: name,
      phone: phone,
      relationship: relationship,
      permissions: initialPermissions,
      consentHistory: consent,
      registeredAt: now,
    );

    await _save(person);
    return person;
  }

  @override
  Future<TrustedPerson> updatePermissions(
    Set<TrustedPermission> permissions,
  ) async {
    final person = await _load();
    if (person == null) throw StateError('No trusted person registered.');

    final now = DateTime.now().toUtc();
    final newConsent = <ConsentRecord>[...person.consentHistory];

    for (final p in TrustedPermission.values) {
      final wasActive = person.permissions.contains(p);
      final isActive = permissions.contains(p);
      if (wasActive && !isActive) {
        newConsent.add(
          ConsentRecord(
            permission: p,
            action: ConsentAction.revoked,
            timestamp: now,
          ),
        );
      } else if (!wasActive && isActive) {
        newConsent.add(
          ConsentRecord(
            permission: p,
            action: ConsentAction.granted,
            timestamp: now,
          ),
        );
      }
    }

    final updated = person.copyWith(
      permissions: permissions,
      consentHistory: newConsent,
    );
    await _save(updated);
    return updated;
  }

  @override
  Future<void> remove() async {
    final person = await _load();
    if (person == null) return;

    final now = DateTime.now().toUtc();
    for (final p in person.permissions) {
      person.consentHistory.add(
        ConsentRecord(
          permission: p,
          action: ConsentAction.revoked,
          timestamp: now,
        ),
      );
    }

    await _save(null);
  }

  @override
  Future<bool> hasPermission(TrustedPermission permission) async {
    final person = await _load();
    return person?.hasPermission(permission) ?? false;
  }

  @override
  Stream<TrustedPerson?> watchTrustedPerson() async* {
    yield await _load();
    yield* _controller.stream;
  }
}
