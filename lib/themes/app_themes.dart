import 'package:flutter/material.dart';
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  // Brand Colors
  static const Color primaryDark = Color(0xFF0D1B3E);
  static const Color primaryMid = Color(0xFF1A3561);
  static const Color primaryAccent = Color(0xFF2563EB);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3B82F6);

  // Light Mode Neutrals
  static const Color bgLight = Color(0xFFF4F6FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Mode
  static const Color bgDark = Color(0xFF0A0F1E);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceDark2 = Color(0xFF1F2937);
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);

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
        selectedItemColor: accentBlue,
        unselectedItemColor: textDarkSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
