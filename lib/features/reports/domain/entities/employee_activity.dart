import 'package:equatable/equatable.dart';

class EmployeeActivity extends Equatable {
  final String activityName;
  final String visitTo;
  final String dailyTranId;
  final String farmerName;
  final String outletName;
  final String time;
  final String userId;
  final String selfieImage;
  final String adminName;
  final String adminMobile;
  final String isMaxVisited;

  const EmployeeActivity({
    required this.activityName,
    required this.visitTo,
    required this.dailyTranId,
    this.farmerName = '',
    this.outletName = '',
    required this.time,
    required this.userId,
    required this.selfieImage,
    required this.adminName,
    required this.adminMobile,
    required this.isMaxVisited,
  });

  @override
  List<Object?> get props => [
        activityName,
        visitTo,
        dailyTranId,
        farmerName,
        outletName,
        time,
        userId,
        selfieImage,
        adminName,
        adminMobile,
        isMaxVisited,
      ];
}