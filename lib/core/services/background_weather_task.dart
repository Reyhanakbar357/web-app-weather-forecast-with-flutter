import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:weather_app/core/services/notification_service.dart';
import 'package:weather_app/core/utils/api_service.dart';
import 'package:weather_app/data/models/weather_model.dart';

const String backgroundWeatherTask = "backgroundWeatherTask";

/// Inisialisasi Workmanager — hanya dipanggil di Android/iOS
void initializeWorkmanager() {
  Workmanager().initialize(callbackDispatcher);
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifEnabled = prefs.getBool('notif_enabled') ?? false;

      // If notifications are disabled, don't do anything
      if (!notifEnabled) return Future.value(true);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return Future.value(true);

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.value(true);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      final json = await ApiService.getWeatherByCoordinates(
          position.latitude, position.longitude);
      final weather = WeatherModel.fromJson(json).toEntity();

      final lastDesc = prefs.getString('last_weather_desc');

      final notifService = NotificationService();
      await notifService.init();

      if (lastDesc != null &&
          lastDesc.toLowerCase() != weather.description.toLowerCase()) {
        await notifService.showWeatherChangeAlert(
          cityName: weather.cityName,
          oldDesc: lastDesc,
          newDesc: weather.description,
          temperature: weather.temperature.round(),
        );
      }

      // Save current description as last known
      await prefs.setString('last_weather_desc', weather.description);
    } catch (e) {
      // Ignore errors in background task
      debugPrint("Background task error: $e");
    }
    return Future.value(true);
  });
}
