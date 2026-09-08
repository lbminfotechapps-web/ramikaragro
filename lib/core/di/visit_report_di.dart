import 'package:get_it/get_it.dart';

import 'package:demo/core/api_constant/dio_client.dart';

import 'package:demo/features/reports/data/datasources/visit_report_remote_data_source.dart';
import 'package:demo/features/reports/data/repositories/visit_report_repository_impl.dart';

import 'package:demo/features/reports/domain/repositories/visit_report_repository.dart';
import 'package:demo/features/reports/domain/usecases/get_visit_report.dart';

import 'package:demo/features/reports/presentation/bloc/visit_report_bloc.dart';

final sl = GetIt.instance;

Future<void> initVisitReportDi() async {
  // =========================================================
  // VISIT REPORT
  // =========================================================

  sl.registerLazySingleton<VisitReportRemoteDataSource>(
    () => VisitReportRemoteDataSource(
      sl<DioClient>(),
    ),
  );

  sl.registerLazySingleton<VisitReportRepository>(
    () => VisitReportRepositoryImpl(
      sl<VisitReportRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetVisitReport>(
    () => GetVisitReport(
      sl<VisitReportRepository>(),
    ),
  );

  sl.registerFactory<VisitReportBloc>(
    () => VisitReportBloc(
      sl<GetVisitReport>(),
    ),
  );
}