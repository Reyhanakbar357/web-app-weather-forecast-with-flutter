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
import 'main_scaffold.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with TickerProviderStateMixin {
  final Map<String, WeatherEntity?> _cache = {};
  final Map<String, bool> _loading = {};
  bool _isGrid = false;
  late AnimationController _headerCtrl;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    final p = Provider.of<WeatherProvider>(context, listen: false);
    for (final city in p.favorites) {
      if (!_cache.containsKey(city)) _fetchCity(city);
    }
  }

  Future<void> _fetchCity(String city) async {
    if (!mounted) return;
    setState(() => _loading[city] = true);
    try {
      final p = Provider.of<WeatherProvider>(context, listen: false);
      final result = await p.fetchWeatherByCity(city);
      if (mounted) {
        setState(() {
          _cache[city] = result;
          _loading[city] = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading[city] = false);
    }
  }

  void _goToHome(WeatherProvider p, String city) {
    p.fetchWeather(city);
    context.findAncestorStateOfType<MainScaffoldState>()?.switchTab(0);
  }

  String _emoji(String code) {
    switch (code.length >= 2 ? code.substring(0, 2) : '01') {
      case '01': return '☀️';
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

  Color _tempColor(double t) {
    if (t < 10) return AppColors.cyan;
    if (t < 20) return const Color(0xFF00B4D8);
    if (t < 28) return AppColors.green;
    if (t < 33) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(builder: (_, p, __) {
      final favs = p.favorites;
      for (final city in favs) {
        if (!_cache.containsKey(city) && _loading[city] != true) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _fetchCity(city));
        }
      }

      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bg1, AppColors.bg2, AppColors.bg3],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(
                        colors: [AppColors.pink, AppColors.purple],
                      ).createShader(b),
                      child: Text('Favorit',
                          style: GoogleFonts.syne(
                              fontSize: RS.fontSize(context, 30),
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                    Text('${favs.length} kota tersimpan',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: RS.fontSize(context, 12))),
                  ]),
                  const Spacer(),
                  // Toggle grid/list
                  GlowIconButton(
                    icon: (ResponsiveLayout.isMobile(context) ? _isGrid : !_isGrid)
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    onTap: () => setState(() => _isGrid = !_isGrid),
                    active: false,
                  ),
                  const SizedBox(width: 8),
                  // Refresh all
                  GlowIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: () {
                      _cache.clear();
                      _fetchAll();
                    },
                    active: false,
                  ),
                ]),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -.06),

              const SizedBox(height: 16),

              // ── EMPTY STATE ──
              if (favs.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🌍', style: TextStyle(fontSize: RS.fontSize(context, 72)))
                            .animate(
                                onPlay: (c) => c.repeat(reverse: true))
                            .moveY(
                                begin: -12,
                                end: 12,
                                duration: 2.4.seconds,
                                curve: Curves.easeInOut),
                        const SizedBox(height: 24),
                        Text('Belum Ada Favorit',
                            style: GoogleFonts.syne(
                                fontSize: RS.fontSize(context, 22),
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 10),
                        Text(
                          'Tap ♡ di Beranda untuk\nmenambahkan kota favorit',
                          style: TextStyle(
                              color: AppColors.textSub, fontSize: RS.fontSize(context, 14)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        AccentButton(
                          onTap: () => context
                              .findAncestorStateOfType<MainScaffoldState>()
                              ?.switchTab(0),
                          colors: AppColors.gradPink,
                          isSmall: true,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home_rounded,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 8),
                               Text('Ke Beranda',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // ── FAVORITES LIST / GRID ──
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _cache.clear();
                      await _fetchAll();
                    },
                    color: AppColors.pink,
                    backgroundColor: AppColors.bg2,
                    child: (ResponsiveLayout.isMobile(context) ? _isGrid : !_isGrid)
                        ? _buildGrid(favs, p)
                        : _buildList(favs, p),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildList(List<String> favs, WeatherProvider p) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      itemCount: favs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildListCard(favs[i], p, i),
    );
  }

  Widget _buildGrid(List<String> favs, WeatherProvider p) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayout.isDesktop(context) ? 4 : ResponsiveLayout.isTablet(context) ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: favs.length,
      itemBuilder: (_, i) => _buildGridCard(favs[i], p, i),
    );
  }

  Widget _buildListCard(String city, WeatherProvider p, int i) {
    final w = _cache[city];
    final isLoading = _loading[city] == true;

    return GlassCard(
      onTap: isLoading || w == null ? null : () => _goToHome(p, city),
      borderColor: AppColors.pink.withAlphaSafe(0.18),
      shadows: [
        BoxShadow(
            color: AppColors.pink.withAlphaSafe(0.07), blurRadius: 16),
        BoxShadow(
            color: Colors.black.withAlphaSafe(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6))
      ],
      padding: const EdgeInsets.all(18),
      child: isLoading
          ? const SizedBox(
              height: 70,
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.pink),
              ))
          : w == null
              ? Row(children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(city,
                        style: GoogleFonts.syne(
                            fontSize: RS.fontSize(context, 16),
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                  GestureDetector(
                    onTap: () {
                      p.removeFavorite(city);
                      setState(() {
                        _cache.remove(city);
                        _loading.remove(city);
                      });
                    },
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.red, size: 22),
                  )
                ])
              : _ListTileContent(
                  w: w,
                  p: p,
                  emoji: _emoji(w.iconCode),
                  tempColor: _tempColor(w.temperature),
                  onRemove: () {
                    p.removeFavorite(city);
                    setState(() {
                      _cache.remove(city);
                      _loading.remove(city);
                    });
                  },
                ),
    )
        .animate(delay: Duration(milliseconds: i * 70))
        .fadeIn(duration: 400.ms)
        .slideY(begin: .08);
  }

  Widget _buildGridCard(String city, WeatherProvider p, int i) {
    final w = _cache[city];
    final isLoading = _loading[city] == true;

    return GlassCard(
      onTap: isLoading || w == null ? null : () => _goToHome(p, city),
      borderColor: AppColors.pink.withAlphaSafe(0.18),
      padding: const EdgeInsets.all(16),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.pink),
            )
          : w == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(city,
                        style: GoogleFonts.syne(
                            fontSize: RS.fontSize(context, 14),
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.red, size: 20),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_emoji(w.iconCode),
                              style: TextStyle(fontSize: RS.fontSize(context, 32)))
                              .animate(
                                  onPlay: (c) =>
                                      c.repeat(reverse: true))
                              .moveY(
                                  begin: -4,
                                  end: 4,
                                  duration: 2.seconds),
                          GestureDetector(
                            onTap: () {
                              p.removeFavorite(city);
                              setState(() {
                                _cache.remove(city);
                                _loading.remove(city);
                              });
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.pink.withAlphaSafe(0.12),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.favorite_rounded,
                                  color: AppColors.pink,
                                  size: 16),
                            ),
                          ),
                        ]),
                    const Spacer(),
                    Text(w.cityName,
                        style: GoogleFonts.syne(
                            fontSize: RS.fontSize(context, 14),
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(w.countryCode,
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: RS.fontSize(context, 11))),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (b) => LinearGradient(
                        colors: [Colors.white, _tempColor(w.temperature)],
                      ).createShader(b),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                            '${p.convertTemp(w.temperature).round()}${p.unitSymbol}',
                            style: GoogleFonts.syne(
                                fontSize: RS.fontSize(context, 28),
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ),
                    Text(w.description,
                        style: TextStyle(
                            color: AppColors.textSub,
                            fontSize: RS.fontSize(context, 11)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
    )
        .animate(delay: Duration(milliseconds: i * 60))
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(.92, .92));
  }
}

