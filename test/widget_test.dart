import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/presentation/providers/weather_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WeatherModel & Entity Tests', () {
    test('WeatherModel.fromJson parses correctly', () {
      final sampleJson = {
        'name': 'Jakarta',
        'sys': {'country': 'ID', 'sunrise': 1600000000, 'sunset': 1600045000},
        'main': {
          'temp': 30.5,
          'feels_like': 34.0,
          'temp_min': 28.0,
          'temp_max': 32.0,
          'humidity': 75,
          'pressure': 1010,
        },
        'weather': [
          {'main': 'Rain', 'description': 'hujan sedang', 'icon': '10d'}
        ],
        'wind': {'speed': 4.5, 'deg': 120.0, 'gust': 6.0},
        'visibility': 8000,
        'clouds': {'all': 80},
        'timezone': 25200,
      };

      final model = WeatherModel.fromJson(sampleJson);
      expect(model.cityName, 'Jakarta');
      expect(model.countryCode, 'ID');
      expect(model.temperature, 30.5);
      expect(model.condition, 'Rain');
      expect(model.description, 'hujan sedang');
      expect(model.humidity, 75);
      expect(model.windSpeed, 4.5);

      final entity = model.toEntity();
      expect(entity.cityName, 'Jakarta');
      expect(entity.temperature, 30.5);
    });

    test('WeatherModel.fromJson handles null/empty weather gracefully', () {
      final emptyJson = {
        'name': 'Unknown City',
      };

      final model = WeatherModel.fromJson(emptyJson);
      expect(model.cityName, 'Unknown City');
      expect(model.temperature, 0.0);
      expect(model.condition, 'Unknown');
      expect(model.description, '');
      expect(model.iconCode, '01d');
    });
  });

  group('WeatherProvider Unit Tests', () {
    test('Temperature conversion works between Celsius and Fahrenheit', () {
      final provider = WeatherProvider();
      expect(provider.isCelsius, true);
      expect(provider.convertTemp(0), 0);
      expect(provider.convertTemp(25), 25);

      provider.toggleUnit();
      expect(provider.isCelsius, false);
      expect(provider.convertTemp(0), 32);
      expect(provider.convertTemp(100), 212);
    });

    test('Wind unit formatting works', () {
      final provider = WeatherProvider();
      // Default kmh: 10 m/s * 3.6 = 36 km/h
      expect(provider.formatWindSpeed(10.0), '36 km/h');

      provider.cycleWindUnit();
      // ms
      expect(provider.formatWindSpeed(10.0), '10.0 m/s');

      provider.cycleWindUnit();
      // knots: 10 * 1.94384 ~= 19 kt
      expect(provider.formatWindSpeed(10.0), '19 kt');
    });
  });
}
