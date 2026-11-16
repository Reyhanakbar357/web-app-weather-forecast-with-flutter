class WeatherEntity {
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

  WeatherEntity({
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
}
