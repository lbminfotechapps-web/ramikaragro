import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:solufine/core/location_tracking/location_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [LocationHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ============================================================
  // SAVE LOCATION
  // ============================================================

  Future<int> insertLocation({
    required int userId,
    required String latitude,
    required String longitude,
    required String geoAddress,
    required int capturedAt,
    required double accuracy,
    required String provider,
    required double distance,
  }) {
    return into(locationHistory).insert(
      LocationHistoryCompanion.insert(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        geoAddress: Value(geoAddress),
        capturedAt: capturedAt,
        accuracy: Value(accuracy),
        provider: Value(provider),
        distance: Value(distance),
      ),
    );
  }

  // ============================================================
  // GET LAST LOCATION
  // ============================================================

  Future<LocationHistoryData?> getLastLocation(int userId) {
    return (select(locationHistory)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.capturedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  // ============================================================
  // GET ALL LOCATIONS
  // ============================================================

  Future<List<LocationHistoryData>> getAllLocations(int userId) {
    return (select(locationHistory)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.capturedAt,
              mode: OrderingMode.asc,
            ),
          ]))
        .get();
  }

  // ============================================================
  // DELETE USER LOCATION HISTORY
  // ============================================================

  Future<int> deleteUserLocations(int userId) {
    return (delete(
      locationHistory,
    )..where((tbl) => tbl.userId.equals(userId))).go();
  }

  Future<int> deleteAllExceptLastLocation(int userId) async {
    // Get latest location first
    final lastLocation = await getLastLocation(userId);

    if (lastLocation == null) {
      return 0;
    }

    // Delete all records for this user except latest record
    return (delete(locationHistory)..where(
          (tbl) =>
              tbl.userId.equals(userId) & tbl.id.isNotValue(lastLocation.id),
        ))
        .go();
  }
}

// ============================================================
// DATABASE CONNECTION
// ============================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File(p.join(directory.path, 'ramikar_location.db'));

    return NativeDatabase.createInBackground(file);
  });
}
