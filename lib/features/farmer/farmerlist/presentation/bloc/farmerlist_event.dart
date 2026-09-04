import 'dart:ffi';

import 'package:equatable/equatable.dart';

class FarmerlistEvent extends Equatable {
  const FarmerlistEvent();

  @override
  List<Object> get props => [];
}

class FarmerListEvent extends FarmerlistEvent {
  final int user_id;
  final String currentLat;
  final String currentLong;
  final int limit;
  final String searchKey;

  const FarmerListEvent({
    required this.user_id,
    required this.currentLat,
    required this.currentLong,
    required this.limit,
    required this.searchKey,
  });

  @override
  List<Object> get props => [
    user_id,
    currentLat,
    currentLong,
    limit,
    searchKey,
  ];
}
