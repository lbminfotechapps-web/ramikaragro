import '../../domain/entities/calendar_day_entity.dart';

enum CalendarReportStatus {
  initial,
  loading,
  success,
  failure,
}

class CalendarReportState {
  final CalendarReportStatus status;

  final DateTime visibleMonth;

  final List<CalendarDayEntity> days;

  final String? errorMessage;

  const CalendarReportState({
    required this.visibleMonth,
    this.status = CalendarReportStatus.initial,
    this.days = const [],
    this.errorMessage,
  });

  CalendarReportState copyWith({
    CalendarReportStatus? status,
    DateTime? visibleMonth,
    List<CalendarDayEntity>? days,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CalendarReportState(
      status:
          status ??
              this.status,

      visibleMonth:
          visibleMonth ??
              this.visibleMonth,

      days:
          days ??
              this.days,

      errorMessage:
          clearError
              ? null
              : errorMessage ??
                  this.errorMessage,
    );
  }
}