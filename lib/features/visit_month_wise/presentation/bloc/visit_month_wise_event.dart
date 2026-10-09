abstract class VisitMonthWiseEvent {
  const VisitMonthWiseEvent();
}

// ============================================================
// MONTH WISE REPORT
// ============================================================

class LoadVisitMonthWiseEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitMonthWiseEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}

// ============================================================
// DAY WISE REPORT
// ============================================================

class LoadVisitDayWiseEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitDayWiseEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}

// ============================================================
// HOUR WISE REPORT
// ============================================================

class LoadVisitHourWiseEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitHourWiseEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}

// ============================================================
// VISIT FREQUENCY REPORT
// ============================================================

class LoadVisitFrequencyEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitFrequencyEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}

// ============================================================
// GEO WISE REPORT
// ============================================================

class LoadVisitGeoWiseEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitGeoWiseEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}

// ============================================================
// TOP DEALER / FARMER LIST
// ============================================================

class LoadVisitTopListEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitTopListEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}

// ============================================================
// TOP EMPLOYEE REPORT
// ============================================================

class LoadVisitTopEmployeeEvent extends VisitMonthWiseEvent {
  final String fromDate;
  final String toDate;
  final String employeeId;

  const LoadVisitTopEmployeeEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
  });
}

// ============================================================
// EMPLOYEE SEARCH
// ============================================================

class SearchVisitReportEmployeesEvent extends VisitMonthWiseEvent {
  final String userId;
  final String searchText;

  const SearchVisitReportEmployeesEvent({
    required this.userId,
    required this.searchText,
  });
}

// ============================================================
// CLEAR EMPLOYEE
// ============================================================

class ClearVisitReportEmployeesEvent extends VisitMonthWiseEvent {
  const ClearVisitReportEmployeesEvent();
}
