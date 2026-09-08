import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/home/data/home_datasource/home_datasource.dart';
import 'package:demo/features/home/data/home_datasource/quick_access_datasource.dart';
import 'package:demo/features/home/data/home_repo_imp/home_repo_imp.dart';
import 'package:demo/features/home/data/home_repo_imp/quick_access_repo_imp.dart';
import 'package:demo/features/home/doman/home_repository/home_repo.dart';
import 'package:demo/features/home/doman/home_repository/qick_access_repo.dart';
import 'package:demo/features/home/doman/home_usecases/get_menu_usecase.dart';
import 'package:demo/features/home/doman/home_usecases/get_punch_status_usecase.dart';
import 'package:demo/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initHomeDi() async {
  // Home Di
  sl.registerLazySingleton<HomeDatasource>(
    () => HomeDatasource(sl<DioClient>()),
  );
  sl.registerLazySingleton<HomeRepo>(() => HomeRepoImp(sl<HomeDatasource>()));

  sl.registerLazySingleton<GetMenuUsecase>(
    () => GetMenuUsecase(sl<HomeRepo>()),
  );
  sl.registerFactory<HomeBloc>(() => HomeBloc(sl<GetMenuUsecase>()));

  // Quick Acces Di

  sl.registerLazySingleton<QuickAccessDatasource>(
    () => QuickAccessDatasource(sl<DioClient>()),
  );

  sl.registerLazySingleton<QickAccessRepo>(
    () => QuickAccessRepoImp(sl<QuickAccessDatasource>()),
  );

  sl.registerLazySingleton<GetPunchStatusUsecase>(
    () => GetPunchStatusUsecase(sl<QickAccessRepo>()),
  );

  sl.registerFactory<QuickAcessBloc>(
    () => QuickAcessBloc(sl<GetPunchStatusUsecase>()),
  );
}
