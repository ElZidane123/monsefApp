import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/app_themes.dart';
import '../widgets/spending_insights.dart';
import '../controllers/app_controller.dart';
import '../utils/currency_formatter.dart';
import '../models/models.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactions = context.watch<AppController>().transactions;

    // Filter for current month
    final now = DateTime.now();
    final currentMonthTxs = transactions.where((t) => 
      t.date.month == now.month && t.date.year == now.year).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in currentMonthTxs) {
      if (tx.isExpense) {
        totalExpense += tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistik Keuangan',
                          style: GoogleFonts.dmSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Performa bulan ini',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getMonthName(now.month),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 1. Monthly Performance Summary (Request)
              _MonthlySummaryCard(
                income: totalIncome,
                expense: totalExpense,
                isDark: isDark,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),
              
              // 2. Spending Insights Chart
              const SpendingInsights(),
              
              const SizedBox(height: 24),

              // 3. Category Breakdown
              _CategoryBreakdown(transactions: currentMonthTxs, isDark: isDark)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final bool isDark;

  const _MonthlySummaryCard({
    required this.income,
    required this.expense,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final netSavings = income - expense;
    final savingsRate = income > 0 ? (netSavings / income * 100) : 0.0;
    
    // Performance logic
    String conclusion;
    String recommendation;
    IconData statusIcon;
    Color statusColor;

    if (savingsRate > 20) {
      conclusion = 'Sangat Sehat!';
      recommendation = 'Anda menabung ${savingsRate.toStringAsFixed(1)}% dari pemasukan. Pertahankan!';
      statusIcon = Icons.auto_awesome_rounded;
      statusColor = AppTheme.accentGreen;
    } else if (savingsRate > 0) {
      conclusion = 'Cukup Stabil';
      recommendation = 'Tabungan Anda positif. Coba kurangi pengeluaran gaya hidup.';
      statusIcon = Icons.check_circle_rounded;
      statusColor = Colors.blueAccent;
    } else {
      conclusion = 'Perlu Perbaikan';
      recommendation = 'Pengeluaran melebihi pemasukan. Waspada defisit bulan ini.';
      statusIcon = Icons.warning_amber_rounded;
      statusColor = AppTheme.accentRose;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Kesimpulan Keuangan',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      conclusion,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildSimpleStat('Pemasukan', income, AppTheme.accentGreen),
                const SizedBox(width: 16),
                _buildSimpleStat('Pengeluaran', expense, AppTheme.accentRose),
              ],
            ),
            const Divider(height: 32, thickness: 0.5),
            Text(
              recommendation,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStat(String label, double value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyFormatter.format(value),
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isDark;

  const _CategoryBreakdown({required this.transactions, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categories = {};
    double totalExpense = 0;

    for (var tx in transactions) {
      if (tx.isExpense) {
        categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
        totalExpense += tx.amount;
      }
    }

    final sortedCats = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alokasi Pengeluaran',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedCats.take(4).map((entry) {
            final percentage = (entry.value / totalExpense) * 100;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage > 40 ? AppTheme.accentRose : AppTheme.primaryAccent,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
