import 'package:demo/features/farmer/farmerregistration/domain/entity/district_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/farmer_details_entity.dart';
import 'package:demo/features/farmer/farmerregistration/domain/entity/state_entity.dart';
import 'package:equatable/equatable.dart';

enum StatesStatus { initial, loading, failed, sucess }

class StatsState extends Equatable {
  final StatesStatus status;
  final List<StateEntity> statentity;
  final List<DistrictEntity> districtList;
  final String? errorMessage;
  final FarmerDetailsEntity? farmerDetailsEntity;

  const StatsState({
    this.status = StatesStatus.initial,
    this.statentity = const [],
    this.districtList = const [],
    this.errorMessage,
    this.farmerDetailsEntity,
  });

  StatsState copyWith({
    StatesStatus? status,
    List<StateEntity>? statentity,
    List<DistrictEntity>? districtList,
    String? errorMessage,
    FarmerDetailsEntity? farmerDetailsEntity,
  }) {
    return StatsState(
      status: status ?? this.status,
      statentity: statentity ?? this.statentity,
      districtList: districtList ?? this.districtList,
      errorMessage: errorMessage ?? this.errorMessage,
      farmerDetailsEntity: farmerDetailsEntity ?? this.farmerDetailsEntity,
    );
  }

  @override
  List<Object?> get props => [
    status,
    statentity,
    districtList,
    errorMessage,
    farmerDetailsEntity,
  ];
}
