import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../themes/app_themes.dart';
import '../service/app_routes.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _currentPin = '';
  bool _isError = false;

  void _onKeyPress(String key) {
    if (_currentPin.length < 6) {
      setState(() {
        _currentPin += key;
        _isError = false;
      });
      if (_currentPin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_currentPin.isNotEmpty) {
      setState(() {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
        _isError = false;
      });
    }
  }

  void _logout() async {
    await context.read<AppController>().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _verifyPin() async {
    final userPin = context.read<AppController>().user?.pin;
    
    // If somehow they reached here without a PIN in the backend, allow them in but they will be prompted on next login
    if (userPin == null || userPin.isEmpty) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    if (_currentPin == userPin) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      setState(() {
        _isError = true;
      });
      
      // Vibrate or show error visually
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN Salah. Silakan coba lagi.'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 1),
        ),
      );
      
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _currentPin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.read<AppController>().user;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryAccent.withOpacity(0.2),
              child: Text(
                user?.avatarInitials ?? '??',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryAccent,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'Selamat Datang Kembali',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?.name ?? 'Pengguna',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 48),
            
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
                    color: _isError
                        ? Colors.redAccent
                        : isFilled 
                            ? AppTheme.primaryAccent 
                            : (isDark ? Colors.white24 : Colors.black12),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 24),
            
            TextButton(
              onPressed: _logout,
              child: Text(
                'Bukan Anda? Logout',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const Spacer(),
            
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
