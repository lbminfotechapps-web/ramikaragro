import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoUtil {
  DeviceInfoUtil._();

  static final DeviceInfoUtil instance = DeviceInfoUtil._();

  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // ============================================================
  // BATTERY
  // ============================================================

  Future<String> getBatteryInfo() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      return '$batteryLevel%';
    } catch (e) {
      return '';
    }
  }

  // ============================================================
  // NETWORK
  // ============================================================

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

  // ============================================================
  // MOBILE INFO
  // ============================================================

  Future<String> getMobileInfo() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;

      return '${androidInfo.manufacturer} ${androidInfo.model}';
    } catch (e) {
      try {
        final iosInfo = await _deviceInfo.iosInfo;

        return '${iosInfo.name} ${iosInfo.model}';
      } catch (e) {
        return '';
      }
    }
  }

  // ============================================================
  // MAC / DEVICE IDENTIFIER
  // ============================================================

  Future<String> getMacAddress() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;

      // NOTE:
      // This is NOT the physical Wi-Fi MAC address.
      // Android does not normally allow apps to access
      // the real MAC address on modern Android versions.
      return androidInfo.id;
    } catch (e) {
      try {
        final iosInfo = await _deviceInfo.iosInfo;

        return iosInfo.identifierForVendor ?? '';
      } catch (e) {
        return '';
      }
    }
  }

  // ============================================================
  // MOBILE INFO + MAC ADDRESS
  // ============================================================

  Future<Map<String, String>> getDeviceInfo() async {
    final mobileInfo = await getMobileInfo();
    final macAddress = await getMacAddress();

    return {
      'mobileInfo': mobileInfo,
      'macAddress': macAddress,
    };
  }
}