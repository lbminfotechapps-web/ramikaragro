import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmTokenService {
  FcmTokenService._();

  static final FcmTokenService instance =
      FcmTokenService._();

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  // ============================================================
  // GET TOKEN
  // ============================================================

  Future<String?> getToken() async {
    try {
      final String? token =
          await _messaging.getToken();

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
      (String newToken) {
        debugPrint('======================================');
        debugPrint('FCM TOKEN REFRESHED');
        debugPrint(newToken);
        debugPrint('======================================');

        saveTokenToServer(newToken);
      },
      onError: (error) {
        debugPrint(
          'FCM token refresh error: $error',
        );
      },
    );
  }

  // ============================================================
  // SAVE TOKEN
  // ============================================================

  Future<void> saveCurrentToken() async {
    final String? token =
        await getToken();

    if (token == null ||
        token.trim().isEmpty) {
      debugPrint(
        'FCM token is empty. Not sending to server.',
      );

      return;
    }

    await saveTokenToServer(token);
  }

  // ============================================================
  // SEND TOKEN TO SERVER
  // ============================================================

  Future<void> saveTokenToServer(
    String token,
  ) async {
    try {
      final String deviceType =
          Platform.isAndroid
              ? 'android'
              : Platform.isIOS
                  ? 'ios'
                  : 'unknown';

      debugPrint('======================================');
      debugPrint('SAVE FCM TOKEN TO SERVER');
      debugPrint('TOKEN       : $token');
      debugPrint('DEVICE TYPE : $deviceType');
      debugPrint('======================================');

  
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('SAVE FCM TOKEN ERROR');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('======================================');
    }
  }
}