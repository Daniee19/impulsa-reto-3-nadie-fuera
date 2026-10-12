import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Accessible theme: Atkinson Hyperlegible, high contrast, large text.
abstract final class AppTheme {
  static const _primary = Color(0xFF1A3C6E);
  static const _error = Color(0xFFB3261E);
  static const _surface = Color(0xFFFAFAFA);
  static const _onSurface = Color(0xFF1C1B1F);
  static const _secondary = Color(0xFF2E7D32);
  static const _surfaceContainer = Color(0xFFF0F2F5);
  static const _warmAccent = Color(0xFFE8891D);

  /// Accessible ThemeData with high contrast and large text.
  static ThemeData get theme {
    final base = GoogleFonts.atkinsonHyperlegibleTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _primary,
        onPrimary: Color(0xFFFFFFFF),
        secondary: _secondary,
        onSecondary: Color(0xFFFFFFFF),
        tertiary: _warmAccent,
        onTertiary: Color(0xFFFFFFFF),
        error: _error,
        onError: Color(0xFFFFFFFF),
        surface: _surface,
        onSurface: _onSurface,
        surfaceContainerHighest: _surfaceContainer,
      ),
      textTheme: base.copyWith(
        bodyLarge: base.bodyLarge?.copyWith(fontSize: 18),
        bodyMedium: base.bodyMedium?.copyWith(fontSize: 18),
        bodySmall: base.bodySmall?.copyWith(fontSize: 16),
        titleLarge: base.titleLarge?.copyWith(fontSize: 22),
        titleMedium: base.titleMedium?.copyWith(fontSize: 20),
        displayLarge: base.displayLarge?.copyWith(
          fontSize: 36,
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
        foregroundColor: Color(0xFFFFFFFF),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _onSurface.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Color(0xFFFFFFFF),
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _warmAccent,
        foregroundColor: Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: const TextStyle(fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }
}
