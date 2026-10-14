
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
  });

  String get fullLocation =>
      '$talukaName, $districtName, $stateName';
}
