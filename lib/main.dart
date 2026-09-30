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
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate needs Firebase initialization.
  await Firebase.initializeApp();
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

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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

  runApp(const MyApp());
}
