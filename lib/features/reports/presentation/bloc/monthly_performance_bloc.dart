import 'package:flutter_bloc/flutter_bloc.dart';

// ============================================================
// ENTITIES
// ============================================================

import '../../domain/entities/area_performance.dart';
import '../../domain/entities/daily_performance.dart';
import '../../domain/entities/expense_performance.dart';
import '../../domain/entities/hourly_performance.dart';
import '../../domain/entities/top_dealer_performance.dart';

// ============================================================
// USE CASES
// ============================================================

import '../../domain/usecases/get_area_performance_usecase.dart';
import '../../domain/usecases/get_daily_performance_usecase.dart';
import '../../domain/usecases/get_expense_performance_usecase.dart';
import '../../domain/usecases/get_hourly_performance_usecase.dart';
import '../../domain/usecases/get_monthly_performance_usecase.dart';
import '../../domain/usecases/get_report_financial_years.dart';
import '../../domain/usecases/get_top_dealer_performance_usecase.dart';

// ============================================================
// BLOC
// ============================================================

import 'monthly_performance_event.dart';
import 'monthly_performance_state.dart';

class MonthlyPerformanceBloc extends Bloc<
    MonthlyPerformanceEvent,
    MonthlyPerformanceState> {
  // ==========================================================
  // USE CASES
  // ==========================================================

  final GetMonthlyPerformanceUseCase
      getMonthlyPerformanceUseCase;

  final GetReportFinancialYears
      getReportFinancialYears;

  final GetDailyPerformanceUseCase
      getDailyPerformanceUseCase;

  final GetHourlyPerformanceUseCase
      getHourlyPerformanceUseCase;

  final GetAreaPerformanceUseCase
      getAreaPerformanceUseCase;

  final GetTopDealerPerformanceUseCase
      getTopDealerPerformanceUseCase;

  final GetExpensePerformanceUseCase
      getExpensePerformanceUseCase;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  MonthlyPerformanceBloc({
    required this.getMonthlyPerformanceUseCase,
    required this.getReportFinancialYears,
    required this.getDailyPerformanceUseCase,
    required this.getHourlyPerformanceUseCase,
    required this.getAreaPerformanceUseCase,
    required this.getTopDealerPerformanceUseCase,
    required this.getExpensePerformanceUseCase,
  }) : super(
          const MonthlyPerformanceState(),
        ) {
    // ========================================================
    // FINANCIAL YEAR
    // ========================================================

    on<GetReportFinancialYearsEvent>(
      _financialYears,
    );

    // ========================================================
    // MONTHLY
    // ========================================================

    on<GetMonthlyPerformanceEvent>(
      _monthlyPerformance,
    );

    // ========================================================
    // DAILY
    // ========================================================

    on<GetDailyPerformanceEvent>(
      _dailyPerformance,
    );

    on<ClearDailyPerformanceEvent>(
      _clearDailyPerformance,
    );

    // ========================================================
    // HOURLY
    // ========================================================

    on<GetHourlyPerformanceEvent>(
      _hourlyPerformance,
    );

    on<ClearHourlyPerformanceEvent>(
      _clearHourlyPerformance,
    );

    // ========================================================
    // AREA
    // ========================================================

    on<GetAreaPerformanceEvent>(
      _areaPerformance,
    );

    on<ClearAreaPerformanceEvent>(
      _clearAreaPerformance,
    );

    // ========================================================
    // TOP DEALER
    // ========================================================

    on<GetTopDealerPerformanceEvent>(
      _topDealerPerformance,
    );

    on<ClearTopDealerPerformanceEvent>(
      _clearTopDealerPerformance,
    );

    // ========================================================
    // EXPENSE
    // ========================================================

    on<GetExpensePerformanceEvent>(
      _expensePerformance,
    );

    on<ClearExpensePerformanceEvent>(
      _clearExpensePerformance,
    );
  }

  // ============================================================
  // FINANCIAL YEAR
  // ============================================================

  Future<void> _financialYears(
    GetReportFinancialYearsEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) async {
    emit(
      state.copyWith(
        financialYearStatus:
            FinancialYearStatus.loading,
        clearFinancialYearError:
            true,
      ),
    );

    try {
      final result =
          await getReportFinancialYears();

      emit(
        state.copyWith(
          financialYearStatus:
              FinancialYearStatus.success,

          financialYears:
              result,

          clearFinancialYearError:
              true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          financialYearStatus:
              FinancialYearStatus.failure,

          financialYearError:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),
        ),
      );
    }
  }

  // ============================================================
  // MONTHLY
  // ============================================================

  Future<void> _monthlyPerformance(
    GetMonthlyPerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) async {
    emit(
      state.copyWith(
        status:
            MonthlyPerformanceStatus.loading,

        clearError:
            true,

        // DAILY
        dailyStatus:
            DailyPerformanceStatus.initial,

        clearDailyReport:
            true,

        clearDailyError:
            true,

        // HOURLY
        hourlyStatus:
            HourlyPerformanceStatus.initial,

        clearHourlyReport:
            true,

        clearHourlyError:
            true,

        // AREA
        areaStatus:
            AreaPerformanceStatus.initial,

        clearAreaReport:
            true,

        clearAreaError:
            true,

        // TOP DEALER
        topDealerStatus:
            TopDealerPerformanceStatus.initial,

        clearTopDealerReport:
            true,

        clearTopDealerError:
            true,

        // EXPENSE
        expenseStatus:
            ExpensePerformanceStatus.initial,

        clearExpenseReport:
            true,

        clearExpenseError:
            true,
      ),
    );

    try {
      final result =
          await getMonthlyPerformanceUseCase(
        employeeId:
            event.employeeId,

        financialYear:
            event.financialYear,
      );

      emit(
        state.copyWith(
          status:
              MonthlyPerformanceStatus.success,

          report:
              result,

          clearError:
              true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status:
              MonthlyPerformanceStatus.failure,

          errorMessage:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),
        ),
      );
    }
  }

  // ============================================================
  // DAILY
  // ============================================================

  Future<void> _dailyPerformance(
    GetDailyPerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) async {
    emit(
      state.copyWith(
        dailyStatus:
            DailyPerformanceStatus.loading,

        clearDailyError:
            true,

        clearDailyReport:
            true,
      ),
    );

    try {
      final DailyPerformance result =
          await getDailyPerformanceUseCase(
        employeeId:
            event.employeeId,

        financialYear:
            event.financialYear,

        selectedMonths:
            event.selectedMonths,
      );

      emit(
        state.copyWith(
          dailyStatus:
              DailyPerformanceStatus.success,

          dailyReport:
              result,

          clearDailyError:
              true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          dailyStatus:
              DailyPerformanceStatus.failure,

          dailyError:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),

          clearDailyReport:
              true,
        ),
      );
    }
  }

  void _clearDailyPerformance(
    ClearDailyPerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) {
    emit(
      state.copyWith(
        dailyStatus:
            DailyPerformanceStatus.initial,

        clearDailyReport:
            true,

        clearDailyError:
            true,
      ),
    );
  }

  // ============================================================
  // HOURLY
  // ============================================================

  Future<void> _hourlyPerformance(
    GetHourlyPerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) async {
    emit(
      state.copyWith(
        hourlyStatus:
            HourlyPerformanceStatus.loading,

        clearHourlyError:
            true,

        clearHourlyReport:
            true,
      ),
    );

    try {
      final HourlyPerformance result =
          await getHourlyPerformanceUseCase(
        employeeId:
            event.employeeId,

        financialYear:
            event.financialYear,

        selectedMonths:
            event.selectedMonths,
      );

      emit(
        state.copyWith(
          hourlyStatus:
              HourlyPerformanceStatus.success,

          hourlyReport:
              result,

          clearHourlyError:
              true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          hourlyStatus:
              HourlyPerformanceStatus.failure,

          hourlyError:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),

          clearHourlyReport:
              true,
        ),
      );
    }
  }

  void _clearHourlyPerformance(
    ClearHourlyPerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) {
    emit(
      state.copyWith(
        hourlyStatus:
            HourlyPerformanceStatus.initial,

        clearHourlyReport:
            true,

        clearHourlyError:
            true,
      ),
    );
  }

  // ============================================================
  // AREA
  // ============================================================

  Future<void> _areaPerformance(
    GetAreaPerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) async {
    emit(
      state.copyWith(
        areaStatus:
            AreaPerformanceStatus.loading,

        clearAreaError:
            true,

        clearAreaReport:
            true,
      ),
    );

    try {
      final AreaPerformance result =
          await getAreaPerformanceUseCase(
        employeeId:
            event.employeeId,

        financialYear:
            event.financialYear,

        selectedMonths:
            event.selectedMonths,
      );

      emit(
        state.copyWith(
          areaStatus:
              AreaPerformanceStatus.success,

          areaReport:
              result,

          clearAreaError:
              true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          areaStatus:
              AreaPerformanceStatus.failure,

          areaError:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),

          clearAreaReport:
              true,
        ),
      );
    }
  }

  void _clearAreaPerformance(
    ClearAreaPerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) {
    emit(
      state.copyWith(
        areaStatus:
            AreaPerformanceStatus.initial,

        clearAreaReport:
            true,

        clearAreaError:
            true,
      ),
    );
  }

  // ============================================================
  // TOP DEALER
  // ============================================================

  Future<void> _topDealerPerformance(
    GetTopDealerPerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) async {
    emit(
      state.copyWith(
        topDealerStatus:
            TopDealerPerformanceStatus.loading,

        clearTopDealerError:
            true,

        clearTopDealerReport:
            true,
      ),
    );

    try {
      final TopDealerPerformance result =
          await getTopDealerPerformanceUseCase(
        employeeId:
            event.employeeId,

        financialYear:
            event.financialYear,

        selectedMonths:
            event.selectedMonths,
      );

      emit(
        state.copyWith(
          topDealerStatus:
              TopDealerPerformanceStatus.success,

          topDealerReport:
              result,

          clearTopDealerError:
              true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          topDealerStatus:
              TopDealerPerformanceStatus.failure,

          topDealerError:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),

          clearTopDealerReport:
              true,
        ),
      );
    }
  }

  void _clearTopDealerPerformance(
    ClearTopDealerPerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) {
    emit(
      state.copyWith(
        topDealerStatus:
            TopDealerPerformanceStatus.initial,

        clearTopDealerReport:
            true,

        clearTopDealerError:
            true,
      ),
    );
  }

  // ============================================================
  // EXPENSE
  // ============================================================

  Future<void> _expensePerformance(
    GetExpensePerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) async {
    emit(
      state.copyWith(
        expenseStatus:
            ExpensePerformanceStatus.loading,

        clearExpenseError:
            true,

        clearExpenseReport:
            true,
      ),
    );

    try {
      final ExpensePerformance result =
          await getExpensePerformanceUseCase(
        employeeId:
            event.employeeId,

        financialYear:
            event.financialYear,

        selectedMonths:
            event.selectedMonths,
      );

      emit(
        state.copyWith(
          expenseStatus:
              ExpensePerformanceStatus.success,

          expenseReport:
              result,

          clearExpenseError:
              true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          expenseStatus:
              ExpensePerformanceStatus.failure,

          expenseError:
              e
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ),

          clearExpenseReport:
              true,
        ),
      );
    }
  }

  void _clearExpensePerformance(
    ClearExpensePerformanceEvent event,
    Emitter<MonthlyPerformanceState> emit,
  ) {
    emit(
      state.copyWith(
        expenseStatus:
            ExpensePerformanceStatus.initial,

        clearExpenseReport:
            true,

        clearExpenseError:
            true,
      ),
    );
  }
}