import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solufine/core/utility/widgets/connection_status_row.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('shows unavailable, idle and measured speeds with correct units', () {
    expect(formatNetworkSpeed(null), '— KB/s');
    expect(formatNetworkSpeed(0), '0.0 KB/s');
    expect(formatNetworkSpeed(12500), '12.5 KB/s');
    expect(formatNetworkSpeed(1000000), '1.0 MB/s');
    expect(formatNetworkSpeed(2500000), '2.5 MB/s');
  });

  testWidgets('renders on a narrow screen and cleans up polling', (
    tester,
  ) async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const connectivity = MethodChannel(
      'dev.fluttercommunity.plus/connectivity',
    );
    const events = MethodChannel(
      'dev.fluttercommunity.plus/connectivity_status',
    );
    const traffic = MethodChannel('solufine/network_traffic');
    messenger.setMockMethodCallHandler(connectivity, (_) async => ['wifi']);
    messenger.setMockMethodCallHandler(events, (_) async => null);
    var trafficReads = 0;
    messenger.setMockMethodCallHandler(traffic, (_) async {
      trafficReads++;
      return 1000;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(connectivity, null);
      messenger.setMockMethodCallHandler(events, null);
      messenger.setMockMethodCallHandler(traffic, null);
    });
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 280, child: ConnectionStatusRow()),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(trafficReads, 1);
    await tester.pump(const Duration(seconds: 4));
    expect(trafficReads, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(trafficReads, 2);
    expect(find.text('↕ 0.0 KB/s'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
    expect(trafficReads, 2);
    expect(tester.takeException(), isNull);
  });
}
