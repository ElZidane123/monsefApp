import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../provider/app_provider.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../widgets/shared_widgets.dart';

class ManualEntryScreen extends StatefulWidget {
  final String? initialTitle;
  final double? initialAmount;
  final bool isExpense;

  const ManualEntryScreen({
    super.key,
    this.initialTitle,
    this.initialAmount,
    this.isExpense = true,
  });

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  late bool _isExpense;
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isExpense = widget.isExpense;
    if (widget.initialTitle != null) {
      _titleCtrl.text = widget.initialTitle!;
    }
    if (widget.initialAmount != null) {
      _amountCtrl.text = widget.initialAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
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
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category.isEmpty ? 'Lainnya' : category,
      amount: amount,
      isExpense: _isExpense,
      date: DateTime.now(),
      iconEmoji: _isExpense ? '💸' : '💰',
      status: TransactionStatus.completed,
    );

    final success = await context.read<AppProvider>().addTransaction(newTx);
    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.watch<AppProvider>().isLoading;

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
