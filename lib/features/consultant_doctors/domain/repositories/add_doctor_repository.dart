
import '../entities/add_doctor_result.dart';
import '../entities/consultant_doctor.dart';

abstract class AddDoctorRepository {
  Future<AddDoctorResult> addDoctor({
    required String userId,
    required ConsultantDoctor consultant,
    required String remark,
  });
}
