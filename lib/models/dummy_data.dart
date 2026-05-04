import 'models.dart';

class DummyData {
  static const UserModel user = UserModel(
    name: 'Alex Sterling',
    greeting: 'Welcome back,',
    avatarInitials: 'AS',
    totalBalance: 124592.00,
    monthlyGrowth: 2.4,
    notificationCount: 3,
  );

  static const List<AccountModel> accounts = [
    AccountModel(
      id: '1',
      name: 'Savings Account',
      type: 'savings',
      balance: 82400.00,
      lastFourDigits: '4429',
    ),
    AccountModel(
      id: '2',
      name: 'Checking Account',
      type: 'checking',
      balance: 12192.00,
      lastFourDigits: '8810',
    ),
    AccountModel(
      id: '3',
      name: 'Investment Account',
      type: 'investment',
      balance: 30000.00,
      lastFourDigits: '2201',
    ),
  ];

  static final List<TransactionModel> transactions = [
    TransactionModel(
      id: 't1',
      title: 'Starbucks',
      category: 'Food & Drink',
      amount: 12.50,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(hours: 1, minutes: 19)),
      iconEmoji: '☕',
    ),
    TransactionModel(
      id: 't2',
      title: 'Monthly Salary',
      category: 'Income',
      amount: 4250.00,
      isExpense: false,
      date: DateTime.now().subtract(const Duration(hours: 6)),
      iconEmoji: '💰',
    ),
    TransactionModel(
      id: 't3',
      title: 'Apple Store',
      category: 'Shopping',
      amount: 199.00,
      isExpense: true,
      date: DateTime.now().subtract(
        const Duration(days: 1, hours: 7, minutes: 45),
      ),
      iconEmoji: '🍎',
    ),
    TransactionModel(
      id: 't4',
      title: 'Uber Trip',
      category: 'Transport',
      amount: 24.40,
      isExpense: true,
      date: DateTime.now().subtract(
        const Duration(days: 1, hours: 11, minutes: 30),
      ),
      iconEmoji: '🚗',
    ),
    TransactionModel(
      id: 't5',
      title: 'Rent Payment',
      category: 'Housing',
      amount: 1800.00,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
      iconEmoji: '🏠',
    ),
    TransactionModel(
      id: 't6',
      title: 'Netflix',
      category: 'Entertainment',
      amount: 15.99,
      isExpense: true,
      date: DateTime(2024, 10, 24, 8, 30),
      iconEmoji: '🎬',
      status: TransactionStatus.completed,
    ),
    TransactionModel(
      id: 't7',
      title: 'Whole Foods',
      category: 'Groceries',
      amount: 124.50,
      isExpense: true,
      date: DateTime(2024, 10, 24, 14, 15),
      iconEmoji: '🛒',
    ),
    TransactionModel(
      id: 't8',
      title: 'Freelance Payment',
      category: 'Income',
      amount: 850.00,
      isExpense: false,
      date: DateTime(2024, 10, 23, 10, 0),
      iconEmoji: '💼',
    ),
    TransactionModel(
      id: 't9',
      title: 'Spotify',
      category: 'Entertainment',
      amount: 9.99,
      isExpense: true,
      date: DateTime(2024, 10, 22, 9, 0),
      iconEmoji: '🎵',
    ),
    TransactionModel(
      id: 't10',
      title: 'Electric Bill',
      category: 'Utilities',
      amount: 88.20,
      isExpense: true,
      date: DateTime(2024, 10, 21, 11, 0),
      iconEmoji: '⚡',
    ),
    TransactionModel(
      id: 't11',
      title: 'Dividend Income',
      category: 'Income',
      amount: 320.00,
      isExpense: false,
      date: DateTime(2024, 10, 20, 9, 0),
      iconEmoji: '📈',
    ),
    TransactionModel(
      id: 't12',
      title: 'Amazon Purchase',
      category: 'Shopping',
      amount: 67.30,
      isExpense: true,
      date: DateTime(2024, 10, 19, 15, 30),
      iconEmoji: '📦',
    ),
  ];

  static const List<AssetAllocation> assetAllocations = [
    AssetAllocation(label: 'Stocks', percentage: 45, colorHex: 0xFF2563EB),
    AssetAllocation(label: 'Bonds', percentage: 25, colorHex: 0xFF10B981),
    AssetAllocation(label: 'Cash', percentage: 15, colorHex: 0xFFF59E0B),
    AssetAllocation(label: 'Crypto', percentage: 15, colorHex: 0xFF8B5CF6),
  ];

  static const List<InvestmentAsset> topAssets = [
    InvestmentAsset(
      name: 'Apple Inc.',
      ticker: 'AAPL',
      value: 2842.20,
      changePercent: 1.42,
      emoji: '🍎',
      detail: '124 shares',
    ),
    InvestmentAsset(
      name: 'Ethereum',
      ticker: 'ETH',
      value: 10450.12,
      changePercent: 5.86,
      emoji: '⟠',
      detail: '4.0 units',
    ),
    InvestmentAsset(
      name: 'Tesla',
      ticker: 'TSLA',
      value: 1892.50,
      changePercent: -2.14,
      emoji: '⚡',
      detail: '8 shares',
    ),
    InvestmentAsset(
      name: 'Bitcoin',
      ticker: 'BTC',
      value: 8340.00,
      changePercent: 3.22,
      emoji: '₿',
      detail: '0.2 BTC',
    ),
    InvestmentAsset(
      name: 'Microsoft',
      ticker: 'MSFT',
      value: 3120.80,
      changePercent: 0.87,
      emoji: '🪟',
      detail: '10 shares',
    ),
  ];

  static const List<SpendingDataModel> monthlySpending = [
    SpendingDataModel(label: 'W1', amount: 1200),
    SpendingDataModel(label: 'W2', amount: 1800),
    SpendingDataModel(label: 'W3', amount: 950),
    SpendingDataModel(label: 'W4', amount: 2440, isHighlighted: true),
    SpendingDataModel(label: 'W5', amount: 1650),
    SpendingDataModel(label: 'W6', amount: 2100),
    SpendingDataModel(label: 'W7', amount: 1380),
  ];

  static const List<SpendingDataModel> weeklySpending = [
    SpendingDataModel(label: 'Mon', amount: 320),
    SpendingDataModel(label: 'Tue', amount: 180),
    SpendingDataModel(label: 'Wed', amount: 540),
    SpendingDataModel(label: 'Thu', amount: 290),
    SpendingDataModel(label: 'Fri', amount: 680, isHighlighted: true),
    SpendingDataModel(label: 'Sat', amount: 410),
    SpendingDataModel(label: 'Sun', amount: 220),
  ];
}
