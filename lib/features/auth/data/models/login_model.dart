import 'package:demo/features/auth/domain/entity/login_entity.dart';

class LoginModel extends UserLoginEntity {
  const LoginModel({
    super.status,
    super.userId,
    super.userName,
    super.userEmail,
    super.daKm,
    super.daRate,
    super.haltAtDaRate,
    super.fldMobileNo,

    super.fldAddress,
    super.assignedStates,
    super.selfTargetFlag,
    super.designation,
    super.mpinuser,
    super.userType,
    super.minLocationRadius,
    super.minLocationCheckCount,
    super.locationTryTimeout,
    super.payoutRate,
    super.shopInOutDistance,
    super.inPunch,

    super.lastLatitude,
    super.lastLongitude,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status']?.toString(),
      userId: json['user_id']?.toString(),
      userName: json['user_name']?.toString(),
      userEmail: json['user_email']?.toString(),

      daKm: json['daKm']?.toString(),
      daRate: json['daRate']?.toString(),
      haltAtDaRate: json['haltAtDaRate']?.toString(),

      fldMobileNo: json['fld_mobile_no']?.toString(),
      fldAddress: json['fld_address']?.toString(),

      assignedStates: json['assignedStates']?.toString(),

      selfTargetFlag: json['self_target_flag']?.toString(),
      designation: json['designation']?.toString(),
      mpinuser: json['mpinuser']?.toString(),
      userType: json['user_type']?.toString(),

      minLocationRadius: json['minLocationRadius']?.toString(),
      minLocationCheckCount: json['minLocationCheckCount']?.toString(),
      locationTryTimeout: json['locationTryTimeout']?.toString(),

      payoutRate: json['payoutRate']?.toString(),
      shopInOutDistance: json['shopInOutDistance']?.toString(),

      inPunch: json['inPunch'] == true,

      lastLatitude: json['lastLatitude']?.toString(),
      lastLongitude: json['lastLongitude']?.toString(),
    );
  }
}
