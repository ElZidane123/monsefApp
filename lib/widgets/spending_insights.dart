import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../models/dummy_data.dart';
import '../themes/app_themes.dart';

class SpendingInsights extends StatefulWidget {
  const SpendingInsights({super.key});

  @override
  State<SpendingInsights> createState() => _SpendingInsightsState();
}

class _SpendingInsightsState extends State<SpendingInsights> {
  String _selectedPeriod = 'Monthly';
  final List<String> _periods = ['Weekly', 'Monthly', 'Yearly'];

  List<SpendingDataModel> get _currentData {
    if (_selectedPeriod == 'Weekly') return DummyData.weeklySpending;
    return DummyData.monthlySpending;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wawasan Pengeluaran',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppTheme.textDarkPrimary
                            : AppTheme.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tren pengeluaran Anda',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: isDark
                            ? AppTheme.textDarkSecondary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                _PeriodSelector(
                  value: _selectedPeriod,
                  items: _periods,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _selectedPeriod = v!),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Summary row
            _SpendingSummary(data: _currentData, isDark: isDark),
            const SizedBox(height: 20),

            // Chart
            SizedBox(
              height: 170,
              child: _SpendingBarChart(
                  data: _currentData, isDark: isDark),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.08, end: 0);
  }
}

class _SpendingSummary extends StatelessWidget {
  final List<SpendingDataModel> data;
  final bool isDark;

  const _SpendingSummary({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final total = data.fold(0.0, (sum, d) => sum + d.amount);
    final highest = data.reduce((a, b) => a.amount > b.amount ? a : b);

    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            label: 'Total Dikeluarkan',
            value:
                'Rp ${_compact(total)}',
            icon: Icons.account_balance_wallet_outlined,
            color: AppTheme.primaryAccent,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryBox(
            label: 'Tertinggi (${highest.label})',
            value: 'Rp ${_compact(highest.amount)}',
            icon: Icons.trending_up_rounded,
            color: AppTheme.accentRose,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  String _compact(double v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(1)}jt';
    } else if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(0)}rb';
    }
    return v.toStringAsFixed(0);
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SummaryBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textDarkSecondary
                        : AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingBarChart extends StatefulWidget {
  final List<SpendingDataModel> data;
  final bool isDark;

  const _SpendingBarChart({required this.data, required this.isDark});

  @override
  State<_SpendingBarChart> createState() => _SpendingBarChartState();
}

class _SpendingBarChartState extends State<_SpendingBarChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final maxY = widget.data
            .map((e) => e.amount)
            .reduce((a, b) => a > b ? a : b) *
        1.35;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (response == null || response.spot == null) {
              setState(() => touchedIndex = -1);
              return;
            }
            if (event is FlTapDownEvent || event is FlPanUpdateEvent) {
              setState(
                  () => touchedIndex = response.spot!.touchedBarGroupIndex);
            }
          },
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 12,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final amount = widget.data[groupIndex].amount;
              final label = widget.data[groupIndex].label;
              return BarTooltipItem(
                '$label\nRp ${_fmt(amount)}',
                GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.5,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= widget.data.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    widget.data[idx].label,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: touchedIndex == idx
                          ? AppTheme.primaryAccent
                          : (widget.isDark
                              ? AppTheme.textDarkSecondary
                              : AppTheme.textSecondary),
                      fontWeight: touchedIndex == idx
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: widget.isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.04),
            strokeWidth: 1,
            dashArray: [4, 6],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(widget.data.length, (index) {
          final item = widget.data[index];
          final isTouched = touchedIndex == index;
          final isHighlighted = item.isHighlighted;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.amount,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                gradient: isTouched || isHighlighted
                    ? const LinearGradient(
                        colors: [
                          AppTheme.primaryAccent,
                          AppTheme.accentPurple,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      )
                    : LinearGradient(
                        colors: [
                          (widget.isDark
                                  ? AppTheme.primaryAccent
                                  : AppTheme.primaryAccent)
                              .withOpacity(widget.isDark ? 0.25 : 0.2),
                          (widget.isDark
                                  ? AppTheme.primaryGlow
                                  : AppTheme.primaryAccent)
                              .withOpacity(widget.isDark ? 0.4 : 0.35),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.025),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}rb';
    return v.toStringAsFixed(0);
  }
}

class _PeriodSelector extends StatelessWidget {
  final String value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _PeriodSelector({
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppTheme.borderLight,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(
            Icons.expand_more_rounded,
            size: 18,
            color: isDark
                ? AppTheme.textDarkSecondary
                : AppTheme.textSecondary,
          ),
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
          ),
          dropdownColor:
              isDark ? AppTheme.surfaceDark2 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}