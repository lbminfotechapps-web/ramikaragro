import 'package:demo/core/api_constant/dio_client.dart';
import 'package:get_it/get_it.dart';

// ==========================================================
// DATA SOURCES
// ==========================================================

import '../../features/place_order/data/datasources/place_order_remote_datasource.dart';
import '../../features/place_order/data/datasources/product_rate_remote_datasource.dart';

// ==========================================================
// REPOSITORIES
// ==========================================================

import '../../features/place_order/data/repositories/place_order_repository_impl.dart';
import '../../features/place_order/data/repositories/product_rate_repository_impl.dart';

// ==========================================================
// DOMAIN REPOSITORIES
// ==========================================================

import '../../features/place_order/domain/repositories/place_order_repository.dart';
import '../../features/place_order/domain/repositories/product_rate_repository.dart';

// ==========================================================
// USE CASES
// ==========================================================

import '../../features/place_order/domain/usecases/get_categories_usecase.dart';
import '../../features/place_order/domain/usecases/get_dealers_usecase.dart';
import '../../features/place_order/domain/usecases/get_godowns_usecase.dart';
import '../../features/place_order/domain/usecases/get_products_usecase.dart';
import '../../features/place_order/domain/usecases/get_product_detail_rates_usecase.dart';
import '../../features/place_order/domain/usecases/submit_order_usecase.dart';

// ==========================================================
// BLOC
// ==========================================================

import '../../features/place_order/presentation/bloc/place_order_bloc.dart';

final sl = GetIt.instance;

Future<void> initPlaceOrderTargetDi() async {
  // ==========================================================
  // DIO CLIENT
  // ==========================================================

  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  // ==========================================================
  // PLACE ORDER DATA SOURCE
  // ==========================================================

  if (!sl.isRegistered<PlaceOrderRemoteDataSource>()) {
    sl.registerLazySingleton<PlaceOrderRemoteDataSource>(
      () => PlaceOrderRemoteDataSource(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // ==========================================================
  // PLACE ORDER REPOSITORY
  // ==========================================================

  if (!sl.isRegistered<PlaceOrderRepository>()) {
    sl.registerLazySingleton<PlaceOrderRepository>(
      () => PlaceOrderRepositoryImpl(
        remoteDataSource: sl<PlaceOrderRemoteDataSource>(),
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
  // GET DEALERS USE CASE
  // ==========================================================

  if (!sl.isRegistered<GetDealersUseCase>()) {
    sl.registerLazySingleton<GetDealersUseCase>(
      () => GetDealersUseCase(
        sl<PlaceOrderRepository>(),
      ),
    );
  }

  // ==========================================================
  // GET GODOWNS USE CASE
  // ==========================================================

  if (!sl.isRegistered<GetGodownsUseCase>()) {
    sl.registerLazySingleton<GetGodownsUseCase>(
      () => GetGodownsUseCase(
        sl<PlaceOrderRepository>(),
      ),
    );
  }

  // ==========================================================
  // GET CATEGORIES USE CASE
  // ==========================================================

  if (!sl.isRegistered<GetCategoriesUseCase>()) {
    sl.registerLazySingleton<GetCategoriesUseCase>(
      () => GetCategoriesUseCase(
        sl<PlaceOrderRepository>(),
      ),
    );
  }

  // ==========================================================
  // GET PRODUCTS USE CASE
  // ==========================================================

  if (!sl.isRegistered<GetProductsUseCase>()) {
    sl.registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(
        sl<PlaceOrderRepository>(),
      ),
    );
  }

  // ==========================================================
  // GET PRODUCT DETAIL RATES USE CASE
  // ==========================================================

  if (!sl.isRegistered<GetProductDetailRatesUseCase>()) {
    sl.registerLazySingleton<GetProductDetailRatesUseCase>(
      () => GetProductDetailRatesUseCase(
        repository: sl<ProductRateRepository>(),
      ),
    );
  }

  // ==========================================================
  // SUBMIT ORDER USE CASE
  // ==========================================================

  if (!sl.isRegistered<SubmitOrderUseCase>()) {
    sl.registerLazySingleton<SubmitOrderUseCase>(
      () => SubmitOrderUseCase(
        repository: sl<PlaceOrderRepository>(),
      ),
    );
  }

  // ==========================================================
  // PLACE ORDER BLOC
  // ==========================================================

  if (!sl.isRegistered<PlaceOrderBloc>()) {
    sl.registerFactory<PlaceOrderBloc>(
      () => PlaceOrderBloc(
        getDealersUseCase: sl<GetDealersUseCase>(),
        getGodownsUseCase: sl<GetGodownsUseCase>(),
        getCategoriesUseCase: sl<GetCategoriesUseCase>(),
        getProductsUseCase: sl<GetProductsUseCase>(),
        submitOrderUseCase: sl<SubmitOrderUseCase>(),
      ),
    );
  }
}