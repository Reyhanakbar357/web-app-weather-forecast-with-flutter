import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:weather_app/core/themes/app_theme.dart';
import 'package:weather_app/core/utils/responsive_utils.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/presentation/providers/weather_provider.dart';
import 'package:weather_app/presentation/widgets/common.dart';

// ── Simple data models for forecast display (local to this file) ──
class HourItem {
  final String time;
  final String iconCode;
  final double temp;
  HourItem(this.time, this.iconCode, this.temp);
}

class DayItem {
  final String dayName;
  final String iconCode;
  final double tempMin;
  final double tempMax;
  final int pop;
  DayItem(this.dayName, this.iconCode, this.tempMin, this.tempMax, this.pop);
}

// Helper: generate simulated hourly items from current weather
List<HourItem> _buildHourlyItems(WeatherEntity w) {
  final now = DateTime.now();
  final baseTemp = w.temperature;
  final iconCode = w.iconCode;
  final items = <HourItem>[];
  for (int i = 0; i < 24; i++) {
    final h = now.add(Duration(hours: i));
    final label = i == 0 ? 'Sekarang' : '${h.hour.toString().padLeft(2, '0')}:00';
    // Slight variation in temp
    final variation = (i % 6 < 3) ? i * 0.3 : (6 - i % 6) * 0.3;
    items.add(HourItem(label, iconCode, baseTemp + variation - 1.5));
  }
  return items;
}

