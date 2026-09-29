import 'package:equatable/equatable.dart';

class CollectionTypeResponseEntity extends Equatable {
  final bool status;
  final List<CollectionTypeEntity> collectionTypes;
  final String message;

  const CollectionTypeResponseEntity({
    required this.status,
    required this.collectionTypes,
    required this.message,
  });

  @override
  List<Object?> get props => [status, collectionTypes, message];
}

class CollectionTypeEntity extends Equatable {
  final String collectionType;
  final String collectionTypeId;

  const CollectionTypeEntity({
    required this.collectionType,
    required this.collectionTypeId,
  });

  @override
  List<Object?> get props => [collectionType, collectionTypeId];
}
