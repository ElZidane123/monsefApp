import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/dummy_data.dart';

class AppProvider extends ChangeNotifier {
  UserModel _user = DummyData.user;
  List<TransactionModel> _transactions = List.from(DummyData.transactions);
  List<AccountModel> _accounts = List.from(DummyData.accounts);
  bool _isLoading = false;

  UserModel get user => _user;
  List<TransactionModel> get transactions => _transactions;
  List<AccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;

  Future<bool> addTransaction(TransactionModel tx) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    _transactions = [tx, ..._transactions];
    
    // Update balance
    double newBalance = _user.totalBalance;
    if (tx.isExpense) {
      newBalance -= tx.amount;
    } else {
      newBalance += tx.amount;
    }

    _user = UserModel(
      name: _user.name,
      greeting: _user.greeting,
      avatarInitials: _user.avatarInitials,
      totalBalance: newBalance,
      monthlyGrowth: _user.monthlyGrowth,
      notificationCount: _user.notificationCount,
    );
    
    _isLoading = false;
    notifyListeners();
    return true;
  }
}