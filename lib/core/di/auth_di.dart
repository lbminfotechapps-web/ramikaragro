import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/notifiations/fcm_token_service.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/features/auth/data/datasource/auth_datasource.dart';
import 'package:demo/features/auth/data/repoimp/login_repo_imp.dart';
import 'package:demo/features/auth/domain/repository/login_repo.dart';
import 'package:demo/features/auth/domain/usecases/login_usecase.dart';
import 'package:demo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:demo/features/auth/provider/auth_provider.dart';

import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initAuthDi() async {
  sl.registerLazySingleton<DioClient>(() => DioClient());

  sl.registerLazySingleton<AuthDatasource>(
    () => AuthDatasource(sl<DioClient>()),
  );

  sl.registerLazySingleton<SecureStorage>(() => SecureStorage.instance);

  sl.registerLazySingleton<LoginRepository>(
    () => LoginRepoImp(sl<AuthDatasource>(), sl<SecureStorage>()),
  );
  sl.registerLazySingleton<FcmTokenService>(() => FcmTokenService.instance);

  sl.registerLazySingleton<LoginUsecase>(
    () => LoginUsecase(sl<LoginRepository>(), sl<FcmTokenService>()),
  );

  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<LoginUsecase>()));
  sl.registerLazySingleton<AuthProvider>(() => AuthProvider());
}
