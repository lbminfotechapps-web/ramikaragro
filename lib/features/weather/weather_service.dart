import 'package:dio/dio.dart';
import 'package:solufine/features/weather/weathermodel.dart';

class WeatherService {
  final Dio _dio = Dio();

  Future<WeatherModel> getWeather() async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': 19.9676,
          'longitude': 73.7776,
          'hourly': 'temperature_2m,wind_speed_10m',
          'timezone': 'Asia/Kolkata',
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      throw Exception('Failed to load weather');
    } catch (e) {
      throw Exception('Weather API Error: $e');
    }
  }
}
