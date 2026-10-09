import '../entities/calendar_day_entity.dart';
import '../repositories/calendar_report_repository.dart';

class GetCalendarReportUseCase {
  final CalendarReportRepository repository;

  GetCalendarReportUseCase(
    this.repository,
  );

  Future<List<CalendarDayEntity>> call({
    required String userId,
    required String month,
  }) {
    return repository.getCalendarReport(
      userId: userId,
      month: month,
    );
  }
}