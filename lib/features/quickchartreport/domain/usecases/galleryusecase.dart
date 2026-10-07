import 'package:solufine/features/quickchartreport/domain/enitities/galleryfileentity.dart';
import 'package:solufine/features/quickchartreport/domain/repositries/galleryrepository.dart';

class GetGallery {
  final GalleryRepository repository;

  GetGallery({required this.repository});

  Future<List<GalleryEntity>> call() async {
    return await repository.getGallery();
  }
}
