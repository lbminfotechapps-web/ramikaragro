import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenService {
  FcmTokenService._();

  static final FcmTokenService instance = FcmTokenService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getFcmToken() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $fcmToken');
      return fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  void listenTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen(
      (token) {
        print('FCM Token refreshed: $token');

      },
      onError: (error) {
        print('FCM Token refresh error: $error');
      },
    );
  }
}
