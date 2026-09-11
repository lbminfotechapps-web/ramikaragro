import 'package:equatable/equatable.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/home/doman/home_entity/vehicle_type_entity.dart';

enum QuickAccessStatus { initial, loading, success, failure }

class QuickAccessState extends Equatable {
  final QuickAccessStatus quickAccessStatus;
  final PunchStatEntity? punchStat;
  final String? errorMessage;
  final List<VehicleTypeEntity> vehicleList;
  final VehicleTypeEntity? selectedVehicle;
  final String? punchStatus;

  const QuickAccessState({
    this.quickAccessStatus = QuickAccessStatus.initial,
    this.punchStat,
    this.errorMessage,
    this.vehicleList = const [],
    this.selectedVehicle,
    this.punchStatus,
  });

  QuickAccessState copyWith({
    QuickAccessStatus? quickAccessStatus,
    PunchStatEntity? punchStat,
    String? errorMessage,
    List<VehicleTypeEntity>? vehicleList,
    VehicleTypeEntity? selectedVehicle,
    String? punchStatus,
  }) {
    return QuickAccessState(
      quickAccessStatus: quickAccessStatus ?? this.quickAccessStatus,
      punchStat: punchStat ?? this.punchStat,
      errorMessage: errorMessage ?? this.errorMessage,
      vehicleList: vehicleList ?? this.vehicleList,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      punchStatus: punchStatus ?? this.punchStatus,
    );
  }

  @override
  List<Object?> get props => [
    quickAccessStatus,
    punchStat,
    errorMessage,
    vehicleList,
    selectedVehicle,
  ];
}
