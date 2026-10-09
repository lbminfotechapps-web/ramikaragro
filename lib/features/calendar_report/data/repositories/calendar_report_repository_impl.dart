import '../../domain/entities/calendar_day_entity.dart';
import '../../domain/repositories/calendar_report_repository.dart';

import '../datasources/calendar_report_remote_datasource.dart';

class CalendarReportRepositoryImpl
    implements CalendarReportRepository {
  final CalendarReportRemoteDataSource
      remoteDataSource;

  CalendarReportRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<CalendarDayEntity>>
      getCalendarReport({
    required String userId,
    required String month,
  }) {
    return remoteDataSource
        .getCalendarReport(
      userId: userId,
      month: month,
    );
  }
}