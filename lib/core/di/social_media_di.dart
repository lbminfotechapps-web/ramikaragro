import 'package:demo/features/home/data/home_datasource/social_media_remote_datasource.dart';
import 'package:demo/features/home/data/home_repo_imp/social_media_repository_impl.dart';
import 'package:demo/features/home/doman/home_repository/social_media_repository.dart';
import 'package:demo/features/home/doman/home_usecases/get_social_media.dart';
import 'package:demo/features/home/presentation/home_bloc/social_media_bloc.dart';
import 'package:get_it/get_it.dart';

import '../api_constant/dio_client.dart';

final sl = GetIt.instance;

Future<void> initSocialMediaDi() async {
  // =========================
  // DATA SOURCE
  // =========================

  sl.registerLazySingleton<SocialMediaRemoteDataSource>(
    () => SocialMediaRemoteDataSourceImpl(
      dioClient: sl<DioClient>(),
    ),
  );

  // =========================
  // REPOSITORY
  // =========================

  sl.registerLazySingleton<SocialMediaRepository>(
    () => SocialMediaRepositoryImpl(
      remoteDataSource:
          sl<SocialMediaRemoteDataSource>(),
    ),
  );

  // =========================
  // USE CASE
  // =========================

  sl.registerLazySingleton<GetSocialMedia>(
    () => GetSocialMedia(
      repository: sl<SocialMediaRepository>(),
    ),
  );

  // =========================
  // BLOC
  // =========================

  sl.registerFactory<SocialMediaBloc>(
    () => SocialMediaBloc(
      getSocialMedia: sl<GetSocialMedia>(),
    ),
  );
}