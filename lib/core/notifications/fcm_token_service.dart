import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmTokenService {
  FcmTokenService._();

  static final FcmTokenService instance = FcmTokenService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ============================================================
  // GET TOKEN
  // ============================================================

  Future<String?> getToken() async {
    try {
      // ============================================================
      // iOS - WAIT FOR APNS TOKEN FIRST
      // ============================================================

      if (Platform.isIOS) {
        String? apnsToken;

        for (int attempt = 1; attempt <= 10; attempt++) {
          try {
            apnsToken = await _messaging.getAPNSToken();
          } catch (e) {
            debugPrint('APNS token check error: $e');
          }

          if (apnsToken != null && apnsToken.trim().isNotEmpty) {
            debugPrint('======================================');
            debugPrint('APNS TOKEN RECEIVED');
            debugPrint(apnsToken);
            debugPrint('======================================');

            break;
          }

          debugPrint(
            'APNS token not available yet. '
            'Attempt $attempt/10',
          );

          await Future.delayed(const Duration(seconds: 1));
        }

        // ============================================================
        // DO NOT CALL getToken() UNTIL APNS TOKEN EXISTS
        // ============================================================

        if (apnsToken == null || apnsToken.trim().isEmpty) {
          debugPrint('======================================');
          debugPrint('APNS TOKEN NOT AVAILABLE');
          debugPrint('Skipping FCM token request for now.');
          debugPrint('======================================');

          return null;
        }
      }

      // ============================================================
      // GET FCM TOKEN
      // ============================================================

      final String? token = await _messaging.getToken();

      debugPrint('======================================');
      debugPrint('FCM TOKEN');
      debugPrint(token);
      debugPrint('======================================');

      return token;
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('FCM TOKEN ERROR');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('======================================');

      return null;
    }
  }

  // ============================================================
  // LISTEN TOKEN REFRESH
  // ============================================================

  void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen(
      (String newToken) async {
        debugPrint('======================================');
        debugPrint('FCM TOKEN REFRESHED');
        debugPrint(newToken);
        debugPrint('======================================');

        if (newToken.trim().isEmpty) {
          return;
        }

        await saveTokenToServer(newToken);
      },
      onError: (error) {
        debugPrint('FCM token refresh error: $error');
      },
    );
  }

  // ============================================================
  // SAVE CURRENT TOKEN
  // ============================================================

  Future<void> saveCurrentToken() async {
    final String? token = await getToken();

    if (token == null || token.trim().isEmpty) {
      debugPrint('======================================');
      debugPrint(
        'FCM token is empty. '
        'Not sending to server.',
      );
      debugPrint('======================================');

      return;
    }

    await saveTokenToServer(token);
  }

  // ============================================================
  // SEND TOKEN TO SERVER
  // ============================================================

  Future<void> saveTokenToServer(String token) async {
    try {
      final String deviceType = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : 'unknown';

      debugPrint('======================================');
      debugPrint('SAVE FCM TOKEN TO SERVER');
      debugPrint('TOKEN       : $token');
      debugPrint('DEVICE TYPE : $deviceType');
      debugPrint('======================================');

      // ============================================================
      // YOUR API CALL HERE
      // ============================================================

      /*
      await yourRepository.saveFcmToken(
        token: token,
        deviceType: deviceType,
      );
      */
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('SAVE FCM TOKEN ERROR');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('======================================');
    }
  }
}
