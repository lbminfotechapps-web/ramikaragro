

import 'package:drift/drift.dart';

class LocationHistory extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get userId => integer()();

  TextColumn get latitude => text()();

  TextColumn get longitude => text()();

  TextColumn get geoAddress =>
      text().withDefault(const Constant(''))();

  IntColumn get capturedAt => integer()();

  RealColumn get accuracy =>
      real().withDefault(const Constant(0.0))();

  TextColumn get provider =>
      text().withDefault(const Constant(''))();

  RealColumn get distance =>
      real().withDefault(const Constant(0.0))();
}