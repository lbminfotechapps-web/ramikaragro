import 'package:equatable/equatable.dart';

abstract class EmployeeActivityEvent
    extends Equatable {
  const EmployeeActivityEvent();

  @override
  List<Object?> get props => [];
}

class GetEmployeeActivityEvent
    extends EmployeeActivityEvent {

  final String userId;
  final String searchDate;
  final String logUserId;

  const GetEmployeeActivityEvent({
    required this.userId,
    required this.searchDate,
    required this.logUserId,
  });

  @override
  List<Object?> get props => [
        userId,
        searchDate,
        logUserId,
      ];
}