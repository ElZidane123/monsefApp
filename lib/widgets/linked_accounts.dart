import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../utils/currency_formatter.dart';
import '../controllers/app_controller.dart';
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
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _showDeleteDialog(context);
      },
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        title: Text(
          'Hapus Akun',
          style: GoogleFonts.inter(
            color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus akun "${account.name}"? Saldo utama akan menyesuaikan.',
          style: GoogleFonts.inter(
            color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AppController>().deleteAccount(account.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Akun berhasil dihapus' : 'Gagal menghapus akun', style: GoogleFonts.inter(color: Colors.white)),
                    backgroundColor: success ? AppTheme.income : AppTheme.accentRose,
                  ),
                );
              }
            },
            child: Text('Hapus', style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
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
        _showAddAccountSheet(context, isDark);
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

  void _showAddAccountSheet(BuildContext context, bool isDark) {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    String selectedType = 'savings';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (ctx, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tambah Akun / Kartu',
                  style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(nameCtrl, 'Nama Akun (Misal: BCA)', isDark),
                const SizedBox(height: 16),
                _buildTextField(balanceCtrl, 'Saldo Awal (Rp)', isDark, isNumber: true),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark2 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      dropdownColor: isDark ? AppTheme.surfaceDark2 : Colors.white,
                      items: const [
                        DropdownMenuItem(value: 'savings', child: Text('Tabungan')),
                        DropdownMenuItem(value: 'checking', child: Text('Giro')),
                        DropdownMenuItem(value: 'investment', child: Text('Investasi')),
                      ],
                      onChanged: (v) => setState(() => selectedType = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final balance = double.tryParse(balanceCtrl.text.trim()) ?? 0;
                      if (name.isEmpty) return;

                      final data = {
                        "id": "acc_${DateTime.now().millisecondsSinceEpoch}",
                        "name": name,
                        "type": selectedType,
                        "balance": balance,
                        "lastFourDigits": (DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')
                      };
                      
                      final success = await context.read<AppController>().addAccount(data);
                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Akun berhasil ditambahkan!'), backgroundColor: AppTheme.income));
                          Navigator.pop(ctx);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambahkan akun'), backgroundColor: AppTheme.accentRose));
                        }
                      }
                    },
                    child: Text(
                      'Simpan Akun',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, bool isDark, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: isDark ? Colors.white38 : Colors.black38),
        filled: true,
        fillColor: isDark ? AppTheme.surfaceDark2 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
      ),
    );
  }
}