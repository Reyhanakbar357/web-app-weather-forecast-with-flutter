import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/core/themes/app_theme.dart';
import 'package:weather_app/core/utils/responsive_utils.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/presentation/providers/weather_provider.dart';
import 'package:weather_app/presentation/widgets/common.dart';

// ── HEADER ──────────────────────────────────────────────────
class HomeHeader extends StatelessWidget {
  final WeatherProvider provider;
  final WeatherEntity weather;
  final VoidCallback onSearchTab;

  const HomeHeader({
    super.key,
    required this.provider,
    required this.weather,
    required this.onSearchTab,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = provider.favorites.contains(weather.cityName);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GlowIconButton(
            icon: Icons.search_rounded,
            onTap: onSearchTab,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: AppColors.cyan, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        weather.cityName,
                        style: GoogleFonts.syne(
                          fontSize: RS.fontSize(context, 18),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${weather.countryCode} · Diperbarui ${TimeOfDay.now().format(context)}',
                  style: TextStyle(color: AppColors.textSub.withAlphaSafe(0.8), fontSize: RS.fontSize(context, 11)),
                ),
              ],
            ),
          ),
          // Tombol GPS — lacak lokasi saat ini
          _GpsButton(provider: provider),
          const SizedBox(width: 8),
          GlowIconButton(
            icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            active: isFav,
            activeColor: AppColors.pink,
            onTap: () => provider.toggleFavorite(weather.cityName),
          ),
          const SizedBox(width: 8),
          GlowIconButton(
            icon: Icons.notifications_none_rounded,
            active: provider.notifEnabled,
            activeColor: AppColors.amber,
            onTap: () => provider.toggleNotification(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -.2);
  }
}

/// Tombol GPS dengan animasi loading saat sedang melacak lokasi
class _GpsButton extends StatefulWidget {
  final WeatherProvider provider;
  const _GpsButton({required this.provider});

  @override
  State<_GpsButton> createState() => _GpsButtonState();
}

class _GpsButtonState extends State<_GpsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void didUpdateWidget(_GpsButton old) {
    super.didUpdateWidget(old);
    if (widget.provider.isLocating) {
      _spinCtrl.repeat();
    } else {
      _spinCtrl.stop();
      _spinCtrl.reset();
    }
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocating = widget.provider.isLocating;
    return GestureDetector(
      onTap: isLocating ? null : () => widget.provider.fetchCurrentLocation(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isLocating
              ? AppColors.cyan.withAlphaSafe(0.2)
              : Colors.white.withAlphaSafe(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLocating
                ? AppColors.cyan.withAlphaSafe(0.6)
                : Colors.white.withAlphaSafe(0.12),
          ),
        ),
        child: Center(
          child: isLocating
              ? RotationTransition(
                  turns: _spinCtrl,
                  child: const Icon(Icons.sync_rounded,
                      color: AppColors.cyan, size: 20),
                )
              : const Icon(Icons.my_location_rounded,
                  color: AppColors.cyan, size: 20),
        ),
      ),
    );
  }
}



// ── HERO CARD (Suhu & Kondisi) ──────────────────────────────
class HomeHeroCard extends StatelessWidget {
  final WeatherEntity weather;
  final WeatherProvider provider;
  final VoidCallback onRefresh;

  const HomeHeroCard({
    super.key,
    required this.weather,
    required this.provider,
    required this.onRefresh,
  });

  String _emoji(String code) {
    final id = code.length >= 2 ? code.substring(0, 2) : '01';
    final isNight = DateTime.now().hour < 6 || DateTime.now().hour > 19;
    switch (id) {
      case '01': return isNight ? '🌙' : '☀️';
      case '02': return isNight ? '🌤' : '⛅';
      case '03': case '04': return '☁️';
      case '09': return '🌦';
      case '10': return '🌧';
      case '11': return '⛈️';
      case '13': return '❄️';
      case '50': return '🌫';
      default: return '🌡';
    }
  }

