
import '../../domain/entities/consultant_doctor.dart';

class ConsultantDoctorModel {
  final ConsultantDoctor entity;

  const ConsultantDoctorModel(this.entity);

  Map<String, dynamic> toJson() {
    final item = entity;

    return {
      'id': item.id,
      'doctorName': item.doctorName,
      'ownerName': item.ownerName,
      'mobile': item.mobile,
      'address': item.address,
      'stateId': item.stateId,
      'stateName': item.stateName,
      'districtId': item.districtId,
      'districtName': item.districtName,
      'talukaId': item.talukaId,
      'talukaName': item.talukaName,
      'createdAt': item.createdAt.toIso8601String(),
    };
  }

  factory ConsultantDoctorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConsultantDoctorModel(
      ConsultantDoctor(
        id: '${json['id'] ?? ''}',
        doctorName: '${json['doctorName'] ?? ''}',
        ownerName: '${json['ownerName'] ?? ''}',
        mobile: '${json['mobile'] ?? ''}',
        address: '${json['address'] ?? ''}',
        stateId: '${json['stateId'] ?? ''}',
        stateName: '${json['stateName'] ?? ''}',
        districtId: '${json['districtId'] ?? ''}',
        districtName: '${json['districtName'] ?? ''}',
        talukaId: '${json['talukaId'] ?? ''}',
        talukaName: '${json['talukaName'] ?? ''}',
        createdAt: DateTime.tryParse(
              '${json['createdAt'] ?? ''}',
            ) ??
            DateTime.now(),
      ),
    );
  }
}
