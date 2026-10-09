import '../../domain/entities/area_performance.dart';
import '../../domain/entities/daily_performance.dart';
import '../../domain/entities/expense_performance.dart';
import '../../domain/entities/hourly_performance.dart';
import '../../domain/entities/monthly_performance.dart';
import '../../domain/entities/report_financial_year.dart';
import '../../domain/entities/top_dealer_performance.dart';

// ============================================================
// APPLICATION PHASE
// ============================================================

enum ApplicationPhaseStatus {
  initial,
  loading,
  success,
  failure,
}

// ============================================================
// MONTHLY
// ============================================================

enum MonthlyPerformanceStatus {
  initial,
  loading,
  success,
  failure,
}

// ============================================================
// FINANCIAL YEAR
// ============================================================

enum FinancialYearStatus {
  initial,
  loading,
  success,
  failure,
}

// ============================================================
// DAILY
// ============================================================

enum DailyPerformanceStatus {
  initial,
  loading,
  success,
  failure,
}

// ============================================================
// HOURLY
// ============================================================

enum HourlyPerformanceStatus {
  initial,
  loading,
  success,
  failure,
}

// ============================================================
// AREA
// ============================================================

enum AreaPerformanceStatus {
  initial,
  loading,
  success,
  failure,
}

// ============================================================
// TOP DEALER
// ============================================================

enum TopDealerPerformanceStatus {
  initial,
  loading,
  success,
  failure,
}

// ============================================================
// EXPENSE
// ============================================================

enum ExpensePerformanceStatus {
  initial,
  loading,
  success,
  failure,
}

// ============================================================
// STATE
// ============================================================

class MonthlyPerformanceState {
  // ==========================================================
  // APPLICATION PHASE
  // ==========================================================

  final ApplicationPhaseStatus
      applicationPhaseStatus;

  final int applicationPhase;

  final String? applicationPhaseError;

  // ==========================================================
  // MONTHLY
  // ==========================================================

  final MonthlyPerformanceStatus status;

  final MonthlyPerformance? report;

  final String? errorMessage;

  // ==========================================================
  // FINANCIAL YEAR
  // ==========================================================

  final FinancialYearStatus financialYearStatus;

  final List<ReportFinancialYear> financialYears;

  final String? financialYearError;

  // ==========================================================
  // DAILY
  // ==========================================================

  final DailyPerformanceStatus dailyStatus;

  final DailyPerformance? dailyReport;

  final String? dailyError;

  // ==========================================================
  // HOURLY
  // ==========================================================

  final HourlyPerformanceStatus hourlyStatus;

  final HourlyPerformance? hourlyReport;

  final String? hourlyError;

  // ==========================================================
  // AREA
  // ==========================================================

  final AreaPerformanceStatus areaStatus;

  final AreaPerformance? areaReport;

  final String? areaError;

  // ==========================================================
  // TOP DEALER
  // ==========================================================

  final TopDealerPerformanceStatus
      topDealerStatus;

  final TopDealerPerformance?
      topDealerReport;

  final String? topDealerError;

  // ==========================================================
  // EXPENSE
  // ==========================================================

  final ExpensePerformanceStatus expenseStatus;

  final ExpensePerformance?
      expenseReport;

  final String? expenseError;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const MonthlyPerformanceState({
    // APPLICATION PHASE
    this.applicationPhaseStatus =
        ApplicationPhaseStatus.initial,

    this.applicationPhase = 0,

    this.applicationPhaseError,

    // MONTHLY
    this.status =
        MonthlyPerformanceStatus.initial,

    this.report,

    this.errorMessage,

    // FINANCIAL YEAR
    this.financialYearStatus =
        FinancialYearStatus.initial,

    this.financialYears = const [],

    this.financialYearError,

    // DAILY
    this.dailyStatus =
        DailyPerformanceStatus.initial,

    this.dailyReport,

    this.dailyError,

    // HOURLY
    this.hourlyStatus =
        HourlyPerformanceStatus.initial,

    this.hourlyReport,

    this.hourlyError,

    // AREA
    this.areaStatus =
        AreaPerformanceStatus.initial,

    this.areaReport,

    this.areaError,

    // TOP DEALER
    this.topDealerStatus =
        TopDealerPerformanceStatus.initial,

    this.topDealerReport,

    this.topDealerError,

    // EXPENSE
    this.expenseStatus =
        ExpensePerformanceStatus.initial,

    this.expenseReport,

    this.expenseError,
  });

  // ==========================================================
  // HELPER
  // ==========================================================

