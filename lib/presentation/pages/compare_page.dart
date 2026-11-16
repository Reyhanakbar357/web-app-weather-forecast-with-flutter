import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/themes/app_theme.dart';
import 'package:weather_app/core/utils/responsive_utils.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/presentation/providers/weather_provider.dart';
import 'package:weather_app/presentation/widgets/common.dart';
import 'package:weather_app/presentation/widgets/responsive_layout.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});
  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();
  WeatherEntity? _w1, _w2;
  bool _loading1 = false, _loading2 = false;
  String? _err1, _err2;

  Future<void> _fetch(int idx) async {
    final ctrl = idx == 1 ? _ctrl1 : _ctrl2;
    final city = ctrl.text.trim();
    if (city.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      if (idx == 1) {
        _loading1 = true;
        _err1 = null;
      } else {
        _loading2 = true;
        _err2 = null;
      }
    });
    try {
      final p = Provider.of<WeatherProvider>(context, listen: false);
      final result = await p.fetchWeatherByCity(city);
      if (!mounted) return;
      setState(() {
        if (idx == 1) {
          _w1 = result;
          _loading1 = false;
        } else {
          _w2 = result;
          _loading2 = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        if (idx == 1) {
          _err1 = msg;
          _loading1 = false;
        } else {
          _err2 = msg;
          _loading2 = false;
        }
      });
    }
  }

  void _reset() => setState(() {
        _w1 = null;
        _w2 = null;
        _ctrl1.clear();
        _ctrl2.clear();
        _err1 = null;
        _err2 = null;
      });

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    super.dispose();
  }

  String _emoji(String code) {
    switch (code.length >= 2 ? code.substring(0, 2) : '01') {
      case '01': return DateTime.now().hour < 6 || DateTime.now().hour > 19 ? '🌙' : '☀️';
      case '02': return '⛅';
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bg1, AppColors.bg2, AppColors.bg3],
        ),
      ),
      child: SafeArea(
        child: MaxWidthContainer(
          child: Column(children: [
            // ── HEADER ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.amber, AppColors.orange],
                  ).createShader(b),
                  child: Text('Bandingkan',
                      style: GoogleFonts.syne(
                          fontSize: RS.fontSize(context, 28),
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
                Text('2 kota sekaligus',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: RS.fontSize(context, 12))),
              ]),
              const Spacer(),
              if (_w1 != null || _w2 != null)
                GestureDetector(
                  onTap: _reset,
                  child: NeonBorderCard(
                    color: AppColors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.refresh_rounded,
                          size: 14, color: AppColors.red),
                      SizedBox(width: 5),
                      Text('Reset',
                          style: TextStyle(
                              color: AppColors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
            ]),
          ).animate().fadeIn(duration: 400.ms),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              physics: const BouncingScrollPhysics(),
              child: Column(children: [
                // ── SEARCH ROW ──
                Row(children: [
                  Expanded(
                      child: _SearchInput(
                          ctrl: _ctrl1,
                          hint: '🏙️ Kota pertama',
                          color: AppColors.cyan,
                          onSearch: () => _fetch(1))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _SearchInput(
                          ctrl: _ctrl2,
                          hint: '🌆 Kota kedua',
                          color: AppColors.amber,
                          onSearch: () => _fetch(2))),
                ]),
                const SizedBox(height: 14),

                // ── CITY CARDS ──
                Consumer<WeatherProvider>(
                  builder: (_, p, __) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CityCard(
                          w: _w1,
                          isLoading: _loading1,
                          err: _err1,
                          emoji: _w1 != null ? _emoji(_w1!.iconCode) : '🏙️',
                          p: p,
                          accentColor: AppColors.cyan,
                          onReset: () => setState(() {
                            _w1 = null;
                            _err1 = null;
                            _ctrl1.clear();
                          }),
                        ),
                      ),
                      // VS badge
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.amber, AppColors.orange],
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.amber.withAlphaSafe(0.4),
                                  blurRadius: 12)
                            ],
                          ),
                          child: const Center(
                            child: Text('VS',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                                begin: const Offset(.95, .95),
                                end: const Offset(1.05, 1.05),
                                duration: 2.seconds),
                      ),
                      Expanded(
                        child: _CityCard(
                          w: _w2,
                          isLoading: _loading2,
                          err: _err2,
                          emoji: _w2 != null ? _emoji(_w2!.iconCode) : '🌆',
                          p: p,
                          accentColor: AppColors.amber,
                          onReset: () => setState(() {
                            _w2 = null;
                            _err2 = null;
                            _ctrl2.clear();
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_w1 != null && _w2 != null) ...[
                  const SizedBox(height: 12),
                  Builder(
                    builder: (ctx) {
                      final isWide = ResponsiveLayout.isDesktop(ctx) || ResponsiveLayout.isTablet(ctx);
                      
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Consumer<WeatherProvider>(
                                builder: (_, p, __) => _CompareTable(w1: _w1!, w2: _w2!, p: p),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  Consumer<WeatherProvider>(
                                    builder: (_, p, __) => _RadarChart(w1: _w1!, w2: _w2!, p: p),
                                  ),
                                  const SizedBox(height: 14),
                                  Consumer<WeatherProvider>(
                                    builder: (_, p, __) => _WinnerCard(w1: _w1!, w2: _w2!, p: p),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      
                      // Mobile layout
                      return Column(
                        children: [
                          Consumer<WeatherProvider>(
                            builder: (_, p, __) => _CompareTable(w1: _w1!, w2: _w2!, p: p),
                          ),
                          const SizedBox(height: 14),
                          Consumer<WeatherProvider>(
                            builder: (_, p, __) => _RadarChart(w1: _w1!, w2: _w2!, p: p),
                          ),
                          const SizedBox(height: 14),
                          Consumer<WeatherProvider>(
                            builder: (_, p, __) => _WinnerCard(w1: _w1!, w2: _w2!, p: p),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ]),
            ),
          ),
        ]),
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final VoidCallback onSearch;
  final Color color;
  const _SearchInput(
      {required this.ctrl,
      required this.hint,
      required this.onSearch,
      required this.color});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: AppColors.textMuted, fontSize: 12),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: color, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onSearch,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withAlphaSafe(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withAlphaSafe(0.4)),
              boxShadow: [
                BoxShadow(color: color.withAlphaSafe(0.2), blurRadius: 10)
              ],
            ),
            child: Icon(Icons.search_rounded, color: color, size: 20),
          ),
        ),
      ]);
}

