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

class $AiChatSessionsTable extends AiChatSessions
    with TableInfo<$AiChatSessionsTable, AiChatSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiChatSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_chat_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiChatSession> instance, {
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiChatSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiChatSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AiChatSessionsTable createAlias(String alias) {
    return $AiChatSessionsTable(attachedDatabase, alias);
  }
}

class AiChatSession extends DataClass implements Insertable<AiChatSession> {
  final int id;
  final int userId;
  final String title;
  final int createdAt;
  final int updatedAt;
  const AiChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AiChatSessionsCompanion toCompanion(bool nullToAbsent) {
    return AiChatSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiChatSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiChatSession(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AiChatSession copyWith({
    int? id,
    int? userId,
    String? title,
    int? createdAt,
    int? updatedAt,
  }) => AiChatSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AiChatSession copyWithCompanion(AiChatSessionsCompanion data) {
    return AiChatSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiChatSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, title, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiChatSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AiChatSessionsCompanion extends UpdateCompanion<AiChatSession> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> title;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const AiChatSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AiChatSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String title,
    required int createdAt,
    required int updatedAt,
  }) : userId = Value(userId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AiChatSession> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? title,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AiChatSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? title,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return AiChatSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiChatSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AiChatMessagesTable extends AiChatMessages
    with TableInfo<$AiChatMessagesTable, AiChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiChatMessagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUserMeta = const VerificationMeta('isUser');
  @override
  late final GeneratedColumn<bool> isUser = GeneratedColumn<bool>(
    'is_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_user" IN (0, 1))',
    ),
  );
  static const VerificationMeta _outputTypeMeta = const VerificationMeta(
    'outputType',
  );
  @override
  late final GeneratedColumn<String> outputType = GeneratedColumn<String>(
    'output_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('text'),
  );
  static const VerificationMeta _responseDataMeta = const VerificationMeta(
    'responseData',
  );
  @override
  late final GeneratedColumn<String> responseData = GeneratedColumn<String>(
    'response_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    message,
    isUser,
    outputType,
    responseData,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('is_user')) {
      context.handle(
        _isUserMeta,
        isUser.isAcceptableOrUnknown(data['is_user']!, _isUserMeta),
      );
    } else if (isInserting) {
      context.missing(_isUserMeta);
    }
    if (data.containsKey('output_type')) {
      context.handle(
        _outputTypeMeta,
        outputType.isAcceptableOrUnknown(data['output_type']!, _outputTypeMeta),
      );
    }
    if (data.containsKey('response_data')) {
      context.handle(
        _responseDataMeta,
        responseData.isAcceptableOrUnknown(
          data['response_data']!,
          _responseDataMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiChatMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      isUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_user'],
      )!,
      outputType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}output_type'],
      )!,
      responseData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_data'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiChatMessagesTable createAlias(String alias) {
    return $AiChatMessagesTable(attachedDatabase, alias);
  }
}

class AiChatMessage extends DataClass implements Insertable<AiChatMessage> {
  final int id;
  final int sessionId;
  final String message;
  final bool isUser;
  final String outputType;
  final String responseData;
  final int createdAt;
  const AiChatMessage({
    required this.id,
    required this.sessionId,
    required this.message,
    required this.isUser,
    required this.outputType,
    required this.responseData,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['message'] = Variable<String>(message);
    map['is_user'] = Variable<bool>(isUser);
    map['output_type'] = Variable<String>(outputType);
    map['response_data'] = Variable<String>(responseData);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AiChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return AiChatMessagesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      message: Value(message),
      isUser: Value(isUser),
      outputType: Value(outputType),
      responseData: Value(responseData),
      createdAt: Value(createdAt),
    );
  }

