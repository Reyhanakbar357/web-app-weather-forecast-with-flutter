import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart'
    if (dart.library.html) 'package:weather_app/core/services/workmanager_stub.dart';
import 'package:weather_app/core/services/background_weather_task.dart'
    if (dart.library.html) 'package:weather_app/core/services/background_weather_task_stub.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const String _prefKey = 'notif_enabled';

  Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    if (value) {
      await init();
      await _requestPermission();
      // Register periodic background weather check (hanya di mobile)
      if (!kIsWeb) {
        await Workmanager().registerPeriodicTask(
          backgroundWeatherTask,
          backgroundWeatherTask,
          frequency: const Duration(minutes: 15),
          constraints: Constraints(
            networkType: NetworkType.connected,
          ),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        );
      }
      // Kirim notifikasi selamat datang
      await _showWelcome();
    } else {
      await _plugin.cancelAll();
      // Cancel background weather tracking task (hanya di mobile)
      if (!kIsWeb) {
        await Workmanager().cancelByUniqueName(backgroundWeatherTask);
      }
    }
  }

  Future<void> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  Future<void> _showWelcome() async {
    await _plugin.show(
      99,
      '🌤 SkyView Notifikasi Aktif',
      'Kamu akan mendapat info cuaca terkini setiap kali membuka app',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'skyview_general',
          'SkyView Info',
          channelDescription: 'Info & pembaruan cuaca',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF5BC8FF),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showWeatherUpdate({
    required String cityName,
    required String description,
    required int temperature,
    required int humidity,
  }) async {
    final enabled = await isEnabled();
    if (!enabled) return;
    await init();

    final emoji = _emoji(description);
    await _plugin.show(
      0,
      '$emoji SkyView — $cityName',
      '$description · $temperature°C · Kelembapan $humidity%',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'skyview_weather',
          'SkyView Cuaca',
          channelDescription: 'Notifikasi cuaca terkini',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          color: const Color(0xFF5BC8FF),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showAlert({required String title, required String body}) async {
    final enabled = await isEnabled();
    if (!enabled) return;
    await init();

    await _plugin.show(
      1,
      '⚠️ $title',
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'skyview_alerts',
          'SkyView Peringatan',
          channelDescription: 'Peringatan cuaca ekstrem',
          importance: Importance.max,
          priority: Priority.max,
          color: const Color(0xFFF97316),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showWeatherChangeAlert({
    required String cityName,
    required String oldDesc,
    required String newDesc,
    required int temperature,
  }) async {
    final enabled = await isEnabled();
    if (!enabled) return;
    await init();

    final emoji = _emoji(newDesc);
    await _plugin.show(
      2,
      '$emoji Cuaca Berubah: $cityName',
      'Cuaca berubah dari $oldDesc menjadi $newDesc. Suhu saat ini $temperature°C.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'skyview_weather_change',
          'Perubahan Cuaca',
          channelDescription: 'Notifikasi saat cuaca tiba-tiba berubah',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF5BC8FF),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  String _emoji(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('rain') || d.contains('hujan')) return '🌧';
    if (d.contains('clear') || d.contains('cerah')) return '☀️';
    if (d.contains('cloud') || d.contains('awan')) return '☁️';
    if (d.contains('thunder') || d.contains('petir')) return '⛈️';
    if (d.contains('fog') || d.contains('mist') || d.contains('kabut')) return '🌫';
    if (d.contains('snow') || d.contains('salju')) return '❄️';
    return '🌤';
  }
}
