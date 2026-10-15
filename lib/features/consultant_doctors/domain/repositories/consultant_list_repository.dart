
import '../entities/consultant_doctor.dart';

abstract class ConsultantListRepository {
  Future<List<ConsultantDoctor>> getDoctors({
    required String userId,
    String search = '',
    String districtId = '',
    String talukaId = '',
  });
}
