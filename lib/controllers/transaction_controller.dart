import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class TransactionController extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _apiService.getTransactions();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching transactions: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Example of adding a transaction via API
  Future<bool> addTransaction(TransactionModel tx) async {
    // In a real app, you would call _apiService.postTransaction(tx)
    // For now, we update local state
    _transactions = [tx, ..._transactions];
    notifyListeners();
    return true;
  }
}
