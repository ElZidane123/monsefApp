import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/app_controller.dart';
import '../themes/app_themes.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/action_buttons.dart';
import '../widgets/linked_accounts.dart';
import '../widgets/spending_insights.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/savings_goals_widget.dart';
import '../service/app_routes.dart';
import 'transaction_history_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedNavIndex) {
      case 0:
        return _HomeContent(
          onSeeAllTransactions: () => setState(() => _selectedNavIndex = 1),
          onViewAllAccounts: () => _showNotImplemented(context, 'Akun'),
          onViewAllGoals: () => _showNotImplemented(context, 'Goals'),
        );
      case 1:
        return const TransactionHistoryScreen();
      case 2:
        return const AnalyticsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _HomeContent(
          onSeeAllTransactions: () => setState(() => _selectedNavIndex = 1),
          onViewAllAccounts: () => _showNotImplemented(context, 'Akun'),
          onViewAllGoals: () => _showNotImplemented(context, 'Goals'),
        );
    }
  }

  void _showNotImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur $feature segera hadir!')),
    );
  }

  Widget _buildFAB() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryAccent.withOpacity(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.accentPurple.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _QuickActionsSheet(
        isDark: isDark,
        onAction: (route) {
          Navigator.pop(ctx);
          if (route.isNotEmpty) {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final VoidCallback onSeeAllTransactions;
  final VoidCallback onViewAllAccounts;
  final VoidCallback onViewAllGoals;

  const _HomeContent({
    required this.onSeeAllTransactions,
    required this.onViewAllAccounts,
    required this.onViewAllGoals,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final user = controller.user;
    final transactions = controller.transactions;
    final accounts = controller.accounts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 600 ? 40.0 : 20.0;
        final maxWidth = constraints.maxWidth > 1000 ? 1000.0 : constraints.maxWidth;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  DashboardHeader(user: user)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 20),
                  BalanceCard(user: user)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 20),
                  const ActionButtons()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 300.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 24),
                  SavingsGoalsWidget(
                    goals: controller.savingsGoals,
                    onViewAll: onViewAllGoals,
                  ).animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 24),
                  LinkedAccounts(
                    accounts: accounts,
                    onViewAll: onViewAllAccounts,
                  ).animate()
                      .fadeIn(duration: 400.ms, delay: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 24),
                  const SpendingInsights()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 600.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 24),
                  RecentTransactions(
                    transactions: transactions,
                    isLoading: controller.isLoading,
                    onSeeAll: onSeeAllTransactions,
                  ).animate()
                      .fadeIn(duration: 400.ms, delay: 700.ms)
                      .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


class _QuickActionsSheet extends StatelessWidget {
  final bool isDark;
  final ValueChanged<String> onAction;

  const _QuickActionsSheet({
    required this.isDark,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        label: 'Manual',
        icon: Icons.edit_note_rounded,
        gradient: AppTheme.primaryGradient,
        glow: AppTheme.primaryAccent,
        route: AppRoutes.manualEntry,
        desc: 'Catat manual',
      ),
      (
        label: 'Scan Struk',
        icon: Icons.document_scanner_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF9B59F4), Color(0xFF6C3CE1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glow: AppTheme.accentPurple,
        route: AppRoutes.qrScan,
        desc: 'Scan nota',
      ),
      (
        label: 'Suara',
        icon: Icons.mic_rounded,
        gradient: AppTheme.greenGradient,
        glow: AppTheme.accentGreen,
        route: AppRoutes.voiceNote,
        desc: 'Input suara',
      ),
      (
        label: 'Riwayat',
        icon: Icons.receipt_long_rounded,
        gradient: AppTheme.roseGradient,
        glow: AppTheme.accentRose,
        route: AppRoutes.history,
        desc: 'Lihat semua',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Tambah Transaksi',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih metode pencatatan',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
            physics: const NeverScrollableScrollPhysics(),
            children: actions.map((a) {
              return GestureDetector(
                onTap: () => onAction(a.route),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : AppTheme.borderLight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: a.gradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: a.glow.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(a.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        a.desc,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          color: isDark
                              ? AppTheme.textDarkSecondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}