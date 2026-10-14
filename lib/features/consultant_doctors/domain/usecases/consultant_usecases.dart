
import '../entities/consultant_doctor.dart';
import '../repositories/consultant_repository.dart';

class GetConsultantsUseCase {
  final ConsultantRepository repository;

  const GetConsultantsUseCase(this.repository);

  Future<List<ConsultantDoctor>> call() {
    return repository.getAll();
  }
}

class SaveConsultantUseCase {
  final ConsultantRepository repository;

  const SaveConsultantUseCase(this.repository);

  Future<void> call(ConsultantDoctor doctor) {
    if (doctor.doctorName.trim().isEmpty ||
        doctor.ownerName.trim().isEmpty ||
        doctor.address.trim().isEmpty) {
      throw ArgumentError('Complete all required fields');
    }

    if (!RegExp(r'^\d{10}$').hasMatch(doctor.mobile)) {
      throw ArgumentError('Enter a valid 10-digit mobile');
    }

    if (doctor.stateId == '0' ||
        doctor.districtId == '0' ||
        doctor.talukaId == '0' ||
        doctor.stateId.isEmpty ||
        doctor.districtId.isEmpty ||
        doctor.talukaId.isEmpty) {
      throw ArgumentError('Select a valid location');
    }

    return repository.save(doctor);
  }
}
