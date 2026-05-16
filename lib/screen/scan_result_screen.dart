import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../models/models.dart';
import '../themes/app_themes.dart';
import '../widgets/shared_widgets.dart';

class ScanResultScreen extends StatefulWidget {
  final String scannedTitle;
  final double scannedAmount;
  final String rawText;

  const ScanResultScreen({
    super.key,
    required this.scannedTitle,
    required this.scannedAmount,
    required this.rawText,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  String? _selectedAccountId;
  String _selectedCategory = 'Belanja';

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.scannedTitle);
    _amountCtrl = TextEditingController(text: widget.scannedAmount.toStringAsFixed(0));
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
        const SnackBar(content: Text('Data tidak valid')),
      );
      return;
    }

    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: _selectedCategory,
      amount: amount,
      isExpense: true,
      date: DateTime.now(),
      icon: Icons.receipt_long_rounded,
      status: TransactionStatus.completed,
      accountId: _selectedAccountId,
    );

    final appCtrl = context.read<AppController>();
    final success = await appCtrl.addTransaction(newTx);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil menyimpan dari struk!')),
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

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: FintechAppBar(title: 'Review Hasil Scan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryAccent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Total Terdeteksi',
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
                          ),
                        ),
                      ),
                    ],
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
                  items: ['Belanja', 'Makanan', 'Transportasi', 'Hiburan', 'Lainnya']
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
              label: 'Bayar Menggunakan',
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
            
            const SizedBox(height: 20),
            
            // Raw text toggle (Optional: for debugging/manual check)
            Center(
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Teks Asli Scan'),
                      content: SingleChildScrollView(child: Text(widget.rawText)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Lihat Teks Hasil Scan',
                  style: GoogleFonts.inter(color: AppTheme.primaryAccent),
                ),
              ),
            ),
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
