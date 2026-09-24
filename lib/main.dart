// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:solufine/app.dart';
// import 'package:solufine/core/di/global_di.dart';
// import 'package:solufine/core/location_tracking/background_location_service.dart';

// import 'package:solufine/core/notifiations/fcm_token_service.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   FcmTokenService.instance.listenTokenRefresh();
//   await initGlobalDi();
//   await BackgroundLocationService.initialize();
//   await BackgroundLocationService.checkServiceStatus();

//   runApp(const MyApp());
// }


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:solufine/app.dart';
import 'package:solufine/core/di/global_di.dart';
import 'package:solufine/core/location_tracking/background_location_service.dart';
import 'package:solufine/core/notifications/fcm_service.dart';
import 'package:solufine/core/notifications/local_notification_service.dart';



// ============================================================
// FCM BACKGROUND HANDLER
// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Background isolate needs Firebase initialization.
  await Firebase.initializeApp();

  debugPrint('==========================================');
  debugPrint('FCM BACKGROUND MESSAGE RECEIVED');
  debugPrint('MESSAGE ID : ${message.messageId}');
  debugPrint('TITLE      : ${message.notification?.title}');
  debugPrint('BODY       : ${message.notification?.body}');
  debugPrint('DATA       : ${message.data}');
  debugPrint('==========================================');
}

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // 1. FIREBASE
  // ============================================================

  await Firebase.initializeApp();

  debugPrint('==========================================');
  debugPrint('FIREBASE INITIALIZED');
  debugPrint('==========================================');

  // ============================================================
  // 2. FCM BACKGROUND HANDLER
  // ============================================================

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  // ============================================================
  // 3. DEPENDENCY INJECTION
  // ============================================================

  await initGlobalDi();

  // ============================================================
  // 4. LOCAL NOTIFICATION SERVICE
  // ============================================================

  await LocalNotificationService.instance.initialize();

  // ============================================================
  // 5. FCM SERVICE
  // ============================================================

  await FcmService.instance.initialize();

  // ============================================================
  // 6. BACKGROUND LOCATION SERVICE
  // ============================================================

  await BackgroundLocationService.initialize();

  await BackgroundLocationService.checkServiceStatus();

  // ============================================================
  // 7. RUN APP
  // ============================================================

  runApp(
    const MyApp(),
  );
}
