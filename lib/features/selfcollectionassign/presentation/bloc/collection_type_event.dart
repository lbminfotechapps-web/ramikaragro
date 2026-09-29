import 'package:equatable/equatable.dart';

abstract class CollectionTypeEvent extends Equatable {
  const CollectionTypeEvent();

  @override
  List<Object?> get props => [];
}

class GetCollectionTypeEvent extends CollectionTypeEvent {
  const GetCollectionTypeEvent();
}

class RefreshCollectionTypeEvent extends CollectionTypeEvent {
  const RefreshCollectionTypeEvent();
}
