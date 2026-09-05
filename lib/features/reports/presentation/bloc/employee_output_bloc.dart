import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_employee_output_report.dart';
import '../../domain/usecases/get_employees.dart';

import 'employee_output_event.dart';
import 'employee_output_state.dart';

class EmployeeOutputBloc
    extends Bloc<
        EmployeeOutputEvent,
        EmployeeOutputState> {
  final GetEmployeeOutputReport
      getEmployeeOutputReport;

  final GetEmployees getEmployees;

  EmployeeOutputBloc({
    required this.getEmployeeOutputReport,
    required this.getEmployees,
  }) : super(
          const EmployeeOutputState(),
        ) {
    // ----------------------------------------------------------
    // REPORT
    // ----------------------------------------------------------

    on<GetEmployeeOutputReportEvent>(
      _getEmployeeOutputReport,
    );

    // ----------------------------------------------------------
    // EMPLOYEE SEARCH
    // ----------------------------------------------------------

    on<SearchEmployeesEvent>(
      _searchEmployees,
    );

    // ----------------------------------------------------------
    // CLEAR
    // ----------------------------------------------------------

    on<ClearEmployeeSuggestionsEvent>(
      _clearEmployeeSuggestions,
    );
  }

  // ============================================================
  // GET REPORT
  // ============================================================

  Future<void> _getEmployeeOutputReport(
    GetEmployeeOutputReportEvent event,
    Emitter<EmployeeOutputState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            EmployeeOutputStatus.loading,
        reports: [],
        clearError: true,
      ),
    );

    try {
      final reports =
          await getEmployeeOutputReport(
        userId: event.logUserId,
        employeeId: event.employeeId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeName: event.employeeName,
        startLimit: event.startLimit,
      );

      emit(
        state.copyWith(
          status:
              EmployeeOutputStatus.success,
          reports: reports,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              EmployeeOutputStatus.failure,
          reports: [],
          errorMessage:
              e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // SEARCH EMPLOYEE
  // ============================================================

  Future<void> _searchEmployees(
    SearchEmployeesEvent event,
    Emitter<EmployeeOutputState> emit,
  ) async {
    emit(
      state.copyWith(
        employeeLoading: true,
      ),
    );

    try {
      final employees =
          await getEmployees(
        logUserId: event.logUserId,
        search: event.search,
      );

      emit(
        state.copyWith(
          employees: employees,
          employeeLoading: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          employees: [],
          employeeLoading: false,
        ),
      );
    }
  }

  // ============================================================
  // CLEAR EMPLOYEE SUGGESTIONS
  // ============================================================

  void _clearEmployeeSuggestions(
    ClearEmployeeSuggestionsEvent event,
    Emitter<EmployeeOutputState> emit,
  ) {
    emit(
      state.copyWith(
        employees: [],
        employeeLoading: false,
      ),
    );
  }
}