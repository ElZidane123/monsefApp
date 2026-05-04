import 'package:flutter/material.dart';
import '../screen/home_screen.dart';
import '../screen/transaction_history_screen.dart';
import '../screen/wealth_investment_screen.dart';
import '../screen/transfer_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String investment = '/investment';
  static const String transfer = '/transfer';

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
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}