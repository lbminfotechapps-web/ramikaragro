import '../entities/calendar_day_entity.dart';

abstract class CalendarReportRepository {
  Future<List<CalendarDayEntity>>
      getCalendarReport({
    required String userId,
    required String month,
  });
}