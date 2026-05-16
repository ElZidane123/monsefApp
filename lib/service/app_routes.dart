import 'package:flutter/material.dart';
import '../screen/home_screen.dart';
import '../screen/transaction_history_screen.dart';
import '../screen/qr_scanner_screen.dart';
import '../screen/manual_entry_screen.dart';
import '../screen/voice_note_screen.dart';
import '../screen/profile_screen.dart';
import '../screen/splash_screen.dart';
import '../screen/login_screen.dart';
import '../screen/register_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String qrScan = '/qr/scan';
  static const String manualEntry = '/manual';
  static const String voiceNote = '/voice';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
      case dashboard:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case history:
        return MaterialPageRoute(
            builder: (_) => const TransactionHistoryScreen());
      case qrScan:
        return MaterialPageRoute(builder: (_) => const QRScannerScreen());
      case manualEntry:
        return MaterialPageRoute(builder: (_) => const ManualEntryScreen());
      case voiceNote:
        return MaterialPageRoute(builder: (_) => const VoiceNoteScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}