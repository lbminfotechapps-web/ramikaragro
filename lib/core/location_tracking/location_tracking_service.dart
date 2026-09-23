import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:solufine/core/location_tracking/location_repository.dart';

class LocationTrackingService {
  final LocationRepository repository;

  LocationTrackingService(this.repository);

  // ============================================================
  // SAVE FIRST PUNCH-IN LOCATION
  // ============================================================

  Future<void> savePunchInLocation({
    required int userId,
    required String latitude,
    required String longitude,
    required String geoAddress,
    required int capturedAt,
    required double accuracy,
    required String provider,
  }) async {
    debugPrint('LOCATION TRACKING: Saving punch-in location');

    await repository.saveLocation(
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      geoAddress: geoAddress,
      capturedAt: capturedAt,
      accuracy: accuracy,
      provider: provider,
      distance: 0.0,
    );

    debugPrint('LOCATION TRACKING: Punch-in location saved');
  }

  Future<void> testSaveLocation(int userId) async {
    await savePunchInLocation(
      userId: userId,
      latitude: '19.076000',
      longitude: '72.877700',
      geoAddress: 'Mumbai Test Location',
      capturedAt: DateTime.now().millisecondsSinceEpoch,
      accuracy: 10.0,
      provider: 'gps',
    );

    debugPrint('========================================');
    debugPrint('LOCATION DB TEST: SAVE SUCCESS');
    debugPrint('========================================');

    final locations = await repository.getAllLocations(userId);

    for (final location in locations) {
      debugPrint(
        'ID: ${location.id} | '
        'Lat: ${location.latitude} | '
        'Lng: ${location.longitude} | '
        'Address: ${location.geoAddress} | '
        'Time: ${location.capturedAt} | '
        'Accuracy: ${location.accuracy} | '
        'Provider: ${location.provider} | '
        'Distance: ${location.distance}',
      );
    }
  }

  // ============================================================
  // SAVE NEXT LOCATION
  // ============================================================

  Future<void> saveNextLocation({
    required int userId,
    required String latitude,
    required String longitude,
    required String geoAddress,
    required int capturedAt,
    required double accuracy,
    required String provider,
  }) async {
    debugPrint('LOCATION TRACKING: Saving next location');

    final previousLocation = await repository.getLastLocation(userId);

    double distance = 0.0;

    if (previousLocation != null) {
      final previousLatitude = double.tryParse(previousLocation.latitude);

      final previousLongitude = double.tryParse(previousLocation.longitude);

      final currentLatitude = double.tryParse(latitude);
      final currentLongitude = double.tryParse(longitude);

      if (previousLatitude != null &&
          previousLongitude != null &&
          currentLatitude != null &&
          currentLongitude != null) {
        distance = _calculateDistanceInMeters(
          previousLatitude,
          previousLongitude,
          currentLatitude,
          currentLongitude,
        );
      }
    }

    await repository.saveLocation(
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      geoAddress: geoAddress,
      capturedAt: capturedAt,
      accuracy: accuracy,
      provider: provider,
      distance: distance,
    );

    debugPrint(
      'LOCATION TRACKING: Location saved | '
      'Distance: ${distance.toStringAsFixed(2)} meters',
    );
  }

  // ============================================================
  // DISTANCE CALCULATION
  // ============================================================

  double _calculateDistanceInMeters(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const earthRadius = 6371000.0;

    final lat1 = _degreesToRadians(latitude1);
    final lat2 = _degreesToRadians(latitude2);

    final deltaLat = _degreesToRadians(latitude2 - latitude1);

    final deltaLongitude = _degreesToRadians(longitude2 - longitude1);

    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLongitude / 2) *
            math.sin(deltaLongitude / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
