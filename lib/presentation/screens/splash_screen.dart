import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/decorations/harag_painter.dart';
import '../widgets/ethiopian_cross_icon.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Navigate to Main Navigation Screen after 2.2 seconds
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (_, __, ___) => const MainNavigationScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF132235), // Deep Sacred Church Navy
      body: Stack(
        children: [
          // Background celestial gradient glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.9,
                  colors: [
                    Color(0xFF1D334D),
                    Color(0xFF132235),
                    Color(0xFF0C1622),
                  ],
                ),
              ),
            ),
          ),

          // Central Sacred Content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),

                        // Golden Ethiopian Orthodox Cross with Radiant Glow
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.goldMuted.withOpacity(0.08),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldAccent.withOpacity(0.22),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: EthiopianCrossIcon(
                              size: 72,
                              color: Color(0xFFF1D28A), // Radiant liturgical gold
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Sacred Invocation
                        Text(
                          'በስመ አብ ወወልድ ወመንፈስ ቅዱስ አሐዱ አምላክ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Noto Sans Ethiopic',
                            fontSize: 12,
                            letterSpacing: 0.8,
                            color: AppColors.goldMuted.withOpacity(0.75),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Main Title in Ge'ez
                        const Text(
                          'መዝሙረ ዳዊት',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Noto Serif Ethiopic',
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Color(0xFFF7F3EB), // Warm ivory gold
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          'my Mezmure Dawit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2.0,
                            color: AppColors.goldAccent.withOpacity(0.9),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Motto
                        Text(
                          'Memorize • Meditate • Pray',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.4,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Traditional Harag Divider
                        SizedBox(
                          width: 180,
                          height: 14,
                          child: CustomPaint(
                            painter: HaragPainter(
                              color: AppColors.goldMuted.withOpacity(0.6),
                              repeatCount: 5,
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // Peaceful spiritual motto at bottom
                        Text(
                          '«መዝሙር በልብህ፥ ጸሎት ለመንገድህ»\n“A Psalm in your heart, a prayer for your journey.”',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.6,
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
