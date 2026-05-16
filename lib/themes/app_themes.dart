import 'package:flutter/material.dart';
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  // ─── Brand Palette ────────────────────────────────────────────────────────
  // Primary: Deep Midnight Navy
  static const Color primaryDark  = Color(0xFF0A0F1E);
  static const Color primaryMid   = Color(0xFF111827);
  static const Color primaryAccent = Color(0xFF4F6EF7); // Indigo-Electric
  static const Color primaryGlow  = Color(0xFF818CF8);  // Soft Lavender

  // Semantic
  static const Color accentGreen  = Color(0xFF00D4AA); // Emerald Teal
  static const Color accentRose   = Color(0xFFFF4D6D); // Vivid Coral-Rose
  static const Color accentAmber  = Color(0xFFFFC542); // Warm Amber
  static const Color accentPurple = Color(0xFF9B59F4); // Soft Violet

  // Light Mode
  static const Color bgLight      = Color(0xFFF0F4FF); // Cool blue-white
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimary  = Color(0xFF0A0F1E);
  static const Color textSecondary = Color(0xFF4B5775);
  static const Color textMuted    = Color(0xFF9AA5BE);
  static const Color borderLight  = Color(0xFFDDE4F5);

  // Dark Mode
  static const Color bgDark       = Color(0xFF060B18);
  static const Color surfaceDark  = Color(0xFF0F1629);
  static const Color surfaceDark2 = Color(0xFF1A2340);
  static const Color textDarkPrimary   = Color(0xFFF0F4FF);
  static const Color textDarkSecondary = Color(0xFF7A8BAD);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F6EF7), Color(0xFF9B59F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00A86B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFFFF8C66)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2D5A), Color(0xFF0F1629)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Glassmorphism ────────────────────────────────────────────────────────
  static Color glassColor(bool isDark) => isDark
      ? Colors.white.withOpacity(0.05)
      : Colors.white.withOpacity(0.75);

  static double glassBlur = 16.0;

  static BoxDecoration glassDecoration(bool isDark) => BoxDecoration(
    color: glassColor(isDark),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.white.withOpacity(0.6),
      width: 1,
    ),
  );

  // ─── Shadows ──────────────────────────────────────────────────────────────
  static List<BoxShadow> premiumShadow(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withOpacity(0.5)
          : const Color(0xFF4F6EF7).withOpacity(0.12),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> softShadow(bool isDark) => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ─── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        brightness: Brightness.light,
        background: bgLight,
        surface: surfaceLight,
        primary: primaryAccent,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surfaceLight,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryAccent,
        unselectedItemColor: textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryAccent,
        brightness: Brightness.dark,
        background: bgDark,
        surface: surfaceDark,
        primary: primaryAccent,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textDarkPrimary,
        displayColor: textDarkPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surfaceDark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryAccent,
        unselectedItemColor: textDarkSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
