import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance =
      LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // NOTIFICATION CLICK CALLBACK
  // ============================================================

  void Function(Map<String, dynamic> data)? onNotificationTap;

  // ============================================================
  // ANDROID NOTIFICATION CHANNEL
  // ============================================================

  static const AndroidNotificationChannel channel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications.',
    importance: Importance.max,
  );

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    debugPrint('======================================');
    debugPrint('INITIALIZING LOCAL NOTIFICATIONS');
    debugPrint('======================================');

    // ----------------------------------------------------------
    // Android settings
    // ----------------------------------------------------------

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // ----------------------------------------------------------
    // iOS settings
    // ----------------------------------------------------------

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // ----------------------------------------------------------
    // Initialization settings
    // ----------------------------------------------------------

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // ==========================================================
    // IMPORTANT:
    // New flutter_local_notifications API uses named "settings"
    // ==========================================================

    await _notifications.initialize(
      settings: initializationSettings,

      onDidReceiveNotificationResponse:
          (NotificationResponse response) {
        debugPrint('======================================');
        debugPrint('LOCAL NOTIFICATION CLICKED');
        debugPrint('ID      : ${response.id}');
        debugPrint('ACTION  : ${response.actionId}');
        debugPrint('PAYLOAD : ${response.payload}');
        debugPrint('======================================');

        _handleNotificationPayload(
          response.payload,
        );
      },
    );

    // ============================================================
    // CREATE ANDROID CHANNEL
    // ============================================================

    final androidImplementation =
        _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation
        ?.createNotificationChannel(
      channel,
    );

    debugPrint('======================================');
    debugPrint(
      'LOCAL NOTIFICATION SERVICE INITIALIZED',
    );
    debugPrint('======================================');
  }

  // ============================================================
  // HANDLE NOTIFICATION PAYLOAD
  // ============================================================

  void _handleNotificationPayload(
    String? payload,
  ) {
    if (payload == null || payload.isEmpty) {
      debugPrint(
        'Notification payload is empty',
      );

      return;
    }

    try {
      debugPrint('======================================');
      debugPrint('DECODING NOTIFICATION PAYLOAD');
      debugPrint('PAYLOAD: $payload');
      debugPrint('======================================');

      final dynamic decodedData =
          jsonDecode(payload);

      if (decodedData is Map) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(
          decodedData,
        );

        debugPrint('======================================');
        debugPrint('NOTIFICATION DATA DECODED');
        debugPrint('DATA: $data');
        debugPrint('======================================');

        // Send notification click to FcmService
        onNotificationTap?.call(
          data,
        );
      } else {
        debugPrint(
          'Notification payload is not a Map',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint(
        'NOTIFICATION PAYLOAD ERROR',
      );
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stackTrace');
      debugPrint('======================================');
    }
  }

  // ============================================================
  // SHOW NOTIFICATION
  // ============================================================

  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // ==========================================================
    // ANDROID DETAILS
    // ==========================================================

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',

      channelDescription:
          'Used for important notifications.',

      importance: Importance.max,

      priority: Priority.high,

      playSound: true,

      enableVibration: true,

      icon: '@mipmap/ic_launcher',
    );

    // ==========================================================
    // IOS DETAILS
    // ==========================================================

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // ==========================================================
    // NOTIFICATION DETAILS
    // ==========================================================

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // ==========================================================
    // PAYLOAD
    // ==========================================================

    final String payload =
        jsonEncode(
      data ?? <String, dynamic>{},
    );

    // ==========================================================
    // NOTIFICATION ID
    // ==========================================================

    final int notificationId =
        DateTime.now()
            .millisecondsSinceEpoch
            .remainder(
              100000,
            );

    debugPrint('======================================');
    debugPrint('SHOWING LOCAL NOTIFICATION');
    debugPrint('ID      : $notificationId');
    debugPrint('TITLE   : $title');
    debugPrint('BODY    : $body');
    debugPrint('DATA    : $data');
    debugPrint('PAYLOAD : $payload');
    debugPrint('======================================');

    // ==========================================================
    // IMPORTANT:
    // New flutter_local_notifications API uses named parameters
    // ==========================================================

    await _notifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );

    debugPrint('======================================');
    debugPrint(
      'LOCAL NOTIFICATION DISPLAYED SUCCESSFULLY',
    );
    debugPrint('======================================');
  }
}