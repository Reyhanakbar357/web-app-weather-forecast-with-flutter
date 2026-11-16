import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/services/notification_service.dart';
import 'package:weather_app/core/utils/api_service.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';

enum WindUnit { kmh, ms, knots }

class WeatherProvider with ChangeNotifier {
  final WeatherRepositoryImpl _repository = WeatherRepositoryImpl();
  final NotificationService _notifService = NotificationService();

  WeatherEntity? _weather;
  bool _isLoading = false;
  String? _error;
  List<String> _searchHistory = [];
  bool _isCelsius = true;
  List<String> _favorites = [];
  bool _notifEnabled = false;
  WindUnit _windUnit = WindUnit.kmh;
  Timer? _autoRefreshTimer;

  WeatherEntity? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get searchHistory => _searchHistory;
  bool get isCelsius => _isCelsius;
  List<String> get favorites => _favorites;
  bool get notifEnabled => _notifEnabled;
  WindUnit get windUnit => _windUnit;
  bool _isLocating = false;
  bool get isLocating => _isLocating;

  /// Minta izin lokasi "sepanjang waktu" (background) agar notifikasi cuaca
  /// bisa terkirim meski aplikasi ditutup.
  Future<void> requestBackgroundLocationPermission() async {
    if (kIsWeb) return;
    try {
      // Langkah 1: minta izin lokasi dasar dulu
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      // Langkah 2: jika sudah diberi izin, minta "allow all the time" (background)
      if (permission == LocationPermission.whileInUse) {
        await Geolocator.requestPermission();
      }
    } catch (e) {
      debugPrint('Background location permission request error: $e');
    }
  }

  double convertTemp(double celsius) =>
      _isCelsius ? celsius : celsius * 9 / 5 + 32;
  String get unitSymbol => _isCelsius ? '°C' : '°F';

  String formatWindSpeed(double ms) {
    switch (_windUnit) {
      case WindUnit.kmh:
        return '${(ms * 3.6).round()} km/h';
      case WindUnit.ms:
        return '${ms.toStringAsFixed(1)} m/s';
      case WindUnit.knots:
        return '${(ms * 1.94384).round()} kt';
    }
  }

  String get windUnitName {
    switch (_windUnit) {
      case WindUnit.kmh:
        return 'Kilometer per jam (km/h)';
      case WindUnit.ms:
        return 'Meter per detik (m/s)';
      case WindUnit.knots:
        return 'Knots (kt)';
    }
  }

  void toggleUnit() {
    _isCelsius = !_isCelsius;
    _saveSettings();
    notifyListeners();
  }

