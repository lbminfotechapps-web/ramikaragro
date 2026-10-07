import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmTokenService {
  FcmTokenService._();

  static final FcmTokenService instance = FcmTokenService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ============================================================
  // GET FCM TOKEN
  // ============================================================

  Future<String?> getFcmToken() async {
    try {
      // ========================================================
      // REQUEST PERMISSION
      // ========================================================

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'NOTIFICATION STATUS: '
        '${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        debugPrint('Notification permission not granted');

        return null;
      }

      // ========================================================
      // IOS - WAIT FOR APNS TOKEN
      // ========================================================

      if (Platform.isIOS) {
        String? apnsToken;

        for (int attempt = 1; attempt <= 15; attempt++) {
          try {
            apnsToken = await _messaging.getAPNSToken();
          } catch (e) {
            debugPrint('APNS TOKEN ERROR: $e');
          }

          if (apnsToken != null && apnsToken.trim().isNotEmpty) {
            debugPrint('======================================');

            debugPrint('APNS TOKEN AVAILABLE');

            debugPrint(apnsToken);

            debugPrint('======================================');

            break;
          }

          debugPrint(
            'Waiting for APNS token '
            '$attempt/15',
          );

          await Future.delayed(const Duration(seconds: 1));
        }

        if (apnsToken == null || apnsToken.trim().isEmpty) {
          debugPrint('APNS TOKEN NOT AVAILABLE');

          return null;
        }
      }

      // ========================================================
      // GET FCM TOKEN
      // ========================================================

      final String? token = await _messaging.getToken();

      debugPrint('======================================');

      debugPrint('FCM TOKEN FOR LOGIN');

      debugPrint(token);

      debugPrint('======================================');

      return token;
    } catch (e, stackTrace) {
      debugPrint('GET FCM TOKEN ERROR: $e');

      debugPrint('$stackTrace');

      return null;
    }
  }

  // ============================================================
  // TOKEN REFRESH
  // ============================================================

  void listenTokenRefresh({
    required Future<void> Function(String token) onTokenChanged,
  }) {
    _messaging.onTokenRefresh.listen(
      (String token) async {
        if (token.trim().isEmpty) {
          return;
        }

        debugPrint('======================================');

        debugPrint('FCM TOKEN REFRESHED');

        debugPrint(token);

        debugPrint('======================================');

        await onTokenChanged(token);
      },
      onError: (error) {
        debugPrint('FCM REFRESH ERROR: $error');
      },
    );
  }
}
