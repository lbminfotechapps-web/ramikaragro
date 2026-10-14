
import '../entities/location_entities.dart';

abstract class LocationRepository {
  Future<List<StateEntity>> getStates(String userId);

  Future<List<DistrictEntity>> getDistrictsAndTalukas({
    required String userId,
    required String stateId,
  });
}
