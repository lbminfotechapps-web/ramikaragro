import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/features/dealer_visit/data/datasources/dealer_visit_data_source.dart';
import 'package:demo/features/dealer_visit/data/repositories/dealer_visit_repository_impl.dart';
import 'package:demo/features/dealer_visit/domain/repositories/dealer_visit_repository.dart';
import 'package:demo/features/dealer_visit/domain/usecases/add_ramark.dart';
import 'package:demo/features/dealer_visit/presentation/bloc/add_dealer_visit_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initAddDealerVisitDi() async {
  // =========================
  sl.registerLazySingleton<DealerVisitDataSource>(
    () => DealerVisitDataSource(sl<DioClient>()),
  );
  sl.registerLazySingleton<AddDealerVisitRepository>(
    () => DealerVisitRepositoryImpl(sl<DealerVisitDataSource>()),
  );

  sl.registerLazySingleton<AddRemark>(
    () => AddRemark(sl<AddDealerVisitRepository>())
  );
  sl.registerFactory<AddDealerVisitBlock>(
    () => AddDealerVisitBlock(sl<AddRemark>()),
  );
}
