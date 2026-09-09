import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/products/data/product_datasource.dart';
import 'package:demo/features/products/data/product_repo_imp.dart';
import 'package:demo/features/products/domain/product_repository.dart';
import 'package:demo/features/products/domain/product_use_cases.dart';
import 'package:demo/features/products/presentation/bloc/product_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initProductDi() async {
  // =========================
  // Product
  // =========================

  sl.registerLazySingleton<ProductDatasource>(
    () => ProductDatasource(sl<DioClient>()),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepoImp(sl<ProductDatasource>()),
  );

  sl.registerLazySingleton<ProductUseCases>(
    () => ProductUseCases(sl<ProductRepository>()),
  );

  sl.registerFactory<ProductBloc>(() => ProductBloc(sl<ProductUseCases>()));
}
