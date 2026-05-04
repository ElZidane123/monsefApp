import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_themes.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Beranda',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Riwayat',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
                isDark: isDark,
              ),
              // Center gap for FAB
              const Expanded(child: SizedBox()),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Statistik',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
                isDark: isDark,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryAccent.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppTheme.primaryAccent
                    : (isDark ? AppTheme.textDarkSecondary : AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryAccent
                    : (isDark ? AppTheme.textDarkSecondary : AppTheme.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}