import 'package:flutter/material.dart';
import 'package:solufine/features/weather/weather_service.dart';
import 'package:solufine/features/weather/weathermodel.dart';

class HomeForecastCard extends StatefulWidget {
  const HomeForecastCard({super.key, this.compact = false, this.weatherFuture});

  final bool compact;
  final Future<WeatherModel>? weatherFuture;

  @override
  State<HomeForecastCard> createState() => _HomeForecastCardState();
}

class _HomeForecastCardState extends State<HomeForecastCard> {
  final WeatherService _service = WeatherService();

  late Future<WeatherModel> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.weatherFuture ?? _service.getWeather();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.hasBoundedWidth
              ? constraints.maxWidth
              : widget.compact
              ? 170
              : MediaQuery.sizeOf(context).width - 20,
          height: widget.compact && !constraints.hasBoundedHeight ? 100 : null,
          child: _buildForecast(context),
        );
      },
    );
  }

  Widget _buildForecast(BuildContext context) {
    return FutureBuilder<WeatherModel>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final weather = snapshot.data!;

        // API must use timezone=Asia/Kolkata.
        final now = DateTime.now();

        final today = weather.hourly.where((item) {
          return item.time.year == now.year &&
              item.time.month == now.month &&
              item.time.day == now.day;
        }).toList();

        if (today.isEmpty) {
          return const SizedBox.shrink();
        }

        final maxTemp = today
            .map((e) => e.temperature)
            .reduce((a, b) => a > b ? a : b);

        final minTemp = today
            .map((e) => e.temperature)
            .reduce((a, b) => a < b ? a : b);

        final maxWind = today
            .map((e) => e.windSpeed)
            .reduce((a, b) => a > b ? a : b);

        if (widget.compact) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2379C8), Color(0xFF124B8C)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF124B8C).withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 145,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Today's Weather",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.cloud_outlined,
                          size: 17,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '${maxTemp.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              fontSize: 30,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'HIGH / LOW',
                              style: TextStyle(
                                fontSize: 7,
                                letterSpacing: 0.8,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${maxTemp.toStringAsFixed(0)}° / ${minTemp.toStringAsFixed(0)}°C',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 10,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 2),
                        const Expanded(
                          child: Text(
                            'Nashik',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 9, color: Colors.white70),
                          ),
                        ),
                        const Icon(Icons.air, size: 11, color: Colors.white70),
                        const SizedBox(width: 3),
                        Text(
                          '${maxWind.toStringAsFixed(0)} km/h',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_outlined, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Today's Weather Forecast",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Nashik',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _forecastItem(
                      Icons.thermostat,
                      'Max Temp',
                      '${maxTemp.toStringAsFixed(1)}°',
                      Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _forecastItem(
                      Icons.ac_unit,
                      'Min Temp',
                      '${minTemp.toStringAsFixed(1)}°',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _forecastItem(
                      Icons.air,
                      'Max Wind',
                      maxWind.toStringAsFixed(1),
                      Colors.teal,
                      unit: 'km/h',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _forecastItem(
    IconData icon,
    String label,
    String value,
    Color color, {
    String? unit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (unit != null)
            Text(unit, style: const TextStyle(fontSize: 9, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
