import 'package:flutter/material.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'lastFourDigits': lastFourDigits,
    };
  }

  String get displayName => '$name  ****$lastFourDigits';
  String get shortBalance {
    if (balance >= 1000000000) return 'Rp ${(balance / 1000000000).toStringAsFixed(1)} M';
    if (balance >= 1000000) return 'Rp ${(balance / 1000000).toStringAsFixed(1)} Jt';
    if (balance >= 1000) return 'Rp ${(balance / 1000).toStringAsFixed(0)} Rb';
    return 'Rp ${balance.toStringAsFixed(0)}';
  }
}

class TransactionItem {
  final String name;
  final double price;
  final int quantity;

  const TransactionItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final IconData icon;
  final TransactionStatus status;
  final List<TransactionItem> items;
  final String? accountId;
  final String? note;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.icon,
    this.status = TransactionStatus.completed,
    this.items = const [],
    this.accountId,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      isExpense: json['isExpense'] ?? true,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      icon: _parseIcon(json['icon']),
      status: _parseStatus(json['status']),
      items: (json['items'] as List?)
              ?.map((i) => TransactionItem(
                    name: i['name'],
                    price: (i['price'] ?? 0).toDouble(),
                    quantity: i['quantity'] ?? 1,
                  ))
              .toList() ??
          [],
      accountId: json['accountId']?.toString(),
      note: json['note'],
    );
  }

  static IconData _parseIcon(dynamic icon) {
    if (icon is int) return IconData(icon, fontFamily: 'MaterialIcons');
    if (icon is String) {
      switch (icon) {
        // API string keys (Mockoon)
        case 'coffee':         return Icons.coffee_rounded;
        case 'payments':       return Icons.payments_rounded;
        case 'shopping_bag':   return Icons.shopping_bag_rounded;
        case 'directions_car': return Icons.directions_car_rounded;
        case 'home':           return Icons.home_rounded;
        case 'movie':          return Icons.movie_rounded;
        case 'shopping_cart':  return Icons.shopping_cart_rounded;
        case 'work':           return Icons.work_rounded;
        case 'music_note':     return Icons.music_note_rounded;
        case 'electric_bolt':  return Icons.electric_bolt_rounded;
        case 'trending_up':    return Icons.trending_up_rounded;
        case 'inventory':      return Icons.inventory_2_rounded;
        case 'laptop':         return Icons.laptop_mac_rounded;
        case 'flight':         return Icons.flight_takeoff_rounded;
        case 'security':       return Icons.security_rounded;
        case 'savings':        return Icons.savings_rounded;
        // Legacy emoji keys
        case '☕': return Icons.coffee_rounded;
        case '💰': return Icons.payments_rounded;
        case '🍎': return Icons.shopping_bag_rounded;
        case '🚗': return Icons.directions_car_rounded;
        case '🏠': return Icons.home_rounded;
        case '🎬': return Icons.movie_rounded;
        case '🛒': return Icons.shopping_cart_rounded;
        case '💼': return Icons.work_rounded;
        case '🎵': return Icons.music_note_rounded;
        case '⚡': return Icons.electric_bolt_rounded;
        case '📈': return Icons.trending_up_rounded;
        case '📦': return Icons.inventory_2_rounded;
        case '💻': return Icons.laptop_mac_rounded;
        case '🗾': return Icons.flight_takeoff_rounded;
        case '🛡️': return Icons.security_rounded;
        default: return Icons.receipt_long_rounded;
      }
    }
    return Icons.receipt_long_rounded;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'isExpense': isExpense,
      'date': date.toIso8601String(),
      'icon': _iconToString(icon),
      'status': status.name,
      'accountId': accountId,
      'note': note,
      'items': items.map((i) => {
        'name': i.name,
        'price': i.price,
        'quantity': i.quantity,
      }).toList(),
    };
  }

  static String _iconToString(IconData icon) {
    const map = {
      0xe1d8: 'coffee', 0xf04e: 'payments', 0xea16: 'shopping_bag',
      0xe531: 'directions_car', 0xea41: 'home', 0xe54d: 'movie',
      0xe564: 'shopping_cart', 0xe8f9: 'work', 0xe3a7: 'music_note',
      0xebd5: 'electric_bolt', 0xe6d2: 'trending_up', 0xf058: 'inventory',
      0xe322: 'laptop', 0xe539: 'flight', 0xe32a: 'security',
    };
    return map[icon.codePoint] ?? 'payments';
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
  final IconData icon;
  final String detail;

  const InvestmentAsset({
    required this.name,
    required this.ticker,
    required this.value,
    required this.changePercent,
    required this.icon,
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
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final IconData icon;
  final int colorHex;

  const SavingsGoalModel({
    this.id = '',
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.icon,
    required this.colorHex,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      icon: TransactionModel._parseIcon(json['icon'] ?? 'savings'),
      colorHex: json['colorHex'] ?? 0xFF3B82F6,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'icon': TransactionModel._iconToString(icon),
    'colorHex': colorHex,
  };

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
}