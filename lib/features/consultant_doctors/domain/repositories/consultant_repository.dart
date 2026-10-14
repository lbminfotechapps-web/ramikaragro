
import '../entities/consultant_doctor.dart';

abstract class ConsultantRepository {
  Future<List<ConsultantDoctor>> getAll();

  Future<void> save(ConsultantDoctor doctor);
}
