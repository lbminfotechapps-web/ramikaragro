import 'package:demo/features/auth/domain/entity/login_entity.dart';

abstract class LoginRepository {
  Future<UserLoginEntity> loginUser(String username, String password, String fcmToken);
}
