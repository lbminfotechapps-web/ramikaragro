import '../../domain/entities/visit_day_wise.dart';
import '../../domain/entities/visit_frequency.dart';
import '../../domain/entities/visit_geo_wise.dart';
import '../../domain/entities/visit_hour_wise.dart';
import '../../domain/entities/visit_month_wise.dart';
import '../../domain/entities/visit_report_employee.dart';
import '../../domain/entities/visit_top_employee.dart';
import '../../domain/entities/visit_top_list.dart';

// ============================================================
// MONTH WISE STATUS
// ============================================================

enum VisitMonthWiseStatus { initial, loading, success, failure }

// ============================================================
// DAY WISE STATUS
// ============================================================

enum VisitDayWiseStatus { initial, loading, success, failure }

// ============================================================
// HOUR WISE STATUS
// ============================================================

enum VisitHourWiseStatus { initial, loading, success, failure }

// ============================================================
// FREQUENCY STATUS
// ============================================================

enum VisitFrequencyStatus { initial, loading, success, failure }

// ============================================================
// GEO WISE STATUS
// ============================================================

enum VisitGeoWiseStatus { initial, loading, success, failure }

// ============================================================
// TOP DEALER / FARMER STATUS
// ============================================================

enum VisitTopListStatus { initial, loading, success, failure }

// ============================================================
// TOP EMPLOYEE STATUS
// ============================================================

enum VisitTopEmployeeStatus { initial, loading, success, failure }

// ============================================================
// EMPLOYEE SEARCH STATUS
// ============================================================

enum VisitReportEmployeeStatus { initial, loading, success, failure }

// ============================================================
// STATE
// ============================================================

class VisitMonthWiseState {
  // ==========================================================
  // MONTH
  // ==========================================================

  final VisitMonthWiseStatus status;

  final VisitMonthWiseReport? report;

  final String? errorMessage;

  // ==========================================================
  // DAY
  // ==========================================================

  final VisitDayWiseStatus dayWiseStatus;

  final VisitDayWiseReport? dayWiseReport;

  final String? dayWiseError;

  // ==========================================================
  // HOUR
  // ==========================================================

  final VisitHourWiseStatus hourWiseStatus;

  final VisitHourWiseReport? hourWiseReport;

  final String? hourWiseError;

  // ==========================================================
  // FREQUENCY
  // ==========================================================

  final VisitFrequencyStatus frequencyStatus;

  final VisitFrequencyReport? frequencyReport;

  final String? frequencyError;

  // ==========================================================
  // GEO
  // ==========================================================

  final VisitGeoWiseStatus geoWiseStatus;

  final VisitGeoWiseReport? geoWiseReport;

  final String? geoWiseError;

  // ==========================================================
  // TOP DEALER / FARMER
  // ==========================================================

  final VisitTopListStatus topListStatus;

  final VisitTopListReport? topListReport;

  final String? topListError;

  // ==========================================================
  // TOP EMPLOYEE
  // ==========================================================

  final VisitTopEmployeeStatus topEmployeeStatus;

  final VisitTopEmployeeReport? topEmployeeReport;

  final String? topEmployeeError;

  // ==========================================================
  // EMPLOYEE SEARCH
  // ==========================================================

  final VisitReportEmployeeStatus employeeStatus;

  final List<VisitReportEmployee> employees;

  final String? employeeError;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const VisitMonthWiseState({
    // MONTH
    this.status = VisitMonthWiseStatus.initial,
    this.report,
    this.errorMessage,

    // DAY
    this.dayWiseStatus = VisitDayWiseStatus.initial,
    this.dayWiseReport,
    this.dayWiseError,

    // HOUR
    this.hourWiseStatus = VisitHourWiseStatus.initial,
    this.hourWiseReport,
    this.hourWiseError,

    // FREQUENCY
    this.frequencyStatus = VisitFrequencyStatus.initial,
    this.frequencyReport,
    this.frequencyError,

    // GEO
    this.geoWiseStatus = VisitGeoWiseStatus.initial,
    this.geoWiseReport,
    this.geoWiseError,

    // TOP LIST
    this.topListStatus = VisitTopListStatus.initial,
    this.topListReport,
    this.topListError,

    // TOP EMPLOYEE
    this.topEmployeeStatus = VisitTopEmployeeStatus.initial,
    this.topEmployeeReport,
    this.topEmployeeError,

    // EMPLOYEE
    this.employeeStatus = VisitReportEmployeeStatus.initial,
    this.employees = const [],
    this.employeeError,
  });

  // ==========================================================
  // COPY WITH
  // ==========================================================

