
import '../entities/add_doctor_result.dart';
import '../entities/consultant_doctor.dart';
import '../repositories/add_doctor_repository.dart';

class AddDoctorUseCase {
  final AddDoctorRepository repository;

  AddDoctorUseCase({
    required this.repository,
  });

  Future<AddDoctorResult> call({
    required String userId,
    required ConsultantDoctor consultant,
    required String remark,
  }) {
    return repository.addDoctor(
      userId: userId,
      consultant: consultant,
      remark: remark,
    );
  }
}
