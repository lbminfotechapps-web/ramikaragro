import 'package:solufine/features/quickchartreport/data/model/galleryresponsemodel%20.dart';

abstract class GalleryRemoteDataSource {
  Future<GalleryResponseModel> getGallery();
}
