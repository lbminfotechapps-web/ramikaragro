import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/features/auth/data/datasource/auth_datasource.dart';

import 'package:demo/features/auth/domain/entity/login_entity.dart';
import 'package:demo/features/auth/domain/repository/login_repo.dart';

class LoginRepoImp implements LoginRepository {
  final AuthDatasource authDatasource;
  final SecureStorage secureStorage;

  LoginRepoImp(this.authDatasource, this.secureStorage);

  @override
  Future<UserLoginEntity> loginUser(
    String username,
    String password,
    String fcmToken,
  ) async {
    try {
      final response = await authDatasource.loginUser(
        username,
        password,
        fcmToken,
      );

      await secureStorage.saveUserData({
        'user_id': response.userId,
        'user_name': response.userName,
        'user_email': response.userEmail,
        'daKm': response.daKm,
        'daRate': response.daRate,
        'haltAtDaRate': response.haltAtDaRate,
        'fld_mobile_no': response.fldMobileNo,
        'fld_address': response.fldAddress,
        'assignedStates': response.assignedStates,
        'self_target_flag': response.selfTargetFlag,
        'designation': response.designation,
        'mpinuser': response.mpinuser,
        'user_type': response.userType,
        'minLocationRadius': response.minLocationRadius,
        'minLocationCheckCount': response.minLocationCheckCount,
        'locationTryTimeout': response.locationTryTimeout,
        'payoutRate': response.payoutRate,
        'shopInOutDistance': response.shopInOutDistance,
        'inPunch': response.inPunch,
        'lastLatitude': response.lastLatitude,
        'lastLongitude': response.lastLongitude,
      });

      print('Login successful repo: $response');

      return response;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }
}
