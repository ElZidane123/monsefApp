import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/dummy_data.dart';
import '../services/api_service.dart';


class AppController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserModel _user = DummyData.user;
  List<TransactionModel> _transactions = List.from(DummyData.transactions);
  List<AccountModel> _accounts = List.from(DummyData.accounts);
  List<SavingsGoalModel> _savingsGoals = List.from(DummyData.savingsGoals);
  bool _isLoading = false;

  UserModel get user => _user;
  List<TransactionModel> get transactions => _transactions;
  List<AccountModel> get accounts => _accounts;
  List<SavingsGoalModel> get savingsGoals => _savingsGoals;
  bool get isLoading => _isLoading;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getUserProfile(),
        _apiService.getTransactions(),
        _apiService.getAccounts(),
      ]);

      _user = results[0] as UserModel;
      _transactions = results[1] as List<TransactionModel>;
      _accounts = results[2] as List<AccountModel>;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing data from API: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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