
import '../entities/consultant_doctor.dart';
import '../repositories/consultant_list_repository.dart';

class GetRemoteConsultantsUseCase {
  final ConsultantListRepository repository;

  const GetRemoteConsultantsUseCase(this.repository);

  Future<List<ConsultantDoctor>> call({
    required String userId,
    String search = '',
    String districtId = '',
    String talukaId = '',
  }) {
    return repository.getDoctors(
      userId: userId,
      search: search,
      districtId: districtId,
      talukaId: talukaId,
    );
  }
}
