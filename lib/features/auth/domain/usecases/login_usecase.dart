import 'package:solufine/core/notifiations/fcm_token_service.dart';
import 'package:solufine/core/utility/device_info_util.dart';
import 'package:solufine/features/auth/domain/entity/login_entity.dart';
import 'package:solufine/features/auth/domain/repository/login_repo.dart';

class LoginUsecase {
  final LoginRepository loginRepository;
  final FcmTokenService fcmTokenService;
  final DeviceInfoUtil deviceInfoUtil;

  LoginUsecase(this.loginRepository, this.fcmTokenService, this.deviceInfoUtil);

  Future<UserLoginEntity> loginUser(String username, String password) async {
    try {
      final fcmToken = await fcmTokenService.getFcmToken();

      final deviceInfo = await deviceInfoUtil.getDeviceInfo();

      final mobileInfo = deviceInfo['mobileInfo'] ?? '';
      final macAddress = deviceInfo['macAddress'] ?? '';

      print('FCM Token: $fcmToken');
      print('Mobile Info: $mobileInfo');
      print('MAC Address: $macAddress');

      final response = await loginRepository.loginUser(
        username,
        password,
        fcmToken.toString(),
        mobileInfo,
        macAddress,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }
}
