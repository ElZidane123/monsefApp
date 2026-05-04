import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/dummy_data.dart';

class AppProvider extends ChangeNotifier {
  UserModel _user = DummyData.user;
  List<TransactionModel> _transactions = List.from(DummyData.transactions);
  List<AccountModel> _accounts = List.from(DummyData.accounts);
  TransferData _transferData = const TransferData();
  bool _isLoading = false;

  UserModel get user => _user;
  List<TransactionModel> get transactions => _transactions;
  List<AccountModel> get accounts => _accounts;
  TransferData get transferData => _transferData;
  bool get isLoading => _isLoading;

  void setTransferFrom(AccountModel account) {
    _transferData = _transferData.copyWith(fromAccount: account);
    notifyListeners();
  }

  void setTransferTo(String name) {
    _transferData = _transferData.copyWith(toName: name);
    notifyListeners();
  }

  void setTransferAmount(double amount) {
    _transferData = _transferData.copyWith(amount: amount, fee: amount > 1000 ? 0 : 0);
    notifyListeners();
  }

  void resetTransfer() {
    _transferData = const TransferData();
    notifyListeners();
  }

  Future<bool> confirmTransfer() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1800));
    // Add transaction to list
    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Transfer to ${_transferData.toName ?? 'Account'}',
      category: 'Transfer',
      amount: _transferData.amount,
      isExpense: true,
      date: DateTime.now(),
      iconEmoji: '💸',
      status: TransactionStatus.completed,
    );
    _transactions = [newTx, ..._transactions];
    // Deduct from balance
    _user = UserModel(
      name: _user.name,
      greeting: _user.greeting,
      avatarInitials: _user.avatarInitials,
      totalBalance: _user.totalBalance - _transferData.amount,
      monthlyGrowth: _user.monthlyGrowth,
      notificationCount: _user.notificationCount,
    );
    _isLoading = false;
    notifyListeners();
    return true;
  }
}