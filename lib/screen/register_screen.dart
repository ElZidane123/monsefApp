import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/app_controller.dart';
import '../themes/app_themes.dart';
import '../service/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  void _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom')),
      );
      return;
    }

    final controller = context.read<AppController>();
    final success = await controller.register(name, email, pass);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pendaftaran Berhasil!', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (controller.user?.pin == null || controller.user!.pin!.isEmpty) {
        Navigator.pushReplacementNamed(context, AppRoutes.pinSetup);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else if (mounted && controller.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Gagal mendaftar', style: GoogleFonts.inter())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.watch<AppController>().isLoading;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.income.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add_rounded, size: 40, color: AppTheme.income),
              ).animate().scale(delay: 200.ms, duration: 400.ms),
              
              const SizedBox(height: 32),
              Text(
                'Buat Akun Baru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
              
              const SizedBox(height: 8),
              Text(
                'Mulai perjalanan finansialmu yang lebih baik bersama Monsef.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
              
              const SizedBox(height: 48),
              
              // Name Field
              TextField(
                controller: _nameCtrl,
                style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline, color: isDark ? Colors.white54 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // Email Field
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Alamat Email',
                  prefixIcon: Icon(Icons.email_outlined, color: isDark ? Colors.white54 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 16),
              
              // Password Field
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                style: GoogleFonts.inter(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Kata Sandi',
                  prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.white54 : Colors.black54),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.white54 : Colors.black54),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                  filled: true,
                  fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 48),
              
              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.income,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : _register,
                  child: isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Daftar Sekarang',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 24),
              
              // Login Link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun? ',
                      style: GoogleFonts.inter(color: isDark ? Colors.white54 : Colors.black54),
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: GoogleFonts.inter(color: AppTheme.income, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
