import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../controllers/app_controller.dart';

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
            itemCount: goals.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              if (i == goals.length) {
                return _AddGoalCard(isDark: isDark);
              }
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
      onTap: () {
        HapticFeedback.selectionClick();
        _showTopUpGoalSheet(context, goal, isDark);
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _showDeleteGoalDialog(context, goal, isDark);
      },
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

  void _showDeleteGoalDialog(BuildContext context, SavingsGoalModel goal, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        title: Text('Hapus Tujuan', style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus tujuan "${goal.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<AppController>().deleteSavingsGoal(goal.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Tujuan berhasil dihapus' : 'Gagal menghapus tujuan', style: GoogleFonts.inter(color: Colors.white)),
                    backgroundColor: success ? AppTheme.income : AppTheme.accentRose,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showTopUpGoalSheet(BuildContext context, SavingsGoalModel goal, bool isDark) {
    final amountCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tambah Saldo Tujuan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Nominal (Rp)',
                  filled: true,
                  fillColor: isDark ? AppTheme.surfaceDark2 : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final addAmount = double.tryParse(amountCtrl.text) ?? 0;
                  if (addAmount <= 0) return;
                  final newGoal = SavingsGoalModel(
                    id: goal.id,
                    title: goal.title,
                    targetAmount: goal.targetAmount,
                    currentAmount: goal.currentAmount + addAmount,
                    icon: goal.icon,
                    colorHex: goal.colorHex,
                  );
                  final success = await context.read<AppController>().updateSavingsGoal(goal.id, newGoal.toJson());
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saldo berhasil ditambahkan!'), backgroundColor: AppTheme.income));
                      Navigator.pop(sheetCtx);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambah saldo'), backgroundColor: AppTheme.accentRose));
                    }
                  }
                },
                child: const Text('Simpan'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _AddGoalCard extends StatelessWidget {
  final bool isDark;
  const _AddGoalCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAddGoalSheet(context, isDark);
      },
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 22, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary),
            const SizedBox(height: 6),
            Text('Tambah', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context, bool isDark) {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tambah Tujuan Menabung', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(hintText: 'Nama Tujuan', filled: true, fillColor: isDark ? AppTheme.surfaceDark2 : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(hintText: 'Target Terkumpul (Rp)', filled: true, fillColor: isDark ? AppTheme.surfaceDark2 : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final title = titleCtrl.text.trim();
                  final target = double.tryParse(targetCtrl.text) ?? 0;
                  if (title.isEmpty || target <= 0) return;
                  
                  final data = {
                    "id": "goal_${DateTime.now().millisecondsSinceEpoch}",
                    "title": title,
                    "targetAmount": target,
                    "currentAmount": 0.0,
                    "icon": "savings",
                    "colorHex": 0xFF3B82F6
                  };
                  final success = await context.read<AppController>().addSavingsGoal(data);
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tujuan berhasil ditambahkan!'), backgroundColor: AppTheme.income));
                      Navigator.pop(sheetCtx);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambahkan tujuan'), backgroundColor: AppTheme.accentRose));
                    }
                  }
                },
                child: const Text('Buat Tujuan'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
