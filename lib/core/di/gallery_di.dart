import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/gallery/data/datasource/gallery_datasource.dart';
import 'package:demo/features/gallery/data/repoimp/gallerydatasourceImp.dart';
import 'package:demo/features/gallery/domain/repository/gallery_repository.dart';
import 'package:demo/features/gallery/domain/usecases/GetGalleryDetails.dart';
import 'package:demo/features/gallery/presentation/boc/gallery_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initGalleryDi() async {
  // =========================
  // DATA SOURCE
  // =========================
  sl.registerLazySingleton<GalleryDatasource>(
    () => GalleryDatasource(dioClient: sl<DioClient>()),
  );

  // =========================
  // REPOSITORY
  // =========================
  sl.registerLazySingleton<GalleryRepository>(
    () => GalleryDatasourceImpl(sl<GalleryDatasource>()),
  );

  // =========================
  // USE CASE
  // =========================
  sl.registerLazySingleton<GetGalleryDetails>(
    () => GetGalleryDetails(repository: sl<GalleryRepository>()),
  );

  // =========================
  // BLOC
  // =========================
  sl.registerFactory<GalleryBloc>(
    () => GalleryBloc(getGalleryDetails: sl<GetGalleryDetails>()),
  );
}
