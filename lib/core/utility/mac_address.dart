import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoUtil {
  DeviceInfoUtil._();

  static final DeviceInfoUtil instance = DeviceInfoUtil._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Returns device information
  Future<String> getMobileInfo() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
            await _deviceInfo.androidInfo;

        return '${androidInfo.manufacturer} ${androidInfo.model}';
      }

      if (Platform.isIOS) {
        final IosDeviceInfo iosInfo =
            await _deviceInfo.iosInfo;

        return '${iosInfo.name} ${iosInfo.model}';
      }

      return 'Unknown Device';
    } catch (e) {
      print('Device Info Error: $e');
      return 'Unknown Device';
    }
  }

  /// Returns MAC address
  ///
  /// Android/iOS generally do not expose the real Wi-Fi MAC address
  /// to normal applications on modern OS versions.
  Future<String> getMacAddress() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo =
            await _deviceInfo.androidInfo;

        // Android ID can be used as a stable device identifier
        // when the backend requires a device-specific identifier.
        return androidInfo.id;
      }

      if (Platform.isIOS) {
        final IosDeviceInfo iosInfo =
            await _deviceInfo.iosInfo;

        return iosInfo.identifierForVendor ?? 'unknown';
      }

      return 'unknown';
    } catch (e) {
      print('MAC Address Error: $e');
      return 'unknown';
    }
  }

  /// Gets both values together
  Future<Map<String, String>> getDeviceInfo() async {
    final mobileInfo = await getMobileInfo();
    final macAddress = await getMacAddress();

    return {
      'mobileInfo': mobileInfo,
      'macAddress': macAddress,
    };
  }
}