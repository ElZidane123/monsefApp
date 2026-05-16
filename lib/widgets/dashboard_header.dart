import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';

class DashboardHeader extends StatelessWidget {
  final UserModel user;
  const DashboardHeader({super.key, required this.user});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi';
    if (h < 15) return 'Selamat Siang';
    if (h < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Row(
        children: [
          // Avatar — clean circle, single accent
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.avatarInitials,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Greeting + name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: isDark
                        ? AppTheme.textDarkSecondary
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  user.name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textDarkPrimary
                        : AppTheme.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),

          // Notification bell — clean button
          _NotificationBell(count: user.notificationCount, isDark: isDark),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final bool isDark;
  const _NotificationBell({required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              shape: BoxShape.circle,
              boxShadow: AppTheme.softShadow(isDark),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 20,
              color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
            ),
          ),
          if (count > 0)
            Positioned(
              top: 1,
              right: 1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.expense,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}