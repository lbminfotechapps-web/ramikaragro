//=======================================notification24-09-2026===============================================

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'fcm_token_service.dart';
import 'local_notification_service.dart';
import 'notification_navigation_service.dart';

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    debugPrint('======================================');
    debugPrint('FCM SERVICE INITIALIZING');
    debugPrint('======================================');

    // 1. Ask permission
    await _requestPermission();

    // 2. Get/save current token
    await FcmTokenService.instance.saveCurrentToken();

    // 3. Listen token refresh
    FcmTokenService.instance.listenTokenRefresh();

    // 4. Listen foreground messages
    _listenForegroundMessages();

    // 5. Notification clicked from background
    _listenNotificationClick();

    // 6. Local notification clicked
    LocalNotificationService.instance.onNotificationTap =
        (Map<String, dynamic> data) {
      debugPrint('======================================');
      debugPrint('LOCAL NOTIFICATION CLICKED');
      debugPrint('DATA: $data');
      debugPrint('======================================');

      NotificationNavigationService.instance
          .handleNotification(data);
    };

    // 7. App opened from terminated notification
    await _checkInitialNotification();

    debugPrint('======================================');
    debugPrint('FCM SERVICE INITIALIZED');
    debugPrint('======================================');
  }

  // ============================================================
  // PERMISSION
  // ============================================================

  Future<void> _requestPermission() async {
    final NotificationSettings settings =
        await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('======================================');
    debugPrint('NOTIFICATION PERMISSION');
    debugPrint(
      'STATUS: ${settings.authorizationStatus}',
    );
    debugPrint('======================================');
  }

  // ============================================================
  // FOREGROUND MESSAGE
  // ============================================================

  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        debugPrint('======================================');
        debugPrint('FCM MESSAGE RECEIVED - FOREGROUND');
        debugPrint('MESSAGE ID: ${message.messageId}');
        debugPrint('DATA: ${message.data}');
        debugPrint('======================================');

        // ======================================================
        // SAME AS YOUR KOTLIN:
        //
        // remoteMessage.data["notificationTitle"]
        // remoteMessage.data["notificationMessage"]
        // ======================================================

        final String title =
            message.data['notificationTitle']
                    ?.toString() ??
                message.notification?.title ??
                'Solufine';

        final String body =
            message.data['notificationMessage']
                    ?.toString() ??
                message.notification?.body ??
                '';

        final String notificationType =
            message.data['notificationType']
                    ?.toString() ??
                '';

        debugPrint('======================================');
        debugPrint('PARSED NOTIFICATION');
        debugPrint('TITLE   : $title');
        debugPrint('MESSAGE : $body');
        debugPrint('TYPE    : $notificationType');
        debugPrint('======================================');

        if (body.isEmpty) {
          debugPrint(
            'Notification message empty. Not displaying.',
          );
          return;
        }

        // ======================================================
        // SAME PURPOSE AS Kotlin sendNotification()
        // ======================================================

        await LocalNotificationService.instance
            .showNotification(
          title: title,
          body: body,
          data: message.data,
        );

        debugPrint('======================================');
        debugPrint(
          'LOCAL NOTIFICATION DISPLAY REQUEST COMPLETE',
        );
        debugPrint('======================================');
      },
      onError: (error) {
        debugPrint('======================================');
        debugPrint('FOREGROUND FCM ERROR');
        debugPrint('$error');
        debugPrint('======================================');
      },
    );
  }

  // ============================================================
  // BACKGROUND -> USER CLICKS FCM NOTIFICATION
  // ============================================================

  void _listenNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        debugPrint('======================================');
        debugPrint('FCM NOTIFICATION CLICKED');
        debugPrint('STATE: BACKGROUND');
        debugPrint('DATA: ${message.data}');
        debugPrint('======================================');

        NotificationNavigationService.instance
            .handleNotification(
          message.data,
        );
      },
    );
  }

  // ============================================================
  // TERMINATED -> USER CLICKS NOTIFICATION
  // ============================================================

  Future<void> _checkInitialNotification() async {
    final RemoteMessage? message =
        await _messaging.getInitialMessage();

    if (message == null) {
      return;
    }

    debugPrint('======================================');
    debugPrint('APP OPENED FROM NOTIFICATION');
    debugPrint('PREVIOUS STATE: TERMINATED');
    debugPrint('DATA: ${message.data}');
    debugPrint('======================================');

    Future.delayed(
      const Duration(seconds: 1),
      () {
        NotificationNavigationService.instance
            .handleNotification(
          message.data,
        );
      },
    );
  }
}