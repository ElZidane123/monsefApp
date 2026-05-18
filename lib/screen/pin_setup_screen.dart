import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/app_controller.dart';
import '../themes/app_themes.dart';
import '../service/app_routes.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _firstPin = '';
  String _currentPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;

  void _onKeyPress(String key) {
    if (_currentPin.length < 6) {
      setState(() {
        _currentPin += key;
      });
      if (_currentPin.length == 6) {
        _handlePinComplete();
      }
    }
  }

  void _onDelete() {
    if (_currentPin.isNotEmpty) {
      setState(() {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      });
    }
  }

  void _handlePinComplete() async {
    if (!_isConfirming) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _firstPin = _currentPin;
        _currentPin = '';
        _isConfirming = true;
      });
    } else {
      if (_currentPin == _firstPin) {
        setState(() => _isLoading = true);
        final appCtrl = context.read<AppController>();
        final success = await appCtrl.updateProfile({'pin': _currentPin});
        setState(() => _isLoading = false);
        
        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_pin', _currentPin);
          
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(appCtrl.errorMessage ?? 'Gagal menyimpan PIN ke server')),
            );
            setState(() {
              _firstPin = '';
              _currentPin = '';
              _isConfirming = false;
            });
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN tidak cocok, silakan coba lagi.')),
        );
        setState(() {
          _currentPin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              _isConfirming ? 'Konfirmasi PIN Anda' : 'Buat PIN Keamanan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isConfirming 
                ? 'Masukkan kembali 6 digit PIN Anda' 
                : 'PIN digunakan untuk mengamankan data Anda',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 60),
            
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                bool isFilled = index < _currentPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled 
                        ? AppTheme.primaryAccent 
                        : (isDark ? Colors.white24 : Colors.black12),
                  ),
                );
              }),
            ),
            
            const Spacer(),
            
            if (_isLoading)
              const CircularProgressIndicator(color: AppTheme.primaryAccent)
            else
              _buildNumpad(isDark),
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _buildNumpadRow(['1', '2', '3'], isDark),
          const SizedBox(height: 16),
          _buildNumpadRow(['4', '5', '6'], isDark),
          const SizedBox(height: 16),
          _buildNumpadRow(['7', '8', '9'], isDark),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumpadButton('', isDark, isAction: true),
              _buildNumpadButton('0', isDark),
              _buildNumpadButton('del', isDark, isAction: true, icon: Icons.backspace_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadRow(List<String> keys, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _buildNumpadButton(k, isDark)).toList(),
    );
  }

  Widget _buildNumpadButton(String key, bool isDark, {bool isAction = false, IconData? icon}) {
    if (key.isEmpty && !isAction) return const SizedBox(width: 72, height: 72);
    
    return GestureDetector(
      onTap: () {
        if (key == 'del') {
          _onDelete();
        } else if (key.isNotEmpty) {
          _onKeyPress(key);
        }
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isAction ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
        ),
        child: Center(
          child: icon != null 
              ? Icon(icon, size: 28, color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary)
              : Text(
                  key,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
