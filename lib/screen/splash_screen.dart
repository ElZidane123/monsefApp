import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/app_routes.dart';
import '../themes/app_themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // We force a dark-ish premium look regardless of system theme for the splash
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Color(0xFF1E293B), // primaryMid
                    Color(0xFF020617), // bgDark
                  ],
                ),
              ),
            ),
          ),

          // Animated Orbs (Subtle)
          Positioned(
            top: -100,
            right: -100,
            child: _buildAmbientOrb(AppTheme.primaryAccent.withOpacity(0.15), 300),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildAmbientOrb(const Color(0xFF7C3AED).withOpacity(0.1), 250),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 64,
                    color: AppTheme.primaryAccent,
                  ),
                )
                    .animate()
                    .scale(
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                    )
                    .shimmer(
                      delay: 1000.ms,
                      duration: 1500.ms,
                      color: Colors.white.withOpacity(0.3),
                    )
                    .then()
                    .shake(duration: 500.ms, hz: 2),

                const SizedBox(height: 32),

                // Brand Name
                Text(
                  'MONSEF',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: AppTheme.primaryAccent.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 800.ms)
                    .slideY(begin: 0.3, end: 0)
                    .custom(
                      begin: 20,
                      end: 8,
                      duration: 1500.ms,
                      curve: Curves.easeOutQuint,
                      builder: (context, value, child) {
                        return Text(
                          'MONSEF',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: value,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: AppTheme.primaryAccent.withOpacity(0.5),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                const SizedBox(height: 8),

                // Slogan
                Text(
                  'Smart Finance Tracking',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 800.ms),
              ],
            ),
          ),

          // Bottom Loading Indicator (Minimalist)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 40,
                height: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryAccent,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 2000.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).moveY(
          begin: -20,
          end: 20,
          duration: 4000.ms,
          curve: Curves.easeInOut,
        );
  }
}
