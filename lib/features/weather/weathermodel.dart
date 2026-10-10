class HourlyWeather {
  final DateTime time;
  final double temperature;
  final double windSpeed;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.windSpeed,
  });
}

class WeatherModel {
  final double latitude;
  final double longitude;
  final String timezone;
  final double currentTemperature;
  final double currentWindSpeed;
  final List<HourlyWeather> hourly;

  const WeatherModel({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.currentTemperature,
    required this.currentWindSpeed,
    required this.hourly,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final hourlyData = json['hourly'] as Map<String, dynamic>;
    final times = hourlyData['time'] as List;
    final temperatures = hourlyData['temperature_2m'] as List;
    final winds = hourlyData['wind_speed_10m'] as List;

    final count = [
      times.length,
      temperatures.length,
      winds.length,
    ].reduce((a, b) => a < b ? a : b);

    final hourly = List.generate(count, (index) {
      return HourlyWeather(
        time: DateTime.parse(times[index].toString()),
        temperature: (temperatures[index] as num).toDouble(),
        windSpeed: (winds[index] as num).toDouble(),
      );
    });

    final current = json['current'] as Map<String, dynamic>?;

    // Fallback for the original JSON without "current".
    final now = DateTime.now();
    int closestIndex = 0;

    if (hourly.isNotEmpty) {
      for (var i = 1; i < hourly.length; i++) {
        if (hourly[i].time.difference(now).abs() <
            hourly[closestIndex].time.difference(now).abs()) {
          closestIndex = i;
        }
      }
    }

    return WeatherModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone']?.toString() ?? '',
      currentTemperature:
          (current?['temperature_2m'] as num?)?.toDouble() ??
          (hourly.isNotEmpty ? hourly[closestIndex].temperature : 0),
      currentWindSpeed:
          (current?['wind_speed_10m'] as num?)?.toDouble() ??
          (hourly.isNotEmpty ? hourly[closestIndex].windSpeed : 0),
      hourly: hourly,
    );
  }
}
