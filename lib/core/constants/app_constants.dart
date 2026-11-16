class AppConstants {
  static const String appName = 'SkyView';
  // Dapatkan API Key gratis di https://openweathermap.org/api
  static const String openWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: 'YOUR_OPENWEATHER_API_KEY',
  );
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
}
