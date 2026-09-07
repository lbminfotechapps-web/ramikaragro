import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DeviceInfoUtil {
  DeviceInfoUtil._();

  static final DeviceInfoUtil instance = DeviceInfoUtil._();

  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  Future<String> getBatteryInfo() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      return '$batteryLevel%';
    } catch (e) {
      return '';
    }
  }

  Future<String> getNetworkInfo() async {
    try {
      final result = await _connectivity.checkConnectivity();

      if (result.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      }

      if (result.contains(ConnectivityResult.mobile)) {
        return 'Mobile Data';
      }

      if (result.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      }

      if (result.contains(ConnectivityResult.bluetooth)) {
        return 'Bluetooth';
      }

      if (result.contains(ConnectivityResult.none)) {
        return 'No Network';
      }

      return 'Unknown';
    } catch (e) {
      return '';
    }
  }
}
