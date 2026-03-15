// ============================================================
// app_theme.dart — Centralized dark-blue theme
// ============================================================

import 'package:flutter/material.dart';

class AppTheme {
  // ---- Brand Colors ----
  static const Color background    = Color(0xFF0A1628); // Deep navy
  static const Color surface       = Color(0xFF0F2040); // Dark blue surface
  static const Color surfaceAlt    = Color(0xFF152A52); // Card background
  static const Color accent        = Color(0xFF2563EB); // Vivid blue
  static const Color accentLight   = Color(0xFF3B82F6); // Lighter blue
  static const Color accentGlow    = Color(0xFF1D4ED8); // Glow blue
  static const Color border        = Color(0xFF1E3A6E); // Subtle border
  static const Color textPrimary   = Color(0xFFE2E8F0); // Near white
  static const Color textSecondary = Color(0xFF94A3B8); // Muted
  static const Color passGreen     = Color(0xFF10B981); // Pass
  static const Color failRed       = Color(0xFFEF4444); // Fail
  static const Color gradeGold     = Color(0xFFF59E0B); // Highlight
  static const Color divider       = Color(0xFF1E3A6E);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentLight,
          surface: surface,
          onPrimary: Colors.white,
          onSurface: textPrimary,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
        ),
        cardTheme: CardThemeData(
          color: surfaceAlt,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
        dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      );
}
