import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/visit_day_wise.dart';
import '../../domain/entities/visit_frequency.dart';
import '../../domain/entities/visit_geo_wise.dart';
import '../../domain/entities/visit_hour_wise.dart';
import '../../domain/entities/visit_month_wise.dart';
import '../../domain/entities/visit_report_employee.dart';
import '../../domain/entities/visit_top_employee.dart';
import '../../domain/entities/visit_top_list.dart';

import '../../domain/usecases/get_visit_day_wise_usecase.dart';
import '../../domain/usecases/get_visit_frequency_usecase.dart';
import '../../domain/usecases/get_visit_geo_wise_usecase.dart';
import '../../domain/usecases/get_visit_hour_wise_usecase.dart';
import '../../domain/usecases/get_visit_month_wise_usecase.dart';
import '../../domain/usecases/get_visit_report_employees_usecase.dart';
import '../../domain/usecases/get_visit_top_employee_usecase.dart';
import '../../domain/usecases/get_visit_top_list_usecase.dart';

import 'visit_month_wise_event.dart';
import 'visit_month_wise_state.dart';

class VisitMonthWiseBloc
    extends Bloc<VisitMonthWiseEvent, VisitMonthWiseState> {
  // ==========================================================
  // USE CASES
  // ==========================================================

  final GetVisitMonthWiseUseCase getVisitMonthWiseUseCase;

  final GetVisitDayWiseUseCase getVisitDayWiseUseCase;

  final GetVisitHourWiseUseCase getVisitHourWiseUseCase;

  final GetVisitFrequencyUseCase getVisitFrequencyUseCase;

  final GetVisitGeoWiseUseCase getVisitGeoWiseUseCase;

  final GetVisitTopListUseCase getVisitTopListUseCase;

  final GetVisitTopEmployeeUseCase getVisitTopEmployeeUseCase;

  final GetVisitReportEmployeesUseCase getVisitReportEmployeesUseCase;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  VisitMonthWiseBloc({
    required this.getVisitMonthWiseUseCase,
    required this.getVisitDayWiseUseCase,
    required this.getVisitHourWiseUseCase,
    required this.getVisitFrequencyUseCase,
    required this.getVisitGeoWiseUseCase,
    required this.getVisitTopListUseCase,
    required this.getVisitTopEmployeeUseCase,
    required this.getVisitReportEmployeesUseCase,
  }) : super(const VisitMonthWiseState()) {
    // ========================================================
    // MONTH WISE
    // ========================================================

    on<LoadVisitMonthWiseEvent>(_loadMonthWiseReport);

    // ========================================================
    // DAY WISE
    // ========================================================

    on<LoadVisitDayWiseEvent>(_loadDayWiseReport);

    // ========================================================
    // HOUR WISE
    // ========================================================

    on<LoadVisitHourWiseEvent>(_loadHourWiseReport);

    // ========================================================
    // FREQUENCY
    // ========================================================

    on<LoadVisitFrequencyEvent>(_loadVisitFrequency);

    // ========================================================
    // GEO WISE
    // ========================================================

    on<LoadVisitGeoWiseEvent>(_loadGeoWiseReport);

    // ========================================================
    // TOP DEALER / FARMER
    // ========================================================

    on<LoadVisitTopListEvent>(_loadVisitTopList);

    // ========================================================
    // TOP EMPLOYEE
    // ========================================================

    on<LoadVisitTopEmployeeEvent>(_loadVisitTopEmployee);

    // ========================================================
    // EMPLOYEE SEARCH
    // ========================================================

    on<SearchVisitReportEmployeesEvent>(_searchEmployees);

    on<ClearVisitReportEmployeesEvent>(_clearEmployees);
  }

  // ============================================================
  // MONTH WISE REPORT
  // ============================================================

  Future<void> _loadMonthWiseReport(
    LoadVisitMonthWiseEvent event,
    Emitter<VisitMonthWiseState> emit,
  ) async {
    emit(
      state.copyWith(status: VisitMonthWiseStatus.loading, clearError: true),
    );

    try {
      final VisitMonthWiseReport result = await getVisitMonthWiseUseCase(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      emit(
        state.copyWith(
          status: VisitMonthWiseStatus.success,
          report: result,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: VisitMonthWiseStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          clearReport: true,
        ),
      );
    }
  }

  // ============================================================
  // DAY WISE REPORT
  // ============================================================

  Future<void> _loadDayWiseReport(
    LoadVisitDayWiseEvent event,
    Emitter<VisitMonthWiseState> emit,
  ) async {
    emit(
      state.copyWith(
        dayWiseStatus: VisitDayWiseStatus.loading,
        clearDayWiseError: true,
      ),
    );

    try {
      final VisitDayWiseReport result = await getVisitDayWiseUseCase(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      emit(
        state.copyWith(
          dayWiseStatus: VisitDayWiseStatus.success,
          dayWiseReport: result,
          clearDayWiseError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          dayWiseStatus: VisitDayWiseStatus.failure,
          dayWiseError: e.toString().replaceFirst('Exception: ', ''),
          clearDayWiseReport: true,
        ),
      );
    }
  }

  // ============================================================
  // HOUR WISE REPORT
  // ============================================================

  Future<void> _loadHourWiseReport(
    LoadVisitHourWiseEvent event,
    Emitter<VisitMonthWiseState> emit,
  ) async {
    emit(
      state.copyWith(
        hourWiseStatus: VisitHourWiseStatus.loading,
        clearHourWiseError: true,
      ),
    );

    try {
      final VisitHourWiseReport result = await getVisitHourWiseUseCase(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      emit(
        state.copyWith(
          hourWiseStatus: VisitHourWiseStatus.success,
          hourWiseReport: result,
          clearHourWiseError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          hourWiseStatus: VisitHourWiseStatus.failure,
          hourWiseError: e.toString().replaceFirst('Exception: ', ''),
          clearHourWiseReport: true,
        ),
      );
    }
  }

  // ============================================================
  // VISIT FREQUENCY
  // ============================================================

  Future<void> _loadVisitFrequency(
    LoadVisitFrequencyEvent event,
    Emitter<VisitMonthWiseState> emit,
  ) async {
    emit(
      state.copyWith(
        frequencyStatus: VisitFrequencyStatus.loading,
        clearFrequencyError: true,
      ),
    );

    try {
      final VisitFrequencyReport result = await getVisitFrequencyUseCase(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      emit(
        state.copyWith(
          frequencyStatus: VisitFrequencyStatus.success,
          frequencyReport: result,
          clearFrequencyError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          frequencyStatus: VisitFrequencyStatus.failure,
          frequencyError: e.toString().replaceFirst('Exception: ', ''),
          clearFrequencyReport: true,
        ),
      );
    }
  }

  // ============================================================
  // GEO WISE
  // ============================================================

  Future<void> _loadGeoWiseReport(
    LoadVisitGeoWiseEvent event,
    Emitter<VisitMonthWiseState> emit,
  ) async {
    emit(
      state.copyWith(
        geoWiseStatus: VisitGeoWiseStatus.loading,
        clearGeoWiseError: true,
      ),
    );

    try {
      final VisitGeoWiseReport result = await getVisitGeoWiseUseCase(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      emit(
        state.copyWith(
          geoWiseStatus: VisitGeoWiseStatus.success,
          geoWiseReport: result,
          clearGeoWiseError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          geoWiseStatus: VisitGeoWiseStatus.failure,
          geoWiseError: e.toString().replaceFirst('Exception: ', ''),
          clearGeoWiseReport: true,
        ),
      );
    }
  }

  // ============================================================
  // TOP DEALER / FARMER LIST
  // ============================================================

  Future<void> _loadVisitTopList(
    LoadVisitTopListEvent event,
    Emitter<VisitMonthWiseState> emit,
  ) async {
    emit(
      state.copyWith(
        topListStatus: VisitTopListStatus.loading,
        clearTopListError: true,
      ),
    );

    try {
      final VisitTopListReport result = await getVisitTopListUseCase(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      emit(
        state.copyWith(
          topListStatus: VisitTopListStatus.success,
          topListReport: result,
          clearTopListError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          topListStatus: VisitTopListStatus.failure,
          topListError: e.toString().replaceFirst('Exception: ', ''),
          clearTopListReport: true,
        ),
      );
    }
  }

  // ============================================================
  // TOP EMPLOYEE
  // ============================================================

  Future<void> _loadVisitTopEmployee(
    LoadVisitTopEmployeeEvent event,
    Emitter<VisitMonthWiseState> emit,
  ) async {
    emit(
      state.copyWith(
        topEmployeeStatus: VisitTopEmployeeStatus.loading,
        clearTopEmployeeError: true,
      ),
    );

    try {
      final VisitTopEmployeeReport result = await getVisitTopEmployeeUseCase(
        fromDate: event.fromDate,
        toDate: event.toDate,
        employeeId: event.employeeId,
      );

      emit(
        state.copyWith(
          topEmployeeStatus: VisitTopEmployeeStatus.success,
          topEmployeeReport: result,
          clearTopEmployeeError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          topEmployeeStatus: VisitTopEmployeeStatus.failure,
          topEmployeeError: e.toString().replaceFirst('Exception: ', ''),
          clearTopEmployeeReport: true,
        ),
      );
    }
  }

  // ============================================================
  // EMPLOYEE SEARCH
  // ============================================================

  Future<void> _searchEmployees(
    SearchVisitReportEmployeesEvent event,
    Emitter<VisitMonthWiseState> emit,
  ) async {
    emit(
      state.copyWith(
        employeeStatus: VisitReportEmployeeStatus.loading,
        clearEmployeeError: true,
      ),
    );

    try {
      final List<VisitReportEmployee> result =
          await getVisitReportEmployeesUseCase(
            userId: event.userId,
            searchText: event.searchText,
          );

      emit(
        state.copyWith(
          employeeStatus: VisitReportEmployeeStatus.success,
          employees: result,
          clearEmployeeError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          employeeStatus: VisitReportEmployeeStatus.failure,
          employeeError: e.toString().replaceFirst('Exception: ', ''),
          clearEmployees: true,
        ),
      );
    }
  }

  // ============================================================
  // CLEAR EMPLOYEE
  // ============================================================

  void _clearEmployees(
    ClearVisitReportEmployeesEvent event,
    Emitter<VisitMonthWiseState> emit,
  ) {
    emit(
      state.copyWith(
        employeeStatus: VisitReportEmployeeStatus.initial,
        clearEmployees: true,
        clearEmployeeError: true,
      ),
    );
  }
}
