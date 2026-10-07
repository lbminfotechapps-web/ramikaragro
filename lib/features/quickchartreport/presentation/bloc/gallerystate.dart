import 'package:equatable/equatable.dart';
import 'package:solufine/features/quickchartreport/domain/enitities/galleryfileentity.dart';

enum GalleryStatus { initial, loading, success, failure }

class GalleryState extends Equatable {
  final GalleryStatus status;
  final List<GalleryEntity> galleryList;
  final String message;

  const GalleryState({
    this.status = GalleryStatus.initial,
    this.galleryList = const [],
    this.message = '',
  });

  GalleryState copyWith({
    GalleryStatus? status,
    List<GalleryEntity>? galleryList,
    String? message,
  }) {
    return GalleryState(
      status: status ?? this.status,
      galleryList: galleryList ?? this.galleryList,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, galleryList, message];
}
