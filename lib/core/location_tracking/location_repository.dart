import 'package:solufine/core/location_tracking/app_database.dart';

class LocationRepository {
  final AppDatabase database;

  LocationRepository(this.database);

  // Save a location record
  Future<int> saveLocation({
    required int userId,
    required String latitude,
    required String longitude,
    required String geoAddress,
    required int capturedAt,
    required double accuracy,
    required String provider,
    required double distance,
  }) {
    return database.insertLocation(
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      geoAddress: geoAddress,
      capturedAt: capturedAt,
      accuracy: accuracy,
      provider: provider,
      distance: distance,
    );
  }

  // Get the last saved location
  Future<LocationHistoryData?> getLastLocation(int userId) {
    return database.getLastLocation(userId);
  }

  // Get complete tracking history
  Future<List<LocationHistoryData>> getAllLocations(int userId) {
    return database.getAllLocations(userId);
  }

  // Delete user's tracking history
  Future<int> deleteUserLocations(int userId) {
    return database.deleteUserLocations(userId);
  }

  Future<int> deleteAllExceptLastLocation(int userId) {
  return database.deleteAllExceptLastLocation(userId);
}
}