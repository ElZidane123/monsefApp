import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/app_themes.dart';
import '../controllers/app_controller.dart';
import '../utils/currency_formatter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<AppController>();
    final user = controller.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ─── Hero header band ────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B2A6B), Color(0xFF0D1540)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryAccent.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // background glow
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.accentPurple.withOpacity(0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppTheme.primaryAccent.withOpacity(0.45),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                user.avatarInitials,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .scale(begin: const Offset(0.85, 0.85)),
                          const SizedBox(height: 14),
                          Text(
                            user.name,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Akun Premium Aktif',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Mini stats row
                          Row(
                            children: [
                              Expanded(
                                child: _HeroStat(
                                  label: 'Total Saldo',
                                  value: CurrencyFormatter.compact(
                                      user.totalBalance),
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 36,
                                  color: Colors.white.withOpacity(0.15)),
                              Expanded(
                                child: _HeroStat(
                                  label: 'Pertumbuhan',
                                  value:
                                      '+${user.monthlyGrowth.toStringAsFixed(1)}%',
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 36,
                                  color: Colors.white.withOpacity(0.15)),
                              Expanded(
                                child: _HeroStat(
                                  label: 'Transaksi',
                                  value:
                                      '${controller.transactions.length}',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ─── Settings groups ─────────────────────────────────────────
            _buildSettingGroup(
              context,
              isDark,
              title: 'Pengaturan Akun',
              items: [
                _SettingItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profil',
                  color: AppTheme.primaryAccent,
                ),
                _SettingItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  color: AppTheme.accentAmber,
                ),
                _SettingItem(
                  icon: Icons.security_rounded,
                  label: 'Keamanan & PIN',
                  color: AppTheme.accentGreen,
                ),
                _SettingItem(
                  icon: Icons.dark_mode_outlined,
                  label: 'Tampilan',
                  color: AppTheme.accentPurple,
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

            const SizedBox(height: 20),

            _buildSettingGroup(
              context,
              isDark,
              title: 'Keuangan',
              items: [
                _SettingItem(
                  icon: Icons.account_balance_outlined,
                  label: 'Kelola Rekening',
                  color: AppTheme.primaryAccent,
                ),
                _SettingItem(
                  icon: Icons.savings_outlined,
                  label: 'Tujuan Menabung',
                  color: AppTheme.accentGreen,
                ),
                _SettingItem(
                  icon: Icons.download_rounded,
                  label: 'Export Laporan',
                  color: AppTheme.accentPurple,
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

            const SizedBox(height: 20),

            _buildSettingGroup(
              context,
              isDark,
              title: 'Bantuan & Lainnya',
              items: [
                _SettingItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Pusat Bantuan',
                  color: AppTheme.primaryAccent,
                ),
                _SettingItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Kebijakan Privasi',
                  color: AppTheme.textMuted,
                ),
                _SettingItem(
                  icon: Icons.star_outline_rounded,
                  label: 'Beri Ulasan',
                  color: AppTheme.accentAmber,
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

            const SizedBox(height: 24),

            // ─── Logout ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  _showLogoutDialog(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRose.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.accentRose.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded,
                          color: AppTheme.accentRose, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Keluar dari Akun',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentRose,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

            const SizedBox(height: 12),
            Text(
              'Monsef v1.0.0',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark
                    ? AppTheme.textDarkSecondary
                    : AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingGroup(
    BuildContext context,
    bool isDark, {
    required String title,
    required List<_SettingItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.textDarkSecondary
                    : AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : AppTheme.borderLight,
              ),
              boxShadow: AppTheme.softShadow(isDark),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;
                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.vertical(
                          top: index == 0
                              ? const Radius.circular(22)
                              : Radius.zero,
                          bottom: isLast
                              ? const Radius.circular(22)
                              : Radius.zero,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (item.onTap != null) {
                            item.onTap!();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Fitur ${item.label} segera hadir!'),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: item.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 19,
                                  color: item.color,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppTheme.textDarkPrimary
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 70,
                        endIndent: 18,
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : AppTheme.borderLight,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Keluar dari Akun',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keluar',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentRose),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  _SettingItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}
