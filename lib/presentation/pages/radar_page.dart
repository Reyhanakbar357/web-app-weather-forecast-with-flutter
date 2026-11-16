import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/themes/app_theme.dart';
import 'package:weather_app/core/utils/responsive_utils.dart';
import 'package:weather_app/presentation/providers/weather_provider.dart';
import 'package:weather_app/presentation/widgets/common.dart';
import 'main_scaffold.dart';

class RadarPage extends StatefulWidget {
  const RadarPage({super.key});
  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> with TickerProviderStateMixin {
  late AnimationController _radarCtrl;
  late AnimationController _pulseCtrl;
  int _selectedLayer = 0;
  final List<String> _layers = ['🌧 Hujan', '☁️ Awan', '🌡 Suhu', '💨 Angin', '👁 Visibilitas'];

  final List<_WorldCity> _cities = [
    _WorldCity('Medan', 3.6, 98.7, 31, 78, '🇮🇩', '🌤'),
    _WorldCity('Jakarta', -6.2, 106.8, 33, 80, '🇮🇩', '⛅'),
    _WorldCity('Surabaya', -7.3, 112.7, 34, 76, '🇮🇩', '☀️'),
    _WorldCity('Bali', -8.4, 115.2, 29, 82, '🇮🇩', '🌤'),
    _WorldCity('Singapore', 1.3, 103.8, 30, 85, '🇸🇬', '🌦'),
    _WorldCity('KL', 3.1, 101.7, 31, 83, '🇲🇾', '⛈️'),
    _WorldCity('Bangkok', 13.8, 100.5, 35, 70, '🇹🇭', '☀️'),
    _WorldCity('Tokyo', 35.7, 139.7, 18, 55, '🇯🇵', '☁️'),
    _WorldCity('Sydney', -33.9, 151.2, 22, 60, '🇦🇺', '☀️'),
    _WorldCity('Dubai', 25.2, 55.3, 38, 40, '🇦🇪', '☀️'),
    _WorldCity('London', 51.5, -0.1, 12, 75, '🇬🇧', '🌧'),
    _WorldCity('Paris', 48.9, 2.4, 14, 70, '🇫🇷', '⛅'),
    _WorldCity('NY', 40.7, -74.0, 15, 65, '🇺🇸', '☁️'),
    _WorldCity('LA', 34.1, -118.2, 24, 50, '🇺🇸', '☀️'),
    _WorldCity('Cairo', 30.0, 31.2, 28, 35, '🇪🇬', '☀️'),
  ];

  _WorldCity? _selected;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() { _radarCtrl.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  Color _tempColor(int temp) {
    if (temp < 10) return AppColors.cyan;
    if (temp < 20) return const Color(0xFF00B4D8);
    if (temp < 28) return AppColors.green;
    if (temp < 33) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return skyBackground(child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: Row(children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(colors: [AppColors.green, AppColors.cyan]).createShader(b),
          child: Text('Radar Cuaca', style: GoogleFonts.syne(fontSize: RS.fontSize(context, 28), fontWeight: FontWeight.w800, color: Colors.white)),
        ),
        const Spacer(),
        AnimatedBuilder(animation: _pulseCtrl, builder: (_, __) =>
          Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.green.withAlphaSafe(0.5 + _pulseCtrl.value * 0.5),
              boxShadow: [BoxShadow(color: AppColors.green.withAlphaSafe(0.3), blurRadius: 8)]))),
        Text('LIVE', style: TextStyle(color: AppColors.green, fontSize: RS.fontSize(context, 11), fontWeight: FontWeight.w700, letterSpacing: .1)),
      ])).animate().fadeIn(duration: 400.ms),
      const SizedBox(height: 14),

      // Layer selector
      SizedBox(height: 36, child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _layers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => setState(() => _selectedLayer = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedLayer == i ? AppColors.green.withAlphaSafe(0.15) : Colors.white.withAlphaSafe(0.05),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: _selectedLayer == i ? AppColors.green.withAlphaSafe(0.4) : Colors.white.withAlphaSafe(0.08))),
            child: Text(_layers[i], style: TextStyle(
              color: _selectedLayer == i ? AppColors.green : AppColors.textSub,
              fontSize: RS.fontSize(context, 12), fontWeight: _selectedLayer == i ? FontWeight.w700 : FontWeight.w400))),
        ),
      )).animate().fadeIn(delay: 100.ms),
      const SizedBox(height: 14),

      // Radar/Map visual
      Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(children: [
        Expanded(child: GlassCard(
          padding: EdgeInsets.zero, radius: 24,
          borderColor: AppColors.green.withAlphaSafe(0.2),
          child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Stack(children: [
            // Grid background
            CustomPaint(size: const Size(double.infinity, double.infinity), painter: _GridPainter()),
            // Radar sweep
            AnimatedBuilder(animation: _radarCtrl, builder: (_, __) =>
              CustomPaint(size: const Size(double.infinity, double.infinity),
                painter: _RadarSweepPainter(_radarCtrl.value))),
            // City dots
            ..._cities.map((city) => _CityDot(city: city, layer: _selectedLayer, tempColor: _tempColor(city.temp),
              onTap: () => setState(() => _selected = _selected == city ? null : city))),
            // Legend
            Positioned(left: 12, bottom: 12, child: _Legend(layer: _selectedLayer)),
          ])),
        )),
        const SizedBox(height: 12),

        // Selected city card
        if (_selected != null)
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.green.withAlphaSafe(0.25),
            child: Row(children: [
              Text(_selected!.emoji, style: TextStyle(fontSize: RS.fontSize(context, 36))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_selected!.name, style: GoogleFonts.syne(fontSize: RS.fontSize(context, 16), fontWeight: FontWeight.w700, color: Colors.white)),
                Text('${_selected!.flag}  ${_selected!.emoji}  Kelembapan: ${_selected!.humidity}%',
                    style: TextStyle(color: AppColors.textSub, fontSize: RS.fontSize(context, 12))),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${_selected!.temp}°C', style: GoogleFonts.syne(fontSize: RS.fontSize(context, 26), fontWeight: FontWeight.w800, color: _tempColor(_selected!.temp))),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    final p = Provider.of<WeatherProvider>(context, listen: false);
                    final cityName = _selected!.name;
                    p.fetchWeather(cityName);
                    setState(() => _selected = null);
                    // Switch ke tab Beranda (index 0)
                    context.findAncestorStateOfType<MainScaffoldState>()?.switchTab(0);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.cyanDim]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: AppColors.cyan.withAlphaSafe(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: const Text('Lihat Detail →', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ]),
          ).animate().fadeIn().slideY(begin: .1),

        // City grid
        if (_selected == null) ...[
          const SizedBox(height: 4),
          SizedBox(height: 90, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _cities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final c = _cities[i];
              return GestureDetector(
                onTap: () => setState(() => _selected = c),
                child: Container(
                  width: RS.space(context, 78),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlphaSafe(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withAlphaSafe(0.08))),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(c.emoji, style: TextStyle(fontSize: RS.fontSize(context, 22))),
                    const SizedBox(height: 4),
                    Text(c.name, style: TextStyle(color: Colors.white, fontSize: RS.fontSize(context, 10), fontWeight: FontWeight.w600)),
                    Text('${c.temp}°C', style: TextStyle(color: _tempColor(c.temp), fontSize: RS.fontSize(context, 11), fontWeight: FontWeight.w700)),
                  ])),
              );
            },
          )),
        ],
      ]))),
      const SizedBox(height: 80), // For bottom nav bar spacing
    ])));
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlphaSafe(0.04)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final circlePaint = Paint()..color = Colors.white.withAlphaSafe(0.05)..style = PaintingStyle.stroke..strokeWidth = 1;
    final cx = size.width / 2, cy = size.height / 2;
    for (double r = 60; r < size.width; r += 60) {
      canvas.drawCircle(Offset(cx, cy), r, circlePaint);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _RadarSweepPainter extends CustomPainter {
  final double progress;
  const _RadarSweepPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final angle = progress * 2 * math.pi;
    final shader = SweepGradient(
      startAngle: angle - 0.8,
      endAngle: angle,
      colors: [Colors.transparent, AppColors.green.withAlphaSafe(0.35)],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: size.width));
    canvas.drawCircle(Offset(cx, cy), math.min(cx, cy) * 1.4,
      Paint()..shader = shader..style = PaintingStyle.fill);
    final linePaint = Paint()..color = AppColors.green.withAlphaSafe(0.7)..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx, cy), Offset(cx + math.cos(angle) * math.min(cx, cy) * 1.3, cy + math.sin(angle) * math.min(cy, cx) * 1.3), linePaint);
  }
  @override bool shouldRepaint(covariant _RadarSweepPainter old) => old.progress != progress;
}

