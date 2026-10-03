import 'package:meta/meta.dart';

/// A saved contact the user can send money to.
@immutable
class SavedContact {
  /// Creates a saved contact.
  const SavedContact({
    required this.id,
    required this.name,
    required this.initial,
    required this.maskedAccount,
  });

  /// Unique identifier.
  final String id;

  /// Full name.
  final String name;

  /// Single-character initial for avatar.
  final String initial;

  /// Masked destination account (e.g. ****9012).
  final String maskedAccount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedContact &&
          id == other.id &&
          name == other.name &&
          initial == other.initial &&
          maskedAccount == other.maskedAccount;

  @override
  int get hashCode => Object.hash(id, name, initial, maskedAccount);
}
