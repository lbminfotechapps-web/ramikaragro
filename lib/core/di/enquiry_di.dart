import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';

import 'package:solufine/features/enquiry/data/datasources/enquiry_remote_data_source.dart';
import 'package:solufine/features/enquiry/data/repositories/enquiry_repository_impl.dart';

import 'package:solufine/features/enquiry/domain/repositories/enquiry_repository.dart';
import 'package:solufine/features/enquiry/domain/usecases/get_districts_usecase.dart';
import 'package:solufine/features/enquiry/domain/usecases/get_states_usecase.dart';
import 'package:solufine/features/enquiry/domain/usecases/get_talukas_usecase.dart';
import 'package:solufine/features/enquiry/domain/usecases/submit_enquiry_usecase.dart';

import 'package:solufine/features/enquiry/presentation/bloc/enquiry_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initEnquiryDi() async {
  // ============================================================
  // DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<EnquiryRemoteDataSource>()) {
    sl.registerLazySingleton<EnquiryRemoteDataSource>(
      () => EnquiryRemoteDataSourceImpl(
        dioClient: DioClient(),
      ),
    );
  }

  // ============================================================
  // REPOSITORY
  // ============================================================

  if (!sl.isRegistered<EnquiryRepository>()) {
    sl.registerLazySingleton<EnquiryRepository>(
      () => EnquiryRepositoryImpl(
        remoteDataSource: sl<EnquiryRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // USE CASES
  // ============================================================

  if (!sl.isRegistered<GetStatesUseCase>()) {
    sl.registerLazySingleton<GetStatesUseCase>(
      () => GetStatesUseCase(
        sl<EnquiryRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<GetDistrictsUseCase>()) {
    sl.registerLazySingleton<GetDistrictsUseCase>(
      () => GetDistrictsUseCase(
        sl<EnquiryRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<GetTalukasUseCase>()) {
    sl.registerLazySingleton<GetTalukasUseCase>(
      () => GetTalukasUseCase(
        sl<EnquiryRepository>(),
      ),
    );
  }

  if (!sl.isRegistered<SubmitEnquiryUseCase>()) {
    sl.registerLazySingleton<SubmitEnquiryUseCase>(
      () => SubmitEnquiryUseCase(
        sl<EnquiryRepository>(),
      ),
    );
  }

  // ============================================================
  // BLOC
  // ============================================================

  if (!sl.isRegistered<EnquiryBloc>()) {
    sl.registerFactory<EnquiryBloc>(
      () => EnquiryBloc(
        getStatesUseCase: sl<GetStatesUseCase>(),
        getDistrictsUseCase: sl<GetDistrictsUseCase>(),
        getTalukasUseCase: sl<GetTalukasUseCase>(),
        submitEnquiryUseCase: sl<SubmitEnquiryUseCase>(),
      ),
    );
  }
}