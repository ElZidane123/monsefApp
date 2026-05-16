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

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
            blurRadius: 25,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Stack(
              children: [
                SizedBox(
                  height: 70,
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.grid_view_rounded,
                        label: 'Home',
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                        isDark: isDark,
                      ),
                      _NavItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'History',
                        isSelected: currentIndex == 1,
                        onTap: () => onTap(1),
                        isDark: isDark,
                      ),
                      const Expanded(child: SizedBox()),
                      _NavItem(
                        icon: Icons.bar_chart_rounded,
                        label: 'Stats',
                        isSelected: currentIndex == 2,
                        onTap: () => onTap(2),
                        isDark: isDark,
                      ),
                      _NavItem(
                        icon: Icons.person_rounded,
                        label: 'Profile',
                        isSelected: currentIndex == 3,
                        onTap: () => onTap(3),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                // Selection Indicator Line
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  left: _getIndicatorPos(
                    currentIndex,
                    MediaQuery.of(context).size.width,
                  ),
                  child: Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
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
    );
  }

  double _getIndicatorPos(int index, double screenWidth) {
    final itemWidth = screenWidth / 5;
    if (index >= 2) {
      return (index + 1) * itemWidth + (itemWidth / 2) - 20;
    }
    return index * itemWidth + (itemWidth / 2) - 20;
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
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppTheme.primaryAccent
                    : (isDark
                          ? AppTheme.textDarkSecondary
                          : AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
