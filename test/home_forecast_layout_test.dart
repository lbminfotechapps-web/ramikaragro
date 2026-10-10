import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/home/presentation/widgets/rotating_home_card.dart';
import 'package:solufine/features/weather/homeforecastcard.dart';
import 'package:solufine/features/weather/weathermodel.dart';

void main() {
  testWidgets('cold reopen loads weather while pending is visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (var opening = 0; opening < 2; opening++) {
      final weather = Completer<WeatherModel>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Row(
                children: [
                  const Expanded(child: SizedBox(height: 100)),
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: RotatingHomeCard(
                        showPending: true,
                        weather: HomeForecastCard(
                          compact: true,
                          weatherFuture: weather.future,
                        ),
                        pending: const ColoredBox(
                          color: Colors.green,
                          child: Text('Pending'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 4));
      // The loading spinner animates continuously, so advance fixed frames.
      await tester.pump(const Duration(milliseconds: 700));
      weather.complete(
        WeatherModel(
          latitude: 19.96,
          longitude: 73.77,
          timezone: 'Asia/Kolkata',
          currentTemperature: 28,
          currentWindSpeed: 12,
          hourly: [
            HourlyWeather(time: DateTime.now(), temperature: 28, windSpeed: 12),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text("Today's Weather"), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('loaded weather stays constrained during both flips', (
    tester,
  ) async {
    final weather = Completer<WeatherModel>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Row(
              children: [
                const Expanded(child: SizedBox(height: 100)),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: RotatingHomeCard(
                      showPending: true,
                      weather: HomeForecastCard(
                        compact: true,
                        weatherFuture: weather.future,
                      ),
                      pending: const ColoredBox(
                        color: Colors.green,
                        child: Text('Pending'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    weather.complete(
      WeatherModel(
        latitude: 19.96,
        longitude: 73.77,
        timezone: 'Asia/Kolkata',
        currentTemperature: 28,
        currentWindSpeed: 12,
        hourly: [
          HourlyWeather(time: DateTime.now(), temperature: 28, windSpeed: 12),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Today's Weather"), findsOneWidget);
    expect(tester.takeException(), isNull);
    for (var i = 0; i < 2; i++) {
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());

    // Also constrain the card when used directly as a non-flex Row child.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              HomeForecastCard(compact: true, weatherFuture: weather.future),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Today's Weather"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
