import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:get_it/get_it.dart';
import 'package:solufine/features/salesreturn/data/datasources/product_rate_remote_datasource.dart';

import 'package:solufine/features/salesreturn/data/datasources/sales_return_remote_datasource.dart';
import 'package:solufine/features/salesreturn/data/repositories/product_rate_repository_impl.dart';
import 'package:solufine/features/salesreturn/data/repositories/sales_return_repository_impl.dart';
import 'package:solufine/features/salesreturn/domain/repositories/product_rate_repository.dart';
import 'package:solufine/features/salesreturn/domain/repositories/sales_return_repository.dart';
import 'package:solufine/features/salesreturn/domain/usecases/get_categories_usecase.dart';
import 'package:solufine/features/salesreturn/domain/usecases/get_dealers_usecase.dart';
import 'package:solufine/features/salesreturn/domain/usecases/get_godowns_usecase.dart';
import 'package:solufine/features/salesreturn/domain/usecases/get_product_detail_rates_usecase.dart';
import 'package:solufine/features/salesreturn/domain/usecases/get_products_usecase.dart';
import 'package:solufine/features/salesreturn/domain/usecases/submit_order_usecase.dart';
import 'package:solufine/features/salesreturn/presentation/bloc/sales_return_bloc.dart';

// ==========================================================
// DATA SOURCES
// ==========================================================

// ==========================================================
// BLOC
// ==========================================================



final sl = GetIt.instance;

Future<void> initSalesReturnDi() async {
  // ==========================================================
  // DIO CLIENT
  // ==========================================================

  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  // ==========================================================
  //  ORDER DATA SOURCE
  // ==========================================================


  if (!sl.isRegistered<SalesReturnRemoteDataSource>()) {
  sl.registerLazySingleton<SalesReturnRemoteDataSource>(
    () => SalesReturnRemoteDataSource(
      sl<DioClient>(),
    ),
  );
}

  // ==========================================================
  //  ORDER REPOSITORY
  // ==========================================================

  if (!sl.isRegistered<SalesReturnRepository>()) {
    sl.registerLazySingleton<SalesReturnRepository>(
      () => SalesReturnRepositoryImpl(
        remoteDataSource: sl<SalesReturnRemoteDataSource>(),
      ),
    );
  }

  // ==========================================================
  // PRODUCT RATE DATA SOURCE
  // ==========================================================

  if (!sl.isRegistered<ProductRateRemoteDataSource>()) {
    sl.registerLazySingleton<ProductRateRemoteDataSource>(
      () => ProductRateRemoteDataSource(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // ==========================================================
  // PRODUCT RATE REPOSITORY
  // ==========================================================

  if (!sl.isRegistered<ProductRateRepository>()) {
    sl.registerLazySingleton<ProductRateRepository>(
      () => ProductRateRepositoryImpl(
        remoteDataSource: sl<ProductRateRemoteDataSource>(),
      ),
    );
  }

  // ==========================================================
  // GET DEALERS
  // ==========================================================

  if (!sl.isRegistered<GetDealersUseCase>()) {
    sl.registerLazySingleton<GetDealersUseCase>(
      () => GetDealersUseCase(
        sl<SalesReturnRepository>(),
      ),
    );
  }

  // ==========================================================
  // GET GODOWNS
  // ==========================================================

  if (!sl.isRegistered<GetGodownsUseCase>()) {
    sl.registerLazySingleton<GetGodownsUseCase>(
      () => GetGodownsUseCase(
        sl<SalesReturnRepository>(),
      ),
    );
  }

  // ==========================================================
  // GET CATEGORIES
  // ==========================================================

  if (!sl.isRegistered<GetCategoriesUseCase>()) {
    sl.registerLazySingleton<GetCategoriesUseCase>(
      () => GetCategoriesUseCase(
        sl<SalesReturnRepository>(),
      ),
    );
  }

  // ==========================================================
  // GET PRODUCTS
  // ==========================================================

  if (!sl.isRegistered<GetProductsUseCase>()) {
    sl.registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(
        sl<SalesReturnRepository>(),
      ),
    );
  }

  // ==========================================================
  // GET PRODUCT DETAIL RATES
  // ==========================================================

  if (!sl.isRegistered<GetProductDetailRatesUseCase>()) {
    sl.registerLazySingleton<GetProductDetailRatesUseCase>(
      () => GetProductDetailRatesUseCase(
        repository: sl<ProductRateRepository>(),
      ),
    );
  }

  // ==========================================================
  // SUBMIT ORDER
  // ==========================================================

  if (!sl.isRegistered<SubmitOrderUseCase>()) {
    sl.registerLazySingleton<SubmitOrderUseCase>(
      () => SubmitOrderUseCase(
        repository: sl<SalesReturnRepository>(),
      ),
    );
  }

  // ==========================================================
  // PLACE ORDER BLOC
  // ==========================================================

  if (!sl.isRegistered<SalesReturnBloc>()) {
    sl.registerFactory<SalesReturnBloc>(
      () => SalesReturnBloc(
        getDealersUseCase: sl<GetDealersUseCase>(),
        getGodownsUseCase: sl<GetGodownsUseCase>(),
        getCategoriesUseCase: sl<GetCategoriesUseCase>(),
        getProductsUseCase: sl<GetProductsUseCase>(),
        submitOrderUseCase: sl<SubmitOrderUseCase>(),
      ),
    );
  }
}