class _CityDot extends StatelessWidget {
  final _WorldCity city;
  final int layer;
  final Color tempColor;
  final VoidCallback onTap;
  const _CityDot({required this.city, required this.layer, required this.tempColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Map lat/lon to relative position on the widget
    // We show Asia-Pacific region: lat 40 to -40, lon 70 to 160
    final relX = ((city.lon - 70) / 90).clamp(0.05, 0.95);
    final relY = ((40 - city.lat) / 80).clamp(0.05, 0.90);
    final color = layer == 2 ? tempColor : layer == 3 ? AppColors.purple : AppColors.cyan;

    return Positioned(
      left: 0, top: 0, right: 0, bottom: 0,
      child: LayoutBuilder(builder: (_, c) {
        final left = relX * c.maxWidth - 14;
        final top = relY * c.maxHeight - 14;
        return Stack(children: [
          Positioned(
            left: left, top: top,
            child: GestureDetector(onTap: onTap,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 28, height: 28,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: color.withAlphaSafe(0.15),
                    border: Border.all(color: color.withAlphaSafe(0.6), width: 1.5),
                    boxShadow: [BoxShadow(color: color.withAlphaSafe(0.3), blurRadius: 6)]),
                  child: Center(child: Text(city.flag, style: const TextStyle(fontSize: 12)))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(color: Colors.black.withAlphaSafe(0.6), borderRadius: BorderRadius.circular(4)),
                  child: Text(layer == 2 ? '${city.temp}°' : layer == 1 ? city.emoji : '${city.humidity}%',
                      style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w700))),
              ])),
          ),
        ]);
      }),
    );
  }
}

class _Legend extends StatelessWidget {
  final int layer;
  const _Legend({required this.layer});
  @override
  Widget build(BuildContext context) {
    final items = layer == 2
        ? [('< 15°C', AppColors.cyan), ('15-28°C', AppColors.green), ('28-33°C', AppColors.amber), ('> 33°C', AppColors.red)]
        : [('Rendah', AppColors.cyan), ('Sedang', AppColors.green), ('Tinggi', AppColors.amber), ('Ekstrem', AppColors.red)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: Colors.black.withAlphaSafe(0.5), borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: items.map((e) =>
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 5, bottom: 2),
            decoration: BoxDecoration(shape: BoxShape.circle, color: e.$2)),
          Text(e.$1, style: const TextStyle(color: Colors.white54, fontSize: 8)),
        ])).toList()),
    );
  }
}

class _WorldCity {
  final String name, flag, emoji;
  final double lat, lon;
  final int temp, humidity;
  const _WorldCity(this.name, this.lat, this.lon, this.temp, this.humidity, this.flag, this.emoji);
}
