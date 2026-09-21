

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:solufine/app.dart';
import 'package:solufine/core/di/global_di.dart';
import 'package:solufine/core/notifiations/fcm_token_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FcmTokenService.instance.listenTokenRefresh();
  await initGlobalDi();
  runApp(const MyApp());
}
