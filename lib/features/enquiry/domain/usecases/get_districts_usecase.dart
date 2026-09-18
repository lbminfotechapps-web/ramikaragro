import '../entities/district_entity.dart';
import '../repositories/enquiry_repository.dart';

class GetDistrictsUseCase {
  final EnquiryRepository repository;

  GetDistrictsUseCase(this.repository);

  Future<List<DistrictEntity>> call({
    required String userId,
    required String stateId,
  }) {
    return repository.getDistricts(
      userId: userId,
      stateId: stateId,
    );
  }
}