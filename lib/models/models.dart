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

  String get displayName => '$name  ****$lastFourDigits';
  String get shortBalance => '\$${balance.toStringAsFixed(2)}';
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