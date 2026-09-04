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
}
