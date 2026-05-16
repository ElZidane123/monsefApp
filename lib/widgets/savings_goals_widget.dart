import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';

class SavingsGoalsWidget extends StatelessWidget {
  final List<SavingsGoalModel> goals;
  final VoidCallback? onViewAll;

  const SavingsGoalsWidget({super.key, required this.goals, this.onViewAll});

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
                'Tujuan Menabung',
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
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: goals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              return _GoalCard(goal: goals[i], isDark: isDark)
                  .animate()
                  .fadeIn(delay: (i * 80).ms, duration: 350.ms);
            },
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final bool isDark;
  const _GoalCard({required this.goal, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress.clamp(0.0, 1.0);
    final pct = (progress * 100).toInt();
    final goalColor = Color(goal.colorHex);

    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        width: 152,
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
            // Icon — small and clean
            Icon(goal.icon, size: 22, color: goalColor),

            // Title
            Text(
              goal.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
              ),
            ),

            // Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$pct%',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: goalColor,
                      ),
                    ),
                    Text(
                      'dari target',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isDark
                            ? AppTheme.textDarkSecondary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(
                        height: 5,
                        color: isDark
                            ? Colors.white.withOpacity(0.07)
                            : Colors.black.withOpacity(0.06),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 5,
                          color: goalColor,
                        ),
                      ).animate().scaleX(
                        alignment: Alignment.centerLeft,
                        duration: 900.ms,
                        curve: Curves.easeOutExpo,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
