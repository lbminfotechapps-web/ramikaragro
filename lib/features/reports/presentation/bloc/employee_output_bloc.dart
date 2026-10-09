import 'package:flutter/material.dart';
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


     on<EmployeeOutRepoDetailsEvent>(_onEmployeeOutRepoDetails);
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






  Future<void> _onEmployeeOutRepoDetails(
  EmployeeOutRepoDetailsEvent event,
  Emitter<EmployeeOutputState> emit,
) async {
  debugPrint('========== EMPLOYEE OUTPUT DETAILS START ==========');
  debugPrint('Employee ID: ${event.empId}');
  debugPrint('From Date: ${event.fromdate}');
  debugPrint('To Date: ${event.toDate}');

  // ===============================
  // LOADING STATE
  // ===============================
  emit(
    state.copyWith(
      status: EmployeeOutputStatus.loading,
     
      clearError: true,
    ),
  );

  try {
    // ===============================
    // CALL USECASE
    // ===============================
    final result = await getEmployees.getEmployeeOutputReportDetails(
      empId: event.empId,
      fromdate: event.fromdate,
      toDate: event.toDate,
    );

    debugPrint('========== EMPLOYEE OUTPUT DETAILS RESPONSE ==========');
    debugPrint('Status: ${result.status}');
    debugPrint('Message: ${result.message}');
    debugPrint('Total Records: ${result.result.length}');

    for (int i = 0; i < result.result.length; i++) {
      final item = result.result[i];

      debugPrint('---------- Record ${i + 1} ----------');
      debugPrint('Date: ${item.date}');
      debugPrint('Total Expense: ${item.totalExpense}');
      debugPrint('Total Kilometer: ${item.totalKilometer}');
      debugPrint('Present Status: ${item.presentStatus}');
    }

    // ===============================
    // CHECK API STATUS
    // ===============================
    if (result.status) {
      emit(
        state.copyWith(
          status: EmployeeOutputStatus.success,
          employeeOutRepoDetailsEntity: result,
     
        ),
      );

      debugPrint('Employee output details loaded successfully');
    } else {
      emit(
        state.copyWith(
          status: EmployeeOutputStatus.failure,
      
          errorMessage: result.message,
        ),
      );

      debugPrint('Employee output details failed: ${result.message}');
    }
  } catch (e, stackTrace) {
    // ===============================
    // ERROR STATE
    // ===============================
    debugPrint('========== EMPLOYEE OUTPUT DETAILS ERROR ==========');
    debugPrint('Error: $e');
    debugPrint('StackTrace: $stackTrace');

    emit(
      state.copyWith(
        status: EmployeeOutputStatus.failure,
     
        errorMessage: e.toString(),
      ),
    );
  }

  debugPrint('========== EMPLOYEE OUTPUT DETAILS END ==========');
}
}