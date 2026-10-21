
import 'package:get_it/get_it.dart';
import 'package:solufine/features/schedule/data/datasources/schedule_list_remote_data_source.dart';
import 'package:solufine/features/schedule/data/repositories/schedule_list_repository_impl.dart';
import 'package:solufine/features/schedule/domain/repositories/schedule_list_repository.dart';
import 'package:solufine/features/schedule/domain/usecases/get_schedule_list.dart';
import 'package:solufine/features/schedule/presentation/bloc/schedule_list_bloc.dart';

import '../api_constant/dio_client.dart';



Future<void> initScheduleListDi() async {
  final sl = GetIt.instance;

  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  if (!sl.isRegistered<ScheduleListRemoteDataSource>()) {
    sl.registerLazySingleton<ScheduleListRemoteDataSource>(
      () => ScheduleListRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  if (!sl.isRegistered<ScheduleListRepository>()) {
    sl.registerLazySingleton<ScheduleListRepository>(
      () => ScheduleListRepositoryImpl(
        remote: sl<ScheduleListRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<GetScheduleList>()) {
    sl.registerLazySingleton<GetScheduleList>(
      () => GetScheduleList(
        sl<ScheduleListRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<SearchScheduleListFarmers>()) {
    sl.registerLazySingleton<SearchScheduleListFarmers>(
      () => SearchScheduleListFarmers(
        sl<ScheduleListRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<ScheduleListBloc>()) {
    sl.registerFactory<ScheduleListBloc>(
      () => ScheduleListBloc(
        getScheduleList: sl<GetScheduleList>(),
        searchFarmers:
            sl<SearchScheduleListFarmers>(),
      ),
    );
  }
}
