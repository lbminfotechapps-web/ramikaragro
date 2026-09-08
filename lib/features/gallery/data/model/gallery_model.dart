import 'package:demo/features/gallery/domain/entities/gallery_entity.dart';

class GalleryModel extends GalleryEntity {
  const GalleryModel({
    required super.galleryId,
    required super.galleryPath,
    required super.galleryTitle,
    required super.galleryDescription,
    required super.galleryType,
    required super.cropId,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      galleryId: json['fld_gallery_id']?.toString() ?? '',
      galleryPath: json['fld_gallery_path']?.toString() ?? '',
      galleryTitle: json['fld_gallery_title']?.toString() ?? '',
      galleryDescription: json['fld_gallery_description']?.toString() ?? '',
      galleryType: json['fld_gallery_type']?.toString() ?? '',
      cropId: json['fld_crop_id']?.toString() ?? '',
    );
  }
}
