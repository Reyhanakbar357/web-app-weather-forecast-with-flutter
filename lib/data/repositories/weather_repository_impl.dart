import 'package:weather_app/core/utils/api_service.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  @override
  Future<WeatherEntity> getWeatherByCity(String city) async {
    try {
      final jsonData = await ApiService.getWeatherByCity(city);
      final weatherModel = WeatherModel.fromJson(jsonData);
      return weatherModel.toEntity();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }

  @override
  Future<WeatherEntity> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final jsonData = await ApiService.getWeatherByCoordinates(
        latitude,
        longitude,
      );
      final weatherModel = WeatherModel.fromJson(jsonData);
      return weatherModel.toEntity();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      throw Exception(msg);
    }
  }
}