import 'package:equatable/equatable.dart';

abstract class EmployeeOutputEvent
    extends Equatable {
  const EmployeeOutputEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// GET REPORT
// ============================================================

class GetEmployeeOutputReportEvent
    extends EmployeeOutputEvent {
  final String logUserId;
  final String employeeId;
  final String fromDate;
  final String toDate;
  final String employeeName;
  final String startLimit;

  const GetEmployeeOutputReportEvent({
    required this.logUserId,
    required this.employeeId,
    required this.fromDate,
    required this.toDate,
    required this.employeeName,
    required this.startLimit,
  });

  @override
  List<Object?> get props => [
        logUserId,
        employeeId,
        fromDate,
        toDate,
        employeeName,
        startLimit,
      ];
}

// ============================================================
// SEARCH EMPLOYEES
// ============================================================

class SearchEmployeesEvent
    extends EmployeeOutputEvent {
  final String logUserId;
  final String search;

  const SearchEmployeesEvent({
    required this.logUserId,
    required this.search,
  });

  @override
  List<Object?> get props => [
        logUserId,
        search,
      ];
}

// ============================================================
// CLEAR SUGGESTIONS
// ============================================================

class ClearEmployeeSuggestionsEvent
    extends EmployeeOutputEvent {
  const ClearEmployeeSuggestionsEvent();
}