class _CityCard extends StatelessWidget {
  final WeatherEntity? w;
  final bool isLoading;
  final String? err;
  final String emoji;
  final WeatherProvider p;
  final VoidCallback onReset;
  final Color accentColor;

  const _CityCard(
      {required this.w,
      required this.isLoading,
      required this.err,
      required this.emoji,
      required this.p,
      required this.onReset,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        borderColor: accentColor.withAlphaSafe(0.2),
        child: SizedBox(
          height: 120,
          child: Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: accentColor),
          ),
        ),
      );
    }
    if (err != null) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: AppColors.red.withAlphaSafe(0.3),
        child: Column(children: [
          const Text('⛈️', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(err!,
              style: const TextStyle(color: AppColors.red, fontSize: 11),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onReset,
            child: const Text('↺ Hapus',
                style: TextStyle(color: AppColors.cyan, fontSize: 11)),
          ),
        ]),
      );
    }
    if (w == null) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        borderColor: accentColor.withAlphaSafe(0.12),
        child: SizedBox(
          height: 120,
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  const Text('Cari kota',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ]),
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: accentColor.withAlphaSafe(0.25),
      shadows: [
        BoxShadow(color: accentColor.withAlphaSafe(0.12), blurRadius: 20),
        BoxShadow(
            color: Colors.black.withAlphaSafe(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6))
      ],
      child: Column(children: [
        Text(emoji, style: TextStyle(fontSize: RS.fontSize(context, 36)))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: -5, end: 5, duration: 2.3.seconds),
        const SizedBox(height: 8),
        Text(w!.cityName,
            style: GoogleFonts.syne(
                fontSize: RS.fontSize(context, 13),
                fontWeight: FontWeight.w700,
                color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        Text(w!.countryCode,
            style:
                TextStyle(color: AppColors.textSub, fontSize: RS.fontSize(context, 11))),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: ShaderMask(
            shaderCallback: (b) =>
                LinearGradient(colors: [Colors.white, accentColor])
                    .createShader(b),
            child: Text(
                '${p.convertTemp(w!.temperature).round()}${p.unitSymbol}',
                style: GoogleFonts.syne(
                    fontSize: RS.fontSize(context, 30),
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ),
        Text(w!.description,
            style: TextStyle(color: AppColors.textSub, fontSize: RS.fontSize(context, 10)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(.92, .92));
  }
}

class _CompareTable extends StatelessWidget {
  final WeatherEntity w1, w2;
  final WeatherProvider p;
  const _CompareTable({required this.w1, required this.w2, required this.p});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _R('🌡 Suhu', '${p.convertTemp(w1.temperature).round()}${p.unitSymbol}',
          '${p.convertTemp(w2.temperature).round()}${p.unitSymbol}',
          w1.temperature > w2.temperature ? -1 : w2.temperature > w1.temperature ? 1 : 0),
      _R('💧 Kelembapan', '${w1.humidity}%', '${w2.humidity}%',
          w1.humidity < w2.humidity ? -1 : w2.humidity < w1.humidity ? 1 : 0),
      _R('💨 Angin', '${(w1.windSpeed * 3.6).round()} km/h',
          '${(w2.windSpeed * 3.6).round()} km/h',
          w1.windSpeed < w2.windSpeed ? -1 : w2.windSpeed < w1.windSpeed ? 1 : 0),
      _R('👁 Visibilitas', '${(w1.visibility / 1000).toStringAsFixed(1)} km',
          '${(w2.visibility / 1000).toStringAsFixed(1)} km',
          w1.visibility > w2.visibility ? -1 : w2.visibility > w1.visibility ? 1 : 0),
      _R('☁️ Awan', '${w1.cloudiness}%', '${w2.cloudiness}%',
          w1.cloudiness < w2.cloudiness ? -1 : w2.cloudiness < w1.cloudiness ? 1 : 0),
      _R('🌡 Terasa', '${p.convertTemp(w1.feelsLike).round()}${p.unitSymbol}',
          '${p.convertTemp(w2.feelsLike).round()}${p.unitSymbol}', 0),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.amber.withAlphaSafe(0.15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle('Perbandingan Detail',
            accentColor: AppColors.amber),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cyan.withAlphaSafe(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(w1.cityName,
                  style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: RS.fontSize(context, 11),
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          SizedBox(width: RS.space(context, 50)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.amber.withAlphaSafe(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(w2.cityName,
                  style: TextStyle(
                      color: AppColors.amber,
                      fontSize: RS.fontSize(context, 11),
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        ...rows.asMap().entries.map((e) => _TableRow(r: e.value, i: e.key)),
      ]),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _R {
  final String label, v1, v2;
  final int winner;
  const _R(this.label, this.v1, this.v2, this.winner);
}

class _TableRow extends StatelessWidget {
  final _R r;
  final int i;
  const _TableRow({required this.r, required this.i});

  @override
  Widget build(BuildContext context) {
    final leftWins = r.winner == -1;
    final rightWins = r.winner == 1;
    final labelWidth = RS.space(context, 50);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: leftWins
                  ? AppColors.cyan.withAlphaSafe(0.13)
                  : Colors.white.withAlphaSafe(0.03),
              borderRadius: BorderRadius.circular(10),
              border: leftWins
                  ? Border.all(color: AppColors.cyan.withAlphaSafe(0.4))
                  : null,
              boxShadow: leftWins
                  ? [
                      BoxShadow(
                          color: AppColors.cyan.withAlphaSafe(0.12),
                          blurRadius: 10)
                    ]
                  : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(r.v1,
                  style: TextStyle(
                      color:
                          leftWins ? AppColors.cyan : AppColors.textSub,
                      fontSize: RS.fontSize(context, 12),
                      fontWeight: leftWins
                          ? FontWeight.w700
                          : FontWeight.w400),
                  textAlign: TextAlign.center),
            ),
          ),
        ),
        SizedBox(
          width: labelWidth,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(r.label,
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: RS.fontSize(context, 9)),
                  textAlign: TextAlign.center),
            ),
          ),
        ),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: rightWins
                  ? AppColors.amber.withAlphaSafe(0.13)
                  : Colors.white.withAlphaSafe(0.03),
              borderRadius: BorderRadius.circular(10),
              border: rightWins
                  ? Border.all(color: AppColors.amber.withAlphaSafe(0.4))
                  : null,
              boxShadow: rightWins
                  ? [
                      BoxShadow(
                          color: AppColors.amber.withAlphaSafe(0.12),
                          blurRadius: 10)
                    ]
                  : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(r.v2,
                  style: TextStyle(
                      color: rightWins
                          ? AppColors.amber
                          : AppColors.textSub,
                      fontSize: RS.fontSize(context, 12),
                      fontWeight: rightWins
                          ? FontWeight.w700
                          : FontWeight.w400),
                  textAlign: TextAlign.center),
            ),
          ),
        ),
      ]),
    ).animate(delay: Duration(milliseconds: i * 55)).fadeIn().slideX(begin: -.03);
  }
}

