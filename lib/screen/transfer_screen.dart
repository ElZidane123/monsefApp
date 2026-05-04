import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../models/dummy_data.dart';
import '../provider/app_provider.dart';
import '../service/app_routes.dart';
import '../themes/app_themes.dart';
import '../widgets/shared_widgets.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> with TickerProviderStateMixin {
  AccountModel? _selectedAccount;
  String _selectedContact = '';
  String _amountStr = '0';
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  bool get _isValid => _selectedAccount != null && _selectedContact.isNotEmpty && double.tryParse(_amountStr) != null && double.parse(_amountStr) > 0;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (key == '.') {
        if (!_amountStr.contains('.')) _amountStr += '.';
      } else {
        if (_amountStr == '0') {
          _amountStr = key;
        } else {
          if (_amountStr.contains('.')) {
            final parts = _amountStr.split('.');
            if (parts[1].length < 2) _amountStr += key;
          } else {
            if (_amountStr.length < 8) _amountStr += key;
          }
        }
      }
    });
  }

  void _onNext() {
    final amount = double.tryParse(_amountStr) ?? 0;
    context.read<AppProvider>().setTransferFrom(_selectedAccount!);
    context.read<AppProvider>().setTransferTo(_selectedContact);
    context.read<AppProvider>().setTransferAmount(amount);
    Navigator.pushNamed(context, AppRoutes.review);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double amount = double.tryParse(_amountStr) ?? 0;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: FintechAppBar(title: 'Transfer Funds'),
      body: SlideTransition(
        position: _slideAnim,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FROM
                    Text('FROM', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary, letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    _AccountSelector(
                      accounts: DummyData.accounts,
                      selected: _selectedAccount,
                      isDark: isDark,
                      onSelect: (a) => setState(() => _selectedAccount = a),
                    ),
                    const SizedBox(height: 20),

                    // TO
                    Text('TO', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary, letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    _ContactSelector(
                      selected: _selectedContact,
                      isDark: isDark,
                      onSelect: (c) => setState(() => _selectedContact = c),
                    ),
                    const SizedBox(height: 28),

                    // Amount display
                    Center(
                      child: Column(
                        children: [
                          Text('AMOUNT TO TRANSFER', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary, letterSpacing: 0.8)),
                          const SizedBox(height: 10),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            child: Text(
                              key: ValueKey(_amountStr),
                              '\$ $_amountStr',
                              style: GoogleFonts.dmSans(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: amount > 0 ? (isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary) : (isDark ? AppTheme.textDarkSecondary : AppTheme.textMuted),
                                letterSpacing: -1.5,
                              ),
                            ),
                          ),
                          if (_selectedAccount != null && amount > _selectedAccount!.balance)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('Insufficient balance', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFFEF4444), fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Custom numpad
                    _CustomNumpad(onKey: _onKey, isDark: isDark),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: PrimaryButton(
                label: 'Next',
                onTap: _isValid ? _onNext : null,
                isEnabled: _isValid && (amount <= (_selectedAccount?.balance ?? 0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSelector extends StatelessWidget {
  final List<AccountModel> accounts;
  final AccountModel? selected;
  final bool isDark;
  final ValueChanged<AccountModel> onSelect;

  const _AccountSelector({required this.accounts, required this.selected, required this.isDark, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAccountPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white12 : AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primaryAccent, size: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: selected == null
                  ? Text('Select account', style: GoogleFonts.dmSans(fontSize: 14, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textMuted))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selected!.name, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                        Text('****${selected!.lastFourDigits} · ${selected!.shortBalance}', style: GoogleFonts.dmSans(fontSize: 12, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary)),
                      ],
                    ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Select Account', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
            const SizedBox(height: 16),
            ...accounts.map((a) => GestureDetector(
              onTap: () { onSelect(a); Navigator.pop(ctx); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: a == selected ? AppTheme.primaryAccent.withOpacity(0.08) : (isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: a == selected ? AppTheme.primaryAccent.withOpacity(0.3) : Colors.transparent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_outlined, color: AppTheme.primaryAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                        Text('****${a.lastFourDigits}', style: GoogleFonts.dmSans(fontSize: 12, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary)),
                      ],
                    )),
                    Text(a.shortBalance, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ContactSelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelect;

  static const contacts = ['Sarah Johnson', 'Mike Chen', 'Emma Davis', 'James Wilson', 'Savings Account ****5678'];

  const _ContactSelector({required this.selected, required this.isDark, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showContactPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white12 : AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person_add_outlined, color: Color(0xFF7C3AED), size: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selected.isEmpty ? 'Select account or contact' : selected,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: selected.isEmpty ? FontWeight.w400 : FontWeight.w600,
                  color: selected.isEmpty ? (isDark ? AppTheme.textDarkSecondary : AppTheme.textMuted) : (isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showContactPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Send To', style: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
            const SizedBox(height: 16),
            ...contacts.map((c) => GestureDetector(
              onTap: () { onSelect(c); Navigator.pop(ctx); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c == selected ? AppTheme.primaryAccent.withOpacity(0.08) : (isDark ? AppTheme.surfaceDark2 : AppTheme.bgLight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: const Color(0xFF7C3AED).withOpacity(0.15), child: Text(c[0], style: GoogleFonts.dmSans(color: const Color(0xFF7C3AED), fontWeight: FontWeight.w700))),
                    const SizedBox(width: 12),
                    Text(c, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _CustomNumpad extends StatelessWidget {
  final ValueChanged<String> onKey;
  final bool isDark;

  const _CustomNumpad({required this.onKey, required this.isDark});

  static const keys = [
    ['1','2','3'],
    ['4','5','6'],
    ['7','8','9'],
    ['.','0','⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: keys.map((row) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: row.map((k) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => onKey(k),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 62,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Center(
                    child: k == '⌫'
                        ? Icon(Icons.backspace_outlined, size: 20, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)
                        : Text(k, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)),
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
      )).toList(),
    );
  }
}