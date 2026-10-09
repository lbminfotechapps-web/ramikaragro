abstract class CalendarReportEvent {
  const CalendarReportEvent();
}

// ============================================================
// INITIAL / MONTH LOAD
// ============================================================

class LoadCalendarReportEvent
    extends CalendarReportEvent {
  final String userId;

  final DateTime month;

  const LoadCalendarReportEvent({
    required this.userId,
    required this.month,
  });
}

// ============================================================
// PREVIOUS
// ============================================================

class PreviousCalendarMonthEvent
    extends CalendarReportEvent {
  final String userId;

  const PreviousCalendarMonthEvent({
    required this.userId,
  });
}

// ============================================================
// NEXT
// ============================================================

class NextCalendarMonthEvent
    extends CalendarReportEvent {
  final String userId;

  const NextCalendarMonthEvent({
    required this.userId,
  });
}

// ============================================================
// TODAY
// ============================================================

class TodayCalendarEvent
    extends CalendarReportEvent {
  final String userId;

  const TodayCalendarEvent({
    required this.userId,
  });
}