import 'package:demo/core/notifiations/fcm_token_service.dart';
import 'package:demo/features/auth/domain/entity/login_entity.dart';
import 'package:demo/features/auth/domain/repository/login_repo.dart';

class LoginUsecase {
  final LoginRepository loginRepository;
  final FcmTokenService fcmTokenService;
  LoginUsecase(this.loginRepository, this.fcmTokenService);
  Future<UserLoginEntity> loginUser(String username, String password) async {
    try {
      final fcmToken = await fcmTokenService.getFcmToken();
      print('Login FCM Token: $fcmToken');
      final response = await loginRepository.loginUser(
        username,
        password,
        fcmToken.toString(),
      );
      print('Response Usecase: ${response}');
      return response;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }
}
