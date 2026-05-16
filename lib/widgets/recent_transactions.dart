import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return _buildSkeleton(isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppTheme.textDarkPrimary
                      : AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See All',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final tx = entry.value;
          return _TransactionTile(
                transaction: tx,
                isDark: isDark,
                formattedDate: _formatDate(tx.date),
              )
              .animate()
              .fadeIn(delay: (index * 50).ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildSkeleton(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
      highlightColor: isDark ? Colors.white24 : Colors.black.withOpacity(0.01),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatefulWidget {
  final TransactionModel transaction;
  final bool isDark;
  final String formattedDate;

  const _TransactionTile({
    required this.transaction,
    required this.isDark,
    required this.formattedDate,
  });

  @override
  State<_TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<_TransactionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            TransactionDetailSheet.show(context, widget.transaction);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.04),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: Offset(0, _isHovered ? 4 : 2),
                ),
              ],
              border: Border.all(
                color: _isHovered
                    ? AppTheme.primaryAccent.withOpacity(0.3)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Emoji icon with background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        (widget.transaction.isExpense
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF10B981))
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      widget.transaction.iconEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title + Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.transaction.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark
                              ? AppTheme.textDarkPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.transaction.category} • ${widget.formattedDate}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.5,
                          color: widget.isDark
                              ? AppTheme.textDarkSecondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.transaction.isExpense ? '-' : '+'}\$${widget.transaction.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: widget.transaction.isExpense
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      widget.transaction.isExpense
                          ? Icons.arrow_outward_rounded
                          : Icons.call_received_rounded,
                      size: 14,
                      color:
                          (widget.transaction.isExpense
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF10B981))
                              .withOpacity(0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
