import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../provider/app_provider.dart';
import '../themes/app_themes.dart';
import '../widgets/shared_widgets.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = '';
  String _sortBy = 'Date';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TransactionModel> _filtered(List<TransactionModel> all) {
    var list = all.where((t) {
      final q = _searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
    }).toList();

    if (_activeFilter == 'Income') {
      list = list.where((t) => !t.isExpense).toList();
    } else if (_activeFilter == 'Expense') {
      list = list.where((t) => t.isExpense).toList();
    }

    if (_sortBy == 'Amount') {
      list.sort((a, b) => b.amount.compareTo(a.amount));
    } else {
      list.sort((a, b) => b.date.compareTo(a.date));
    }
    return list;
  }

  Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> txs) {
    final map = <String, List<TransactionModel>>{};
    for (final t in txs) {
      final now = DateTime.now();
      String label;
      final diff = now.difference(t.date);
      if (diff.inDays == 0) {
        label = 'TODAY';
      } else if (diff.inDays == 1) {
        label = 'YESTERDAY';
      } else {
        label = '${_monthName(t.date.month).toUpperCase()} ${t.date.day}';
      }
      map.putIfAbsent(label, () => []).add(t);
    }
    return map;
  }

  String _monthName(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactions = context.watch<AppProvider>().transactions;
    final filtered = _filtered(transactions);
    final grouped = _groupByDate(filtered);
    final groups = grouped.entries.toList();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: FintechAppBar(
        title: 'Transaction History',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                ),
                child: Icon(Icons.download_outlined, size: 18, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.dmSans(fontSize: 14, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search merchants, categories...',
                hintStyle: GoogleFonts.dmSans(fontSize: 14, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textMuted),
                prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textMuted, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () => setState(() { _searchQuery = ''; _searchCtrl.clear(); }),
                        child: Icon(Icons.close_rounded, size: 18, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textMuted),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.4)),
                ),
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(label: 'Date', icon: Icons.calendar_today_outlined, active: _sortBy == 'Date', onTap: () => setState(() => _sortBy = 'Date'), isDark: isDark),
                const SizedBox(width: 8),
                _FilterChip(label: 'Income', icon: Icons.arrow_downward_rounded, active: _activeFilter == 'Income', onTap: () => setState(() => _activeFilter = _activeFilter == 'Income' ? '' : 'Income'), isDark: isDark),
                const SizedBox(width: 8),
                _FilterChip(label: 'Expense', icon: Icons.arrow_upward_rounded, active: _activeFilter == 'Expense', onTap: () => setState(() => _activeFilter = _activeFilter == 'Expense' ? '' : 'Expense'), isDark: isDark),
                const SizedBox(width: 8),
                _FilterChip(label: 'Amount', icon: Icons.attach_money_rounded, active: _sortBy == 'Amount', onTap: () => setState(() => _sortBy = 'Amount'), isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Transaction list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textMuted),
                        const SizedBox(height: 12),
                        Text('No transactions found', style: GoogleFonts.dmSans(fontSize: 15, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: groups.length,
                    itemBuilder: (context, gi) {
                      final entry = groups[gi];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 10),
                            child: Text(
                              entry.key,
                              style: GoogleFonts.dmSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          ...entry.value.asMap().entries.map((e) {
                            final globalIndex = gi * 4 + e.key;
                            return AnimatedListItem(
                              index: globalIndex,
                              child: _TransactionTile(tx: e.value, isDark: isDark),
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({required this.label, required this.icon, required this.active, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryAccent : (isDark ? AppTheme.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppTheme.primaryAccent : (isDark ? Colors.white12 : AppTheme.borderLight)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: active ? Colors.white : (isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary)),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : (isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final bool isDark;

  const _TransactionTile({required this.tx, required this.isDark});

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m ${date.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(tx.iconEmoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text('${tx.category} · ${_formatTime(tx.date)}', style: GoogleFonts.dmSans(fontSize: 12, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${tx.isExpense ? '-' : '+'}\$${tx.amount.toStringAsFixed(2)}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: tx.isExpense ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor(tx.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tx.status.name.toUpperCase(),
                  style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: _statusColor(tx.status), letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(TransactionStatus s) {
    switch (s) {
      case TransactionStatus.completed: return const Color(0xFF10B981);
      case TransactionStatus.pending: return const Color(0xFFF59E0B);
      case TransactionStatus.failed: return const Color(0xFFEF4444);
    }
  }
}