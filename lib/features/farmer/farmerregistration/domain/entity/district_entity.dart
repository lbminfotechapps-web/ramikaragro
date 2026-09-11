import 'package:equatable/equatable.dart';
import 'taluka_entity.dart';

class DistrictEntity extends Equatable {
  final String fldDistId;
  final String fldDistName;
  final List<TalukaEntity> taluka;

  const DistrictEntity({
    required this.fldDistId,
    required this.fldDistName,
    required this.taluka,
  });

  @override
  List<Object?> get props => [
        fldDistId,
        fldDistName,
        taluka,
      ];
}