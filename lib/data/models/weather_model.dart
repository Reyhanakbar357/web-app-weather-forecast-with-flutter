import 'package:weather_app/domain/entities/weather_entity.dart';

class WeatherModel {
  final String cityName;
  final String countryCode;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final double windDeg;
  final double? windGust;
  final String iconCode;
  final int pressure;
  final int visibility;
  final int cloudiness;
  final double? rainLastHour;
  final int sunrise;
  final int sunset;
  final int timezone;

  WeatherModel({
    required this.cityName,
    required this.countryCode,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    this.windGust,
    required this.iconCode,
    required this.pressure,
    required this.visibility,
    required this.cloudiness,
    this.rainLastHour,
    required this.sunrise,
    required this.sunset,
    required this.timezone,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>?;
    final weatherList = json['weather'] as List?;
    final firstWeather = (weatherList != null && weatherList.isNotEmpty)
        ? weatherList[0] as Map<String, dynamic>?
        : null;
    final wind = json['wind'] as Map<String, dynamic>?;
    final sys = json['sys'] as Map<String, dynamic>?;
    final clouds = json['clouds'] as Map<String, dynamic>?;
    final rain = json['rain'] as Map<String, dynamic>?;

    return WeatherModel(
      cityName: json['name'] as String? ?? 'Unknown',
      countryCode: sys?['country'] as String? ?? '',
      temperature: (main?['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main?['feels_like'] as num?)?.toDouble() ?? 0.0,
      tempMin: (main?['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (main?['temp_max'] as num?)?.toDouble() ?? 0.0,
      condition: firstWeather?['main'] as String? ?? 'Unknown',
      description: firstWeather?['description'] as String? ?? '',
      humidity: (main?['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind?['speed'] as num?)?.toDouble() ?? 0.0,
      windDeg: (wind?['deg'] as num?)?.toDouble() ?? 0.0,
      windGust: (wind?['gust'] as num?)?.toDouble(),
      iconCode: firstWeather?['icon'] as String? ?? '01d',
      pressure: (main?['pressure'] as num?)?.toInt() ?? 1013,
      visibility: (json['visibility'] as num?)?.toInt() ?? 10000,
      cloudiness: (clouds?['all'] as num?)?.toInt() ?? 0,
      rainLastHour: (rain?['1h'] as num?)?.toDouble(),
      sunrise: (sys?['sunrise'] as num?)?.toInt() ?? 0,
      sunset: (sys?['sunset'] as num?)?.toInt() ?? 0,
      timezone: (json['timezone'] as num?)?.toInt() ?? 0,
    );
  }

  WeatherEntity toEntity() {
    return WeatherEntity(
      cityName: cityName,
      countryCode: countryCode,
      temperature: temperature,
      feelsLike: feelsLike,
      tempMin: tempMin,
      tempMax: tempMax,
      condition: condition,
      description: description,
      humidity: humidity,
      windSpeed: windSpeed,
      windDeg: windDeg,
      windGust: windGust,
      iconCode: iconCode,
      pressure: pressure,
      visibility: visibility,
      cloudiness: cloudiness,
      rainLastHour: rainLastHour,
      sunrise: sunrise,
      sunset: sunset,
      timezone: timezone,
    );
  }
}