  void cycleWindUnit() {
    _windUnit = WindUnit.values[(_windUnit.index + 1) % WindUnit.values.length];
    _saveSettings();
    notifyListeners();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      if (_weather != null) {
        fetchWeather(_weather!.cityName, isAuto: true);
      } else {
        fetchDefaultWeather();
      }
    });
  }

  // ── FETCH WEATHER ──────────────────────────────────────
  Future<void> fetchWeather(String city, {bool isAuto = false}) async {
    if (!isAuto) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    try {
      _weather = await _repository.getWeatherByCity(city);
      _error = null;
      await _addSearchHistory(city);
      if (!isAuto) await _sendWeatherNotif();
    } catch (e) {
      if (!isAuto) _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (!isAuto) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchWeatherByCoordinates() async {
    _isLoading = true;
    _isLocating = true;
    _error = null;
    notifyListeners();
    try {
      final pos = await _getPosition();
      _weather = await _repository.getWeatherByCoordinates(
          pos.latitude, pos.longitude);
      await _addSearchHistory(_weather!.cityName);
      await _sendWeatherNotif();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _weather = null;
    } finally {
      _isLoading = false;
      _isLocating = false;
      notifyListeners();
    }
  }

  /// Dipanggil saat user menekan tombol GPS di UI
  Future<void> fetchCurrentLocation() => fetchWeatherByCoordinates();

  Future<void> fetchWeatherByLatLon(double lat, double lon) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _weather = await _repository.getWeatherByCoordinates(lat, lon);
      await _addSearchHistory(_weather!.cityName);
      await _sendWeatherNotif();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WeatherEntity> fetchWeatherByCoordsSilent(double lat, double lon) async {
    final json = await ApiService.getWeatherByCoordinates(lat, lon);
    return WeatherModel.fromJson(json).toEntity();
  }

  Future<WeatherEntity> fetchWeatherByCity(String city) async {
    final json = await ApiService.getWeatherByCity(city);
    return WeatherModel.fromJson(json).toEntity();
  }

  Future<void> fetchDefaultWeather() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        return fetchWeatherByCoordinates();
      }
    }
    return fetchWeather('Medan');
  }

  // Kirim notif setelah fetch berhasil
  Future<void> _sendWeatherNotif() async {
    if (_weather == null || !_notifEnabled) return;
    final w = _weather!;
    
    final prefs = await SharedPreferences.getInstance();
    final lastDesc = prefs.getString('last_weather_desc');

    if (w.temperature > 37) {
      await _notifService.showAlert(
        title: 'Suhu Sangat Tinggi — ${w.cityName}',
        body: 'Suhu mencapai ${w.temperature.round()}°C! Hindari aktivitas luar ruangan.',
      );
    } else if (w.windSpeed > 15) {
      await _notifService.showAlert(
        title: 'Angin Kencang — ${w.cityName}',
        body: 'Kecepatan angin ${(w.windSpeed * 3.6).round()} km/h. Harap berhati-hati.',
      );
    } else {
      if (lastDesc != null && lastDesc.toLowerCase() != w.description.toLowerCase()) {
        await _notifService.showWeatherChangeAlert(
          cityName: w.cityName,
          oldDesc: lastDesc,
          newDesc: w.description,
          temperature: w.temperature.round(),
        );
      }
    }
    
    // Save current description as last known
    await prefs.setString('last_weather_desc', w.description);
  }

  // ── NOTIFIKASI ─────────────────────────────────────────
  Future<void> toggleNotification() async {
    _notifEnabled = !_notifEnabled;
    await _saveSettings();
    notifyListeners();
    await _notifService.setEnabled(_notifEnabled);
  }

  // ── HISTORY & SETTINGS ─────────────────────────────────
  void removeFromHistory(String city) async {
    _searchHistory.remove(city);
    await _saveSettings();
    notifyListeners();
  }

  void clearHistory() async {
    _searchHistory.clear();
    await _saveSettings();
    notifyListeners();
  }

  Future<void> _addSearchHistory(String city) async {
    _searchHistory.removeWhere((c) => c.toLowerCase() == city.toLowerCase());
    _searchHistory.insert(0, city);
    if (_searchHistory.length > 8) _searchHistory.removeLast();
    await _saveSettings();
  }

  Future<void> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('search_history') ?? [];
    _favorites = prefs.getStringList('favorites') ?? [];
    _notifEnabled = prefs.getBool('notif_enabled') ?? false;
    _isCelsius = prefs.getBool('is_celsius') ?? true;
    _windUnit = WindUnit.values[prefs.getInt('wind_unit') ?? 0];
    notifyListeners();
    _startAutoRefresh();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
    await prefs.setStringList('favorites', _favorites);
    await prefs.setBool('notif_enabled', _notifEnabled);
    await prefs.setBool('is_celsius', _isCelsius);
    await prefs.setInt('wind_unit', _windUnit.index);
  }

  // ── FAVORITES ──────────────────────────────────────────
  bool isFavorite(String city) =>
      _favorites.any((f) => f.toLowerCase() == city.toLowerCase());

  Future<void> toggleFavorite(String city) async {
    if (isFavorite(city)) {
      _favorites.removeWhere((f) => f.toLowerCase() == city.toLowerCase());
    } else {
      _favorites.insert(0, city);
    }
    await _saveSettings();
    notifyListeners();
  }

  Future<void> removeFavorite(String city) async {
    _favorites.removeWhere((f) => f.toLowerCase() == city.toLowerCase());
    await _saveSettings();
    notifyListeners();
  }

  // ── LOCATION ───────────────────────────────────────────
  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Layanan lokasi tidak aktif');
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen');
    }
    return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}
