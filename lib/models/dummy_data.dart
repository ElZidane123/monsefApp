import 'models.dart';

class DummyData {
  static const UserModel user = UserModel(
    name: 'Alex Sterling',
    greeting: 'Selamat datang,',
    avatarInitials: 'AS',
    totalBalance: 124592000,
    monthlyGrowth: 2.4,
    notificationCount: 3,
  );

  static const List<AccountModel> accounts = [
    AccountModel(
      id: '1',
      name: 'Tabungan',
      type: 'savings',
      balance: 82400000,
      lastFourDigits: '4429',
    ),
    AccountModel(
      id: '2',
      name: 'Giro',
      type: 'checking',
      balance: 12192000,
      lastFourDigits: '8810',
    ),
    AccountModel(
      id: '3',
      name: 'Investasi',
      type: 'investment',
      balance: 30000000,
      lastFourDigits: '2201',
    ),
  ];

  static final List<TransactionModel> transactions = [
    TransactionModel(
      id: 't1',
      title: 'Starbucks',
      category: 'Makanan & Minuman',
      amount: 65000,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(hours: 1, minutes: 19)),
      iconEmoji: '☕',
    ),
    TransactionModel(
      id: 't2',
      title: 'Gaji Bulanan',
      category: 'Pemasukan',
      amount: 8500000,
      isExpense: false,
      date: DateTime.now().subtract(const Duration(hours: 6)),
      iconEmoji: '💰',
    ),
    TransactionModel(
      id: 't3',
      title: 'Apple Store',
      category: 'Belanja',
      amount: 3200000,
      isExpense: true,
      date: DateTime.now().subtract(
        const Duration(days: 1, hours: 7, minutes: 45),
      ),
      iconEmoji: '🍎',
    ),
    TransactionModel(
      id: 't4',
      title: 'Grab',
      category: 'Transportasi',
      amount: 85000,
      isExpense: true,
      date: DateTime.now().subtract(
        const Duration(days: 1, hours: 11, minutes: 30),
      ),
      iconEmoji: '🚗',
    ),
    TransactionModel(
      id: 't5',
      title: 'Sewa Kost',
      category: 'Tempat Tinggal',
      amount: 4500000,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
      iconEmoji: '🏠',
    ),
    TransactionModel(
      id: 't6',
      title: 'Netflix',
      category: 'Hiburan',
      amount: 65000,
      isExpense: true,
      date: DateTime(2024, 10, 24, 8, 30),
      iconEmoji: '🎬',
      status: TransactionStatus.completed,
    ),
    TransactionModel(
      id: 't7',
      title: 'Superindo',
      category: 'Belanja Bulanan',
      amount: 450000,
      isExpense: true,
      date: DateTime(2024, 10, 24, 14, 15),
      iconEmoji: '🛒',
    ),
    TransactionModel(
      id: 't8',
      title: 'Freelance Project',
      category: 'Pemasukan',
      amount: 2500000,
      isExpense: false,
      date: DateTime(2024, 10, 23, 10, 0),
      iconEmoji: '💼',
    ),
    TransactionModel(
      id: 't9',
      title: 'Spotify',
      category: 'Hiburan',
      amount: 59000,
      isExpense: true,
      date: DateTime(2024, 10, 22, 9, 0),
      iconEmoji: '🎵',
    ),
    TransactionModel(
      id: 't10',
      title: 'Tagihan Listrik',
      category: 'Utilitas',
      amount: 350000,
      isExpense: true,
      date: DateTime(2024, 10, 21, 11, 0),
      iconEmoji: '⚡',
    ),
    TransactionModel(
      id: 't11',
      title: 'Dividen Saham',
      category: 'Pemasukan',
      amount: 1200000,
      isExpense: false,
      date: DateTime(2024, 10, 20, 9, 0),
      iconEmoji: '📈',
    ),
    TransactionModel(
      id: 't12',
      title: 'Shopee',
      category: 'Belanja Online',
      amount: 350000,
      isExpense: true,
      date: DateTime(2024, 10, 19, 15, 30),
      iconEmoji: '📦',
    ),
  ];

  static const List<AssetAllocation> assetAllocations = [
    AssetAllocation(label: 'Saham', percentage: 45, colorHex: 0xFF2563EB),
    AssetAllocation(label: 'Obligasi', percentage: 25, colorHex: 0xFF10B981),
    AssetAllocation(label: 'Tunai', percentage: 15, colorHex: 0xFFF59E0B),
    AssetAllocation(label: 'Kripto', percentage: 15, colorHex: 0xFF8B5CF6),
  ];

  static const List<InvestmentAsset> topAssets = [
    InvestmentAsset(
      name: 'Apple Inc.',
      ticker: 'AAPL',
      value: 45000000,
      changePercent: 1.42,
      emoji: '🍎',
      detail: '124 lembar',
    ),
    InvestmentAsset(
      name: 'Ethereum',
      ticker: 'ETH',
      value: 165000000,
      changePercent: 5.86,
      emoji: '⟠',
      detail: '4.0 unit',
    ),
    InvestmentAsset(
      name: 'Tesla',
      ticker: 'TSLA',
      value: 30000000,
      changePercent: -2.14,
      emoji: '⚡',
      detail: '8 lembar',
    ),
    InvestmentAsset(
      name: 'Bitcoin',
      ticker: 'BTC',
      value: 132000000,
      changePercent: 3.22,
      emoji: '₿',
      detail: '0.2 BTC',
    ),
    InvestmentAsset(
      name: 'Microsoft',
      ticker: 'MSFT',
      value: 49000000,
      changePercent: 0.87,
      emoji: '🪟',
      detail: '10 lembar',
    ),
  ];

  static const List<SpendingDataModel> monthlySpending = [
    SpendingDataModel(label: 'M1', amount: 3200000),
    SpendingDataModel(label: 'M2', amount: 4800000),
    SpendingDataModel(label: 'M3', amount: 2500000),
    SpendingDataModel(label: 'M4', amount: 6500000, isHighlighted: true),
    SpendingDataModel(label: 'M5', amount: 4200000),
    SpendingDataModel(label: 'M6', amount: 5100000),
    SpendingDataModel(label: 'M7', amount: 3800000),
  ];

  static const List<SpendingDataModel> weeklySpending = [
    SpendingDataModel(label: 'Sen', amount: 850000),
    SpendingDataModel(label: 'Sel', amount: 480000),
    SpendingDataModel(label: 'Rab', amount: 1400000),
    SpendingDataModel(label: 'Kam', amount: 720000),
    SpendingDataModel(label: 'Jum', amount: 1800000, isHighlighted: true),
    SpendingDataModel(label: 'Sab', amount: 950000),
    SpendingDataModel(label: 'Min', amount: 600000),
  ];
}
