import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../utils/currency_formatter.dart';
import 'transaction_detail_sheet.dart';

class RecentTransactions extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final VoidCallback? onSeeAll;

  const RecentTransactions({
    super.key,
    required this.transactions,
    this.isLoading = false,
    this.onSeeAll,
  });

  String _relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi Terakhir',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // List container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow(isDark),
            ),
            child: Column(
              children: transactions.asMap().entries.map((e) {
                final isLast = e.key == transactions.length - 1;
                return _TxTile(
                  tx: e.value,
                  isDark: isDark,
                  date: _relativeDate(e.value.date),
                  isLast: isLast,
                ).animate().fadeIn(delay: (e.key * 50).ms, duration: 350.ms);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TxTile extends StatefulWidget {
  final TransactionModel tx;
  final bool isDark;
  final String date;
  final bool isLast;

  const _TxTile({
    required this.tx,
    required this.isDark,
    required this.date,
    required this.isLast,
  });

  @override
  State<_TxTile> createState() => _TxTileState();
}

class _TxTileState extends State<_TxTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.tx.isExpense;
    final amountColor = isExpense ? AppTheme.expense : AppTheme.income;

    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            HapticFeedback.lightImpact();
            TransactionDetailSheet.show(context, widget.tx);
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: _pressed
                ? (widget.isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.black.withOpacity(0.02))
                : Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                children: [
                  // Icon container — subtle, monochrome tint
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      widget.tx.icon,
                      size: 20,
                      color: widget.isDark
                          ? AppTheme.textDarkPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tx.title,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: widget.isDark
                                ? AppTheme.textDarkPrimary
                                : AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.tx.category} · ${widget.date}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: widget.isDark
                                ? AppTheme.textDarkSecondary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Text(
                    '${isExpense ? '-' : '+'} ${CurrencyFormatter.format(widget.tx.amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: amountColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!widget.isLast)
          Divider(
            height: 1,
            indent: 76,
            endIndent: 18,
            color: widget.isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.055),
          ),
      ],
    );
  }
}
