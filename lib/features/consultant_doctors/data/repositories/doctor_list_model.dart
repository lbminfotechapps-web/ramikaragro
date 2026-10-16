
import '../../domain/entities/consultant_doctor.dart';

class DoctorListModel {
  final String doctorId;
  final String doctorName;
  final String ownerName;
  final String mobileNo;
  final String address;
  final String remark;
  final String stateId;
  final String districtId;
  final String talukaId;
  final String createdBy;
  final String createdDate;
  final String stateName;
  final String districtName;
  final String talukaName;

  const DoctorListModel({
    required this.doctorId,
    required this.doctorName,
    required this.ownerName,
    required this.mobileNo,
    required this.address,
    required this.remark,
    required this.stateId,
    required this.districtId,
    required this.talukaId,
    required this.createdBy,
    required this.createdDate,
    required this.stateName,
    required this.districtName,
    required this.talukaName,
  });

  factory DoctorListModel.fromJson(
    Map<String, dynamic> json,
  ) {
    String read(String key) =>
        json[key]?.toString().trim() ?? '';

    return DoctorListModel(
      doctorId: read('doctor_id'),
      doctorName: read('doctor_name'),
      ownerName: read('owner_name'),
      mobileNo: read('mobile_no'),
      address: read('address'),
      remark: read('remark'),
      stateId: read('state_id'),
      districtId: read('district_id'),
      talukaId: read('taluka_id'),
      createdBy: read('created_by'),
      createdDate: read('created_date'),
      stateName: read('state_name'),
      districtName: read('district_name'),
      talukaName: read('taluka_name'),
    );
  }

  ConsultantDoctor toEntity() {
    return ConsultantDoctor(
      id: doctorId,
      doctorName: doctorName,
      ownerName: ownerName,
      mobile: mobileNo,
      address: address,
      remark: remark,
      stateId: stateId,
      stateName: stateName,
      districtId: districtId,
      districtName: districtName,
      talukaId: talukaId,
      talukaName: talukaName,
      createdBy: createdBy,
      createdAt:
          DateTime.tryParse(createdDate) ?? DateTime(1970),
    );
  }
}
