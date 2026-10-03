import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/fraud_shield/domain/entities/trusted_person.dart';

/// Stub provider for the trusted person (replace when 006 is implemented).
final trustedPersonProvider = Provider<TrustedPerson?>(
  (ref) => const TrustedPerson(name: 'Valeria', relationship: 'Hija'),
);
