import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/app_themes.dart';

// ─── Custom AppBar ─────────────────────────────────────────────────────────
class FintechAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const FintechAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: showBack
          ? GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : AppTheme.borderLight,
                  ),
                  boxShadow: AppTheme.softShadow(isDark),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: isDark
                      ? AppTheme.textDarkPrimary
                      : AppTheme.textPrimary,
                ),
              ),
            )
          : null,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
          letterSpacing: -0.4,
        ),
      ),
      actions: actions,
    );
  }
}

// ─── Primary Button ────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isEnabled;
  final LinearGradient? gradient;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final active = isEnabled && !isLoading;
    final grad = gradient ?? AppTheme.primaryGradient;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: active ? grad : null,
          color: active ? null : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: grad.colors.first.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  label,
                  style: GoogleFonts.inter(
                    color: active ? Colors.white : Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Secondary Button ──────────────────────────────────────────────────────
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const SecondaryButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark2 : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : AppTheme.borderLight,
          ),
          boxShadow: AppTheme.softShadow(isDark),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppTheme.textDarkPrimary
                  : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer Card ─────────────────────────────────────────────────────────
class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const ShimmerCard({super.key, required this.height, this.width, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader(
      {super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                actionLabel!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryAccent,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Animated List Item (Slide + Fade) ────────────────────────────────────
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 60),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}