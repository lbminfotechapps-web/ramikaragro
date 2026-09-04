class UserLoginEntity {
  final String? status;
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? daKm;
  final String? daRate;
  final String? haltAtDaRate;
  final String? fldMobileNo;
  final String? fldAddress;
  final String? assignedStates;
  final String? selfTargetFlag;
  final String? designation;
  final String? mpinuser;
  final String? userType;
  final String? minLocationRadius;
  final String? minLocationCheckCount;
  final String? locationTryTimeout;
  final String? payoutRate;
  final String? shopInOutDistance;
  final bool? inPunch;
  final String? lastLatitude;
  final String? lastLongitude;

  const UserLoginEntity({
    this.status,
    this.userId,
    this.userName,
    this.userEmail,
    this.daKm,
    this.daRate,
    this.haltAtDaRate,
    this.fldMobileNo,
    this.fldAddress,
    this.assignedStates,
    this.selfTargetFlag,
    this.designation,
    this.mpinuser,
    this.userType,
    this.minLocationRadius,
    this.minLocationCheckCount,
    this.locationTryTimeout,
    this.payoutRate,
    this.shopInOutDistance,
    this.inPunch,
    this.lastLatitude,
    this.lastLongitude,
  });

  // factory UserEntity.fromJson(Map<String, dynamic> json) {
  //   return UserEntity(
  //     status: json['status']?.toString(),
  //     userId: json['user_id']?.toString(),
  //     userName: json['user_name']?.toString(),
  //     userEmail: json['user_email']?.toString(),
  //     daKm: json['daKm']?.toString(),
  //     daRate: json['daRate']?.toString(),
  //     haltAtDaRate: json['haltAtDaRate']?.toString(),
  //     fldMobileNo: json['fld_mobile_no']?.toString(),
  //     fldAddress: json['fld_address']?.toString(),
  //     assignedStates: json['assignedStates']?.toString(),
  //     selfTargetFlag: json['self_target_flag']?.toString(),
  //     designation: json['designation']?.toString(),
  //     mpinuser: json['mpinuser']?.toString(),
  //     userType: json['user_type']?.toString(),
  //     minLocationRadius: json['minLocationRadius']?.toString(),
  //     minLocationCheckCount: json['minLocationCheckCount']?.toString(),
  //     locationTryTimeout: json['locationTryTimeout']?.toString(),
  //     payoutRate: json['payoutRate']?.toString(),
  //     shopInOutDistance: json['shopInOutDistance']?.toString(),
  //     inPunch: json['inPunch'] == true,
  //     lastLatitude: json['lastLatitude']?.toString(),
  //     lastLongitude: json['lastLongitude']?.toString(),
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'status': status,
  //     'user_id': userId,
  //     'user_name': userName,
  //     'user_email': userEmail,
  //     'daKm': daKm,
  //     'daRate': daRate,
  //     'haltAtDaRate': haltAtDaRate,
  //     'fld_mobile_no': fldMobileNo,
  //     'fld_address': fldAddress,
  //     'assignedStates': assignedStates,
  //     'self_target_flag': selfTargetFlag,
  //     'designation': designation,
  //     'mpinuser': mpinuser,
  //     'user_type': userType,
  //     'minLocationRadius': minLocationRadius,
  //     'minLocationCheckCount': minLocationCheckCount,
  //     'locationTryTimeout': locationTryTimeout,
  //     'payoutRate': payoutRate,
  //     'shopInOutDistance': shopInOutDistance,
  //     'inPunch': inPunch,
  //     'lastLatitude': lastLatitude,
  //     'lastLongitude': lastLongitude,
  //   };
  // }
}
