import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../widgets/shared_widgets.dart';

class VoiceResultScreen extends StatefulWidget {
  final String parsedTitle;
  final double parsedAmount;
  final bool initialIsExpense;
  final String initialCategory;
  final String rawText;

  const VoiceResultScreen({
    super.key,
    required this.parsedTitle,
    required this.parsedAmount,
    required this.initialIsExpense,
    required this.initialCategory,
    required this.rawText,
  });

  @override
  State<VoiceResultScreen> createState() => _VoiceResultScreenState();
}

class _VoiceResultScreenState extends State<VoiceResultScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  late bool _isExpense;
  String? _selectedAccountId;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.parsedTitle);
    _amountCtrl = TextEditingController(text: widget.parsedAmount > 0 ? widget.parsedAmount.toStringAsFixed(0) : '');
    _isExpense = widget.initialIsExpense;
    _selectedCategory = widget.initialCategory.isNotEmpty ? widget.initialCategory : 'Lainnya';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _confirmAndSave() async {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan Nominal tidak valid')),
      );
      return;
    }

    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: _selectedCategory,
      amount: amount,
      isExpense: _isExpense,
      date: DateTime.now(),
      icon: _isExpense ? Icons.mic_rounded : Icons.monetization_on_rounded,
      status: TransactionStatus.completed,
      accountId: _selectedAccountId,
    );

    final appCtrl = context.read<AppController>();
    final success = await appCtrl.addTransaction(newTx);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil menyimpan dari suara!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accounts = context.watch<AppController>().accounts;
    
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    final primaryColor = _isExpense ? AppTheme.expense : AppTheme.income;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: FintechAppBar(title: 'Review Hasil Suara'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Amount Card with Voice Wave graphic
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Nominal Terekam',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Rp',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Raw text display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anda berkata:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${widget.rawText}"',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            Text(
              'Detail Transaksi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Expense / Income Toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpense = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isExpense ? AppTheme.expense.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isExpense ? AppTheme.expense : (isDark ? Colors.white12 : Colors.black12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Pengeluaran',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: _isExpense ? AppTheme.expense : (isDark ? Colors.white54 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpense = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isExpense ? AppTheme.income.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: !_isExpense ? AppTheme.income : (isDark ? Colors.white12 : Colors.black12),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Pemasukan',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: !_isExpense ? AppTheme.income : (isDark ? Colors.white54 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Edit Title
            _buildField(
              icon: Icons.title_rounded,
              label: 'Nama Transaksi',
              child: TextField(
                controller: _titleCtrl,
                style: GoogleFonts.inter(color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
              isDark: isDark,
            ),
            
            const SizedBox(height: 16),
            
            // Edit Category
            _buildField(
              icon: Icons.category_rounded,
              label: 'Kategori',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: isDark ? AppTheme.surfaceDark : Colors.white,
                  items: ['Belanja', 'Makanan', 'Transportasi', 'Hiburan', 'Lainnya', 'Gaji', 'Transfer']
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: GoogleFonts.inter(color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
              isDark: isDark,
            ),
            
            const SizedBox(height: 16),
            
            // Account Selection
            _buildField(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Sumber Dana',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAccountId,
                  isExpanded: true,
                  dropdownColor: isDark ? AppTheme.surfaceDark : Colors.white,
                  items: accounts
                      .map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.name, style: GoogleFonts.inter(color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                ),
              ),
              isDark: isDark,
            ),
            
            const SizedBox(height: 40),
            
            PrimaryButton(
              label: 'Konfirmasi & Simpan',
              onTap: _confirmAndSave,
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryAccent),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
