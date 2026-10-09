/// Granular permissions a trusted person can have.
enum TrustedPermission {
  /// Can receive security alert notifications (002-fraud-shield).
  securityAlerts,

  /// Can receive help requests with context (003-contextual-human-help).
  helpRequests,

  /// Can suggest configuration changes (006-trusted-person).
  configHelp,
}
