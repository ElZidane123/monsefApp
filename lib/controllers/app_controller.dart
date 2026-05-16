import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppController extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ─── State ───────────────────────────────────────────────────────────────
  UserModel? _user;
  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];
  List<SavingsGoalModel> _savingsGoals = [];
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ─────────────────────────────────────────────────────────────
  UserModel? get user => _user;
  List<TransactionModel> get transactions => _transactions;
  List<AccountModel> get accounts => _accounts;
  List<SavingsGoalModel> get savingsGoals => _savingsGoals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isLoggedIn => _isLoggedIn;

  // ─── AUTHENTICATION ──────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await _api.login(email, password);
      _isLoggedIn = true;
      await _loadDashboardData();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase();
      final data = {
        "id": "user_${DateTime.now().millisecondsSinceEpoch}",
        "name": name,
        "email": email,
        "password": password,
        "greeting": "Halo",
        "avatarInitials": initials,
        "totalBalance": 0.0,
        "monthlyGrowth": 0.0,
        "notificationCount": 0
      };
      _user = await _api.register(data);
      _isLoggedIn = true;
      await _loadDashboardData();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _isLoggedIn = false;
    _user = null;
    _transactions = [];
    _accounts = [];
    _savingsGoals = [];
    notifyListeners();
  }

  // ─── Init / Refresh ──────────────────────────────────────────────────────
  Future<void> initializeData() async {
    if (!_isLoggedIn) return;
    _setLoading(true);
    _errorMessage = null;
    try {
      // Refresh profile data as well if needed
      _user = await _api.getUserProfile();
      await _loadDashboardData();
    } catch (e) {
      _errorMessage = _friendlyError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadDashboardData() async {
    final results = await Future.wait([
      _api.getTransactions(),
      _api.getAccounts(),
      _api.getSavingsGoals(),
    ]);
    _transactions = results[0] as List<TransactionModel>;
    _accounts = results[1] as List<AccountModel>;
    _savingsGoals = results[2] as List<SavingsGoalModel>;
    _recalcBalance();
  }

  // ─── PROFILE CRUD ────────────────────────────────────────────────────────
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updated = await _api.updateProfile(data);
      _user = UserModel(
        name: updated.name,
        greeting: updated.greeting,
        avatarInitials: updated.avatarInitials,
        totalBalance: _user?.totalBalance ?? updated.totalBalance, // keep local calculated balance
        monthlyGrowth: updated.monthlyGrowth,
        notificationCount: updated.notificationCount,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshData() => initializeData();

  // ─── TRANSACTION CRUD ─────────────────────────────────────────────────────

  Future<bool> addTransaction(TransactionModel tx) async {
    _setLoading(true);
    try {
      await _api.createTransaction(tx.toJson());
      _transactions = [tx, ..._transactions];
      if (tx.accountId != null) {
        _updateAccountBalance(tx.accountId!, tx.amount, tx.isExpense);
      }
      _recalcBalance();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      if (kDebugMode) print('[AppController] addTransaction error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTransaction(String id, TransactionModel tx) async {
    _setLoading(true);
    try {
      final oldTx = _transactions.firstWhere((t) => t.id == id);
      await _api.updateTransaction(id, tx.toJson());
      _transactions = _transactions
          .map((t) => t.id == id ? tx : t)
          .toList();
          
      if (oldTx.accountId != null) {
        _updateAccountBalance(oldTx.accountId!, oldTx.amount, !oldTx.isExpense);
      }
      if (tx.accountId != null) {
        _updateAccountBalance(tx.accountId!, tx.amount, tx.isExpense);
      }
      
      _recalcBalance();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      if (kDebugMode) print('[AppController] updateTransaction error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction(String id) async {
    _setLoading(true);
    try {
      final oldTx = _transactions.firstWhere((t) => t.id == id);
      await _api.deleteTransaction(id);
      _transactions = _transactions.where((t) => t.id != id).toList();
      if (oldTx.accountId != null) {
        _updateAccountBalance(oldTx.accountId!, oldTx.amount, !oldTx.isExpense);
      }
      _recalcBalance();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      if (kDebugMode) print('[AppController] deleteTransaction error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── ACCOUNT CRUD ─────────────────────────────────────────────────────────

  Future<bool> addAccount(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _api.createAccount(data);
      final newAccount = AccountModel.fromJson(data);
      _accounts = [..._accounts, newAccount];
      _recalcBalance();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount(String id) async {
    _setLoading(true);
    try {
      await _api.deleteAccount(id);
      _accounts = _accounts.where((a) => a.id != id).toList();
      _recalcBalance();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── SAVINGS GOAL CRUD ────────────────────────────────────────────────────

  Future<bool> addSavingsGoal(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      await _api.createSavingsGoal(data);
      final newGoal = SavingsGoalModel.fromJson(data);
      _savingsGoals = [..._savingsGoals, newGoal];
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateSavingsGoal(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updated = await _api.updateSavingsGoal(id, data);
      _savingsGoals = _savingsGoals
          .map((g) => g.id == id ? updated : g)
          .toList();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteSavingsGoal(String id) async {
    _setLoading(true);
    try {
      await _api.deleteSavingsGoal(id);
      _savingsGoals = _savingsGoals.where((g) => g.id != id).toList();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  /// Helper to locally update account balance and push to API
  void _updateAccountBalance(String accountId, double amount, bool isExpense) {
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx != -1) {
      final acc = _accounts[idx];
      final newBalance = isExpense ? acc.balance - amount : acc.balance + amount;
      final updatedAcc = AccountModel(
        id: acc.id,
        name: acc.name,
        type: acc.type,
        balance: newBalance,
        lastFourDigits: acc.lastFourDigits,
      );
      _accounts[idx] = updatedAcc;
      // Update asynchronously to Mockoon
      _api.updateAccount(accountId, updatedAcc.toJson()).catchError((_) => updatedAcc);
    }
  }

  /// Recalculate totalBalance by summing up all account balances
  void _recalcBalance() {
    if (_user == null) return;
    double total = 0;
    for (final acc in _accounts) {
      total += acc.balance;
    }
    // Update totalBalance in user model
    _user = UserModel(
      name: _user!.name,
      greeting: _user!.greeting,
      avatarInitials: _user!.avatarInitials,
      totalBalance: total,
      monthlyGrowth: _user!.monthlyGrowth,
      notificationCount: _user!.notificationCount,
    );
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Tidak dapat terhubung ke server.\nPastikan Mockoon sudah berjalan.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }
    if (msg.contains('ApiException')) {
      return msg.replaceAll('ApiException', '').trim();
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}