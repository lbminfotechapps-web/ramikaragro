import 'package:equatable/equatable.dart';

import '../../domain/entities/collection_list.dart';

enum CollectionListStatus {
  initial,
  loading,
  success,
  failure,
}

class CollectionListState
    extends Equatable {
  final CollectionListStatus status;

  final List<CollectionList> collectionList;

  final String errorMessage;

  const CollectionListState({
    this.status =
        CollectionListStatus.initial,

    this.collectionList =
        const [],

    this.errorMessage = '',
  });

  CollectionListState copyWith({
    CollectionListStatus? status,

    List<CollectionList>? collectionList,

    String? errorMessage,
  }) {
    return CollectionListState(
      status: status ?? this.status,

      collectionList:
          collectionList ??
              this.collectionList,

      errorMessage:
          errorMessage ??
              this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        status,
        collectionList,
        errorMessage,
      ];
}