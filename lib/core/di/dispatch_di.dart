import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/distpatchistory/data/datasource/dispatch_remote_datasource.dart';
import 'package:solufine/features/distpatchistory/data/repoimp/dispatch_repository_impl.dart';
import 'package:solufine/features/distpatchistory/domain/repository/dispatch_repository.dart';
import 'package:solufine/features/distpatchistory/domain/usecases/get_dispatch_list_usecase.dart';
import 'package:solufine/features/distpatchistory/presentation/bloc/dispatch_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDispatchDi() async {
  // =========================================================
  // DISPATCH
  // =========================================================

  sl.registerLazySingleton<DispatchRemoteDataSource>(
    () => DispatchRemoteDataSource(sl<DioClient>().client),
  );

  sl.registerLazySingleton<DispatchRepository>(
    () => DispatchRepositoryImpl(sl<DispatchRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetDispatchListUseCase>(
    () => GetDispatchListUseCase(sl<DispatchRepository>()),
  );

  sl.registerFactory<DispatchBloc>(
    () => DispatchBloc(getDispatchListUseCase: sl<GetDispatchListUseCase>()),
  );
}
