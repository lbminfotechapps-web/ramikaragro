import 'package:equatable/equatable.dart';

class VisitReport extends Equatable {
  final String date;
  final String empCode;
  final String empName;
  final String inTime;
  final String dealerVisit;
  final String farmerVisit;
  final String outTime;
  final String totalTime;
  final String expenseAmount;
  final String onMapKm;
  final String totalKm;
  final String status;

  const VisitReport({
    required this.date,
    required this.empCode,
    required this.empName,
    required this.inTime,
    required this.dealerVisit,
    required this.farmerVisit,
    required this.outTime,
    required this.totalTime,
    required this.expenseAmount,
    required this.onMapKm,
    required this.totalKm,
    required this.status,
  });

  @override
  List<Object?> get props => [
        date,
        empCode,
        empName,
        inTime,
        dealerVisit,
        farmerVisit,
        outTime,
        totalTime,
        expenseAmount,
        onMapKm,
        totalKm,
        status,
      ];
}