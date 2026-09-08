import 'dart:ffi';

import 'package:equatable/equatable.dart';

class DealerListEvent extends Equatable {
  final String user_id;
  final String latitude;
  final String longitude;
  final String searchText;
  final String type;

  const DealerListEvent({
    required this.user_id,
    required this.latitude,
    required this.longitude,
    required this.searchText,
    required this.type,
  });

  @override
  List<Object> get props => [
        user_id,
        latitude,
        longitude,
        searchText,
        type
      ];
}