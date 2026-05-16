import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../utils/currency_formatter.dart';

class LinkedAccounts extends StatelessWidget {
  final List<AccountModel> accounts;
  final VoidCallback? onViewAll;

  const LinkedAccounts({super.key, required this.accounts, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Akun',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
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
        SizedBox(
          height: 136,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: accounts.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              if (i == accounts.length) {
                return _AddCard(isDark: isDark);
              }
              return _AccountCard(account: accounts[i], isDark: isDark)
                  .animate()
                  .fadeIn(delay: (i * 70).ms, duration: 350.ms);
            },
          ),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountModel account;
  final bool isDark;
  const _AccountCard({required this.account, required this.isDark});

  String _typeLabel() {
    switch (account.type) {
      case 'savings': return 'Tabungan';
      case 'checking': return 'Giro';
      case 'investment': return 'Investasi';
      default: return 'Akun';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        width: 158,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Type label
            Text(
              _typeLabel().toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark
                    ? AppTheme.textDarkSecondary
                    : AppTheme.textSecondary,
              ),
            ),

            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyFormatter.compact(account.balance),
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: isDark
                          ? AppTheme.textDarkPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        account.name,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: isDark
                              ? AppTheme.textDarkSecondary
                              : AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '••${account.lastFourDigits}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.textDarkSecondary
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  final bool isDark;
  const _AddCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur segera hadir!')),
        );
      },
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              size: 22,
              color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              'Tambah',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}