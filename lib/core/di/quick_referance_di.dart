import 'package:get_it/get_it.dart';
import 'package:solufine/features/quickchartreport/data/datasource/galleryremotedatasource.dart';
import 'package:solufine/features/quickchartreport/data/repositories/gallery_remotedata_source_Impl.dart';
import 'package:solufine/features/quickchartreport/data/repositories/gallery_repository_Impl.dart';
import 'package:solufine/features/quickchartreport/domain/repositries/galleryrepository.dart';
import 'package:solufine/features/quickchartreport/domain/usecases/galleryusecase.dart';
import 'package:solufine/features/quickchartreport/presentation/bloc/gallerybloc.dart';

import '../api_constant/dio_client.dart';

final sl = GetIt.instance;

Future<void> initQuickReferenceDi() async {
  // ============================================================
  // DATASOURCE
  // ============================================================

  sl.registerLazySingleton<GalleryRemoteDataSource>(
    () => GalleryRemoteDataSourceImpl(dioClient: sl<DioClient>()),
  );

  // ============================================================
  // REPOSITORY
  // ============================================================

  sl.registerLazySingleton<GalleryRepository>(
    () =>
        GalleryRepositoryImpl(remoteDataSource: sl<GalleryRemoteDataSource>()),
  );

  // ============================================================
  // GET GALLERY USE CASE
  // ============================================================

  sl.registerLazySingleton<GetGallery>(
    () => GetGallery(repository: sl<GalleryRepository>()),
  );

  // ============================================================
  // BLOC
  // ============================================================

  sl.registerFactory<GalleryBloc>(
    () => GalleryBloc(getGallery: sl<GetGallery>()),
  );
}
