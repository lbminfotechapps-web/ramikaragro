
import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';

import 'package:solufine/features/schedule/data/datasources/add_schedule_remote_data_source.dart';
import 'package:solufine/features/schedule/data/repositories/add_schedule_repository_impl.dart';
import 'package:solufine/features/schedule/domain/repositories/add_schedule_repository.dart';
import 'package:solufine/features/schedule/domain/usecases/submit_add_schedule.dart';
import 'package:solufine/features/schedule/presentation/bloc/add_schedule_submit_bloc.dart';

Future<void> initAddScheduleDi() async {
  final sl = GetIt.instance;

  // Reuse the DioClient registered by your main app.
  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  if (!sl.isRegistered<AddScheduleRemoteDataSource>()) {
    sl.registerLazySingleton<AddScheduleRemoteDataSource>(
      () => AddScheduleRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  if (!sl.isRegistered<AddScheduleRepository>()) {
    sl.registerLazySingleton<AddScheduleRepository>(
      () => AddScheduleRepositoryImpl(
        remote: sl<AddScheduleRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<SubmitAddSchedule>()) {
    sl.registerLazySingleton<SubmitAddSchedule>(
      () => SubmitAddSchedule(
        sl<AddScheduleRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<AddScheduleSubmitBloc>()) {
    sl.registerFactory<AddScheduleSubmitBloc>(
      () => AddScheduleSubmitBloc(
        submitAddSchedule: sl<SubmitAddSchedule>(),
      ),
    );
  }
}
