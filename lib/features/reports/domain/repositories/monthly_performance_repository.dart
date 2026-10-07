import 'package:solufine/features/reports/domain/entities/area_performance.dart';
import 'package:solufine/features/reports/domain/entities/expense_performance.dart';
import 'package:solufine/features/reports/domain/entities/hourly_performance.dart';
import 'package:solufine/features/reports/domain/entities/top_dealer_performance.dart';

import '../entities/daily_performance.dart';
import '../entities/monthly_performance.dart';
import '../entities/report_financial_year.dart';

abstract class MonthlyPerformanceRepository {
  // ============================================================
  // FINANCIAL YEAR
  // ============================================================

  Future<List<ReportFinancialYear>>
      getReportFinancialYears();

  // ============================================================
  // MONTHLY PERFORMANCE
  // ============================================================

  Future<MonthlyPerformance>
      getMonthlyPerformance({
    required String employeeId,
    required String financialYear,
  });

  // ============================================================
  // DAILY PERFORMANCE
  // ============================================================

  Future<DailyPerformance>
      getDailyPerformance({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  });


  Future<HourlyPerformance>
      getHourlyPerformance({
    required String employeeId,
    required String financialYear,
    required String selectedMonths,
  });

  Future<AreaPerformance> getAreaPerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
});

Future<TopDealerPerformance>
    getTopDealerPerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
});

Future<ExpensePerformance>
    getExpensePerformance({
  required String employeeId,
  required String financialYear,
  required String selectedMonths,
});

}