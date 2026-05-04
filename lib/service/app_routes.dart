import 'package:flutter/material.dart';
import '../screen/home_screen.dart';
import '../screen/transaction_history_screen.dart';
import '../screen/qr_scanner_screen.dart';
import '../screen/manual_entry_screen.dart';
import '../screen/voice_note_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String qrScan = '/qr/scan';
  static const String manualEntry = '/manual';
  static const String voiceNote = '/voice';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
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