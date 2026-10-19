import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/core/utility/plant_image_picker.dart';

import 'package:solufine/features/plant_doctor/data/datasource/plant_ai_remote_datasource.dart';
import 'package:solufine/features/plant_doctor/data/datasource/plant_product_remote_datasource.dart';

import 'package:solufine/features/plant_doctor/data/repository/plant_doctor_repository_impl.dart';

import 'package:solufine/features/plant_doctor/domain/repositories/plant_doctor_repository.dart';

import 'package:solufine/features/plant_doctor/domain/usecases/analyze_plant_usecase.dart';

import 'package:solufine/features/plant_doctor/presentation/bloc/plant_doctor_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initPlantDoctorDi() async {
  // ============================================================
  // IMAGE PICKER
  // ============================================================

  if (!sl.isRegistered<PlantImagePicker>()) {
    sl.registerLazySingleton<PlantImagePicker>(
      () => PlantImagePicker(),
    );
  }

  // ============================================================
  // GEMINI DIO
  //
  // Separate Dio required because:
  // 1. Your DioClient uses ApiClient.baseUrl
  // 2. Gemini has a completely different URL
  // 3. AI request may need longer timeout
  // ============================================================

  if (!sl.isRegistered<Dio>(
    instanceName: 'plantDoctorGeminiDio',
  )) {
    sl.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          connectTimeout: const Duration(
            seconds: 40,
          ),
          receiveTimeout: const Duration(
            seconds: 60,
          ),
          sendTimeout: const Duration(
            seconds: 60,
          ),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (
              options,
              handler,
            ) {
              print(
                'GEMINI API ${options.method}: ${options.uri}',
              );

              handler.next(
                options,
              );
            },
            onResponse: (
              response,
              handler,
            ) {
              print(
                'GEMINI STATUS: ${response.statusCode}',
              );

              handler.next(
                response,
              );
            },
            onError: (
              error,
              handler,
            ) {
              print(
                'GEMINI ERROR: ${error.message}',
              );

              print(
                'GEMINI STATUS: ${error.response?.statusCode}',
              );

              print(
                'GEMINI RESPONSE: ${error.response?.data}',
              );

              handler.next(
                error,
              );
            },
          ),
        ),
      instanceName: 'plantDoctorGeminiDio',
    );
  }

  // ============================================================
  // AI DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<PlantAiRemoteDataSource>()) {
    sl.registerLazySingleton<PlantAiRemoteDataSource>(
      () => PlantAiRemoteDataSourceImpl(
        dio: sl<Dio>(
          instanceName: 'plantDoctorGeminiDio',
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT DATA SOURCE
  //
  // Uses your existing DioClient because this API belongs to
  // ApiClient.baseUrl
  // ============================================================

  if (!sl.isRegistered<PlantProductRemoteDataSource>()) {
    sl.registerLazySingleton<PlantProductRemoteDataSource>(
      () => PlantProductRemoteDataSourceImpl(
        dioClient: DioClient(),
      ),
    );
  }

  // ============================================================
  // REPOSITORY
  // ============================================================

  if (!sl.isRegistered<PlantDoctorRepository>()) {
    sl.registerLazySingleton<PlantDoctorRepository>(
      () => PlantDoctorRepositoryImpl(
        aiRemoteDataSource:
            sl<PlantAiRemoteDataSource>(),

        productRemoteDataSource:
            sl<PlantProductRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // ANALYZE PLANT USE CASE
  // ============================================================

  if (!sl.isRegistered<AnalyzePlantUseCase>()) {
    sl.registerLazySingleton<AnalyzePlantUseCase>(
      () => AnalyzePlantUseCase(
        sl<PlantDoctorRepository>(),
      ),
    );
  }

  // ============================================================
  // PLANT DOCTOR BLOC
  // ============================================================

  if (!sl.isRegistered<PlantDoctorBloc>()) {
    sl.registerFactory<PlantDoctorBloc>(
      () => PlantDoctorBloc(
        analyzePlantUseCase:
            sl<AnalyzePlantUseCase>(),

        imagePicker:
            sl<PlantImagePicker>(),
      ),
    );
  }
}