// ── RADAR CHART ─────────────────────────────────────────────
class _RadarChart extends StatelessWidget {
  final WeatherEntity w1, w2;
  final WeatherProvider p;
  const _RadarChart({required this.w1, required this.w2, required this.p});

  @override
  Widget build(BuildContext context) {
    // Normalize values 0..1
    final vals1 = [
      (p.convertTemp(w1.temperature) / 50).clamp(0.1, 1.0),
      (w1.humidity / 100).clamp(0.1, 1.0),
      (w1.windSpeed / 30).clamp(0.1, 1.0),
      (w1.visibility / 10000).clamp(0.1, 1.0),
      (1 - w1.cloudiness / 100).clamp(0.1, 1.0),
      ((100 - w1.humidity) / 100).clamp(0.1, 1.0),
    ];
    final vals2 = [
      (p.convertTemp(w2.temperature) / 50).clamp(0.1, 1.0),
      (w2.humidity / 100).clamp(0.1, 1.0),
      (w2.windSpeed / 30).clamp(0.1, 1.0),
      (w2.visibility / 10000).clamp(0.1, 1.0),
      (1 - w2.cloudiness / 100).clamp(0.1, 1.0),
      ((100 - w2.humidity) / 100).clamp(0.1, 1.0),
    ];
    const labels = ['Suhu', 'Hum', 'Angin', 'Visib', 'Cerah', 'Kering'];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.purple.withAlphaSafe(0.2),
      child: Column(children: [
        const SectionTitle('Radar Perbandingan',
            accentColor: AppColors.purple),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _RadarChartPainter(
              vals1: vals1,
              vals2: vals2,
              labels: labels,
              color1: AppColors.cyan,
              color2: AppColors.amber,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Legend(color: AppColors.cyan, label: w1.cityName),
          const SizedBox(width: 20),
          _Legend(color: AppColors.amber, label: w2.cityName),
        ]),
      ]),
    ).animate().fadeIn(delay: 280.ms);
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withAlphaSafe(0.6),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]);
}

