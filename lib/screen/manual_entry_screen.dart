import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../widgets/shared_widgets.dart';

class ManualEntryScreen extends StatefulWidget {
  final String? initialTitle;
  final double? initialAmount;
  final bool isExpense;
  final TransactionModel? existingTransaction;

  const ManualEntryScreen({
    super.key,
    this.initialTitle,
    this.initialAmount,
    this.isExpense = true,
    this.existingTransaction,
  });

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  late bool _isExpense;
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedAccountId;
  IconData _selectedIcon = Icons.payments_rounded;

  final List<IconData> _icons = [
    Icons.payments_rounded,
    Icons.shopping_cart_rounded,
    Icons.coffee_rounded,
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
    Icons.movie_rounded,
    Icons.music_note_rounded,
    Icons.work_rounded,
    Icons.trending_up_rounded,
    Icons.inventory_2_rounded,
    Icons.electric_bolt_rounded,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _isExpense = tx.isExpense;
      _titleCtrl.text = tx.title;
      _amountCtrl.text = tx.amount.toStringAsFixed(0);
      _categoryCtrl.text = tx.category;
      _noteCtrl.text = tx.note ?? '';
      _selectedDate = tx.date;
      _selectedAccountId = tx.accountId;
      _selectedIcon = tx.icon;
    } else {
      _isExpense = widget.isExpense;
      if (widget.initialTitle != null) {
        _titleCtrl.text = widget.initialTitle!;
      }
      if (widget.initialAmount != null) {
        _amountCtrl.text = widget.initialAmount!.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    final title = _titleCtrl.text.trim();
    final amountStr = _amountCtrl.text.trim();
    final category = _categoryCtrl.text.trim();

    if (title.isEmpty || amountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Judul dan Nominal harus diisi')),
      );
      return;
    }

    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nominal tidak valid')),
      );
      return;
    }

    final newTx = TransactionModel(
      id: widget.existingTransaction?.id ?? 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category.isEmpty ? 'Lainnya' : category,
      amount: amount,
      isExpense: _isExpense,
      date: _selectedDate,
      icon: _selectedIcon,
      status: TransactionStatus.completed,
      accountId: _selectedAccountId,
      note: _noteCtrl.text.trim(),
    );

    final appCtrl = context.read<AppController>();
    final success = widget.existingTransaction != null
        ? await appCtrl.updateTransaction(newTx.id, newTx)
        : await appCtrl.addTransaction(newTx);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.watch<AppController>().isLoading;
    final accounts = context.watch<AppController>().accounts;
    
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: FintechAppBar(title: 'Catat Transaksi'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isExpense = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isExpense
                              ? const Color(0xFFEF4444)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Pengeluaran',
                            style: GoogleFonts.dmSans(
                              color: _isExpense
                                  ? Colors.white
                                  : (isDark ? Colors.white54 : Colors.black54),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isExpense = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isExpense
                              ? const Color(0xFF10B981)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Pemasukan',
                            style: GoogleFonts.dmSans(
                              color: !_isExpense
                                  ? Colors.white
                                  : (isDark ? Colors.white54 : Colors.black54),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Icon selector
            _buildLabel('Pilih Ikon', isDark),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryAccent
                            : (isDark ? AppTheme.surfaceDark : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryAccent
                              : (isDark ? Colors.white10 : AppTheme.borderLight),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black54),
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Form
            _buildLabel('Nominal (Rp)', isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _amountCtrl,
              isDark: isDark,
              keyboardType: TextInputType.number,
              hint: 'Contoh: 50000',
              prefix: 'Rp ',
            ),
            const SizedBox(height: 20),

            _buildLabel('Judul Transaksi', isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleCtrl,
              isDark: isDark,
              hint: 'Contoh: Makan Siang',
            ),
            const SizedBox(height: 20),

            _buildLabel('Kategori (Opsional)', isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _categoryCtrl,
              isDark: isDark,
              hint: 'Contoh: Makanan',
            ),
            const SizedBox(height: 20),

            _buildLabel('Pilih Akun', isDark),
            const SizedBox(height: 8),
            _buildAccountDropdown(accounts, isDark),
            const SizedBox(height: 20),

            _buildLabel('Tanggal', isDark),
            const SizedBox(height: 8),
            _buildDatePicker(context, isDark),
            const SizedBox(height: 20),

            _buildLabel('Catatan (Opsional)', isDark),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _noteCtrl,
              isDark: isDark,
              hint: 'Tambahkan catatan...',
            ),
            const SizedBox(height: 40),

            PrimaryButton(
              label: 'Simpan',
              isLoading: isLoading,
              onTap: _saveTransaction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDropdown(List<AccountModel> accounts, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : AppTheme.borderLight,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedAccountId,
          isExpanded: true,
          dropdownColor: isDark ? AppTheme.surfaceDark : Colors.white,
          onChanged: (v) => setState(() => _selectedAccountId = v),
          items: accounts.map((a) {
            return DropdownMenuItem(
              value: a.id,
              child: Text(
                a.name,
                style: GoogleFonts.dmSans(
                  color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : AppTheme.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 18, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: GoogleFonts.dmSans(
                color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    String? prefix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : AppTheme.borderLight,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.dmSans(
          color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix,
          hintStyle: GoogleFonts.dmSans(
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          prefixStyle: GoogleFonts.dmSans(
            color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
