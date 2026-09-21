import 'package:solufine/features/sales_targrt_achievement/data/datasources/sales_target_remote_datasource.dart';
import 'package:solufine/features/sales_targrt_achievement/data/repositories/sales_target_repository_impl.dart';
import 'package:solufine/features/sales_targrt_achievement/domain/repositories/sales_target_repository.dart';
import 'package:solufine/features/sales_targrt_achievement/domain/usecases/get_sales_wise_target.dart';
import 'package:solufine/features/sales_targrt_achievement/domain/usecases/get_target_dates.dart';
import 'package:solufine/features/sales_targrt_achievement/presentation/bloc/sales_target_bloc.dart';
import 'package:get_it/get_it.dart';

import '../api_constant/dio_client.dart';

final sl = GetIt.instance;

Future<void> initSalesTargetDi() async {
  // -----------------------------------
  // DATA SOURCE
  // -----------------------------------

  if (!sl.isRegistered<SalesTargetRemoteDataSource>()) {
    sl.registerLazySingleton<SalesTargetRemoteDataSource>(
      () => SalesTargetRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // -----------------------------------
  // REPOSITORY
  // -----------------------------------

  if (!sl.isRegistered<SalesTargetRepository>()) {
    sl.registerLazySingleton<SalesTargetRepository>(
      () => SalesTargetRepositoryImpl(
        remoteDataSource: sl<SalesTargetRemoteDataSource>(),
      ),
    );
  }

  // -----------------------------------
  // USE CASE
  // -----------------------------------

  if (!sl.isRegistered<GetTargetDates>()) {
    sl.registerLazySingleton<GetTargetDates>(
      () => GetTargetDates(
        repository: sl<SalesTargetRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<GeSalesWiseTarget>()) {
    sl.registerLazySingleton<GeSalesWiseTarget>(
      () => GeSalesWiseTarget(
        repository: sl<SalesTargetRepository>(),
      ),
    );
  }

  // -----------------------------------
  // BLOC
  // -----------------------------------

  if (!sl.isRegistered<SalesTargetBloc>()) {
    sl.registerFactory<SalesTargetBloc>(
      () => SalesTargetBloc(
        getTargetDates: sl<GetTargetDates>(),
        getSalesWiseTarget: sl<GeSalesWiseTarget>(),
      ),
    );
  }
}