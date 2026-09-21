import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/features/dealer_visit/data/datasources/dealer_visit_data_source.dart';
import 'package:solufine/features/dealer_visit/data/repositories/dealer_visit_repository_impl.dart';
import 'package:solufine/features/dealer_visit/domain/repositories/dealer_visit_repository.dart';
import 'package:solufine/features/dealer_visit/domain/usecases/add_ramark.dart';
import 'package:solufine/features/dealer_visit/presentation/bloc/add_dealer_visit_bloc.dart';
import 'package:solufine/features/farmer/farmerregistration/data/datasource/farmerregistration_datasource.dart';
import 'package:solufine/features/farmer/farmerregistration/data/repoimp/farmerregistration_repo_imp.dart';
import 'package:solufine/features/farmer/farmerregistration/domain/repository/farmerregistration_repo.dart';
import 'package:solufine/features/home/doman/home_repository/home_repo.dart';
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
    () => AddRemark(sl<AddDealerVisitRepository>()),
  );

  // sl.registerLazySingleton<FarmerregistrationRepository>(
  //   () => FarmerregistrationRepositoryImpl(
  //     datasource: sl<FarmerregistrationDatasource>(),
  //   ),
  // );

  sl.registerFactory<AddDealerVisitBlock>(
    () => AddDealerVisitBlock(
      sl<AddRemark>(),
      sl<FarmerregistrationRepository>(),
    ),
  );
}
