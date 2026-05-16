import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../controllers/app_controller.dart';
import '../themes/app_themes.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/transaction_detail_sheet.dart';
import '../utils/currency_formatter.dart';
import 'package:flutter/services.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends State<TransactionHistoryScreen> {
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

  Map<String, List<TransactionModel>> _groupByDate(
      List<TransactionModel> txs) {
    final map = <String, List<TransactionModel>>{};
    for (final t in txs) {
      final now = DateTime.now();
      String label;
      final diff = now.difference(t.date);
      if (diff.inDays == 0) {
        label = 'HARI INI';
      } else if (diff.inDays == 1) {
        label = 'KEMARIN';
      } else {
        label =
            '${_monthName(t.date.month).toUpperCase()} ${t.date.day}, ${t.date.year}';
      }
      map.putIfAbsent(label, () => []).add(t);
    }
    return map;
  }

  String _monthName(int m) =>
      ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][m - 1];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactions = context.watch<AppController>().transactions;
    final filtered = _filtered(transactions);
    final grouped = _groupByDate(filtered);
    final groups = grouped.entries.toList();

    // Summary totals
    double totalIncome = 0, totalExpense = 0;
    for (var tx in filtered) {
      if (tx.isExpense) {
        totalExpense += tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: FintechAppBar(
        title: 'Riwayat Transaksi',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softShadow(isDark),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : AppTheme.borderLight,
                  ),
                ),
                child: Icon(
                  Icons.download_outlined,
                  size: 18,
                  color: isDark
                      ? AppTheme.textDarkPrimary
                      : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Summary row ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryChip(
                    label: 'Masuk',
                    value: CurrencyFormatter.compact(totalIncome),
                    color: AppTheme.accentGreen,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryChip(
                    label: 'Keluar',
                    value: CurrencyFormatter.compact(totalExpense),
                    color: AppTheme.accentRose,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryChip(
                    label: 'Total',
                    value: '${filtered.length} tx',
                    color: AppTheme.primaryAccent,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          // ─── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : AppTheme.borderLight,
                ),
                boxShadow: AppTheme.softShadow(isDark),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) =>
                    setState(() => _searchQuery = v),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark
                      ? AppTheme.textDarkPrimary
                      : AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari merchant, kategori...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: isDark
                        ? AppTheme.textDarkSecondary
                        : AppTheme.textMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark
                        ? AppTheme.textDarkSecondary
                        : AppTheme.textMuted,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() {
                            _searchQuery = '';
                            _searchCtrl.clear();
                          }),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: isDark
                                ? AppTheme.textDarkSecondary
                                : AppTheme.textMuted,
                          ),
                        )
                      : null,
                  filled: false,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: AppTheme.primaryAccent.withOpacity(0.4)),
                  ),
                ),
              ),
            ),
          ),

          // ─── Filter chips ────────────────────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterPill(
                  label: 'Terbaru',
                  icon: Icons.access_time_rounded,
                  active: _sortBy == 'Date',
                  onTap: () =>
                      setState(() => _sortBy = 'Date'),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _FilterPill(
                  label: 'Pemasukan',
                  icon: Icons.arrow_downward_rounded,
                  active: _activeFilter == 'Income',
                  onTap: () => setState(() => _activeFilter =
                      _activeFilter == 'Income' ? '' : 'Income'),
                  isDark: isDark,
                  activeColor: AppTheme.accentGreen,
                ),
                const SizedBox(width: 8),
                _FilterPill(
                  label: 'Pengeluaran',
                  icon: Icons.arrow_upward_rounded,
                  active: _activeFilter == 'Expense',
                  onTap: () => setState(() => _activeFilter =
                      _activeFilter == 'Expense' ? '' : 'Expense'),
                  isDark: isDark,
                  activeColor: AppTheme.accentRose,
                ),
                const SizedBox(width: 8),
                _FilterPill(
                  label: 'Nominal',
                  icon: Icons.sort_rounded,
                  active: _sortBy == 'Amount',
                  onTap: () =>
                      setState(() => _sortBy = 'Amount'),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ─── Transaction list ─────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.surfaceDark
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.softShadow(isDark),
                          ),
                          child: Icon(
                            Icons.search_off_rounded,
                            size: 34,
                            color: isDark
                                ? AppTheme.textDarkSecondary
                                : AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada transaksi',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.textDarkPrimary
                                : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Coba ubah filter atau kata pencarian',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? AppTheme.textDarkSecondary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: groups.length,
                    itemBuilder: (context, gi) {
                      final entry = groups[gi];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 18, bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius:
                                        BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.key,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppTheme.textDarkSecondary
                                        : AppTheme.textSecondary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Group container
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.surfaceDark
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : AppTheme.borderLight,
                              ),
                              boxShadow: AppTheme.softShadow(isDark),
                            ),
                            child: Column(
                              children: entry.value
                                  .asMap()
                                  .entries
                                  .map((e) {
                                final isLast =
                                    e.key == entry.value.length - 1;
                                return AnimatedListItem(
                                  index: gi * 4 + e.key,
                                  child: _TransactionTile(
                                    tx: e.value,
                                    isDark: isDark,
                                    isLast: isLast,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
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

// ─── Summary Chip ────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Pill ─────────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;
  final Color? activeColor;

  const _FilterPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    required this.isDark,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppTheme.primaryAccent;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? color
              : (isDark ? AppTheme.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? color
                : (isDark
                    ? Colors.white.withOpacity(0.08)
                    : AppTheme.borderLight),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: active
                  ? Colors.white
                  : (isDark
                      ? AppTheme.textDarkSecondary
                      : AppTheme.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: active
                    ? Colors.white
                    : (isDark
                        ? AppTheme.textDarkSecondary
                        : AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final bool isDark;
  final bool isLast;

  const _TransactionTile({
    required this.tx,
    required this.isDark,
    required this.isLast,
  });

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Color _statusColor(TransactionStatus s) {
    switch (s) {
      case TransactionStatus.completed:
        return AppTheme.accentGreen;
      case TransactionStatus.pending:
        return AppTheme.accentAmber;
      case TransactionStatus.failed:
        return AppTheme.accentRose;
    }
  }

  String _statusLabel(TransactionStatus s) {
    switch (s) {
      case TransactionStatus.completed:
        return 'Selesai';
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.failed:
        return 'Gagal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        tx.isExpense ? AppTheme.accentRose : AppTheme.accentGreen;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(20),
              bottom: isLast
                  ? const Radius.circular(20)
                  : Radius.zero,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              TransactionDetailSheet.show(context, tx);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  // Icon
                  Stack(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Icon(tx.icon,
                              color: accentColor, size: 22),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.surfaceDark
                                  : Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            tx.isExpense
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: Colors.white,
                            size: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Title + info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.textDarkPrimary
                                : AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.surfaceDark2
                                    : AppTheme.bgLight,
                                borderRadius:
                                    BorderRadius.circular(5),
                              ),
                              child: Text(
                                tx.category,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppTheme.textDarkSecondary
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '· ${_formatTime(tx.date)}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDark
                                    ? AppTheme.textDarkSecondary
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Amount + status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${tx.isExpense ? '-' : '+'} ${CurrencyFormatter.format(tx.amount)}',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor(tx.status)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel(tx.status),
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: _statusColor(tx.status),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 14,
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : AppTheme.borderLight,
          ),
      ],
    );
  }
}