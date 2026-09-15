import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/salesreturnhistory/data/datasource/sales_return_history_remote_datasource.dart';
import 'package:demo/features/salesreturnhistory/data/repoimp/sales_return_history_repository_impl.dart';
import 'package:demo/features/salesreturnhistory/domain/repositries/sales_return_history_repository.dart';
import 'package:demo/features/salesreturnhistory/domain/usecases/get_sales_return_history_usecase.dart';
import 'package:demo/features/salesreturnhistory/domain/usecases/search_sales_return_dealer_usecase.dart';
import 'package:demo/features/salesreturnhistory/presentation/bloc/sales_return_history_bloc.dart';

import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initSalesReturnHistoryDi() async {
  // =========================================================
  // SALES RETURN HISTORY
  // =========================================================

  sl.registerLazySingleton<SalesReturnHistoryRemoteDatasource>(
    () => SalesReturnHistoryRemoteDatasource(dio: sl<DioClient>().client),
  );

  sl.registerLazySingleton<SalesReturnHistoryRepository>(
    () => SalesReturnHistoryRepositoryImpl(
      datasource: sl<SalesReturnHistoryRemoteDatasource>(),
    ),
  );

  sl.registerLazySingleton<GetSalesReturnHistoryUseCase>(
    () => GetSalesReturnHistoryUseCase(
      repository: sl<SalesReturnHistoryRepository>(),
    ),
  );

  sl.registerLazySingleton<SearchSalesReturnDealerUseCase>(
    () => SearchSalesReturnDealerUseCase(
      repository: sl<SalesReturnHistoryRepository>(),
    ),
  );

  sl.registerFactory<SalesReturnHistoryBloc>(
    () => SalesReturnHistoryBloc(
      getSalesReturnHistoryUseCase: sl<GetSalesReturnHistoryUseCase>(),
      searchDealerUseCase: sl<SearchSalesReturnDealerUseCase>(),
    ),
  );
}
