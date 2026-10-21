
import 'package:equatable/equatable.dart';

class FarmerPlotEntity extends Equatable {
  final String plotId;
  final String plotName;
  final String farmerId;
  final String farmerName;
  final String cropId;
  final String cropName;
  final String sowingDate;
  final String createdDate;

  const FarmerPlotEntity({
    required this.plotId,
    required this.plotName,
    required this.farmerId,
    required this.farmerName,
    required this.cropId,
    required this.cropName,
    required this.sowingDate,
    required this.createdDate,
  });

  @override
  List<Object?> get props => [
        plotId,
        plotName,
        farmerId,
        farmerName,
        cropId,
        cropName,
        sowingDate,
        createdDate,
      ];
}
