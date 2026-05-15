class UserModel {
  final String name;
  final String greeting;
  final String avatarInitials;
  final double totalBalance;
  final double monthlyGrowth;
  final int notificationCount;

  const UserModel({
    required this.name,
    required this.greeting,
    required this.avatarInitials,
    required this.totalBalance,
    required this.monthlyGrowth,
    required this.notificationCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      greeting: json['greeting'] ?? '',
      avatarInitials: json['avatarInitials'] ?? '',
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
      monthlyGrowth: (json['monthlyGrowth'] ?? 0).toDouble(),
      notificationCount: json['notificationCount'] ?? 0,
    );
  }
}

class AccountModel {
  final String id;
  final String name;
  final String type;
  final double balance;
  final String lastFourDigits;

  const AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.lastFourDigits,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      lastFourDigits: json['lastFourDigits'] ?? '',
    );
  }

  String get displayName => '$name  ****$lastFourDigits';
  String get shortBalance {
    if (balance >= 1000000000) return 'Rp ${(balance / 1000000000).toStringAsFixed(1)} M';
    if (balance >= 1000000) return 'Rp ${(balance / 1000000).toStringAsFixed(1)} Jt';
    if (balance >= 1000) return 'Rp ${(balance / 1000).toStringAsFixed(0)} Rb';
    return 'Rp ${balance.toStringAsFixed(0)}';
  }
}

class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final String iconEmoji;
  final TransactionStatus status;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.iconEmoji,
    this.status = TransactionStatus.completed,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      isExpense: json['isExpense'] ?? true,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      iconEmoji: json['iconEmoji'] ?? '💰',
      status: _parseStatus(json['status']),
    );
  }

  static TransactionStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return TransactionStatus.pending;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.completed;
    }
  }
}

enum TransactionStatus { completed, pending, failed }

class InvestmentAsset {
  final String name;
  final String ticker;
  final double value;
  final double changePercent;
  final String emoji;
  final String detail;

  const InvestmentAsset({
    required this.name,
    required this.ticker,
    required this.value,
    required this.changePercent,
    required this.emoji,
    required this.detail,
  });
}

class AssetAllocation {
  final String label;
  final double percentage;
  final int colorHex;

  const AssetAllocation({
    required this.label,
    required this.percentage,
    required this.colorHex,
  });
}

class TransferData {
  final AccountModel? fromAccount;
  final String? toName;
  final double amount;
  final double fee;

  const TransferData({
    this.fromAccount,
    this.toName,
    this.amount = 0,
    this.fee = 0,
  });

  double get total => amount + fee;

  TransferData copyWith({
    AccountModel? fromAccount,
    String? toName,
    double? amount,
    double? fee,
  }) {
    return TransferData(
      fromAccount: fromAccount ?? this.fromAccount,
      toName: toName ?? this.toName,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
    );
  }
}

class SpendingDataModel {
  final String label;
  final double amount;
  final bool isHighlighted;

  const SpendingDataModel({
    required this.label,
    required this.amount,
    this.isHighlighted = false,
  });
}

class SavingsGoalModel {
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String icon;
  final int colorHex;

  const SavingsGoalModel({
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.icon,
    required this.colorHex,
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
}