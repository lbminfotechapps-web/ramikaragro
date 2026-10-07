import 'package:solufine/features/quickchartreport/domain/enitities/galleryfileentity.dart';

abstract class GalleryRepository {
  Future<List<GalleryEntity>> getGallery();
}
