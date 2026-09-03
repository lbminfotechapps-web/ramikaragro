import 'package:demo/app.dart';
import 'package:demo/core/di/auth_di.dart';
import 'package:demo/core/notifiations/fcm_token_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FcmTokenService.instance.listenTokenRefresh();
  await initAuthDi();
  runApp(const MyApp());
}
