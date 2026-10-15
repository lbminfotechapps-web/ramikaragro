
import 'package:solufine/features/consultant_doctors/domain/repositories/add_doctor_repository.dart';

import '../../domain/entities/add_doctor_result.dart';
import '../../domain/entities/consultant_doctor.dart';

import '../datasources/consultant_remote_data_source.dart';

class AddDoctorRepositoryImpl implements AddDoctorRepository {
  final ConsultantRemoteDataSource remoteDataSource;

  AddDoctorRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<AddDoctorResult> addDoctor({
    required String userId,
    required ConsultantDoctor consultant,
    required String remark,
  }) async {
    final response = await remoteDataSource.addDoctor(
      empId: userId,
      doctorName: consultant.doctorName,
      ownerName: consultant.ownerName,
      mobileNo: consultant.mobile,
      address: consultant.address,
      state: consultant.stateId,
      district: consultant.districtId,
      taluka: consultant.talukaId,
      remark: remark,
    );

    return AddDoctorResult(
      doctorId: response.doctorId,
      message: response.message,
    );
  }
}
