// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocationHistoryTable extends LocationHistory
    with TableInfo<$LocationHistoryTable, LocationHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<String> latitude = GeneratedColumn<String>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<String> longitude = GeneratedColumn<String>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _geoAddressMeta = const VerificationMeta(
    'geoAddress',
  );
  @override
  late final GeneratedColumn<String> geoAddress = GeneratedColumn<String>(
    'geo_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<int> capturedAt = GeneratedColumn<int>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _distanceMeta = const VerificationMeta(
    'distance',
  );
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
    'distance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    latitude,
    longitude,
    geoAddress,
    capturedAt,
    accuracy,
    provider,
    distance,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('geo_address')) {
      context.handle(
        _geoAddressMeta,
        geoAddress.isAcceptableOrUnknown(data['geo_address']!, _geoAddressMeta),
      );
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('distance')) {
      context.handle(
        _distanceMeta,
        distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}longitude'],
      )!,
      geoAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geo_address'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}captured_at'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      distance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance'],
      )!,
    );
  }

  @override
  $LocationHistoryTable createAlias(String alias) {
    return $LocationHistoryTable(attachedDatabase, alias);
  }
}

class LocationHistoryData extends DataClass
    implements Insertable<LocationHistoryData> {
  final int id;
  final int userId;
  final String latitude;
  final String longitude;
  final String geoAddress;
  final int capturedAt;
  final double accuracy;
  final String provider;
  final double distance;
  const LocationHistoryData({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.geoAddress,
    required this.capturedAt,
    required this.accuracy,
    required this.provider,
    required this.distance,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['latitude'] = Variable<String>(latitude);
    map['longitude'] = Variable<String>(longitude);
    map['geo_address'] = Variable<String>(geoAddress);
    map['captured_at'] = Variable<int>(capturedAt);
    map['accuracy'] = Variable<double>(accuracy);
    map['provider'] = Variable<String>(provider);
    map['distance'] = Variable<double>(distance);
    return map;
  }

  LocationHistoryCompanion toCompanion(bool nullToAbsent) {
    return LocationHistoryCompanion(
      id: Value(id),
      userId: Value(userId),
      latitude: Value(latitude),
      longitude: Value(longitude),
      geoAddress: Value(geoAddress),
      capturedAt: Value(capturedAt),
      accuracy: Value(accuracy),
      provider: Value(provider),
      distance: Value(distance),
    );
  }

  factory LocationHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationHistoryData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      latitude: serializer.fromJson<String>(json['latitude']),
      longitude: serializer.fromJson<String>(json['longitude']),
      geoAddress: serializer.fromJson<String>(json['geoAddress']),
      capturedAt: serializer.fromJson<int>(json['capturedAt']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      provider: serializer.fromJson<String>(json['provider']),
      distance: serializer.fromJson<double>(json['distance']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'latitude': serializer.toJson<String>(latitude),
      'longitude': serializer.toJson<String>(longitude),
      'geoAddress': serializer.toJson<String>(geoAddress),
      'capturedAt': serializer.toJson<int>(capturedAt),
      'accuracy': serializer.toJson<double>(accuracy),
      'provider': serializer.toJson<String>(provider),
      'distance': serializer.toJson<double>(distance),
    };
  }

  LocationHistoryData copyWith({
    int? id,
    int? userId,
    String? latitude,
    String? longitude,
    String? geoAddress,
    int? capturedAt,
    double? accuracy,
    String? provider,
    double? distance,
  }) => LocationHistoryData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    geoAddress: geoAddress ?? this.geoAddress,
    capturedAt: capturedAt ?? this.capturedAt,
    accuracy: accuracy ?? this.accuracy,
    provider: provider ?? this.provider,
    distance: distance ?? this.distance,
  );
  LocationHistoryData copyWithCompanion(LocationHistoryCompanion data) {
    return LocationHistoryData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      geoAddress: data.geoAddress.present
          ? data.geoAddress.value
          : this.geoAddress,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      provider: data.provider.present ? data.provider.value : this.provider,
      distance: data.distance.present ? data.distance.value : this.distance,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationHistoryData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geoAddress: $geoAddress, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('accuracy: $accuracy, ')
          ..write('provider: $provider, ')
          ..write('distance: $distance')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    latitude,
    longitude,
    geoAddress,
    capturedAt,
    accuracy,
    provider,
    distance,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationHistoryData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.geoAddress == this.geoAddress &&
          other.capturedAt == this.capturedAt &&
          other.accuracy == this.accuracy &&
          other.provider == this.provider &&
          other.distance == this.distance);
}

