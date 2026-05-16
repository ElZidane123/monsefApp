import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : AppTheme.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Stack(
                children: [
                  // Nav items
                  Row(
                    children: [
                      _NavItem(
                        icon: Icons.grid_view_rounded,
                        activeIcon: Icons.grid_view_rounded,
                        label: 'Beranda',
                        isSelected: currentIndex == 0,
                        onTap: () => _handleTap(0),
                        isDark: isDark,
                      ),
                      _NavItem(
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long_rounded,
                        label: 'Riwayat',
                        isSelected: currentIndex == 1,
                        onTap: () => _handleTap(1),
                        isDark: isDark,
                      ),
                      const Expanded(child: SizedBox()), // FAB space
                      _NavItem(
                        icon: Icons.bar_chart_outlined,
                        activeIcon: Icons.bar_chart_rounded,
                        label: 'Statistik',
                        isSelected: currentIndex == 2,
                        onTap: () => _handleTap(2),
                        isDark: isDark,
                      ),
                      _NavItem(
                        icon: Icons.person_outline_rounded,
                        activeIcon: Icons.person_rounded,
                        label: 'Profil',
                        isSelected: currentIndex == 3,
                        onTap: () => _handleTap(3),
                        isDark: isDark,
                      ),
                    ],
                  ),

                  // Animated pill indicator at bottom
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    bottom: 0,
                    left: _getPillLeft(currentIndex, width),
                    child: Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryAccent.withOpacity(0.6),
                            blurRadius: 8,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(int index) {
    HapticFeedback.selectionClick();
    onTap(index);
  }

  double _getPillLeft(int index, double screenWidth) {
    // Items occupy: [0..1] | spacer(FAB) | [2..3]
    // Each of 4 visible items: screenWidth/5 wide (1/5 each, FAB = 1/5)
    final itemWidth = screenWidth / 5;
    final centerOffset = (itemWidth - 36) / 2;
    if (index < 2) {
      return index * itemWidth + centerOffset;
    } else {
      return (index + 1) * itemWidth + centerOffset;
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
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
              duration: const Duration(milliseconds: 250),
              width: isSelected ? 44 : 40,
              height: isSelected ? 36 : 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryAccent.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    size: isSelected ? 23 : 22,
                    color: isSelected
                        ? AppTheme.primaryAccent
                        : (isDark
                            ? AppTheme.textDarkSecondary
                            : AppTheme.textMuted),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryAccent
                    : (isDark
                        ? AppTheme.textDarkSecondary
                        : AppTheme.textMuted),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
