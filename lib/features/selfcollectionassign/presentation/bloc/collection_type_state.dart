import 'package:equatable/equatable.dart';

import '../../domain/entities/collection_type_entity.dart';

enum CollectionTypeStatus { initial, loading, success, failure }

class CollectionTypeState extends Equatable {
  final CollectionTypeStatus status;

  final List<CollectionTypeEntity> collectionTypes;

  final String message;

  const CollectionTypeState({
    this.status = CollectionTypeStatus.initial,
    this.collectionTypes = const [],
    this.message = '',
  });

  CollectionTypeState copyWith({
    CollectionTypeStatus? status,
    List<CollectionTypeEntity>? collectionTypes,
    String? message,
  }) {
    return CollectionTypeState(
      status: status ?? this.status,
      collectionTypes: collectionTypes ?? this.collectionTypes,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, collectionTypes, message];
}
