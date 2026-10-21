
import 'package:equatable/equatable.dart';

class ScheduleFarmerEntity extends Equatable {
  final String farmerId;
  final String farmerName;
  final String address;
  final String talukaName;
  final String mobileNo;
  final int farmerPlotStatus;

  const ScheduleFarmerEntity({
    required this.farmerId,
    required this.farmerName,
    required this.address,
    required this.talukaName,
    this.mobileNo = '',
    this.farmerPlotStatus = 0,
  });

  bool get hasRegisteredPlots => farmerPlotStatus == 1;

  @override
  List<Object?> get props => [
        farmerId,
        farmerName,
        address,
        talukaName,
        mobileNo,
        farmerPlotStatus,
      ];
}
