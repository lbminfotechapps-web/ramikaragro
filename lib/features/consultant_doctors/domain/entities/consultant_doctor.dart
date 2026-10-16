
class ConsultantDoctor {
  final String id;
  final String doctorName;
  final String ownerName;
  final String mobile;
  final String address;

  final String stateId;
  final String stateName;

  final String districtId;
  final String districtName;

  final String talukaId;
  final String talukaName;

  final String remark;
  final String createdBy;
  final DateTime createdAt;

  const ConsultantDoctor({
    required this.id,
    required this.doctorName,
    required this.ownerName,
    required this.mobile,
    required this.address,
    required this.stateId,
    required this.stateName,
    required this.districtId,
    required this.districtName,
    required this.talukaId,
    required this.talukaName,
    required this.createdAt,
    this.remark = '',
    this.createdBy = '',
  });

  String get fullLocation {
    return [
      talukaName,
      districtName,
      stateName,
    ].where((value) => value.trim().isNotEmpty).join(', ');
  }
}