// Helper: generate simulated daily items from current weather
List<DayItem> _buildDailyItems(WeatherEntity w) {
  final days = ['Hari Ini', 'Besok', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
  final iconCode = w.iconCode;
  return List.generate(7, (i) {
    final maxTemp = w.tempMax - i * 0.5 + (i % 2 == 0 ? 1 : -0.5);
    final minTemp = w.tempMin - i * 0.3 + (i % 2 == 0 ? -0.5 : 0.3);
    final pop = (w.cloudiness * 0.5 + i * 3).clamp(0, 99).round();
    return DayItem(days[i], iconCode, minTemp, maxTemp, pop);
  });
}

// ── HOURLY FORECAST ─────────────────────────────────────────
class HomeHourlyForecast extends StatelessWidget {
  final WeatherEntity weather;
  final WeatherProvider provider;

  const HomeHourlyForecast({super.key, required this.weather, required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = _buildHourlyItems(weather);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SectionTitle('24 Jam Kedepan'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final temp = provider.convertTemp(item.temp).round();
              final isNow = i == 0;
              final time = item.time;

              return Container(
                width: RS.space(context, 68),
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isNow ? AppColors.cyan.withAlphaSafe(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  border: isNow ? Border.all(color: AppColors.cyan.withAlphaSafe(0.3)) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isNow ? 'Sekarang' : time,
                      style: TextStyle(
                        color: isNow ? AppColors.cyan : AppColors.textSub,
                        fontSize: RS.fontSize(context, 11),
                        fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _WeatherIcon(item.iconCode, size: RS.fontSize(context, 26)),
                    const Spacer(),
                    Text(
                      '$temp°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: RS.fontSize(context, 16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (200 + i * 30).ms).slideX(begin: .1);
            },
          ),
        ),
      ],
    );
  }
}

// ── DAILY FORECAST ──────────────────────────────────────────
class HomeDailyForecast extends StatelessWidget {
  final WeatherEntity weather;
  final WeatherProvider provider;

  const HomeDailyForecast({super.key, required this.weather, required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = _buildDailyItems(weather);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('7 Hari Kedepan', accentColor: AppColors.purple),
            const SizedBox(height: 20),
            ...items.asMap().entries.map((e) {
              final i = e.key;
              final data = e.value;
              final p = provider;
              final isToday = i == 0;
              final isTomorrow = i == 1;
              final dayName = data.dayName;

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  children: [
                    SizedBox(
                      width: RS.space(context, 90),
                      child: Text(
                        isToday ? 'Hari Ini' : isTomorrow ? 'Besok' : dayName,
                        style: TextStyle(
                          color: i == 0 ? AppColors.purpleLight : Colors.white,
                          fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                          fontSize: RS.fontSize(context, 14),
                        ),
                      ),
                    ),
                    _WeatherIcon(data.iconCode, size: RS.fontSize(context, 28)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${data.pop}%',
                        style: TextStyle(color: AppColors.cyan, fontSize: RS.fontSize(context, 11), fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${p.convertTemp(data.tempMin).round()}°',
                      style: TextStyle(color: AppColors.textSub, fontSize: RS.fontSize(context, 14), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    _TempBar(data.tempMin, data.tempMax, 15.0, 38.0),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: RS.space(context, 32),
                      child: Text(
                        '${p.convertTemp(data.tempMax).round()}°',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.white, fontSize: RS.fontSize(context, 14), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (300 + i * 50).ms).slideX(begin: .1);
            }),
            const SizedBox(height: 8),
            AccentButton(
              onTap: () {},
              colors: [Colors.white.withAlphaSafe(0.1), Colors.white.withAlphaSafe(0.05)],
              isSmall: true,
              child: const Center(
                child: Text('Kalender Cuaca 14 Hari', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempBar extends StatelessWidget {
  final double min, max, globalMin, globalMax;
  const _TempBar(this.min, this.max, this.globalMin, this.globalMax);

  @override
  Widget build(BuildContext context) {
    final range = globalMax - globalMin;
    double left = range > 0 ? (min - globalMin) / range : 0;
    double width = range > 0 ? (max - min) / range : 0.1;

    left = left.clamp(0.0, 1.0);
    width = width.clamp(0.05, 1.0 - left);

    return Expanded(
      flex: 3,
      child: Stack(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withAlphaSafe(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FractionallySizedBox(
            widthFactor: left + width,
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: width / (left + width),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.orange]),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CHART SECTION ───────────────────────────────────────────
class HomeChartSection extends StatelessWidget {
  final WeatherEntity weather;
  final WeatherProvider provider;

  const HomeChartSection({super.key, required this.weather, required this.provider});

  @override
  Widget build(BuildContext context) {
    final hourly = _buildHourlyItems(weather).take(12).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(22),
        borderColor: AppColors.pink.withAlphaSafe(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Tren Suhu & Curah Hujan', accentColor: AppColors.pink),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: CustomPaint(
                size: const Size(double.infinity, 180),
                painter: WeatherChartPainter(
                  hourlyItems: hourly,
                  provider: provider,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: .1);
  }
}

class WeatherChartPainter extends CustomPainter {
  final List<HourItem> hourlyItems;
  final WeatherProvider provider;

  WeatherChartPainter({required this.hourlyItems, required this.provider});

  @override
  void paint(Canvas canvas, Size size) {
    if (hourlyItems.isEmpty) return;

    final double width = size.width;
    final double height = size.height - 30;

    final double stepX = hourlyItems.length > 1 ? width / (hourlyItems.length - 1) : width;

    double minTemp = provider.convertTemp(hourlyItems.first.temp);
    double maxTemp = provider.convertTemp(hourlyItems.first.temp);
    for (var h in hourlyItems) {
      final t = provider.convertTemp(h.temp);
      if (t < minTemp) minTemp = t;
      if (t > maxTemp) maxTemp = t;
    }

    if (maxTemp == minTemp) {
      maxTemp += 1;
      minTemp -= 1;
    }
    final range = maxTemp - minTemp;

    final Path path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < hourlyItems.length; i++) {
      final t = provider.convertTemp(hourlyItems[i].temp);
      final x = i * stepX;
      final y = height - ((t - minTemp) / range) * height;
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          p1.dx, p1.dy,
        );
      }

      // Gradient fill
      final fillPath = Path.from(path)
        ..lineTo(points.last.dx, height)
        ..lineTo(points.first.dx, height)
        ..close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(0, 0),
            Offset(0, height),
            [
              AppColors.pink.withAlphaSafe(0.3),
              AppColors.pink.withAlphaSafe(0.0),
            ],
          ),
      );

      // Line
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.pink
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Points and labels
      final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

      for (int i = 0; i < points.length; i++) {
        final point = points[i];

        canvas.drawCircle(point, 4, Paint()..color = Colors.white);
        canvas.drawCircle(point, 2, Paint()..color = AppColors.pink);

        final t = provider.convertTemp(hourlyItems[i].temp).round();
        textPainter.text = TextSpan(
          text: '$t°',
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(point.dx - (textPainter.width / 2), point.dy - textPainter.height - 6),
        );

        textPainter.text = TextSpan(
          text: i == 0 ? 'Skrg' : hourlyItems[i].time,
          style: TextStyle(color: AppColors.textSub.withAlphaSafe(0.8), fontSize: 9),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(point.dx - (textPainter.width / 2), height + 10),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WeatherChartPainter oldDelegate) => true;
}

class _WeatherIcon extends StatelessWidget {
  final String code;
  final double size;
  const _WeatherIcon(this.code, {this.size = 24});

  String _getEmoji() {
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
  Widget build(BuildContext context) => Text(_getEmoji(), style: TextStyle(fontSize: size));
}
