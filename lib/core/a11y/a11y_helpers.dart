import 'dart:ui';

import 'package:flutter/semantics.dart';

/// Accessibility constants and helpers.
abstract final class A11yHelpers {
  /// Minimum tap target size in dp (WCAG 2.2 AA).
  static const double minTapTarget = 48;

  /// Minimum separation between interactive elements in dp.
  static const double minSeparation = 8;

  /// Announces a message for screen readers.
  static Future<void> announceForAccessibility(
    FlutterView view,
    String message,
  ) {
    return SemanticsService.sendAnnouncement(
      view,
      message,
      TextDirection.ltr,
    );
  }
}
