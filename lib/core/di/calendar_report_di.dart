

// Import your existing global service locator here.
// Example:
//
// import '../../../core/di/injection_container.dart';

import 'package:solufine/core/di/ai_di.dart';
import 'package:solufine/features/calendar_report/data/datasources/calendar_report_remote_datasource.dart';
import 'package:solufine/features/calendar_report/data/repositories/calendar_report_repository_impl.dart';
import 'package:solufine/features/calendar_report/domain/repositories/calendar_report_repository.dart';
import 'package:solufine/features/calendar_report/domain/usecases/get_calendar_report_usecase.dart';
import 'package:solufine/features/calendar_report/presentation/bloc/calendar_report_bloc.dart';

Future<void> initCalendarReportDi() async {
  // ==========================================================
  // REMOTE DATASOURCE
  // ==========================================================

  if (!sl.isRegistered<
      CalendarReportRemoteDataSource>()) {
    sl.registerLazySingleton<
        CalendarReportRemoteDataSource>(
      () =>
          CalendarReportRemoteDataSourceImpl(
        dioClient:
            sl(),
      ),
    );
  }

  // ==========================================================
  // REPOSITORY
  // ==========================================================

  if (!sl.isRegistered<
      CalendarReportRepository>()) {
    sl.registerLazySingleton<
        CalendarReportRepository>(
      () =>
          CalendarReportRepositoryImpl(
        remoteDataSource:
            sl<
                CalendarReportRemoteDataSource>(),
      ),
    );
  }

  // ==========================================================
  // USE CASE
  // ==========================================================

  if (!sl.isRegistered<
      GetCalendarReportUseCase>()) {
    sl.registerLazySingleton<
        GetCalendarReportUseCase>(
      () =>
          GetCalendarReportUseCase(
        sl<
            CalendarReportRepository>(),
      ),
    );
  }

  // ==========================================================
  // BLOC
  // ==========================================================

  if (!sl.isRegistered<
      CalendarReportBloc>()) {
    sl.registerFactory<
        CalendarReportBloc>(
      () =>
          CalendarReportBloc(
        getCalendarReportUseCase:
            sl<
                GetCalendarReportUseCase>(),
      ),
    );
  }
}