import 'package:solufine/features/schedule/data/datasources/farmer_schedule_remote_data_source.dart';
import 'package:get_it/get_it.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/marketing/field_day_visit/data/datasources/field_day_data_source.dart';
import 'package:solufine/features/marketing/field_day_visit/data/repositories/field_day_repository_impl.dart';
import 'package:solufine/features/marketing/field_day_visit/domain/repositories/field_day_repository.dart';
import 'package:solufine/features/marketing/field_day_visit/domain/usecases/field_day_usecases.dart';
import 'package:solufine/features/marketing/field_day_visit/presentation/bloc/field_day_bloc.dart';

final sl = GetIt.instance;
Future<void> initFieldDayDi() async {
  if (!sl.isRegistered<DioClient>())
    sl.registerLazySingleton<DioClient>(() => DioClient());
  if (!sl.isRegistered<FieldDayDataSource>())
    sl.registerLazySingleton<FieldDayDataSource>(
      () => FieldDayDataSource(
        sl<DioClient>(),
        farmerSearch: sl<FarmerScheduleRemoteDataSource>(),
      ),
    );
  if (!sl.isRegistered<FieldDayRepository>())
    sl.registerLazySingleton<FieldDayRepository>(
      () => FieldDayRepositoryImpl(sl<FieldDayDataSource>()),
    );
  if (!sl.isRegistered<SubmitFieldDay>())
    sl.registerLazySingleton<SubmitFieldDay>(
      () => SubmitFieldDay(sl<FieldDayRepository>()),
    );
  if (!sl.isRegistered<SearchFieldDayFarmers>())
    sl.registerLazySingleton<SearchFieldDayFarmers>(
      () => SearchFieldDayFarmers(sl<FieldDayRepository>()),
    );
  if (!sl.isRegistered<FieldDayBloc>())
    sl.registerFactory<FieldDayBloc>(
      () => FieldDayBloc(sl<SubmitFieldDay>(), sl<SearchFieldDayFarmers>()),
    );
}
