import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/core/notifiations/fcm_token_service.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/utility/device_info_util.dart';
import 'package:solufine/features/auth/data/datasource/auth_datasource.dart';
import 'package:solufine/features/auth/data/repoimp/login_repo_imp.dart';
import 'package:solufine/features/auth/domain/repository/login_repo.dart';
import 'package:solufine/features/auth/domain/usecases/login_usecase.dart';
import 'package:solufine/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:solufine/features/auth/provider/auth_provider.dart';

import 'package:get_it/get_it.dart';
final sl = GetIt.instance;

Future<void> initAuthDi() async {
  sl.registerLazySingleton<DioClient>(
    () => DioClient(),
  );

  sl.registerLazySingleton<AuthDatasource>(
    () => AuthDatasource(
      sl<DioClient>(),
    ),
  );

  sl.registerLazySingleton<SecureStorage>(
    () => SecureStorage.instance,
  );

  sl.registerLazySingleton<LoginRepository>(
    () => LoginRepoImp(
      sl<AuthDatasource>(),
      sl<SecureStorage>(),
    ),
  );

  // FCM
  sl.registerLazySingleton<FcmTokenService>(
    () => FcmTokenService.instance,
  );

  // Device Info
  sl.registerLazySingleton<DeviceInfoUtil>(
    () => DeviceInfoUtil.instance,
  );

  // Login Usecase
  sl.registerLazySingleton<LoginUsecase>(
    () => LoginUsecase(
      sl<LoginRepository>(),
      sl<FcmTokenService>(),
      sl<DeviceInfoUtil>(),
    ),
  );

  // Auth Bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      sl<LoginUsecase>(),
    ),
  );

  sl.registerLazySingleton<AuthProvider>(
    () => AuthProvider(),
  );
}