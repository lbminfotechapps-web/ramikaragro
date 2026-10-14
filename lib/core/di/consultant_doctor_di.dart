
import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';

// DATA SOURCES
import 'package:solufine/features/consultant_doctors/data/datasources/consultant_local_data_source.dart';
import 'package:solufine/features/consultant_doctors/data/datasources/location_remote_data_source.dart';

// REPOSITORY IMPLEMENTATIONS
import 'package:solufine/features/consultant_doctors/data/repositories/consultant_repository_impl.dart';
import 'package:solufine/features/consultant_doctors/data/repositories/location_repository_impl.dart';

// DOMAIN REPOSITORIES
import 'package:solufine/features/consultant_doctors/domain/repositories/consultant_repository.dart';
import 'package:solufine/features/consultant_doctors/domain/repositories/location_repository.dart';

// USE CASES
import 'package:solufine/features/consultant_doctors/domain/usecases/consultant_usecases.dart';
import 'package:solufine/features/consultant_doctors/domain/usecases/location_usecases.dart';

// BLOC / CUBIT
import 'package:solufine/features/consultant_doctors/presentation/bloc/consultant_bloc.dart';
import 'package:solufine/features/consultant_doctors/presentation/bloc/location_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initConsultantDoctorDi() async {
  // ============================================================
  // SECURE STORAGE
  // ============================================================

  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(
      () => SecureStorage.instance,
    );
  }

  // ============================================================
  // DIO CLIENT
  // ============================================================

  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  // ============================================================
  // LOCATION REMOTE DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<LocationRemoteDataSource>()) {
    sl.registerLazySingleton<LocationRemoteDataSource>(
      () => LocationRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // ============================================================
  // CONSULTANT LOCAL DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<ConsultantLocalDataSource>()) {
    sl.registerLazySingleton<ConsultantLocalDataSource>(
      () => ConsultantLocalDataSource(),
    );
  }

  // ============================================================
  // LOCATION REPOSITORY
  // ============================================================

  if (!sl.isRegistered<LocationRepository>()) {
    sl.registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(
        sl<LocationRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // CONSULTANT REPOSITORY
  // ============================================================

  if (!sl.isRegistered<ConsultantRepository>()) {
    sl.registerLazySingleton<ConsultantRepository>(
      () => ConsultantRepositoryImpl(
        sl<ConsultantLocalDataSource>(),
      ),
    );
  }

  // ============================================================
  // LOCATION USE CASES
  // ============================================================

  if (!sl.isRegistered<GetStatesUseCase>()) {
    sl.registerLazySingleton<GetStatesUseCase>(
      () => GetStatesUseCase(
        sl<LocationRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<GetDistrictsAndTalukasUseCase>()) {
    sl.registerLazySingleton<GetDistrictsAndTalukasUseCase>(
      () => GetDistrictsAndTalukasUseCase(
        sl<LocationRepository>(),
      ),
    );
  }

  // ============================================================
  // CONSULTANT USE CASES
  // ============================================================

  if (!sl.isRegistered<GetConsultantsUseCase>()) {
    sl.registerLazySingleton<GetConsultantsUseCase>(
      () => GetConsultantsUseCase(
        sl<ConsultantRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<SaveConsultantUseCase>()) {
    sl.registerLazySingleton<SaveConsultantUseCase>(
      () => SaveConsultantUseCase(
        sl<ConsultantRepository>(),
      ),
    );
  }

  // ============================================================
  // CONSULTANT BLOC
  // ============================================================

  if (!sl.isRegistered<ConsultantBloc>()) {
    sl.registerFactory<ConsultantBloc>(
      () => ConsultantBloc(
        getConsultants: sl<GetConsultantsUseCase>(),
        saveConsultant: sl<SaveConsultantUseCase>(),
      ),
    );
  }

  // ============================================================
  // LOCATION CUBIT
  // ============================================================

  if (!sl.isRegistered<LocationCubit>()) {
    sl.registerFactory<LocationCubit>(
      () => LocationCubit(
        getStates: sl<GetStatesUseCase>(),
        getDistricts:
            sl<GetDistrictsAndTalukasUseCase>(),
      ),
    );
  }
}
