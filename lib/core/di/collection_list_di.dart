import 'package:demo/features/collection/data/datasources/collection_list_remote_data_source.dart';
import 'package:demo/features/collection/data/repositories/collection_list_repository_impl.dart';
import 'package:demo/features/collection/domain/repositories/collection_list_repository.dart';
import 'package:demo/features/collection/domain/usecases/get_collection_list.dart';
import 'package:demo/features/collection/presentation/bloc/collection_list_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:demo/core/api_constant/dio_client.dart';



final sl = GetIt.instance;

Future<void> initCollectionListDi() async {
  // =========================================================
  // REMOTE DATA SOURCE
  // =========================================================

  sl.registerLazySingleton<
      CollectionListRemoteDataSource>(
    () => CollectionListRemoteDataSourceImpl(
      sl<DioClient>(),
    ),
  );

  // =========================================================
  // REPOSITORY
  // =========================================================

  sl.registerLazySingleton<
      CollectionListRepository>(
    () => CollectionListRepositoryImpl(
      sl<CollectionListRemoteDataSource>(),
    ),
  );

  // =========================================================
  // USE CASE
  // =========================================================

  sl.registerLazySingleton<
      GetCollectionList>(
    () => GetCollectionList(
      sl<CollectionListRepository>(),
    ),
  );

  // =========================================================
  // BLOC
  // =========================================================

  sl.registerFactory<
      CollectionListBloc>(
    () => CollectionListBloc(
      getCollectionList:
          sl<GetCollectionList>(),
    ),
  );
}