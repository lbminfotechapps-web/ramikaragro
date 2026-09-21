import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeveloperOptionsChecker {
  static const MethodChannel _channel =
      MethodChannel('developer_options_checker');

  static Future<bool> isDeveloperOptionsEnabled() async {
    try {
      final bool result =
          await _channel.invokeMethod<bool>(
                'isDeveloperOptionsEnabled',
              ) ??
              false;

      return result;
    } catch (e) {
      debugPrint('Developer Options check error: $e');
      return false;
    }
  }
}