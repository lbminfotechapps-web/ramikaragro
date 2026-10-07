import 'package:solufine/features/quickchartreport/domain/enitities/galleryfileentity.dart';
import 'package:solufine/features/quickchartreport/data/datasource/galleryremotedatasource.dart'
    show GalleryRemoteDataSource;
import 'package:solufine/features/quickchartreport/domain/repositries/galleryrepository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final GalleryRemoteDataSource remoteDataSource;

  GalleryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GalleryEntity>> getGallery() async {
    final response = await remoteDataSource.getGallery();

    if (response.status) {
      return response.result;
    }

    throw Exception(response.message);
  }
}
