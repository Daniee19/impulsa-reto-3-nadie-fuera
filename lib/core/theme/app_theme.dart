import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Accessible theme: Atkinson Hyperlegible, high contrast, large text.
abstract final class AppTheme {
  static const _primary = Color(0xFF1A3C6E);
  static const _error = Color(0xFFB3261E);
  static const _surface = Color(0xFFFFFFFF);
  static const _onSurface = Color(0xFF1C1B1F);
  static const _secondary = Color(0xFF2E7D32);

  /// Accessible ThemeData with high contrast and large text.
  static ThemeData get theme {
    final base = GoogleFonts.atkinsonHyperlegibleTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _primary,
        onPrimary: _surface,
        secondary: _secondary,
        onSecondary: _surface,
        error: _error,
        onError: _surface,
        surface: _surface,
        onSurface: _onSurface,
      ),
      textTheme: base.copyWith(
        bodyLarge: base.bodyLarge?.copyWith(fontSize: 18),
        bodyMedium: base.bodyMedium?.copyWith(fontSize: 18),
        bodySmall: base.bodySmall?.copyWith(fontSize: 16),
        titleLarge: base.titleLarge?.copyWith(fontSize: 22),
        titleMedium: base.titleMedium?.copyWith(fontSize: 20),
        displayLarge: base.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: base.displayMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      scaffoldBackgroundColor: _surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: _primary,
        foregroundColor: _surface,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _surface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _surface,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}