  @override
  Widget build(BuildContext context) {
    final temp = provider.convertTemp(weather.temperature).round();
    final tempMin = provider.convertTemp(weather.tempMin).round();
    final tempMax = provider.convertTemp(weather.tempMax).round();

    return GestureDetector(
      onTap: onRefresh,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderColor: AppColors.cyan.withAlphaSafe(0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cyan.withAlphaSafe(0.08),
            AppColors.purple.withAlphaSafe(0.04),
          ],
        ),
        shadows: [
          BoxShadow(color: AppColors.cyan.withAlphaSafe(0.12), blurRadius: 30),
        ],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: ShaderMask(
                                shaderCallback: (b) => const LinearGradient(
                                  colors: [Colors.white, AppColors.cyan],
                                ).createShader(b),
                                child: Text(
                                  '$temp',
                                  style: GoogleFonts.syne(
                                    fontSize: RS.fontSize(context, 72),
                                    height: 1,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            provider.unitSymbol,
                            style: TextStyle(
                              fontSize: RS.fontSize(context, 24),
                              fontWeight: FontWeight.w700,
                              color: AppColors.cyan,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weather.description.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.textSub,
                          fontSize: RS.fontSize(context, 12),
                          letterSpacing: .5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(_emoji(weather.iconCode), style: TextStyle(fontSize: RS.fontSize(context, 56)))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: -8, end: 8, duration: 2.5.seconds, curve: Curves.easeInOut),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Flexible(child: _MinMaxPill('↓', '$tempMin°', 'Min', AppColors.cyan)),
                const SizedBox(width: 8),
                Flexible(child: _MinMaxPill('↑', '$tempMax°', 'Max', AppColors.orange)),
                const Spacer(),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlphaSafe(0.05),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white.withAlphaSafe(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh_rounded, color: AppColors.textSub, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text('Ketuk perbarui',
                            style: TextStyle(color: AppColors.textSub.withAlphaSafe(0.8), fontSize: RS.fontSize(context, 10)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }
}

class _MinMaxPill extends StatelessWidget {
  final String icon, val, label;
  final Color color;
  const _MinMaxPill(this.icon, this.val, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlphaSafe(0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: color.withAlphaSafe(0.3)),
        ),
        child: Row(
          children: [
            Text(icon, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
            const SizedBox(width: 4),
            Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.white.withAlphaSafe(0.5), fontSize: 10)),
          ],
        ),
      );
}

// ── MAIN STATS ──────────────────────────────────────────────
class HomeMainStats extends StatelessWidget {
  final WeatherEntity weather;
  final WeatherProvider provider;

  const HomeMainStats({super.key, required this.weather, required this.provider});

  @override
  Widget build(BuildContext context) {
    final feelsLike = provider.convertTemp(weather.feelsLike).round();
    final windSpeed = provider.formatWindSpeed(weather.windSpeed);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _StatCol('🌡', 'Terasa', '$feelsLike°', AppColors.cyan)),
              _Divider(),
              Expanded(child: _StatCol('💨', 'Angin', windSpeed, AppColors.purple)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withAlphaSafe(0.08), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatCol('💧', 'Lembap', '${weather.humidity}%', AppColors.pink)),
              _Divider(),
              Expanded(child: _StatCol('⏱', 'Tekanan', '${weather.pressure} hPa', AppColors.amber)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: .05);
  }
}

class _StatCol extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _StatCol(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: RS.space(context, 36),
            height: RS.space(context, 36),
            decoration: BoxDecoration(
              color: color.withAlphaSafe(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withAlphaSafe(0.25)),
            ),
            child: Center(child: Text(icon, style: TextStyle(fontSize: RS.fontSize(context, 16)))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textSub, fontSize: RS.fontSize(context, 11))),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: RS.fontSize(context, 13),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30,
        color: Colors.white.withAlphaSafe(0.08),
        margin: const EdgeInsets.symmetric(horizontal: 10),
      );
}

// ── SUN CARD (Terbit & Terbenam) ────────────────────────────
class HomeSunCard extends StatelessWidget {
  final WeatherEntity weather;

  const HomeSunCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    String formatTime(int ms) =>
        TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(ms * 1000)).format(context);
    final rise = formatTime(weather.sunrise);
    final set = formatTime(weather.sunset);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // Calculate progress with safe division
    final totalDay = weather.sunset - weather.sunrise;
    double prog = 0.0;
    if (totalDay > 0) {
      prog = ((now - weather.sunrise) / totalDay).clamp(0.0, 1.0);
    }
    
    final isDay = now >= weather.sunrise && now <= weather.sunset;
    final color = isDay ? AppColors.amber : AppColors.purple;

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderColor: color.withAlphaSafe(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Matahari', accentColor: color),
          const SizedBox(height: 20),
          Row(
            children: [
              _SunTime(rise, 'Terbit', '🌅'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(double.infinity, 40),
                        painter: _SunArcPainter(prog, color),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Text(
                          isDay ? 'Siang' : 'Malam',
                          style: TextStyle(
                            color: color.withAlphaSafe(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _SunTime(set, 'Terbenam', '🌇'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: .05);
  }
}

class _SunTime extends StatelessWidget {
  final String time, label, emoji;
  const _SunTime(this.time, this.label, this.emoji);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: RS.fontSize(context, 20))),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(color: Colors.white, fontSize: RS.fontSize(context, 12), fontWeight: FontWeight.w700)),
          Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: RS.fontSize(context, 10))),
        ],
      );
}

class _SunArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _SunArcPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    
    // Background arc
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.white.withAlphaSafe(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        rect,
        math.pi,
        math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Sun dot
      final cx = size.width / 2;
      final cy = size.height;
      final rx = size.width / 2;
      final ry = size.height;
      final angle = math.pi + math.pi * progress;
      final sx = cx + rx * math.cos(angle);
      final sy = cy + ry * math.sin(angle);

      // Glow behind sun dot
      canvas.drawCircle(
        Offset(sx, sy),
        10,
        Paint()
          ..color = color.withAlphaSafe(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(
        Offset(sx, sy),
        6,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter old) => old.progress != progress;
}
