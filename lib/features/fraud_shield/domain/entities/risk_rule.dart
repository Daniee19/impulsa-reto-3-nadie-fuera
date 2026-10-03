/// Types of risk that the fraud shield evaluates.
enum RiskRule {
  /// Amount significantly higher than the user's average.
  unusualAmount,

  /// Recipient has no prior transaction history.
  newRecipient,

  /// Too many operations in a short time window.
  highFrequency,

  /// Operation outside the user's normal hours.
  unusualTime,
}