  factory AiChatMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiChatMessage(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      message: serializer.fromJson<String>(json['message']),
      isUser: serializer.fromJson<bool>(json['isUser']),
      outputType: serializer.fromJson<String>(json['outputType']),
      responseData: serializer.fromJson<String>(json['responseData']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'message': serializer.toJson<String>(message),
      'isUser': serializer.toJson<bool>(isUser),
      'outputType': serializer.toJson<String>(outputType),
      'responseData': serializer.toJson<String>(responseData),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AiChatMessage copyWith({
    int? id,
    int? sessionId,
    String? message,
    bool? isUser,
    String? outputType,
    String? responseData,
    int? createdAt,
  }) => AiChatMessage(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    message: message ?? this.message,
    isUser: isUser ?? this.isUser,
    outputType: outputType ?? this.outputType,
    responseData: responseData ?? this.responseData,
    createdAt: createdAt ?? this.createdAt,
  );
  AiChatMessage copyWithCompanion(AiChatMessagesCompanion data) {
    return AiChatMessage(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      message: data.message.present ? data.message.value : this.message,
      isUser: data.isUser.present ? data.isUser.value : this.isUser,
      outputType: data.outputType.present
          ? data.outputType.value
          : this.outputType,
      responseData: data.responseData.present
          ? data.responseData.value
          : this.responseData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiChatMessage(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('message: $message, ')
          ..write('isUser: $isUser, ')
          ..write('outputType: $outputType, ')
          ..write('responseData: $responseData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    message,
    isUser,
    outputType,
    responseData,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiChatMessage &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.message == this.message &&
          other.isUser == this.isUser &&
          other.outputType == this.outputType &&
          other.responseData == this.responseData &&
          other.createdAt == this.createdAt);
}

class AiChatMessagesCompanion extends UpdateCompanion<AiChatMessage> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> message;
  final Value<bool> isUser;
  final Value<String> outputType;
  final Value<String> responseData;
  final Value<int> createdAt;
  const AiChatMessagesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.message = const Value.absent(),
    this.isUser = const Value.absent(),
    this.outputType = const Value.absent(),
    this.responseData = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AiChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String message,
    required bool isUser,
    this.outputType = const Value.absent(),
    this.responseData = const Value.absent(),
    required int createdAt,
  }) : sessionId = Value(sessionId),
       message = Value(message),
       isUser = Value(isUser),
       createdAt = Value(createdAt);
  static Insertable<AiChatMessage> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? message,
    Expression<bool>? isUser,
    Expression<String>? outputType,
    Expression<String>? responseData,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (message != null) 'message': message,
      if (isUser != null) 'is_user': isUser,
      if (outputType != null) 'output_type': outputType,
      if (responseData != null) 'response_data': responseData,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AiChatMessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? message,
    Value<bool>? isUser,
    Value<String>? outputType,
    Value<String>? responseData,
    Value<int>? createdAt,
  }) {
    return AiChatMessagesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      message: message ?? this.message,
      isUser: isUser ?? this.isUser,
      outputType: outputType ?? this.outputType,
      responseData: responseData ?? this.responseData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (isUser.present) {
      map['is_user'] = Variable<bool>(isUser.value);
    }
    if (outputType.present) {
      map['output_type'] = Variable<String>(outputType.value);
    }
    if (responseData.present) {
      map['response_data'] = Variable<String>(responseData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('message: $message, ')
          ..write('isUser: $isUser, ')
          ..write('outputType: $outputType, ')
          ..write('responseData: $responseData, ')
          ..write('createdAt: $createdAt')
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
  late final $AiChatSessionsTable aiChatSessions = $AiChatSessionsTable(this);
  late final $AiChatMessagesTable aiChatMessages = $AiChatMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    locationHistory,
    aiChatSessions,
    aiChatMessages,
  ];
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
typedef $$AiChatSessionsTableCreateCompanionBuilder =
    AiChatSessionsCompanion Function({
      Value<int> id,
      required int userId,
      required String title,
      required int createdAt,
      required int updatedAt,
    });
typedef $$AiChatSessionsTableUpdateCompanionBuilder =
    AiChatSessionsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> title,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

class $$AiChatSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $AiChatSessionsTable> {
  $$AiChatSessionsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiChatSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiChatSessionsTable> {
  $$AiChatSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiChatSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiChatSessionsTable> {
  $$AiChatSessionsTableAnnotationComposer({
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AiChatSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiChatSessionsTable,
          AiChatSession,
          $$AiChatSessionsTableFilterComposer,
          $$AiChatSessionsTableOrderingComposer,
          $$AiChatSessionsTableAnnotationComposer,
          $$AiChatSessionsTableCreateCompanionBuilder,
          $$AiChatSessionsTableUpdateCompanionBuilder,
          (
            AiChatSession,
            BaseReferences<_$AppDatabase, $AiChatSessionsTable, AiChatSession>,
          ),
          AiChatSession,
          PrefetchHooks Function()
        > {
  $$AiChatSessionsTableTableManager(
    _$AppDatabase db,
    $AiChatSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiChatSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiChatSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiChatSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => AiChatSessionsCompanion(
                id: id,
                userId: userId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String title,
                required int createdAt,
                required int updatedAt,
              }) => AiChatSessionsCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiChatSessionsTable, AiChatSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AiChatSessionsTable,
                    AiChatSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiChatSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiChatSessionsTable,
      AiChatSession,
      $$AiChatSessionsTableFilterComposer,
      $$AiChatSessionsTableOrderingComposer,
      $$AiChatSessionsTableAnnotationComposer,
      $$AiChatSessionsTableCreateCompanionBuilder,
      $$AiChatSessionsTableUpdateCompanionBuilder,
      (
        AiChatSession,
        BaseReferences<_$AppDatabase, $AiChatSessionsTable, AiChatSession>,
      ),
      AiChatSession,
      PrefetchHooks Function()
    >;
typedef $$AiChatMessagesTableCreateCompanionBuilder =
    AiChatMessagesCompanion Function({
      Value<int> id,
      required int sessionId,
      required String message,
      required bool isUser,
      Value<String> outputType,
      Value<String> responseData,
      required int createdAt,
    });
typedef $$AiChatMessagesTableUpdateCompanionBuilder =
    AiChatMessagesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> message,
      Value<bool> isUser,
      Value<String> outputType,
      Value<String> responseData,
      Value<int> createdAt,
    });

class $$AiChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $AiChatMessagesTable> {
  $$AiChatMessagesTableFilterComposer({
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

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUser => $composableBuilder(
    column: $table.isUser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outputType => $composableBuilder(
    column: $table.outputType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseData => $composableBuilder(
    column: $table.responseData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiChatMessagesTable> {
  $$AiChatMessagesTableOrderingComposer({
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

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUser => $composableBuilder(
    column: $table.isUser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outputType => $composableBuilder(
    column: $table.outputType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseData => $composableBuilder(
    column: $table.responseData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiChatMessagesTable> {
  $$AiChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<bool> get isUser =>
      $composableBuilder(column: $table.isUser, builder: (column) => column);

  GeneratedColumn<String> get outputType => $composableBuilder(
    column: $table.outputType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseData => $composableBuilder(
    column: $table.responseData,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiChatMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiChatMessagesTable,
          AiChatMessage,
          $$AiChatMessagesTableFilterComposer,
          $$AiChatMessagesTableOrderingComposer,
          $$AiChatMessagesTableAnnotationComposer,
          $$AiChatMessagesTableCreateCompanionBuilder,
          $$AiChatMessagesTableUpdateCompanionBuilder,
          (
            AiChatMessage,
            BaseReferences<_$AppDatabase, $AiChatMessagesTable, AiChatMessage>,
          ),
          AiChatMessage,
          PrefetchHooks Function()
        > {
  $$AiChatMessagesTableTableManager(
    _$AppDatabase db,
    $AiChatMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<bool> isUser = const Value.absent(),
                Value<String> outputType = const Value.absent(),
                Value<String> responseData = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => AiChatMessagesCompanion(
                id: id,
                sessionId: sessionId,
                message: message,
                isUser: isUser,
                outputType: outputType,
                responseData: responseData,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String message,
                required bool isUser,
                Value<String> outputType = const Value.absent(),
                Value<String> responseData = const Value.absent(),
                required int createdAt,
              }) => AiChatMessagesCompanion.insert(
                id: id,
                sessionId: sessionId,
                message: message,
                isUser: isUser,
                outputType: outputType,
                responseData: responseData,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiChatMessagesTable, AiChatMessage>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AiChatMessagesTable,
                    AiChatMessage
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiChatMessagesTable,
      AiChatMessage,
      $$AiChatMessagesTableFilterComposer,
      $$AiChatMessagesTableOrderingComposer,
      $$AiChatMessagesTableAnnotationComposer,
      $$AiChatMessagesTableCreateCompanionBuilder,
      $$AiChatMessagesTableUpdateCompanionBuilder,
      (
        AiChatMessage,
        BaseReferences<_$AppDatabase, $AiChatMessagesTable, AiChatMessage>,
      ),
      AiChatMessage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocationHistoryTableTableManager get locationHistory =>
      $$LocationHistoryTableTableManager(_db, _db.locationHistory);
  $$AiChatSessionsTableTableManager get aiChatSessions =>
      $$AiChatSessionsTableTableManager(_db, _db.aiChatSessions);
  $$AiChatMessagesTableTableManager get aiChatMessages =>
      $$AiChatMessagesTableTableManager(_db, _db.aiChatMessages);
}
