import 'package:solufine/features/reports/domain/entities/area_performance.dart';
import 'package:solufine/features/reports/domain/entities/expense_performance.dart';
import 'package:solufine/features/reports/domain/entities/top_dealer_performance.dart';

import '../../domain/entities/daily_performance.dart';
import '../../domain/entities/hourly_performance.dart';
import '../../domain/entities/monthly_performance.dart';
import '../../domain/entities/report_financial_year.dart';

import '../../domain/repositories/monthly_performance_repository.dart';

import '../datasources/monthly_performance_remote_datasource.dart';

class MonthlyPerformanceRepositoryImpl
    implements MonthlyPerformanceRepository {
  final MonthlyPerformanceRemoteDataSource
      remoteDataSource;

  MonthlyPerformanceRepositoryImpl({
    required this.remoteDataSource,
  });

  // ============================================================
  // FINANCIAL YEARS
  // ============================================================

  @override
  Future<List<ReportFinancialYear>>
      getReportFinancialYears() {
    return remoteDataSource
        .getReportFinancialYears();
  }

  // ============================================================
  // MONTHLY PERFORMANCE
  // ============================================================

  @override
  Future<MonthlyPerformance>
      getMonthlyPerformance({
    required String employeeId,
    required String financialYear,
  }) {
    return remoteDataSource
        .getMonthlyPerformance(
      employeeId:
          employeeId,

      financialYear:
          financialYear,
    );
  }

  // ============================================================
  // DAILY PERFORMANCE
  // ============================================================

  @override
  Future<DailyPerformance>
      getDailyPerformance({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  }) {
    return remoteDataSource
        .getDailyPerformance(
      employeeId:
          employeeId,

      financialYear:
          financialYear,

      selectedMonths:
          selectedMonths,
    );
  }

  // ============================================================
  // HOURLY PERFORMANCE
  // ============================================================

  @override
  Future<HourlyPerformance>
      getHourlyPerformance({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  }) {
    return remoteDataSource
        .getHourlyPerformance(
      employeeId:
          employeeId,

      financialYear:
          financialYear,

      selectedMonths:
          selectedMonths,
    );
  }

@override
Future<AreaPerformance>
    getAreaPerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
}) {
  return remoteDataSource
      .getAreaPerformance(
    employeeId: employeeId,
    financialYear: financialYear,
    selectedMonths: selectedMonths,
  );
}


@override
Future<TopDealerPerformance>
    getTopDealerPerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
}) {
  return remoteDataSource.getTopDealerPerformance(
    employeeId: employeeId,
    financialYear: financialYear,
    selectedMonths: selectedMonths,
  );
}


@override
Future<ExpensePerformance>
    getExpensePerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
}) {
  return remoteDataSource
      .getExpensePerformance(
    employeeId:
        employeeId,
    financialYear:
        financialYear,
    selectedMonths:
        selectedMonths,
  );
}



}