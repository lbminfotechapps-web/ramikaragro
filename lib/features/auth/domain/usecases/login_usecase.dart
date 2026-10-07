import 'package:flutter/foundation.dart';
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
      // ==========================================================
      // GET FCM TOKEN
      // ==========================================================

      final String? fcmToken = await FcmTokenService.instance.getFcmToken();

      // ==========================================================
      // DEVICE INFO
      // ==========================================================

      final deviceInfo = await deviceInfoUtil.getDeviceInfo();

      final String mobileInfo = deviceInfo['mobileInfo'] ?? '';

      final String macAddress = deviceInfo['macAddress'] ?? '';

      // ==========================================================
      // DEBUG
      // ==========================================================

      debugPrint('======================================');

      debugPrint('LOGIN REQUEST DATA');

      debugPrint('FCM TOKEN: ${fcmToken ?? 'EMPTY'}');

      debugPrint('MOBILE INFO: $mobileInfo');

      debugPrint('MAC ADDRESS: $macAddress');

      debugPrint('======================================');

      // ==========================================================
      // LOGIN
      // ==========================================================

      final response = await loginRepository.loginUser(
        username,
        password,

        // IMPORTANT
        fcmToken ?? '',

        mobileInfo,
        macAddress,
      );

      return response;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String empId,
  ) async {
    final response = await loginRepository.changePassword(
      oldPassword,
      newPassword,
      empId,
    );

    return response;
  }
}
