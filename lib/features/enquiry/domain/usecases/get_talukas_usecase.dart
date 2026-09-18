import '../entities/taluka_entity.dart';
import '../repositories/enquiry_repository.dart';

class GetTalukasUseCase {
  final EnquiryRepository repository;

  GetTalukasUseCase(
    this.repository,
  );

  Future<List<TalukaEntity>> call({
    required String userId,
    required String districtId,
  }) {
    return repository.getTalukas(
      userId: userId,
      districtId: districtId,
    );
  }
}