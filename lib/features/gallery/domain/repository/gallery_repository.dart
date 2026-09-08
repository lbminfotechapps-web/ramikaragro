import 'package:demo/features/gallery/domain/entities/gallery_entity.dart';

abstract class GalleryRepository {
  Future<List<GalleryEntity>> getGalleryDetails({required String type});
}
