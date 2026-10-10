import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/home/presentation/widgets/rotating_home_card.dart';

void main() {
  testWidgets('flips both ways, preserves weather state, and opens pending', (
    tester,
  ) async {
    var taps = 0;
    Widget card(bool showPending) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 180,
          height: 100,
          child: RotatingHomeCard(
            showPending: showPending,
            weather: const Text('Weather'),
            pending: TextButton(
              onPressed: () => taps++,
              child: const Text('Pending'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(card(true));
    final weatherElement = tester.element(find.text('Weather'));
    expect(find.text('Pending'), findsNothing);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Pending'), findsOneWidget);
    await tester.tap(find.text('Pending'));
    expect(taps, 1);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Weather'), findsOneWidget);
    expect(tester.element(find.text('Weather')), same(weatherElement));

    await tester.pumpWidget(card(false));
    await tester.pump(const Duration(seconds: 8));
    expect(find.text('Weather'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
