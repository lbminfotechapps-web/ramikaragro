import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/features/leave/data/datasources/top_ten_dealer_remote_data_source.dart';
import 'package:demo/features/leave/data/repositories/top_ten_dealer_repository_impl.dart';
import 'package:demo/features/leave/domain/repositories/top_ten_dealer_repository.dart';
import 'package:demo/features/leave/domain/usecases/get_top_ten_dealer.dart';
import 'package:demo/features/leave/presentation/bloc/top_ten_dealer_bloc.dart';

import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> initTopTenDealerDi() async {
  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(
      () => SecureStorage.instance,
    );
  }

  if (!sl.isRegistered<TopTenDealerRemoteDataSource>()) {
    sl.registerLazySingleton<
        TopTenDealerRemoteDataSource>(
      () => TopTenDealerRemoteDataSourceImpl(
        dioClient: DioClient(),
      ),
    );
  }

  if (!sl.isRegistered<TopTenDealerRepository>()) {
    sl.registerLazySingleton<
        TopTenDealerRepository>(
      () => TopTenDealerRepositoryImpl(
        remoteDataSource:
            sl<TopTenDealerRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<GetTopTenDealer>()) {
    sl.registerLazySingleton<GetTopTenDealer>(
      () => GetTopTenDealer(
        sl<TopTenDealerRepository>(),
      ),
    );
  }

  sl.registerFactory<TopTenDealerBloc>(
    () => TopTenDealerBloc(
      getTopTenDealer:
          sl<GetTopTenDealer>(),
      secureStorage:
          sl<SecureStorage>(),
    ),
  );
}