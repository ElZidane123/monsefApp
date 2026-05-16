import 'package:flutter/material.dart';
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  // ─── Core Palette: Clean, Restrained, Elegant ─────────────────────────────
  // One accent. Two neutrals. That's it.
  static const Color accent     = Color(0xFF1A56DB); // Clean navy-blue
  static const Color accentSoft = Color(0xFFEEF2FF); // Very light tint

  static const Color income  = Color(0xFF15803D); // Forest green
  static const Color expense = Color(0xFFB91C1C); // Muted red

  // Light mode
  static const Color bgLight       = Color(0xFFF5F7FA);
  static const Color surfaceLight  = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF0D1526);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted     = Color(0xFFAFBACE);
  static const Color borderLight   = Color(0xFFE8EDF5);

  // Dark mode
  static const Color bgDark        = Color(0xFF0B0F19);
  static const Color surfaceDark   = Color(0xFF131927);
  static const Color surfaceDark2  = Color(0xFF1C2537);
  static const Color textDarkPrimary   = Color(0xFFEFF3FB);
  static const Color textDarkSecondary = Color(0xFF6B7FA0);

  // Legacy aliases so existing code doesn't break
  static const Color primaryAccent  = accent;
  static const Color primaryDark    = Color(0xFF0D1526);
  static const Color primaryMid     = Color(0xFF1C2537);
  static const Color primaryGlow    = Color(0xFF3B6FE8);
  static const Color accentGreen    = income;
  static const Color accentRose     = expense;
  static const Color accentAmber    = Color(0xFFB45309);
  static const Color accentPurple   = Color(0xFF6D28D9);

  // ─── The ONE gradient: balance card only ──────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF1A56DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Kept for compat but not used on small UI elements
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF166534), Color(0xFF15803D)],
  );
  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFF991B1B), Color(0xFFB91C1C)],
  );

  // ─── Shadows: barely-there ────────────────────────────────────────────────
  static List<BoxShadow> softShadow(bool isDark) => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.25 : 0.055),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> premiumShadow(bool isDark) => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.45 : 0.09),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  // ─── Surface decoration ───────────────────────────────────────────────────
  static BoxDecoration cardDecoration(bool isDark) => BoxDecoration(
    color: isDark ? surfaceDark : surfaceLight,
    borderRadius: BorderRadius.circular(20),
    boxShadow: softShadow(isDark),
  );

  static Color glassColor(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.7);
  static double glassBlur = 12.0;
  static BoxDecoration glassDecoration(bool isDark) => BoxDecoration(
    color: glassColor(isDark),
    borderRadius: BorderRadius.circular(20),
  );

  // ─── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData lightTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      background: bgLight,
      surface: surfaceLight,
      primary: accent,
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
  );

  static ThemeData darkTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      background: bgDark,
      surface: surfaceDark,
      primary: accent,
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
  );
}
