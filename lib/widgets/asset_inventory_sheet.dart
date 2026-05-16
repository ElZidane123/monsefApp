import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../controllers/app_controller.dart';
import '../themes/app_themes.dart';
import '../utils/currency_formatter.dart';

class AssetInventorySheet extends StatelessWidget {
  final bool isDark;

  const AssetInventorySheet({
    super.key,
    required this.isDark,
  });

  static void show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssetInventorySheet(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AppController>().accounts;
    final totalBalance = context.watch<AppController>().user.totalBalance;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgDark.withOpacity(0.95) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: AppTheme.premiumShadow(isDark),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aset & Rekening',
                          style: GoogleFonts.dmSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Total kekayaan bersih Anda',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.account_balance_rounded, color: AppTheme.primaryAccent, size: 20),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Total Balance Display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryAccent, AppTheme.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SALDO GABUNGAN',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(totalBalance),
                        style: GoogleFonts.dmSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Account List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    return _AccountItem(
                      account: acc,
                      isDark: isDark,
                      index: index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

class _AccountItem extends StatelessWidget {
  final AccountModel account;
  final bool isDark;
  final int index;

  const _AccountItem({
    required this.account,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (account.type) {
      case 'savings':
        icon = Icons.savings_rounded;
        color = AppTheme.accentGreen;
        break;
      case 'checking':
        icon = Icons.account_balance_wallet_rounded;
        color = AppTheme.primaryAccent;
        break;
      case 'investment':
        icon = Icons.trending_up_rounded;
        color = AppTheme.accentRose;
        break;
      default:
        icon = Icons.credit_card_rounded;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '•••• ${account.lastFourDigits}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(account.balance),
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }
}
