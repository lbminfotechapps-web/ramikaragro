import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/orderhistory/data/datasource/order_history_remote_datasource.dart';
import 'package:demo/features/orderhistory/data/repositories/order_history_repository_impl.dart';
import 'package:demo/features/orderhistory/domain/repository/order_history_repository.dart';
import 'package:demo/features/orderhistory/domain/usecases/get_order_history_usecase.dart';
import 'package:demo/features/orderhistory/domain/usecases/update_order_status_usecase.dart';
import 'package:demo/features/orderhistory/presentation/bloc/order_history_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initOrderHistoryDi() async {
  // =========================================================
  // ORDER HISTORY
  // =========================================================

  sl.registerLazySingleton<OrderHistoryRemoteDataSource>(
    () => OrderHistoryRemoteDataSourceImpl(sl<DioClient>().client),
  );

  sl.registerLazySingleton<OrderHistoryRepository>(
    () => OrderHistoryRepositoryImpl(sl<OrderHistoryRemoteDataSource>()),
  );

  sl.registerLazySingleton<GetOrderHistoryUseCase>(
    () => GetOrderHistoryUseCase(sl<OrderHistoryRepository>()),
  );

  sl.registerLazySingleton<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(sl<OrderHistoryRepository>()),
  );

  sl.registerFactory<OrderHistoryBloc>(
    () => OrderHistoryBloc(
      getOrderHistoryUseCase: sl<GetOrderHistoryUseCase>(),
      updateOrderStatusUseCase: sl<UpdateOrderStatusUseCase>(),
    ),
  );
}
