import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/core/constants/app_constants.dart';

class ApiService {
  static const String _baseUrl = AppConstants.openWeatherBaseUrl;
  static const String _apiKey = AppConstants.openWeatherApiKey;

  static Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final url = Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    try {
      final err = json.decode(response.body);
      throw Exception(err['message'] ?? 'Kota tidak ditemukan');
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) {
        rethrow;
      }
      throw Exception('Kota tidak ditemukan ($city)');
    }
  }

  static Future<Map<String, dynamic>> getWeatherByCoordinates(double lat, double lon) async {
    final url = Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    try {
      final err = json.decode(response.body);
      throw Exception(err['message'] ?? 'Gagal mengambil data cuaca');
    } catch (e) {
      if (e is Exception && !e.toString().contains('FormatException')) {
        rethrow;
      }
      throw Exception('Gagal mengambil data cuaca');
    }
  }

  static Future<List<Map<String, dynamic>>> getMultipleCities(List<String> cities) async {
    final futures = cities.map((c) => getWeatherByCity(c));
    final results = await Future.wait(futures.map((f) => f.catchError((_) => <String, dynamic>{})));
    return results.cast<Map<String, dynamic>>();
  }
}
