import 'package:flutter/material.dart';

/// Returns a practice-mode theme based on [base] with green accents.
ThemeData practiceTheme(ThemeData base) {
  const green = Color(0xFF2E7D32);
  const greenLight = Color(0xFFC8E6C9);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: green,
      primaryContainer: greenLight,
    ),
    appBarTheme: base.appBarTheme.copyWith(backgroundColor: green),
  );
}
