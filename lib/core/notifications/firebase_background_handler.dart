import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// ❌ REMOVE THIS
// import '../../firebase_options.dart';


// ============================================================
// FIREBASE BACKGROUND NOTIFICATION HANDLER
// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {

  // ============================================================
  // FIREBASE INITIALIZATION
  // ============================================================

  await Firebase.initializeApp();

  debugPrint('======================================');
  debugPrint('BACKGROUND FCM MESSAGE');

  debugPrint(
    'MESSAGE ID: ${message.messageId}',
  );

  debugPrint(
    'TITLE: ${message.notification?.title}',
  );

  debugPrint(
    'BODY: ${message.notification?.body}',
  );

  debugPrint(
    'DATA: ${message.data}',
  );

  debugPrint('======================================');
}