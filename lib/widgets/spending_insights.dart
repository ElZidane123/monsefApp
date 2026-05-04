import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spending Insights',
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                _PeriodDropdown(
                  value: _selectedPeriod,
                  items: _periods,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _selectedPeriod = v!),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _SpendingSummary(data: _currentData, isDark: isDark),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: _SpendingBarChart(data: _currentData, isDark: isDark),
            ),
          ],
        ),
      ),
    );
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${total.toStringAsFixed(0)}',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Total Spent',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          height: 36,
          width: 1,
          color: isDark ? Colors.white12 : AppTheme.borderLight,
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${highest.amount.toStringAsFixed(0)}',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Highest (${highest.label})',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
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
    return BarChart(
      BarChartData(
        maxY: widget.data.map((e) => e.amount).reduce((a, b) => a > b ? a : b) * 1.3,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (response == null || response.spot == null) {
              setState(() => touchedIndex = -1);
              return;
            }
            if (event is FlTapDownEvent || event is FlPanUpdateEvent) {
              setState(() => touchedIndex = response.spot!.touchedBarGroupIndex);
            }
          },
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 10,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '\$${widget.data[groupIndex].amount.toStringAsFixed(0)}',
                GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= widget.data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.data[idx].label,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: widget.isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: widget.isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(widget.data.length, (index) {
          final item = widget.data[index];
          final isTouched = touchedIndex == index;
          final isHighlighted = item.isHighlighted;

          Color barColor;
          if (isTouched) {
            barColor = const Color(0xFF2563EB);
          } else if (isHighlighted) {
            barColor = const Color(0xFF2563EB);
          } else {
            barColor = widget.isDark
                ? const Color(0xFF2563EB).withOpacity(0.3)
                : const Color(0xFF93C5FD);
          }

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.amount,
                color: barColor,
                width: 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: widget.data.map((e) => e.amount).reduce((a, b) => a > b ? a : b) * 1.3,
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.03),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _PeriodDropdown({
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
          ),
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
          ),
          dropdownColor: isDark ? AppTheme.surfaceDark2 : Colors.white,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}