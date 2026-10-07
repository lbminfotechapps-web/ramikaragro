import 'package:equatable/equatable.dart';

class GalleryEntity extends Equatable {
  final String galleryId;
  final String title;
  final String date;
  final List<GalleryFileEntity> data;

  const GalleryEntity({
    required this.galleryId,
    required this.title,
    required this.date,
    required this.data,
  });

  @override
  List<Object?> get props => [galleryId, title, date, data];
}

class GalleryFileEntity extends Equatable {
  final String languageId;
  final String language;
  final String file;

  const GalleryFileEntity({
    required this.languageId,
    required this.language,
    required this.file,
  });

  @override
  List<Object?> get props => [languageId, language, file];
}
