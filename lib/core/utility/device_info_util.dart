import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

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
      final info = await _deviceInfo.deviceInfo;
      if (info is AndroidDeviceInfo) {
        return '${info.manufacturer} ${info.model}';
      }
      if (info is IosDeviceInfo) {
        return '${info.name} ${info.model}';
      }
    } catch (e, stackTrace) {
      debugPrint('GET MOBILE INFO ERROR: $e\n$stackTrace');
    }
    return '';
  }

  // ============================================================
  // MAC / DEVICE IDENTIFIER
  // ============================================================

  Future<String> getMacAddress() async {
    try {
      final info = await _deviceInfo.deviceInfo;
      if (info is AndroidDeviceInfo) {
        // This is the Android build ID, not a physical Wi-Fi MAC address.
        return info.id;
      }
      if (info is IosDeviceInfo) {
        return info.identifierForVendor ?? '';
      }
    } catch (e, stackTrace) {
      debugPrint('GET DEVICE IDENTIFIER ERROR: $e\n$stackTrace');
    }
    return '';
  }

  // ============================================================
  // MOBILE INFO + MAC ADDRESS
  // ============================================================

  Future<Map<String, String>> getDeviceInfo() async {
    final mobileInfo = await getMobileInfo();
    final macAddress = await getMacAddress();

    return {'mobileInfo': mobileInfo, 'macAddress': macAddress};
  }
}
