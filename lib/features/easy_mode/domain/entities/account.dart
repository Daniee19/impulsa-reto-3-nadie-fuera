import 'package:meta/meta.dart';

/// User bank account with simulated data.
@immutable
class Account {
  /// Creates an account.
  const Account({
    required this.id,
    required this.holderName,
    required this.maskedNumber,
    required this.availableBalance,
    this.currency = 'PEN',
  });

  /// Unique identifier.
  final String id;

  /// Account holder's name.
  final String holderName;

  /// Masked account number (e.g. ****1234).
  final String maskedNumber;

  /// Available balance in soles.
  final double availableBalance;

  /// Currency code.
  final String currency;

  /// Returns a copy with the given fields replaced.
  Account copyWith({
    String? id,
    String? holderName,
    String? maskedNumber,
    double? availableBalance,
    String? currency,
  }) {
    return Account(
      id: id ?? this.id,
      holderName: holderName ?? this.holderName,
      maskedNumber: maskedNumber ?? this.maskedNumber,
      availableBalance: availableBalance ?? this.availableBalance,
      currency: currency ?? this.currency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          id == other.id &&
          holderName == other.holderName &&
          maskedNumber == other.maskedNumber &&
          availableBalance == other.availableBalance &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(
        id,
        holderName,
        maskedNumber,
        availableBalance,
        currency,
      );
}