class LocationHistoryCompanion extends UpdateCompanion<LocationHistoryData> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> latitude;
  final Value<String> longitude;
  final Value<String> geoAddress;
  final Value<int> capturedAt;
  final Value<double> accuracy;
  final Value<String> provider;
  final Value<double> distance;
  const LocationHistoryCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geoAddress = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.provider = const Value.absent(),
    this.distance = const Value.absent(),
  });
  LocationHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String latitude,
    required String longitude,
    this.geoAddress = const Value.absent(),
    required int capturedAt,
    this.accuracy = const Value.absent(),
    this.provider = const Value.absent(),
    this.distance = const Value.absent(),
  }) : userId = Value(userId),
       latitude = Value(latitude),
       longitude = Value(longitude),
       capturedAt = Value(capturedAt);
  static Insertable<LocationHistoryData> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? latitude,
    Expression<String>? longitude,
    Expression<String>? geoAddress,
    Expression<int>? capturedAt,
    Expression<double>? accuracy,
    Expression<String>? provider,
    Expression<double>? distance,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (geoAddress != null) 'geo_address': geoAddress,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (accuracy != null) 'accuracy': accuracy,
      if (provider != null) 'provider': provider,
      if (distance != null) 'distance': distance,
    });
  }

  LocationHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? latitude,
    Value<String>? longitude,
    Value<String>? geoAddress,
    Value<int>? capturedAt,
    Value<double>? accuracy,
    Value<String>? provider,
    Value<double>? distance,
  }) {
    return LocationHistoryCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geoAddress: geoAddress ?? this.geoAddress,
      capturedAt: capturedAt ?? this.capturedAt,
      accuracy: accuracy ?? this.accuracy,
      provider: provider ?? this.provider,
      distance: distance ?? this.distance,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<String>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<String>(longitude.value);
    }
    if (geoAddress.present) {
      map['geo_address'] = Variable<String>(geoAddress.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<int>(capturedAt.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationHistoryCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geoAddress: $geoAddress, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('accuracy: $accuracy, ')
          ..write('provider: $provider, ')
          ..write('distance: $distance')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocationHistoryTable locationHistory = $LocationHistoryTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [locationHistory];
}

typedef $$LocationHistoryTableCreateCompanionBuilder =
    LocationHistoryCompanion Function({
      Value<int> id,
      required int userId,
      required String latitude,
      required String longitude,
      Value<String> geoAddress,
      required int capturedAt,
      Value<double> accuracy,
      Value<String> provider,
      Value<double> distance,
    });
typedef $$LocationHistoryTableUpdateCompanionBuilder =
    LocationHistoryCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> latitude,
      Value<String> longitude,
      Value<String> geoAddress,
      Value<int> capturedAt,
      Value<double> accuracy,
      Value<String> provider,
      Value<double> distance,
    });

class $$LocationHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $LocationHistoryTable> {
  $$LocationHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geoAddress => $composableBuilder(
    column: $table.geoAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationHistoryTable> {
  $$LocationHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geoAddress => $composableBuilder(
    column: $table.geoAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationHistoryTable> {
  $$LocationHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<String> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get geoAddress => $composableBuilder(
    column: $table.geoAddress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);
}

class $$LocationHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationHistoryTable,
          LocationHistoryData,
          $$LocationHistoryTableFilterComposer,
          $$LocationHistoryTableOrderingComposer,
          $$LocationHistoryTableAnnotationComposer,
          $$LocationHistoryTableCreateCompanionBuilder,
          $$LocationHistoryTableUpdateCompanionBuilder,
          (
            LocationHistoryData,
            BaseReferences<
              _$AppDatabase,
              $LocationHistoryTable,
              LocationHistoryData
            >,
          ),
          LocationHistoryData,
          PrefetchHooks Function()
        > {
  $$LocationHistoryTableTableManager(
    _$AppDatabase db,
    $LocationHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> latitude = const Value.absent(),
                Value<String> longitude = const Value.absent(),
                Value<String> geoAddress = const Value.absent(),
                Value<int> capturedAt = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<double> distance = const Value.absent(),
              }) => LocationHistoryCompanion(
                id: id,
                userId: userId,
                latitude: latitude,
                longitude: longitude,
                geoAddress: geoAddress,
                capturedAt: capturedAt,
                accuracy: accuracy,
                provider: provider,
                distance: distance,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String latitude,
                required String longitude,
                Value<String> geoAddress = const Value.absent(),
                required int capturedAt,
                Value<double> accuracy = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<double> distance = const Value.absent(),
              }) => LocationHistoryCompanion.insert(
                id: id,
                userId: userId,
                latitude: latitude,
                longitude: longitude,
                geoAddress: geoAddress,
                capturedAt: capturedAt,
                accuracy: accuracy,
                provider: provider,
                distance: distance,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocationHistoryTable, LocationHistoryData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $LocationHistoryTable,
                    LocationHistoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationHistoryTable,
      LocationHistoryData,
      $$LocationHistoryTableFilterComposer,
      $$LocationHistoryTableOrderingComposer,
      $$LocationHistoryTableAnnotationComposer,
      $$LocationHistoryTableCreateCompanionBuilder,
      $$LocationHistoryTableUpdateCompanionBuilder,
      (
        LocationHistoryData,
        BaseReferences<
          _$AppDatabase,
          $LocationHistoryTable,
          LocationHistoryData
        >,
      ),
      LocationHistoryData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocationHistoryTableTableManager get locationHistory =>
      $$LocationHistoryTableTableManager(_db, _db.locationHistory);
}
