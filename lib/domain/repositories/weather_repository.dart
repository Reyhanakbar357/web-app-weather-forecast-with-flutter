import 'package:weather_app/domain/entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getWeatherByCity(String city);
  Future<WeatherEntity> getWeatherByCoordinates(double latitude, double longitude);
}