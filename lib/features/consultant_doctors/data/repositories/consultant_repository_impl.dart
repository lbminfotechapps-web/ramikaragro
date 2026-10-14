
import '../../domain/entities/consultant_doctor.dart';
import '../../domain/repositories/consultant_repository.dart';
import '../datasources/consultant_local_data_source.dart';
import '../models/consultant_doctor_model.dart';

class ConsultantRepositoryImpl
    implements ConsultantRepository {
  final ConsultantLocalDataSource local;

  const ConsultantRepositoryImpl(this.local);

  @override
  Future<List<ConsultantDoctor>> getAll() async {
    final models = await local.getAll();

    final doctors = models
        .map((item) => item.entity)
        .toList();

    doctors.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return doctors;
  }

  @override
  Future<void> save(ConsultantDoctor doctor) {
    return local.save(
      ConsultantDoctorModel(doctor),
    );
  }
}
