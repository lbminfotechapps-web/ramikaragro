import 'package:solufine/features/quickchartreport/domain/enitities/galleryfileentity.dart';

class GalleryModel extends GalleryEntity {
  const GalleryModel({
    required super.galleryId,
    required super.title,
    required super.date,
    required super.data,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      galleryId: json['gallery_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => GalleryFileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gallery_id': galleryId,
      'title': title,
      'date': date,
      'data': data
          .map(
            (e) => {
              'language_id': e.languageId,
              'language': e.language,
              'file': e.file,
            },
          )
          .toList(),
    };
  }
}

class GalleryFileModel extends GalleryFileEntity {
  const GalleryFileModel({
    required super.languageId,
    required super.language,
    required super.file,
  });

  factory GalleryFileModel.fromJson(Map<String, dynamic> json) {
    return GalleryFileModel(
      languageId: json['language_id']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
    );
  }
}
