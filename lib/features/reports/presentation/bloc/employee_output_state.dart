import 'package:equatable/equatable.dart';
import 'package:solufine/features/reports/domain/entities/employee_out_repo_details.dart';

import '../../domain/entities/assign_employee.dart';
import '../../domain/entities/employee_output_report.dart';

enum EmployeeOutputStatus { initial, loading, success, failure }

class EmployeeOutputState extends Equatable {
  final EmployeeOutputStatus status;

  final List<EmployeeOutputReport> reports;

  final List<AssignEmployee> employees;

  final bool employeeLoading;

  final String? errorMessage;
  final EmployeeOutRepoDetailsEntity? employeeOutRepoDetailsEntity;
  const EmployeeOutputState({
    this.status = EmployeeOutputStatus.initial,

    this.reports = const [],

    this.employees = const [],

    this.employeeLoading = false,

    this.errorMessage,
    this.employeeOutRepoDetailsEntity,
  });

  EmployeeOutputState copyWith({
    EmployeeOutputStatus? status,
    List<EmployeeOutputReport>? reports,
    List<AssignEmployee>? employees,
    bool? employeeLoading,
    String? errorMessage,
    bool clearError = false,
    EmployeeOutRepoDetailsEntity? employeeOutRepoDetailsEntity,
  }) {
    return EmployeeOutputState(
      status: status ?? this.status,

      reports: reports ?? this.reports,

      employees: employees ?? this.employees,

      employeeLoading: employeeLoading ?? this.employeeLoading,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,

      employeeOutRepoDetailsEntity:
          employeeOutRepoDetailsEntity ?? this.employeeOutRepoDetailsEntity,
    );
  }

  @override
  List<Object?> get props => [
    status,
    reports,
    employees,
    employeeLoading,
    errorMessage,
    employeeOutRepoDetailsEntity,
  ];
}
