import 'package:demo/features/collection/data/datasources/collection_remote_datasource.dart';
import 'package:demo/features/collection/data/repositories/collection_repository_impl.dart';
import 'package:demo/features/collection/domain/repositories/collection_repository.dart';
import 'package:demo/features/collection/domain/usecases/get_bank_details.dart';
import 'package:demo/features/collection/domain/usecases/search_dealers.dart';
import 'package:demo/features/collection/domain/usecases/submit_payment_details.dart';
import 'package:demo/features/collection/presentation/bloc/collection_bloc.dart';
import 'package:get_it/get_it.dart';

import '../api_constant/dio_client.dart';

final sl = GetIt.instance;

Future<void> initCollectionWiseFormDi() async {
  // ============================================================
  // DATASOURCE
  // ============================================================

  sl.registerLazySingleton<
      CollectionRemoteDataSource>(
    () => CollectionRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
    ),
  );

  // ============================================================
  // REPOSITORY
  // ============================================================

  sl.registerLazySingleton<
      CollectionRepository>(
    () => CollectionRepositoryImpl(
      remoteDataSource:
          sl<CollectionRemoteDataSource>(),
    ),
  );

  // ============================================================
  // SUBMIT USE CASE
  // ============================================================

  sl.registerLazySingleton<
      SubmitPaymentDetails>(
    () => SubmitPaymentDetails(
      repository:
          sl<CollectionRepository>(),
    ),
  );

  // ============================================================
  // DEALER SEARCH USE CASE
  // ============================================================

  sl.registerLazySingleton<SearchDealers>(
    () => SearchDealers(
      repository:
          sl<CollectionRepository>(),
    ),
  );

  // ============================================================
  // BANK USE CASE
  // ============================================================

  sl.registerLazySingleton<GetBankDetails>(
    () => GetBankDetails(
      repository:
          sl<CollectionRepository>(),
    ),
  );

  // ============================================================
  // BLOC
  // ============================================================

  sl.registerFactory<CollectionBloc>(
    () => CollectionBloc(
      submitPaymentDetails:
          sl<SubmitPaymentDetails>(),
      searchDealers:
          sl<SearchDealers>(),
      getBankDetails:
          sl<GetBankDetails>(),
    ),
  );
}