  bool get isVisitOnlyPhase {
    return applicationPhase == 1;
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================

  MonthlyPerformanceState copyWith({
    // ========================================================
    // APPLICATION PHASE
    // ========================================================

    ApplicationPhaseStatus?
        applicationPhaseStatus,

    int? applicationPhase,

    String?
        applicationPhaseError,

    bool clearApplicationPhaseError =
        false,

    // ========================================================
    // MONTHLY
    // ========================================================

    MonthlyPerformanceStatus? status,

    MonthlyPerformance? report,

    String? errorMessage,

    bool clearError = false,

    bool clearReport = false,

    // ========================================================
    // FINANCIAL YEAR
    // ========================================================

    FinancialYearStatus?
        financialYearStatus,

    List<ReportFinancialYear>?
        financialYears,

    String? financialYearError,

    bool clearFinancialYearError =
        false,

    // ========================================================
    // DAILY
    // ========================================================

    DailyPerformanceStatus?
        dailyStatus,

    DailyPerformance?
        dailyReport,

    String? dailyError,

    bool clearDailyError =
        false,

    bool clearDailyReport =
        false,

    // ========================================================
    // HOURLY
    // ========================================================

    HourlyPerformanceStatus?
        hourlyStatus,

    HourlyPerformance?
        hourlyReport,

    String? hourlyError,

    bool clearHourlyError =
        false,

    bool clearHourlyReport =
        false,

    // ========================================================
    // AREA
    // ========================================================

    AreaPerformanceStatus?
        areaStatus,

    AreaPerformance?
        areaReport,

    String? areaError,

    bool clearAreaError =
        false,

    bool clearAreaReport =
        false,

    // ========================================================
    // TOP DEALER
    // ========================================================

    TopDealerPerformanceStatus?
        topDealerStatus,

    TopDealerPerformance?
        topDealerReport,

    String? topDealerError,

    bool clearTopDealerError =
        false,

    bool clearTopDealerReport =
        false,

    // ========================================================
    // EXPENSE
    // ========================================================

    ExpensePerformanceStatus?
        expenseStatus,

    ExpensePerformance?
        expenseReport,

    String? expenseError,

    bool clearExpenseError =
        false,

    bool clearExpenseReport =
        false,
  }) {
    return MonthlyPerformanceState(
      // ======================================================
      // APPLICATION PHASE
      // ======================================================

      applicationPhaseStatus:
          applicationPhaseStatus ??
              this.applicationPhaseStatus,

      applicationPhase:
          applicationPhase ??
              this.applicationPhase,

      applicationPhaseError:
          clearApplicationPhaseError
              ? null
              : applicationPhaseError ??
                  this.applicationPhaseError,

      // ======================================================
      // MONTHLY
      // ======================================================

      status:
          status ??
              this.status,

      report:
          clearReport
              ? null
              : report ??
                  this.report,

      errorMessage:
          clearError
              ? null
              : errorMessage ??
                  this.errorMessage,

      // ======================================================
      // FINANCIAL YEAR
      // ======================================================

      financialYearStatus:
          financialYearStatus ??
              this.financialYearStatus,

      financialYears:
          financialYears ??
              this.financialYears,

      financialYearError:
          clearFinancialYearError
              ? null
              : financialYearError ??
                  this.financialYearError,

      // ======================================================
      // DAILY
      // ======================================================

      dailyStatus:
          dailyStatus ??
              this.dailyStatus,

      dailyReport:
          clearDailyReport
              ? null
              : dailyReport ??
                  this.dailyReport,

      dailyError:
          clearDailyError
              ? null
              : dailyError ??
                  this.dailyError,

      // ======================================================
      // HOURLY
      // ======================================================

      hourlyStatus:
          hourlyStatus ??
              this.hourlyStatus,

      hourlyReport:
          clearHourlyReport
              ? null
              : hourlyReport ??
                  this.hourlyReport,

      hourlyError:
          clearHourlyError
              ? null
              : hourlyError ??
                  this.hourlyError,

      // ======================================================
      // AREA
      // ======================================================

      areaStatus:
          areaStatus ??
              this.areaStatus,

      areaReport:
          clearAreaReport
              ? null
              : areaReport ??
                  this.areaReport,

      areaError:
          clearAreaError
              ? null
              : areaError ??
                  this.areaError,

      // ======================================================
      // TOP DEALER
      // ======================================================

      topDealerStatus:
          topDealerStatus ??
              this.topDealerStatus,

      topDealerReport:
          clearTopDealerReport
              ? null
              : topDealerReport ??
                  this.topDealerReport,

      topDealerError:
          clearTopDealerError
              ? null
              : topDealerError ??
                  this.topDealerError,

      // ======================================================
      // EXPENSE
      // ======================================================

      expenseStatus:
          expenseStatus ??
              this.expenseStatus,

      expenseReport:
          clearExpenseReport
              ? null
              : expenseReport ??
                  this.expenseReport,

      expenseError:
          clearExpenseError
              ? null
              : expenseError ??
                  this.expenseError,
    );
  }
}