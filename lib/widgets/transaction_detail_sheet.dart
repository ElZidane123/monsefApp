import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../utils/currency_formatter.dart';

class TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;
  final bool isDark;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.isDark,
  });

  static void show(BuildContext context, TransactionModel transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(
        transaction: transaction,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgDark.withOpacity(0.95) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: AppTheme.premiumShadow(isDark),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // Amount Section
                    _buildAmountSection(),
                    const SizedBox(height: 32),

                    // Items Section (The specific request)
                    if (transaction.items.isNotEmpty) ...[
                      _buildItemsSection(),
                      const SizedBox(height: 32),
                    ],

                    // Meta Info
                    _buildMetaInfo(),
                    const SizedBox(height: 40),

                    // Actions
                    _buildActionButtons(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: (transaction.isExpense ? AppTheme.accentRose : AppTheme.accentGreen).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: (transaction.isExpense ? AppTheme.accentRose : AppTheme.accentGreen).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              transaction.icon,
              color: transaction.isExpense ? AppTheme.accentRose : AppTheme.accentGreen,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          transaction.title,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            transaction.category,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.bgLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            transaction.isExpense ? 'Pengeluaran Total' : 'Pemasukan Total',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(transaction.amount),
            style: GoogleFonts.dmSans(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: transaction.isExpense ? AppTheme.accentRose : AppTheme.accentGreen,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: AppTheme.accentGreen,
        ),
        const SizedBox(width: 6),
        Text(
          'Transaksi Berhasil',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.accentGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RINCIAN ITEM',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...transaction.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${item.quantity}x',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.format(item.total),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMetaInfo() {
    final fullDate = '${transaction.date.day} ${_getMonthName(transaction.date.month)} ${transaction.date.year}';
    final fullTime = '${transaction.date.hour.toString().padLeft(2, '0')}:${transaction.date.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark.withOpacity(0.5) : AppTheme.bgLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _metaRow('ID Transaksi', '#${transaction.id.toUpperCase()}', Icons.qr_code_rounded),
          const Divider(height: 24, thickness: 0.5),
          _metaRow('Tanggal', fullDate, Icons.calendar_today_rounded),
          const Divider(height: 24, thickness: 0.5),
          _metaRow('Waktu', fullTime, Icons.access_time_rounded),
          const Divider(height: 24, thickness: 0.5),
          _metaRow('Metode Pembayaran', 'Digital Wallet', Icons.account_balance_wallet_rounded),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            label: 'Bagikan Resi',
            icon: Icons.ios_share_rounded,
            onPressed: () {},
            primary: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            label: 'Tanya AI',
            icon: Icons.auto_awesome_rounded,
            onPressed: () {},
            primary: true,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool primary,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primary ? AppTheme.primaryAccent : (isDark ? AppTheme.surfaceDark2 : Colors.black12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: primary ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primary ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
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
