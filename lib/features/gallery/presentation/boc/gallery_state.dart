import 'package:equatable/equatable.dart';
import 'package:demo/features/gallery/domain/entities/gallery_entity.dart';

enum GalleryStatus { initial, loading, success, failure }

class GalleryState extends Equatable {
  final GalleryStatus status;

  final List<GalleryEntity> galleryList;
  final List<GalleryEntity> videoList;
  final List<GalleryEntity> certificateList;

  final String? errorMessage;

  final String currentType;

  const GalleryState({
    this.status = GalleryStatus.initial,
    this.galleryList = const [],
    this.videoList = const [],
    this.certificateList = const [],
    this.errorMessage,
    this.currentType = 'gallery',
  });

  GalleryState copyWith({
    GalleryStatus? status,
    List<GalleryEntity>? galleryList,
    List<GalleryEntity>? videoList,
    List<GalleryEntity>? certificateList,
    String? errorMessage,
    String? currentType,
    bool clearError = false,
  }) {
    return GalleryState(
      status: status ?? this.status,
      galleryList: galleryList ?? this.galleryList,
      videoList: videoList ?? this.videoList,
      certificateList: certificateList ?? this.certificateList,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      currentType: currentType ?? this.currentType,
    );
  }

  @override
  List<Object?> get props => [
    status,
    galleryList,
    videoList,
    certificateList,
    errorMessage,
    currentType,
  ];
}
