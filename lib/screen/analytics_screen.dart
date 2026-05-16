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

    final now = DateTime.now();
    final currentMonthTxs = transactions
        .where((t) => t.date.month == now.month && t.date.year == now.year)
        .toList();

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
              // ─── Header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistik',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppTheme.textDarkPrimary
                                : AppTheme.textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        Text(
                          'Performa keuangan bulan ini',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: isDark
                                ? AppTheme.textDarkSecondary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryAccent.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _getMonthName(now.month),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
              const SizedBox(height: 24),

              // ─── Income / Expense cards ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Pemasukan',
                        value: totalIncome,
                        icon: Icons.arrow_downward_rounded,
                        gradient: AppTheme.greenGradient,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Pengeluaran',
                        value: totalExpense,
                        icon: Icons.arrow_upward_rounded,
                        gradient: AppTheme.roseGradient,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 16),

              // ─── Net savings banner ────────────────────────────────────
              _NetSavingsBanner(
                income: totalIncome,
                expense: totalExpense,
                isDark: isDark,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 24),

              // ─── Spending Insights Chart ───────────────────────────────
              const SpendingInsights()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 24),

              // ─── Category Breakdown ────────────────────────────────────
              _CategoryBreakdown(
                transactions: currentMonthTxs,
                isDark: isDark,
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

              const SizedBox(height: 100),
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

// ─── Stat Card ─────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final LinearGradient gradient;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : AppTheme.borderLight,
        ),
        boxShadow: AppTheme.softShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppTheme.textDarkSecondary
                  : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(value),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppTheme.textDarkPrimary
                    : AppTheme.textPrimary,
                letterSpacing: -0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Net Savings Banner ─────────────────────────────────────────────────────
class _NetSavingsBanner extends StatelessWidget {
  final double income;
  final double expense;
  final bool isDark;

  const _NetSavingsBanner({
    required this.income,
    required this.expense,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final net = income - expense;
    final savingsRate = income > 0 ? (net / income * 100) : 0.0;
    final isGood = savingsRate > 20;
    final isOk = savingsRate > 0;

    final statusColor = isGood
        ? AppTheme.accentGreen
        : (isOk ? AppTheme.primaryAccent : AppTheme.accentRose);
    final statusText = isGood
        ? 'Sangat Sehat! 🎉'
        : (isOk ? 'Cukup Stabil' : 'Perlu Perbaikan');
    final statusDesc = isGood
        ? 'Anda menabung ${savingsRate.toStringAsFixed(1)}% dari pemasukan. Pertahankan!'
        : (isOk
            ? 'Tabungan positif. Coba kurangi pengeluaran gaya hidup.'
            : 'Pengeluaran melebihi pemasukan. Waspadai defisit!');
    final statusIcon = isGood
        ? Icons.auto_awesome_rounded
        : (isOk ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(isDark ? 0.2 : 0.08),
              statusColor.withOpacity(isDark ? 0.08 : 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    statusDesc,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.textDarkSecondary
                          : AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Breakdown ─────────────────────────────────────────────────────
class _CategoryBreakdown extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isDark;

  const _CategoryBreakdown(
      {required this.transactions, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categories = {};
    double totalExpense = 0;

    for (var tx in transactions) {
      if (tx.isExpense) {
        categories[tx.category] =
            (categories[tx.category] ?? 0) + tx.amount;
        totalExpense += tx.amount;
      }
    }

    final sortedCats = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      AppTheme.primaryAccent,
      AppTheme.accentPurple,
      AppTheme.accentGreen,
      AppTheme.accentRose,
      AppTheme.accentAmber,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : AppTheme.borderLight,
          ),
          boxShadow: AppTheme.softShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.donut_small_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Alokasi Pengeluaran',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textDarkPrimary
                        : AppTheme.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (sortedCats.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Belum ada pengeluaran bulan ini',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? AppTheme.textDarkSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...sortedCats.take(5).toList().asMap().entries.map((e) {
                final i = e.key;
                final entry = e.value;
                final pct = totalExpense > 0
                    ? (entry.value / totalExpense) * 100
                    : 0.0;
                final color = colors[i % colors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppTheme.textDarkPrimary
                                    : AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.compact(entry.value),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 44,
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${pct.toStringAsFixed(1)}%',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppTheme.textDarkSecondary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Container(
                              height: 7,
                              color: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : color.withOpacity(0.08),
                            ),
                            FractionallySizedBox(
                              widthFactor: (pct / 100).clamp(0.0, 1.0),
                              child: Container(
                                height: 7,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .scaleX(
                                  duration: 900.ms,
                                  delay: (i * 100).ms,
                                  curve: Curves.easeOutExpo,
                                  alignment: Alignment.centerLeft,
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
