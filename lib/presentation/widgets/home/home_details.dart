import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather_app/core/themes/app_theme.dart';
import 'package:weather_app/core/utils/responsive_utils.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/presentation/providers/weather_provider.dart';
import 'package:weather_app/presentation/widgets/common.dart';

// ── EXTRA DETAILS ───────────────────────────────────────────
class HomeExtras extends StatelessWidget {
  final WeatherEntity weather;
  const HomeExtras({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('☁️', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('${weather.cloudiness}%', style: TextStyle(color: Colors.white, fontSize: RS.fontSize(context, 16), fontWeight: FontWeight.w700)),
                  ),
                  Text('Awan', style: TextStyle(color: AppColors.textSub, fontSize: RS.fontSize(context, 11))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('👁', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('${weather.visibility / 1000}km', style: TextStyle(color: Colors.white, fontSize: RS.fontSize(context, 16), fontWeight: FontWeight.w700)),
                  ),
                  Text('Jarak Pandang', style: TextStyle(color: AppColors.textSub, fontSize: RS.fontSize(context, 10))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('💧', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('${(weather.temperature - 2).round()}°', style: TextStyle(color: Colors.white, fontSize: RS.fontSize(context, 16), fontWeight: FontWeight.w700)),
                  ),
                  Text('Titik Embun', style: TextStyle(color: AppColors.textSub, fontSize: RS.fontSize(context, 10))),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: .1);
  }
}

// ── WIND COMPASS ────────────────────────────────────────────
class HomeWindCompass extends StatelessWidget {
  final WeatherEntity weather;
  final WeatherProvider provider;

  const HomeWindCompass({super.key, required this.weather, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(22),
        borderColor: AppColors.cyan.withAlphaSafe(0.2),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass ring
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlphaSafe(0.1), width: 2),
                    ),
                  ),
                  const Positioned(top: 4, child: Text('U', style: TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.w800))),
                  const Positioned(bottom: 4, child: Text('S', style: TextStyle(color: AppColors.textSub, fontSize: 10, fontWeight: FontWeight.w700))),
                  const Positioned(left: 6, child: Text('B', style: TextStyle(color: AppColors.textSub, fontSize: 10, fontWeight: FontWeight.w700))),
                  const Positioned(right: 6, child: Text('T', style: TextStyle(color: AppColors.textSub, fontSize: 10, fontWeight: FontWeight.w700))),
                  
                  // Arrow
                  Transform.rotate(
                    angle: weather.windDeg * (math.pi / 180),
                    child: const Icon(Icons.navigation_rounded, color: AppColors.cyan, size: 36)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: -2, end: 2, duration: 1.seconds),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Arah Angin', accentColor: AppColors.cyan),
                  const SizedBox(height: 8),
                  Text(
                    provider.formatWindSpeed(weather.windSpeed),
                    style: TextStyle(color: Colors.white, fontSize: RS.fontSize(context, 20), fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Berhembus dari arah ${_getWindDirection(weather.windDeg)} dengan kecepatan yang cukup terasa.',
                    style: TextStyle(color: AppColors.textSub.withAlphaSafe(0.9), fontSize: RS.fontSize(context, 11), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: .1);
  }

  String _getWindDirection(double deg) {
    if (deg >= 337 || deg < 22) return 'Utara';
    if (deg >= 22 && deg < 67) return 'Timur Laut';
    if (deg >= 67 && deg < 112) return 'Timur';
    if (deg >= 112 && deg < 157) return 'Tenggara';
    if (deg >= 157 && deg < 202) return 'Selatan';
    if (deg >= 202 && deg < 247) return 'Barat Daya';
    if (deg >= 247 && deg < 292) return 'Barat';
    return 'Barat Laut';
  }
}

// ── WEATHER TIPS ────────────────────────────────────────────
class HomeTips extends StatelessWidget {
  final WeatherEntity weather;
  const HomeTips({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final isRaining = weather.iconCode.startsWith('09') || weather.iconCode.startsWith('10') || weather.iconCode.startsWith('11');
    final isHot = weather.temperature > 30;
    
    String icon = '💡';
    String title = 'Tips Cuaca';
    String msg = 'Cuaca cerah, cocok untuk aktivitas di luar rumah. Jangan lupa tabir surya!';
    List<Color> grad = AppColors.gradAmber;

    if (isRaining) {
      icon = '☂️';
      title = 'Sedia Payung';
      msg = 'Hujan turun. Pastikan bawa payung atau jas hujan sebelum keluar rumah.';
      grad = AppColors.gradCyan;
    } else if (isHot) {
      icon = '🥤';
      title = 'Panas Ekstrem';
      msg = 'Suhu sangat panas. Perbanyak minum air putih agar terhindar dari dehidrasi.';
      grad = AppColors.gradFire;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: NeonBorderCard(
        color: grad.first,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: grad),
                shape: BoxShape.circle,
              ),
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontSize: RS.fontSize(context, 13), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(msg, style: TextStyle(color: AppColors.textSub.withAlphaSafe(0.9), fontSize: RS.fontSize(context, 11), height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: .1);
  }
}

// ── AQI (Air Quality Index) ─────────────────────────────────
class HomeAQI extends StatelessWidget {
  const HomeAQI({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock AQI data for UI completeness
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(22),
        borderColor: AppColors.green.withAlphaSafe(0.3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Kualitas Udara', accentColor: AppColors.green),
                  const SizedBox(height: 12),
                  Text('42 - Baik', style: TextStyle(color: Colors.white, fontSize: RS.fontSize(context, 16), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Tingkat polusi udara rendah. Kualitas udara dapat diterima oleh sebagian besar orang.',
                      style: TextStyle(color: AppColors.textSub, fontSize: RS.fontSize(context, 11), height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    value: 42 / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withAlphaSafe(0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
                  ),
                ),
                const Text('🍃', style: TextStyle(fontSize: 28)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 900.ms).slideY(begin: .1);
  }
}
