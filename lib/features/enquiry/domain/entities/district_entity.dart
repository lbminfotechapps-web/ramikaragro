import 'package:equatable/equatable.dart';

import 'taluka_entity.dart';

class DistrictEntity extends Equatable {
  final String id;
  final String name;
  final List<TalukaEntity> talukas;

  const DistrictEntity({
    required this.id,
    required this.name,
    required this.talukas,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        talukas,
      ];
}