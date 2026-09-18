import 'package:equatable/equatable.dart';

class TalukaEntity extends Equatable {
  final String districtId;
  final String talukaId;
  final String name;

  const TalukaEntity({
    required this.districtId,
    required this.talukaId,
    required this.name,
  });

  @override
  List<Object?> get props => [
        districtId,
        talukaId,
        name,
      ];
}