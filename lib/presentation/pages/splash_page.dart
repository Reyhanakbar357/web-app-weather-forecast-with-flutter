import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/core/themes/app_theme.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashPage({super.key, required this.onComplete});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _orbitCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

    _progressCtrl.forward().then((_) {
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), widget.onComplete);
      }
    });
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: Stack(
        children: [
          // Animated background orbs
          AnimatedBuilder(
            animation: _orbitCtrl,
            builder: (_, __) {
              final t = _orbitCtrl.value * 2 * math.pi;
              return Stack(children: [
                Positioned(
                  top: -100 + math.sin(t) * 40,
                  right: -100 + math.cos(t) * 30,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.cyan.withAlphaSafe(0.12),
                        Colors.transparent
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80 + math.cos(t) * 50,
                  left: -80 + math.sin(t) * 30,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.purple.withAlphaSafe(0.10),
                        Colors.transparent
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  left: MediaQuery.of(context).size.width * 0.5 + math.cos(t) * 60,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.pink.withAlphaSafe(0.07),
                        Colors.transparent
                      ]),
                    ),
                  ),
                ),
              ]);
            },
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing weather emoji
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Container(
                    width: 110 + _pulseCtrl.value * 6,
                    height: 110 + _pulseCtrl.value * 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.cyan.withAlphaSafe(0.15 + _pulseCtrl.value * 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text('🌤',
                          style: TextStyle(fontSize: 60 + _pulseCtrl.value * 4)),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.5, 0.5),
                    curve: Curves.elasticOut,
                    duration: 900.ms),

                const SizedBox(height: 28),

                // Logo text
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.cyan, AppColors.purple, AppColors.pink],
                    stops: [0.0, 0.5, 1.0],
                  ).createShader(b),
                  child: Text('SkyView',
                      style: GoogleFonts.syne(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ).animate(delay: 300.ms).fadeIn(duration: 500.ms).slideY(begin: .2),

                const SizedBox(height: 8),

                Text('Real-time Weather Everywhere',
                    style: TextStyle(
                        color: AppColors.textSub.withAlphaSafe(0.8),
                        fontSize: 14,
                        letterSpacing: .3))
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 60),

                // Progress bar
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressCtrl,
                        builder: (_, __) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: LinearProgressIndicator(
                              value: _progressCtrl.value,
                              minHeight: 3,
                              backgroundColor: Colors.white.withAlphaSafe(0.07),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.cyan),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text('Memuat data cuaca...',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12))
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 400.ms),
                    ],
                  ),
                ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),

          // Version badge
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text('v2.0.0 · Made with ❤️ in Flutter',
                  style: TextStyle(
                      color: AppColors.textMuted.withAlphaSafe(0.5),
                      fontSize: 11))
                  .animate(delay: 800.ms)
                  .fadeIn(duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }
}