  VisitMonthWiseState copyWith({
    // ========================================================
    // MONTH
    // ========================================================

    VisitMonthWiseStatus? status,

    VisitMonthWiseReport? report,

    String? errorMessage,

    bool clearReport = false,

    bool clearError = false,

    // ========================================================
    // DAY
    // ========================================================
    VisitDayWiseStatus? dayWiseStatus,

    VisitDayWiseReport? dayWiseReport,

    String? dayWiseError,

    bool clearDayWiseReport = false,

    bool clearDayWiseError = false,

    // ========================================================
    // HOUR
    // ========================================================
    VisitHourWiseStatus? hourWiseStatus,

    VisitHourWiseReport? hourWiseReport,

    String? hourWiseError,

    bool clearHourWiseReport = false,

    bool clearHourWiseError = false,

    // ========================================================
    // FREQUENCY
    // ========================================================
    VisitFrequencyStatus? frequencyStatus,

    VisitFrequencyReport? frequencyReport,

    String? frequencyError,

    bool clearFrequencyReport = false,

    bool clearFrequencyError = false,

    // ========================================================
    // GEO
    // ========================================================
    VisitGeoWiseStatus? geoWiseStatus,

    VisitGeoWiseReport? geoWiseReport,

    String? geoWiseError,

    bool clearGeoWiseReport = false,

    bool clearGeoWiseError = false,

    // ========================================================
    // TOP LIST
    // ========================================================
    VisitTopListStatus? topListStatus,

    VisitTopListReport? topListReport,

    String? topListError,

    bool clearTopListReport = false,

    bool clearTopListError = false,

    // ========================================================
    // TOP EMPLOYEE
    // ========================================================
    VisitTopEmployeeStatus? topEmployeeStatus,

    VisitTopEmployeeReport? topEmployeeReport,

    String? topEmployeeError,

    bool clearTopEmployeeReport = false,

    bool clearTopEmployeeError = false,

    // ========================================================
    // EMPLOYEE
    // ========================================================
    VisitReportEmployeeStatus? employeeStatus,

    List<VisitReportEmployee>? employees,

    String? employeeError,

    bool clearEmployees = false,

    bool clearEmployeeError = false,
  }) {
    return VisitMonthWiseState(
      // ======================================================
      // MONTH
      // ======================================================

      status: status ?? this.status,

      report: clearReport ? null : report ?? this.report,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,

      // ======================================================
      // DAY
      // ======================================================
      dayWiseStatus: dayWiseStatus ?? this.dayWiseStatus,

      dayWiseReport: clearDayWiseReport
          ? null
          : dayWiseReport ?? this.dayWiseReport,

      dayWiseError: clearDayWiseError
          ? null
          : dayWiseError ?? this.dayWiseError,

      // ======================================================
      // HOUR
      // ======================================================
      hourWiseStatus: hourWiseStatus ?? this.hourWiseStatus,

      hourWiseReport: clearHourWiseReport
          ? null
          : hourWiseReport ?? this.hourWiseReport,

      hourWiseError: clearHourWiseError
          ? null
          : hourWiseError ?? this.hourWiseError,

      // ======================================================
      // FREQUENCY
      // ======================================================
      frequencyStatus: frequencyStatus ?? this.frequencyStatus,

      frequencyReport: clearFrequencyReport
          ? null
          : frequencyReport ?? this.frequencyReport,

      frequencyError: clearFrequencyError
          ? null
          : frequencyError ?? this.frequencyError,

      // ======================================================
      // GEO
      // ======================================================
      geoWiseStatus: geoWiseStatus ?? this.geoWiseStatus,

      geoWiseReport: clearGeoWiseReport
          ? null
          : geoWiseReport ?? this.geoWiseReport,

      geoWiseError: clearGeoWiseError
          ? null
          : geoWiseError ?? this.geoWiseError,

      // ======================================================
      // TOP LIST
      // ======================================================
      topListStatus: topListStatus ?? this.topListStatus,

      topListReport: clearTopListReport
          ? null
          : topListReport ?? this.topListReport,

      topListError: clearTopListError
          ? null
          : topListError ?? this.topListError,

      // ======================================================
      // TOP EMPLOYEE
      // ======================================================
      topEmployeeStatus: topEmployeeStatus ?? this.topEmployeeStatus,

      topEmployeeReport: clearTopEmployeeReport
          ? null
          : topEmployeeReport ?? this.topEmployeeReport,

      topEmployeeError: clearTopEmployeeError
          ? null
          : topEmployeeError ?? this.topEmployeeError,

      // ======================================================
      // EMPLOYEE
      // ======================================================
      employeeStatus: employeeStatus ?? this.employeeStatus,

      employees: clearEmployees ? const [] : employees ?? this.employees,

      employeeError: clearEmployeeError
          ? null
          : employeeError ?? this.employeeError,
    );
  }
}
