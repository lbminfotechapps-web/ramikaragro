import 'package:equatable/equatable.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object?> get props => [];
}

/// Load data for the currently selected tab
class GetGalleryEvent extends GalleryEvent {
  final String type;

  const GetGalleryEvent({required this.type});

  @override
  List<Object?> get props => [type];
}

/// Refresh currently selected tab
class RefreshGalleryEvent extends GalleryEvent {
  final String type;

  const RefreshGalleryEvent({required this.type});

  @override
  List<Object?> get props => [type];
}
