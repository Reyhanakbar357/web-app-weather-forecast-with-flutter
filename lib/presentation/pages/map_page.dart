import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/themes/app_theme.dart';
import 'package:weather_app/core/utils/api_service.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/presentation/providers/weather_provider.dart';
import 'package:weather_app/presentation/widgets/responsive_layout.dart';
import 'main_scaffold.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _pulseCtrl;

  LatLng? _tappedPoint;
  bool _isLoadingMap = false;
  WeatherEntity? _mapWeather;
  String? _mapError;

  final List<_CityMarker> _popularCities = const [
    _CityMarker('Jakarta', -6.2088, 106.8456, '🇮🇩'),
    _CityMarker('Surabaya', -7.2575, 112.7521, '🇮🇩'),
    _CityMarker('Medan', 3.5952, 98.6722, '🇮🇩'),
    _CityMarker('Bandung', -6.9175, 107.6191, '🇮🇩'),
    _CityMarker('Bali', -8.4095, 115.1889, '🇮🇩'),
    _CityMarker('Makassar', -5.1477, 119.4327, '🇮🇩'),
    _CityMarker('Singapore', 1.3521, 103.8198, '🇸🇬'),
    _CityMarker('Kuala Lumpur', 3.1390, 101.6869, '🇲🇾'),
    _CityMarker('Tokyo', 35.6762, 139.6503, '🇯🇵'),
    _CityMarker('Seoul', 37.5665, 126.9780, '🇰🇷'),
    _CityMarker('London', 51.5074, -0.1278, '🇬🇧'),
    _CityMarker('Paris', 48.8566, 2.3522, '🇫🇷'),
    _CityMarker('New York', 40.7128, -74.0060, '🇺🇸'),
    _CityMarker('Dubai', 25.2048, 55.2708, '🇦🇪'),
    _CityMarker('Sydney', -33.8688, 151.2093, '🇦🇺'),
    _CityMarker('Cairo', 30.0444, 31.2357, '🇪🇬'),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final current = _mapController.camera.zoom;
    if (current < 16.0) {
      _mapController.move(_mapController.camera.center, (current + 1.0).clamp(1.0, 16.0));
    }
  }

  void _zoomOut() {
    final current = _mapController.camera.zoom;
    if (current > 1.0) {
      _mapController.move(_mapController.camera.center, (current - 1.0).clamp(1.0, 16.0));
    }
  }

  void _resetToIndonesia() {
    _mapController.move(const LatLng(-2.5, 118.0), 4.5);
  }

  void _resetToWorld() {
    _mapController.move(const LatLng(20.0, 0.0), 2.0);
  }

  Future<void> _fetchWeatherAt(LatLng point) async {
    setState(() {
      _isLoadingMap = true;
      _mapError = null;
      _tappedPoint = point;
      _mapWeather = null;
    });
    try {
      final provider = Provider.of<WeatherProvider>(context, listen: false);
      final result = await provider.fetchWeatherByCoordsSilent(point.latitude, point.longitude);
      if (mounted) {
        setState(() {
          _mapWeather = result;
          _isLoadingMap = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mapError = e.toString().replaceAll('Exception: ', '');
          _isLoadingMap = false;
        });
      }
    }
  }

  Future<void> _searchCity(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoadingMap = true;
      _mapError = null;
      _mapWeather = null;
    });

    // Cek daftar kota populer terlebih dahulu
    final matched = _popularCities.where((c) => c.name.toLowerCase() == trimmed.toLowerCase()).toList();
    if (matched.isNotEmpty) {
      final city = matched.first;
      final point = LatLng(city.lat, city.lon);
      _mapController.move(point, 8.5);
      await _fetchWeatherAt(point);
      return;
    }

    // Cari via OpenWeather API
    try {
      final json = await ApiService.getWeatherByCity(trimmed);
      final coord = json['coord'] as Map<String, dynamic>?;
      if (coord != null && coord['lat'] != null && coord['lon'] != null) {
        final lat = (coord['lat'] as num).toDouble();
        final lon = (coord['lon'] as num).toDouble();
        final point = LatLng(lat, lon);
        final weather = WeatherModel.fromJson(json).toEntity();
        _mapController.move(point, 8.5);
        if (mounted) {
          setState(() {
            _tappedPoint = point;
            _mapWeather = weather;
            _isLoadingMap = false;
          });
        }
      } else {
        throw Exception('Koordinat kota tidak ditemukan');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mapError = e.toString().replaceAll('Exception: ', '');
          _isLoadingMap = false;
        });
      }
    }
  }

  void _goToDetail(WeatherEntity w) {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    provider.fetchWeather(w.cityName);
    final scaffold = context.findAncestorStateOfType<MainScaffoldState>();
    scaffold?.switchTab(0);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final bottomBase = isMobile ? 84.0 : 20.0;

    return ColoredBox(
      color: const Color(0xFF12131A),
      child: Stack(
        children: [
          // ── MAP (FULL SCREEN) ──
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(-2.5, 118.0),
                initialZoom: 4.5,
                minZoom: 1.0,
                maxZoom: 16.0,
                onTap: (_, point) => _fetchWeatherAt(point),
                backgroundColor: const Color(0xFF14151B),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                  scrollWheelVelocity: 0.008,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.skyview.weather',
                  maxZoom: 16,
                ),
                TileLayer(
                  urlTemplate:
                      'https://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Reference/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.skyview.weather',
                  maxZoom: 16,
                ),
                // City markers
                MarkerLayer(
                  markers: _popularCities.map((city) {
                    final isSelected = _tappedPoint != null &&
                        (_tappedPoint!.latitude - city.lat).abs() < 0.05 &&
                        (_tappedPoint!.longitude - city.lon).abs() < 0.05;

                    return Marker(
                      point: LatLng(city.lat, city.lon),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () {
                          _mapController.move(LatLng(city.lat, city.lon), 8.5);
                          _fetchWeatherAt(LatLng(city.lat, city.lon));
                        },
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 36 : 30,
                            height: isSelected ? 36 : 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.cyan.withAlphaSafe(0.3)
                                  : AppColors.bg2.withAlphaSafe(0.85),
                              border: Border.all(
                                color: isSelected ? AppColors.cyan : Colors.white.withAlphaSafe(0.25),
                                width: isSelected ? 2 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? AppColors.cyan.withAlphaSafe(0.5)
                                      : Colors.black.withAlphaSafe(0.3),
                                  blurRadius: isSelected ? 12 : 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                city.flag,
                                style: TextStyle(fontSize: isSelected ? 16 : 14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Active / Tapped Point Marker
                if (_tappedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _tappedPoint!,
                        width: 60,
                        height: 70,
                        child: AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 38 + _pulseCtrl.value * 8,
                                height: 38 + _pulseCtrl.value * 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.cyan.withAlphaSafe(0.2 - _pulseCtrl.value * 0.1),
                                  border: Border.all(
                                    color: AppColors.cyan,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.cyan.withAlphaSafe(0.6),
                                      blurRadius: 14,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.cyan,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Container(
                                width: 2,
                                height: 8,
                                color: AppColors.cyan,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── TOP FLOATING SEARCH & TITLE BAR ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.bg1.withAlphaSafe(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withAlphaSafe(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlphaSafe(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(Icons.search_rounded, color: AppColors.cyan, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: _searchCity,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: 'Cari kota di peta (cth: Jakarta, Tokyo)...',
                            hintStyle: TextStyle(
                              color: Colors.white.withAlphaSafe(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white.withAlphaSafe(0.4),
                              size: 18,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () => _searchCity(_searchController.text),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.cyan, AppColors.cyanDim],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Cari',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

          // ── FLOATING MAP CONTROLS (ZOOM & RESET) ──
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 76,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bg1.withAlphaSafe(0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlphaSafe(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlphaSafe(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _mapButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Perbesar (Zoom In)',
                    onTap: _zoomIn,
                  ),
                  Container(
                    width: 24,
                    height: 1,
                    color: Colors.white.withAlphaSafe(0.08),
                  ),
                  _mapButton(
                    icon: Icons.remove_rounded,
                    tooltip: 'Perkecil (Zoom Out)',
                    onTap: _zoomOut,
                  ),
                  Container(
                    width: 24,
                    height: 1,
                    color: Colors.white.withAlphaSafe(0.08),
                  ),
                  _mapButton(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Pusatkan ke Indonesia',
                    onTap: _resetToIndonesia,
                  ),
                  Container(
                    width: 24,
                    height: 1,
                    color: Colors.white.withAlphaSafe(0.08),
                  ),
                  _mapButton(
                    icon: Icons.public_rounded,
                    tooltip: 'Tampilan Seluruh Dunia',
                    onTap: _resetToWorld,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

          // ── KOTA POPULER CHIPS (Saat Weather Card Tidak Muncul) ──
          if (_mapWeather == null && !_isLoadingMap && _mapError == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomBase,
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _popularCities.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final city = _popularCities[i];
                    return GestureDetector(
                      onTap: () {
                        final point = LatLng(city.lat, city.lon);
                        _mapController.move(point, 8.5);
                        _fetchWeatherAt(point);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.bg1.withAlphaSafe(0.85),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withAlphaSafe(0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlphaSafe(0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(city.flag, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              city.name,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          // ── LOADING OVERLAY CARD ──
          if (_isLoadingMap)
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomBase,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.bg1.withAlphaSafe(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlphaSafe(0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlphaSafe(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.cyan,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Mengambil cuaca titik lokasi...',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withAlphaSafe(0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.2),

          // ── ERROR CARD ──
          if (_mapError != null && !_isLoadingMap)
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomBase,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.bg1.withAlphaSafe(0.95),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.redAccent.withAlphaSafe(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlphaSafe(0.4),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _mapError!,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withAlphaSafe(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 18),
                          onPressed: () => setState(() => _mapError = null),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(),

          // ── LIVE WEATHER CARD AT SELECTED POINT ──
          if (_mapWeather != null && !_isLoadingMap)
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomBase,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: _MapWeatherCard(
                    weather: _mapWeather!,
                    onDetail: () => _goToDetail(_mapWeather!),
                    onClose: () => setState(() {
                      _mapWeather = null;
                      _tappedPoint = null;
                    }),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.15),
        ],
      ),
    );
  }

  Widget _mapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            color: Colors.white.withAlphaSafe(0.85),
            size: 19,
          ),
        ),
      ),
    );
  }
}

// ── WEATHER CARD ON MAP ──────────────────────────────────────
class _MapWeatherCard extends StatelessWidget {
  final WeatherEntity weather;
  final VoidCallback onDetail;
  final VoidCallback onClose;

  const _MapWeatherCard({
    required this.weather,
    required this.onDetail,
    required this.onClose,
  });

  String _emoji(String code, bool night) {
    switch (code.length >= 2 ? code.substring(0, 2) : '01') {
      case '01':
        return night ? '🌙' : '☀️';
      case '02':
        return night ? '🌤' : '⛅';
      case '03':
      case '04':
        return '☁️';
      case '09':
        return '🌦';
      case '10':
        return '🌧';
      case '11':
        return '⛈️';
      case '13':
        return '❄️';
      case '50':
        return '🌫';
      default:
        return '🌡';
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = weather;
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    final temp = provider.convertTemp(w.temperature).round();
    final night = DateTime.now().hour < 6 || DateTime.now().hour > 19;
    final emoji = _emoji(w.iconCode, night);
    final windSpeed = provider.formatWindSpeed(w.windSpeed);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg1.withAlphaSafe(0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlphaSafe(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlphaSafe(0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${w.cityName}, ${w.countryCode}',
                        style: GoogleFonts.syne(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        w.description.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withAlphaSafe(0.5),
                          fontSize: 11,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '$temp${provider.unitSymbol}',
                  style: GoogleFonts.syne(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlphaSafe(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white54, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white.withAlphaSafe(0.06)),
          // Stats & Action
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MapStat('💧', '${w.humidity}%', 'Lembap'),
                _MapStat('💨', windSpeed, 'Angin'),
                _MapStat(
                  '🌡️',
                  '${provider.convertTemp(w.feelsLike).round()}${provider.unitSymbol}',
                  'Terasa',
                ),
                _MapStat('☁️', '${w.cloudiness}%', 'Awan'),
                GestureDetector(
                  onTap: onDetail,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.cyan, AppColors.cyanDim],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withAlphaSafe(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Detail',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapStat extends StatelessWidget {
  final String icon, value, label;
  const _MapStat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlphaSafe(0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _CityMarker {
  final String name, flag;
  final double lat, lon;
  const _CityMarker(this.name, this.lat, this.lon, this.flag);
}
