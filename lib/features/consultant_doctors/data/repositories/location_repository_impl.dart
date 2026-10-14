
import '../../domain/entities/location_entities.dart';
import '../../domain/repositories/location_repository.dart';

import '../datasources/location_remote_data_source.dart';
import '../models/location_models.dart';

// ============================================================
// LOCATION REPOSITORY IMPLEMENTATION
// ============================================================

class LocationRepositoryImpl
    implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  const LocationRepositoryImpl(
    this.remoteDataSource,
  );

  // ==========================================================
  // GET STATES
  // ==========================================================

  @override
  Future<List<StateEntity>> getStates(
    String userId,
  ) async {
    // Fetch API models from remote data source.
    final List<StateModel> stateModels =
        await remoteDataSource.getStates(
      userId,
    );

    // Convert data-layer models to domain entities.
    final List<StateEntity> states = stateModels
        .map<StateEntity>(
          (StateModel model) => model.toEntity(),
        )
        .toList();

    return states;
  }

  // ==========================================================
  // GET DISTRICTS AND TALUKAS
  // ==========================================================

  @override
  Future<List<DistrictEntity>> getDistrictsAndTalukas({
    required String userId,
    required String stateId,
  }) async {
    // Fetch district models with nested talukas.
    final List<DistrictModel> districtModels =
        await remoteDataSource.getDistrictsAndTalukas(
      userId: userId,
      stateId: stateId,
    );

    // Convert district and nested taluka models
    // into domain entities.
    final List<DistrictEntity> districts = districtModels
        .map<DistrictEntity>(
          (DistrictModel model) => model.toEntity(),
        )
        .toList();

    return districts;
  }
}
