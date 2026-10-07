abstract class MonthlyPerformanceEvent {
  const MonthlyPerformanceEvent();
}

// ============================================================
// FINANCIAL YEAR
// ============================================================

class GetReportFinancialYearsEvent
    extends MonthlyPerformanceEvent {
  const GetReportFinancialYearsEvent();
}

// ============================================================
// MONTHLY
// ============================================================

class GetMonthlyPerformanceEvent
    extends MonthlyPerformanceEvent {
  final String employeeId;
  final String financialYear;

  const GetMonthlyPerformanceEvent({
    required this.employeeId,
    required this.financialYear,
  });
}

// ============================================================
// DAILY
// ============================================================

class GetDailyPerformanceEvent
    extends MonthlyPerformanceEvent {
  final String employeeId;
  final String financialYear;
  final String selectedMonths;

  const GetDailyPerformanceEvent({
    required this.employeeId,
    required this.financialYear,
    required this.selectedMonths,
  });
}

class ClearDailyPerformanceEvent
    extends MonthlyPerformanceEvent {
  const ClearDailyPerformanceEvent();
}

// ============================================================
// HOURLY
// ============================================================

class GetHourlyPerformanceEvent
    extends MonthlyPerformanceEvent {
  final String employeeId;
  final String financialYear;
  final String selectedMonths;

  const GetHourlyPerformanceEvent({
    required this.employeeId,
    required this.financialYear,
    required this.selectedMonths,
  });
}

class ClearHourlyPerformanceEvent
    extends MonthlyPerformanceEvent {
  const ClearHourlyPerformanceEvent();
}

// ============================================================
// AREA
// ============================================================

class GetAreaPerformanceEvent
    extends MonthlyPerformanceEvent {
  final String employeeId;
  final String financialYear;
  final String selectedMonths;

  const GetAreaPerformanceEvent({
    required this.employeeId,
    required this.financialYear,
    required this.selectedMonths,
  });
}

class ClearAreaPerformanceEvent
    extends MonthlyPerformanceEvent {
  const ClearAreaPerformanceEvent();
}

// ============================================================
// TOP DEALER
// ============================================================

class GetTopDealerPerformanceEvent
    extends MonthlyPerformanceEvent {
  final String employeeId;
  final String financialYear;
  final String selectedMonths;

  const GetTopDealerPerformanceEvent({
    required this.employeeId,
    required this.financialYear,
    required this.selectedMonths,
  });
}

class ClearTopDealerPerformanceEvent
    extends MonthlyPerformanceEvent {
  const ClearTopDealerPerformanceEvent();
}

// ============================================================
// EXPENSE
// ============================================================

class GetExpensePerformanceEvent
    extends MonthlyPerformanceEvent {
  final String employeeId;
  final String financialYear;
  final String selectedMonths;

  const GetExpensePerformanceEvent({
    required this.employeeId,
    required this.financialYear,
    required this.selectedMonths,
  });
}

// ============================================================
// CLEAR EXPENSE
// ============================================================

class ClearExpensePerformanceEvent
    extends MonthlyPerformanceEvent {
  const ClearExpensePerformanceEvent();
}