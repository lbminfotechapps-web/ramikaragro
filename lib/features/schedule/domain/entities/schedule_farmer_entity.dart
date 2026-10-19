import 'package:equatable/equatable.dart';

class ScheduleFarmerEntity
    extends Equatable {
  final String farmerId;
  final String farmerName;
  final String address;
  final String talukaName;
  final String mobileNo;

  const ScheduleFarmerEntity({
    required this.farmerId,
    required this.farmerName,
    required this.address,
    required this.talukaName,
    this.mobileNo = '',
  });

  @override
  List<Object?> get props => [
        farmerId,
        farmerName,
        address,
        talukaName,
        mobileNo,
      ];
}