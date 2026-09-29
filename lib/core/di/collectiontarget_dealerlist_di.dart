import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/selfcollectionassign/data/datasource/monthly_collection_remote_datasource.dart';

// Dealer
import 'package:solufine/features/selfcollectionassign/data/datasource/dealer_remote_datasource.dart';
import 'package:solufine/features/selfcollectionassign/data/repositories/dealer_repository_impl.dart';
import 'package:solufine/features/selfcollectionassign/domain/repositories/dealer_repository.dart';
import 'package:solufine/features/selfcollectionassign/domain/usecases/get_dealer_list.dart';
import 'package:solufine/features/selfcollectionassign/presentation/bloc/dealer_bloc.dart';

// Collection Type
import 'package:solufine/features/selfcollectionassign/data/datasource/collection_type_remote_datasource.dart';
import 'package:solufine/features/selfcollectionassign/data/repositories/collection_type_repository_impl.dart';
import 'package:solufine/features/selfcollectionassign/domain/repositories/collection_type_repository.dart';
import 'package:solufine/features/selfcollectionassign/domain/usecases/get_collection_type.dart';
import 'package:solufine/features/selfcollectionassign/presentation/bloc/collection_type_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initDealerDI() async {
  sl.registerLazySingleton<MonthlyCollectionRemoteDataSource>(
    () => MonthlyCollectionRemoteDataSource(dio: sl<DioClient>().client),
  );
  // ============================
  // Dealer
  // ============================

  // Data source
  sl.registerLazySingleton<DealerRemoteDataSource>(
    () => DealerRemoteDataSourceImpl(dio: sl<DioClient>().client),
  );

  // Repository
  sl.registerLazySingleton<DealerRepository>(
    () => DealerRepositoryImpl(remoteDataSource: sl<DealerRemoteDataSource>()),
  );

  // Use case
  sl.registerLazySingleton<GetDealerList>(
    () => GetDealerList(sl<DealerRepository>()),
  );

  // Bloc
  sl.registerFactory<DealerBloc>(
    () => DealerBloc(getDealerList: sl<GetDealerList>()),
  );

  // ============================
  // Collection Type
  // ============================

  // Data source
  sl.registerLazySingleton<CollectionTypeRemoteDataSource>(
    () => CollectionTypeRemoteDataSourceImpl(dio: sl<DioClient>().client),
  );

  // Repository
  sl.registerLazySingleton<CollectionTypeRepository>(
    () => CollectionTypeRepositoryImpl(
      remoteDataSource: sl<CollectionTypeRemoteDataSource>(),
    ),
  );

  // Use case
  sl.registerLazySingleton<GetCollectionType>(
    () => GetCollectionType(sl<CollectionTypeRepository>()),
  );

  // Bloc
  sl.registerFactory<CollectionTypeBloc>(
    () => CollectionTypeBloc(getCollectionType: sl<GetCollectionType>()),
  );
}
