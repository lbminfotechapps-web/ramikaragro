
import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';

import 'package:solufine/features/consultant_doctors/data/datasources/consultant_local_data_source.dart';
import 'package:solufine/features/consultant_doctors/data/datasources/location_remote_data_source.dart';
import 'package:solufine/features/consultant_doctors/data/datasources/consultant_remote_data_source.dart';
import 'package:solufine/features/consultant_doctors/data/datasources/consultant_list_remote_data_source.dart';

import 'package:solufine/features/consultant_doctors/data/repositories/consultant_repository_impl.dart';
import 'package:solufine/features/consultant_doctors/data/repositories/location_repository_impl.dart';
import 'package:solufine/features/consultant_doctors/data/repositories/add_doctor_repository_impl.dart';
import 'package:solufine/features/consultant_doctors/data/repositories/consultant_list_repository_impl.dart';

import 'package:solufine/features/consultant_doctors/domain/repositories/consultant_repository.dart';
import 'package:solufine/features/consultant_doctors/domain/repositories/location_repository.dart';
import 'package:solufine/features/consultant_doctors/domain/repositories/add_doctor_repository.dart';
import 'package:solufine/features/consultant_doctors/domain/repositories/consultant_list_repository.dart';

import 'package:solufine/features/consultant_doctors/domain/usecases/consultant_usecases.dart';
import 'package:solufine/features/consultant_doctors/domain/usecases/location_usecases.dart';
import 'package:solufine/features/consultant_doctors/domain/usecases/add_doctor_usecase.dart';
import 'package:solufine/features/consultant_doctors/domain/usecases/get_remote_consultants_usecase.dart';

import 'package:solufine/features/consultant_doctors/presentation/bloc/consultant_bloc.dart';
import 'package:solufine/features/consultant_doctors/presentation/bloc/location_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initConsultantDoctorDi() async {
  // ==========================================================
  // CORE DEPENDENCIES
  // ==========================================================

  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(
      () => SecureStorage.instance,
    );
  }

  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(),
    );
  }

  // ==========================================================
  // LOCATION DATA SOURCE
  // ==========================================================

  if (!sl.isRegistered<LocationRemoteDataSource>()) {
    sl.registerLazySingleton<LocationRemoteDataSource>(
      () => LocationRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // ==========================================================
  // LOCAL CONSULTANT DATA SOURCE
  // Existing: retained for Add Doctor local-save compatibility.
  // The list will not read from this datasource.
  // ==========================================================

  if (!sl.isRegistered<ConsultantLocalDataSource>()) {
    sl.registerLazySingleton<ConsultantLocalDataSource>(
      () => ConsultantLocalDataSource(),
    );
  }

  // ==========================================================
  // ADD DOCTOR REMOTE DATA SOURCE
  // ==========================================================

  if (!sl.isRegistered<ConsultantRemoteDataSource>()) {
    sl.registerLazySingleton<ConsultantRemoteDataSource>(
      () => ConsultantRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // ==========================================================
  // NEW DOCTOR LIST REMOTE DATA SOURCE
  // ==========================================================

  if (!sl.isRegistered<ConsultantListRemoteDataSource>()) {
    sl.registerLazySingleton<ConsultantListRemoteDataSource>(
      () => ConsultantListRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // ==========================================================
  // REPOSITORIES
  // ==========================================================

  if (!sl.isRegistered<LocationRepository>()) {
    sl.registerLazySingleton<LocationRepository>(
      () => LocationRepositoryImpl(
        sl<LocationRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<ConsultantRepository>()) {
    sl.registerLazySingleton<ConsultantRepository>(
      () => ConsultantRepositoryImpl(
        sl<ConsultantLocalDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<AddDoctorRepository>()) {
    sl.registerLazySingleton<AddDoctorRepository>(
      () => AddDoctorRepositoryImpl(
        remoteDataSource: sl<ConsultantRemoteDataSource>(),
      ),
    );
  }

  if (!sl.isRegistered<ConsultantListRepository>()) {
    sl.registerLazySingleton<ConsultantListRepository>(
      () => ConsultantListRepositoryImpl(
        remote: sl<ConsultantListRemoteDataSource>(),
      ),
    );
  }

  // ==========================================================
  // LOCATION USE CASES
  // ==========================================================

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

  // ==========================================================
  // LOCAL SAVE USE CASES
  // ==========================================================

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

  // ==========================================================
  // ADD DOCTOR USE CASE
  // ==========================================================

  if (!sl.isRegistered<AddDoctorUseCase>()) {
    sl.registerLazySingleton<AddDoctorUseCase>(
      () => AddDoctorUseCase(
        repository: sl<AddDoctorRepository>(),
      ),
    );
  }

  // ==========================================================
  // NEW REMOTE DOCTOR LIST USE CASE
  // ==========================================================

  if (!sl.isRegistered<GetRemoteConsultantsUseCase>()) {
    sl.registerLazySingleton<GetRemoteConsultantsUseCase>(
      () => GetRemoteConsultantsUseCase(
        sl<ConsultantListRepository>(),
      ),
    );
  }

  // ==========================================================
  // CONSULTANT BLOC
  // ==========================================================

  if (!sl.isRegistered<ConsultantBloc>()) {
    sl.registerFactory<ConsultantBloc>(
      () => ConsultantBloc(
        getRemoteConsultants:
            sl<GetRemoteConsultantsUseCase>(),
        saveConsultant: sl<SaveConsultantUseCase>(),
        addDoctor: sl<AddDoctorUseCase>(),
      ),
    );
  }

  // ==========================================================
  // LOCATION CUBIT
  // ==========================================================

  if (!sl.isRegistered<LocationCubit>()) {
    sl.registerFactory<LocationCubit>(
      () => LocationCubit(
        getStates: sl<GetStatesUseCase>(),
        getDistricts: sl<GetDistrictsAndTalukasUseCase>(),
      ),
    );
  }
}
