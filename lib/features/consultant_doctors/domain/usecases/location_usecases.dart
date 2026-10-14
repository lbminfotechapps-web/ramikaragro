
import '../entities/location_entities.dart';
import '../repositories/location_repository.dart';

class GetStatesUseCase {
  final LocationRepository repository;

  const GetStatesUseCase(this.repository);

  Future<List<StateEntity>> call(String userId) {
    return repository.getStates(userId);
  }
}

class GetDistrictsAndTalukasUseCase {
  final LocationRepository repository;

  const GetDistrictsAndTalukasUseCase(this.repository);

  Future<List<DistrictEntity>> call({
    required String userId,
    required String stateId,
  }) {
    return repository.getDistrictsAndTalukas(
      userId: userId,
      stateId: stateId,
    );
  }
}