class _ListTileContent extends StatelessWidget {
  final WeatherEntity w;
  final WeatherProvider p;
  final String emoji;
  final Color tempColor;
  final VoidCallback onRemove;

  const _ListTileContent({
    required this.w,
    required this.p,
    required this.emoji,
    required this.tempColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(emoji, style: TextStyle(fontSize: RS.fontSize(context, 44)))
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: -5, end: 5, duration: 2.2.seconds),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(w.cityName,
              style: GoogleFonts.syne(
                  fontSize: RS.fontSize(context, 16),
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text('${w.countryCode} · ${w.description}',
              style: TextStyle(
                  color: AppColors.textSub, fontSize: RS.fontSize(context, 12))),
          const SizedBox(height: 8),
          Row(children: [
            _Chip('💧 ${w.humidity}%', AppColors.cyan),
            const SizedBox(width: 6),
            _Chip('💨 ${(w.windSpeed * 3.6).round()} km/h',
                AppColors.purple),
          ]),
        ]),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        ShaderMask(
          shaderCallback: (b) =>
              LinearGradient(colors: [Colors.white, tempColor])
                  .createShader(b),
          child: Text(
              '${p.convertTemp(w.temperature).round()}${p.unitSymbol}',
              style: GoogleFonts.syne(
                  fontSize: RS.fontSize(context, 30),
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ),
        Text(
            '${p.convertTemp(w.tempMin).round()}° / ${p.convertTemp(w.tempMax).round()}°',
            style: TextStyle(
                color: AppColors.textMuted, fontSize: RS.fontSize(context, 11))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.pink.withAlphaSafe(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.pink.withAlphaSafe(0.3)),
            ),
            child: const Icon(Icons.favorite_rounded,
                color: AppColors.pink, size: 16),
          ),
        ),
      ]),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withAlphaSafe(0.08),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: color.withAlphaSafe(0.2)),
        ),
        child: Text(text,
            style: TextStyle(color: color.withAlphaSafe(0.9), fontSize: RS.fontSize(context, 11))),
      );
}
