import 'package:equatable/equatable.dart';

abstract class VisitReportEvent extends Equatable {
  const VisitReportEvent();

  @override
  List<Object?> get props => [];
}

class GetVisitReportEvent extends VisitReportEvent {
  final String logUserId;
  final String userId;
  final String fromDate;
  final String toDate;

  const GetVisitReportEvent({
    required this.logUserId,
    required this.userId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [
        logUserId,
        userId,
        fromDate,
        toDate,
      ];
}