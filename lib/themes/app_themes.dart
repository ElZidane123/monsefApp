import 'package:flutter/material.dart';
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  // Brand Colors - Premium Fintech Palette
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryMid = Color(0xFF1E293B);
  static const Color primaryAccent = Color(0xFF3B82F6); // Electric Blue
  static const Color primaryGlow = Color(0xFF60A5FA);
  
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentAmber = Color(0xFFF59E0B);

  // Light Mode Neutrals
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Mode - Deep Space Palette
  static const Color bgDark = Color(0xFF020617);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceDark2 = Color(0xFF1E293B);
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
  
  // Glassmorphism helper
  static Color glassColor(bool isDark) => isDark 
      ? Colors.white.withOpacity(0.05) 
      : Colors.white.withOpacity(0.7);
  
  static double glassBlur = 12.0;

  // Premium Shadows
  static List<BoxShadow> premiumShadow(bool isDark) => [
    BoxShadow(
      color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static BoxDecoration glassDecoration(bool isDark) => BoxDecoration(
    color: glassColor(isDark),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
  );

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
      textTheme: GoogleFonts.dmSansTextTheme().apply(
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
      textTheme: GoogleFonts.dmSansTextTheme().apply(
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
