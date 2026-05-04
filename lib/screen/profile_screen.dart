import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../themes/app_themes.dart';
import '../provider/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AppProvider>().user;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.avatarInitials,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Personal Account',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Settings list
              _buildSettingGroup(
                isDark,
                title: 'Pengaturan Akun',
                items: [
                  _SettingItem(icon: Icons.person_outline_rounded, label: 'Edit Profil'),
                  _SettingItem(icon: Icons.notifications_outlined, label: 'Notifikasi'),
                  _SettingItem(icon: Icons.security_rounded, label: 'Keamanan & PIN'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildSettingGroup(
                isDark,
                title: 'Bantuan',
                items: [
                  _SettingItem(icon: Icons.help_outline_rounded, label: 'Pusat Bantuan'),
                  _SettingItem(icon: Icons.privacy_tip_outlined, label: 'Kebijakan Privasi'),
                ],
              ),
              
              const SizedBox(height: 32),
              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Keluar',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingGroup(bool isDark, {required String title, required List<_SettingItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 20, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary),
                    ),
                    title: Text(
                      item.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white30 : Colors.black26),
                  ),
                  if (index < items.length - 1)
                    Divider(height: 1, indent: 64, color: isDark ? Colors.white12 : AppTheme.borderLight),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;

  _SettingItem({required this.icon, required this.label});
}
