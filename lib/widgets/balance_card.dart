import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../utils/currency_formatter.dart';
import 'asset_inventory_sheet.dart';

class BalanceCard extends StatefulWidget {
  final UserModel user;
  const BalanceCard({super.key, required this.user});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          AssetInventorySheet.show(context);
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF1A56DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A56DB).withOpacity(0.28),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL SALDO',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isVisible = !_isVisible),
                      child: Icon(
                        _isVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white.withOpacity(0.5),
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Amount
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isVisible
                      ? Text(
                          key: const ValueKey('vis'),
                          CurrencyFormatter.format(widget.user.totalBalance),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.5,
                          ),
                        )
                      : Text(
                          key: const ValueKey('hid'),
                          '• • • • • • •',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 6,
                          ),
                        ),
                ),
                const SizedBox(height: 28),

                // Divider
                Divider(color: Colors.white.withOpacity(0.12), height: 1),
                const SizedBox(height: 20),

                // Bottom row: growth + last4
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GrowthPill(percentage: widget.user.monthlyGrowth),
                    Text(
                      '•••• 4429',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.06, end: 0);
  }
}

class _GrowthPill extends StatelessWidget {
  final double percentage;
  const _GrowthPill({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final isPos = percentage >= 0;
    return Row(
      children: [
        Icon(
          isPos ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          color: isPos
              ? Colors.white.withOpacity(0.65)
              : Colors.redAccent.withOpacity(0.8),
          size: 13,
        ),
        const SizedBox(width: 4),
        Text(
          '${isPos ? '+' : ''}${percentage.toStringAsFixed(1)}% bulan ini',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.65),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
