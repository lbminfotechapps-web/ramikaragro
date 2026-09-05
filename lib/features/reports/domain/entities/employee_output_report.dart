import 'package:equatable/equatable.dart';

class EmployeeOutputReport extends Equatable {
  final String empName;
  final String empId;
  final String outletCnt;
  final String farmerCnt;
  final String currentCnt;
  final String totalVisits;

  const EmployeeOutputReport({
    required this.empName,
    required this.empId,
    required this.outletCnt,
    required this.farmerCnt,
    required this.currentCnt,
    required this.totalVisits,
  });

  @override
  List<Object?> get props => [
        empName,
        empId,
        outletCnt,
        farmerCnt,
        currentCnt,
        totalVisits,
      ];
}