class _RadarChartPainter extends CustomPainter {
  final List<double> vals1, vals2;
  final List<String> labels;
  final Color color1, color2;

  const _RadarChartPainter({
    required this.vals1,
    required this.vals2,
    required this.labels,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 28;
    final n = vals1.length;
    final angleStep = 2 * math.pi / n;

    // Grid rings
    for (int ring = 1; ring <= 4; ring++) {
      final rr = r * ring / 4;
      final path = Path();
      for (int i = 0; i <= n; i++) {
        final angle = i * angleStep - math.pi / 2;
        final x = cx + rr * math.cos(angle);
        final y = cy + rr * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white.withAlphaSafe(0.05)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }

    // Spokes
    for (int i = 0; i < n; i++) {
      final angle = i * angleStep - math.pi / 2;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        Paint()
          ..color = Colors.white.withAlphaSafe(0.08)
          ..strokeWidth = 1,
      );
    }

    // Draw polygon for vals1
    _drawPolygon(canvas, cx, cy, r, angleStep, vals1, color1);
    // Draw polygon for vals2
    _drawPolygon(canvas, cx, cy, r, angleStep, vals2, color2);

    // Labels
    for (int i = 0; i < n; i++) {
      final angle = i * angleStep - math.pi / 2;
      final lx = cx + (r + 18) * math.cos(angle);
      final ly = cy + (r + 18) * math.sin(angle);
      final tp = TextPainter(
        text: TextSpan(
            text: labels[i],
            style: const TextStyle(
                color: AppColors.textSub,
                fontSize: 9,
                fontWeight: FontWeight.w600)),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }
  }

  void _drawPolygon(Canvas canvas, double cx, double cy, double r,
      double angleStep, List<double> vals, Color color) {
    final path = Path();
    for (int i = 0; i < vals.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final rv = r * vals[i];
      final x = cx + rv * math.cos(angle);
      final y = cy + rv * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(
        path,
        Paint()
          ..color = color.withAlphaSafe(0.20)
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        path,
        Paint()
          ..color = color.withAlphaSafe(0.80)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round);

    // Dots at vertices
    for (int i = 0; i < vals.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final rv = r * vals[i];
      final x = cx + rv * math.cos(angle);
      final y = cy + rv * math.sin(angle);
      canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter old) => false;
}

class _WinnerCard extends StatelessWidget {
  final WeatherEntity w1, w2;
  final WeatherProvider p;
  const _WinnerCard({required this.w1, required this.w2, required this.p});

  @override
  Widget build(BuildContext context) {
    double sA = 0, sB = 0;
    final t1 = w1.temperature, t2 = w2.temperature;
    if (t1 >= 20 && t1 <= 28) sA += 30;
    if (t2 >= 20 && t2 <= 28) sB += 30;
    sA += (100 - w1.humidity) * .3;
    sB += (100 - w2.humidity) * .3;
    sA += (w1.visibility / 10000) * 20;
    sB += (w2.visibility / 10000) * 20;
    sA += math.max(0, 20 - w1.windSpeed);
    sB += math.max(0, 20 - w2.windSpeed);

    final aWins = sA >= sB;
    final winner = aWins ? w1 : w2;
    final loser = aWins ? w2 : w1;
    final winnerColor = aWins ? AppColors.cyan : AppColors.amber;
    final scoreDiff = (math.max(sA, sB) - math.min(sA, sB)).round();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.amber.withAlphaSafe(0.3),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.amber.withAlphaSafe(0.10),
          AppColors.orange.withAlphaSafe(0.05),
        ],
      ),
      shadows: [
        BoxShadow(
            color: AppColors.amber.withAlphaSafe(0.15), blurRadius: 24),
        BoxShadow(
            color: Colors.black.withAlphaSafe(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8))
      ],
      child: Row(children: [
        Container(
          width: RS.space(context, 52),
          height: RS.space(context, 52),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
                colors: [AppColors.amber, AppColors.orange]),
            boxShadow: [
              BoxShadow(
                  color: AppColors.amber.withAlphaSafe(0.4), blurRadius: 16)
            ],
          ),
          child: Center(
            child: Text('🏆', style: TextStyle(fontSize: RS.fontSize(context, 24))),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(begin: const Offset(.95, .95), end: const Offset(1.05, 1.05), duration: 2.seconds),
        SizedBox(width: RS.space(context, 12)),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CUACA LEBIH NYAMAN',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: RS.fontSize(context, 10),
                    letterSpacing: .15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(winner.cityName,
                style: GoogleFonts.syne(
                    fontSize: RS.fontSize(context, 18),
                    fontWeight: FontWeight.w800,
                    color: winnerColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(
                scoreDiff > 0
                    ? 'Unggul $scoreDiff poin dari ${loser.cityName}'
                    : 'Skor hampir setara',
                style: TextStyle(
                    color: AppColors.textSub, fontSize: RS.fontSize(context, 11)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
      ]),
    ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(.94, .94));
  }
}
