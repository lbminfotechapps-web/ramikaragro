
import '../../domain/entities/consultant_doctor.dart';

class ConsultantDoctorApiModel {
  final ConsultantDoctor entity;

  const ConsultantDoctorApiModel(this.entity);

  factory ConsultantDoctorApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    String read(String key) => json[key]?.toString() ?? '';

    return ConsultantDoctorApiModel(
      ConsultantDoctor(
        id: read('doctor_id'),
        doctorName: read('doctor_name'),
        ownerName: read('owner_name'),
        mobile: read('mobile_no'),
        address: read('address'),
        remark: read('remark'),
        createdBy: read('created_by'),
        stateId: read('state_id'),
        stateName: read('state_name'),
        districtId: read('district_id'),
        districtName: read('district_name'),
        talukaId: read('taluka_id'),
        talukaName: read('taluka_name'),
        createdAt: DateTime.tryParse(
              read('created_date'),
            ) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
  }
}
