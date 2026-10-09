import 'package:get_it/get_it.dart';

import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/ai/data/datasource/ai_datasource.dart';
import 'package:solufine/features/ai/data/repositories/ai_repo_imp.dart';
import 'package:solufine/features/ai/domain/repository/ai_repositoty.dart';
import 'package:solufine/features/ai/domain/usecase/ai_query_usecase.dart';

import 'package:solufine/features/ai/presentation/bloc/ai_bloc.dart';

final sl = GetIt.instance;

Future<void> initAiDi() async {
  // ============================================================
  // AI DATASOURCE
  // ============================================================

  if (!sl.isRegistered<AiDatasource>()) {
    sl.registerLazySingleton<AiDatasource>(() => AiDatasource(sl<DioClient>()));
  }

  // ============================================================
  // AI REPOSITORY
  // ============================================================

  if (!sl.isRegistered<AiRepositoty>()) {
    sl.registerLazySingleton<AiRepositoty>(() => AiRepoImp(sl<AiDatasource>()));
  }

  // ============================================================
  // AI QUERY USECASE
  // ============================================================

  if (!sl.isRegistered<AiQueryUsecase>()) {
    sl.registerLazySingleton<AiQueryUsecase>(
      () => AiQueryUsecase(sl<AiRepositoty>()),
    );
  }

  // ============================================================
  // AI BLOC
  // ============================================================

  if (!sl.isRegistered<AiBloc>()) {
    sl.registerFactory<AiBloc>(() => AiBloc(sl<AiQueryUsecase>()));
  }
}
