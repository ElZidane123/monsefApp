import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/app_routes.dart';
import '../themes/app_themes.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  static const _items = [
    (icon: Icons.edit_outlined, label: 'Manual', route: AppRoutes.manualEntry),
    (icon: Icons.document_scanner_outlined, label: 'Scan', route: AppRoutes.qrScan),
    (icon: Icons.mic_none_rounded, label: 'Suara', route: AppRoutes.voiceNote),
    (icon: Icons.tune_rounded, label: 'Filter', route: AppRoutes.history),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _items.asMap().entries.map((e) {
          final item = e.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: e.key == 0 ? 0 : 6,
                right: e.key == _items.length - 1 ? 0 : 6,
              ),
              child: _ActionTile(
                icon: item.icon,
                label: item.label,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (item.label == 'Manual') {
                    _showManualSheet(context, isDark);
                  } else {
                    Navigator.pushNamed(context, item.route);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showManualSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.15)
                      : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Tambah Transaksi',
              style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih jenis transaksi',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            _sheetRow(
              context, isDark,
              icon: Icons.arrow_downward_rounded,
              color: AppTheme.income,
              title: 'Pemasukan',
              subtitle: 'Gaji, transferan masuk',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.manualEntry,
                    arguments: 'income');
              },
            ),
            const SizedBox(height: 12),
            _sheetRow(
              context, isDark,
              icon: Icons.arrow_upward_rounded,
              color: AppTheme.expense,
              title: 'Pengeluaran',
              subtitle: 'Belanja, tagihan, dll.',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.manualEntry,
                    arguments: 'expense');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetRow(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                      )),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18,
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _pressed
              ? (widget.isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight)
              : (widget.isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.softShadow(widget.isDark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 22,
              color: widget.isDark
                  ? AppTheme.textDarkPrimary
                  : AppTheme.textPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: widget.isDark
                    ? AppTheme.textDarkSecondary
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}