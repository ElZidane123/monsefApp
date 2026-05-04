import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dummy_data.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../widgets/shared_widgets.dart';

class WealthInvestmentScreen extends StatefulWidget {
  const WealthInvestmentScreen({super.key});

  @override
  State<WealthInvestmentScreen> createState() => _WealthInvestmentScreenState();
}

class _WealthInvestmentScreenState extends State<WealthInvestmentScreen> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  int _touchedIndex = -1;
  final double _totalPortfolio = 248500.00;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: FintechAppBar(title: 'Wealth & Investments'),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            children: [
              _PortfolioCard(total: _totalPortfolio, isDark: isDark),
              const SizedBox(height: 20),
              _AssetAllocationCard(touchedIndex: _touchedIndex, onTouch: (i) => setState(() => _touchedIndex = i), isDark: isDark),
              const SizedBox(height: 20),
              _TopPerformingSection(isDark: isDark),
              const SizedBox(height: 20),
              _AdvisoryCard(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final double total;
  final bool isDark;

  const _PortfolioCard({required this.total, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B3E), Color(0xFF1A3561), Color(0xFF0F2957)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF1A3561).withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(right: -15, top: -25, child: Container(width: 110, height: 110, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 14)),
                  const SizedBox(width: 8),
                  Text('Total Portfolio Value', style: GoogleFonts.dmSans(color: Colors.white.withOpacity(0.65), fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('\$${total.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: GoogleFonts.dmSans(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.8)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('+4.2%', style: GoogleFonts.dmSans(color: const Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mini bar chart
              SizedBox(
                height: 44,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [0.4, 0.55, 0.45, 0.65, 0.6, 0.75, 0.7, 0.85, 0.8, 1.0].map((h) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          height: 44 * h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(h == 1.0 ? 0.9 : 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssetAllocationCard extends StatelessWidget {
  final int touchedIndex;
  final ValueChanged<int> onTouch;
  final bool isDark;

  const _AssetAllocationCard({required this.touchedIndex, required this.onTouch, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final allocations = DummyData.assetAllocations;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.06), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Asset Allocation', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary, letterSpacing: -0.3)),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            if (response?.touchedSection != null) {
                              onTouch(response!.touchedSection!.touchedSectionIndex);
                            } else {
                              onTouch(-1);
                            }
                          },
                        ),
                        sections: allocations.asMap().entries.map((e) {
                          final isTouched = e.key == touchedIndex;
                          return PieChartSectionData(
                            value: e.value.percentage,
                            color: Color(e.value.colorHex),
                            radius: isTouched ? 42 : 36,
                            title: '',
                            showTitle: false,
                          );
                        }).toList(),
                        centerSpaceRadius: 30,
                        sectionsSpace: 3,
                      ),
                    ),
                    Text('100%', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  children: allocations.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(a.colorHex), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(a.label, style: GoogleFonts.dmSans(fontSize: 13, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary))),
                        Text('${a.percentage.toInt()}%', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopPerformingSection extends StatelessWidget {
  final bool isDark;

  const _TopPerformingSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final assets = DummyData.topAssets;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Top Performing', actionLabel: 'View All', onAction: () {}),
        const SizedBox(height: 12),
        ...assets.asMap().entries.map((e) => AnimatedListItem(
          index: e.key,
          child: _AssetTile(asset: e.value, isDark: isDark, onTap: () => _showDetail(context, e.value, isDark)),
        )),
      ],
    );
  }

  void _showDetail(BuildContext context, InvestmentAsset asset, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _AssetDetailSheet(asset: asset, isDark: isDark),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final InvestmentAsset asset;
  final bool isDark;
  final VoidCallback onTap;

  const _AssetTile({required this.asset, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPositive = asset.changePercent >= 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(asset.emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(asset.name, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                  Text('${asset.ticker} · ${asset.detail}', style: GoogleFonts.dmSans(fontSize: 12, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${asset.value.toStringAsFixed(2)}', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary, letterSpacing: -0.3)),
                Row(
                  children: [
                    Icon(isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 11, color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                    Text('${asset.changePercent.abs().toStringAsFixed(2)}%', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetDetailSheet extends StatelessWidget {
  final InvestmentAsset asset;
  final bool isDark;

  const _AssetDetailSheet({required this.asset, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isPositive = asset.changePercent >= 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(asset.emoji, style: const TextStyle(fontSize: 24)))),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(asset.name, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                Text(asset.ticker, style: GoogleFonts.dmSans(fontSize: 13, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary)),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _StatItem(label: 'Current Value', value: '\$${asset.value.toStringAsFixed(2)}', isDark: isDark),
            _StatItem(label: 'Change', value: '${isPositive ? '+' : ''}${asset.changePercent.toStringAsFixed(2)}%', valueColor: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444), isDark: isDark),
            _StatItem(label: 'Holdings', value: asset.detail, isDark: isDark),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: PrimaryButton(label: 'Buy More', onTap: () => Navigator.pop(context))),
            const SizedBox(width: 12),
            Expanded(child: SecondaryButton(label: 'Sell', onTap: () => Navigator.pop(context))),
          ]),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;

  const _StatItem({required this.label, required this.value, this.valueColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary)),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: valueColor ?? (isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary))),
    ]);
  }
}

class _AdvisoryCard extends StatelessWidget {
  final bool isDark;
  const _AdvisoryCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.06), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.12), shape: BoxShape.circle), child: const Icon(Icons.support_agent_rounded, color: AppTheme.primaryAccent, size: 24)),
          const SizedBox(height: 12),
          Text('Need expert guidance?', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text('Talk to a certified advisor to optimize your allocation and tax strategy.', textAlign: TextAlign.center, style: GoogleFonts.dmSans(fontSize: 13, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Schedule Advisory Session', onTap: () {}),
        ],
      ),
    );
  }
}