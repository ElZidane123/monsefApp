import 'package:flutter/material.dart';
import '../screen/home_screen.dart';
import '../screen/transaction_history_screen.dart';
import '../screen/wealth_investment_screen.dart';
import '../screen/transfer_screen.dart';
import '../screen/transfer_confirm_screen.dart';
import '../screen/qr_scanner_screen.dart';
import '../screen/qr_show_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String investment = '/investment';
  static const String transfer = '/transfer';
  static const String transferConfirm = '/transfer/confirm';
  static const String qrScan = '/qr/scan';
  static const String qrShow = '/qr/show';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
      case dashboard:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case history:
        return MaterialPageRoute(
            builder: (_) => const TransactionHistoryScreen());
      case investment:
        return MaterialPageRoute(
            builder: (_) => const WealthInvestmentScreen());
      case transfer:
        return MaterialPageRoute(builder: (_) => const TransferScreen());
      case transferConfirm:
        return MaterialPageRoute(
            builder: (_) => const TransferConfirmScreen());
      case qrScan:
        return MaterialPageRoute(builder: (_) => const QRScannerScreen());
      case qrShow:
        return MaterialPageRoute(builder: (_) => const QRShowScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}