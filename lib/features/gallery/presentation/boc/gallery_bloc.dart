import 'package:demo/features/gallery/domain/usecases/GetGalleryDetails.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GetGalleryDetails getGalleryDetails;

  GalleryBloc({required this.getGalleryDetails}) : super(const GalleryState()) {
    on<GetGalleryEvent>(_onGetGallery);
    on<RefreshGalleryEvent>(_onRefreshGallery);
  }

  // ============================================================
  // GET GALLERY
  // ============================================================

  Future<void> _onGetGallery(
    GetGalleryEvent event,
    Emitter<GalleryState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GalleryStatus.loading,
        currentType: event.type,
        clearError: true,
      ),
    );

    try {
      final result = await getGalleryDetails(type: event.type);

      if (event.type == 'gallery') {
        emit(
          state.copyWith(
            status: GalleryStatus.success,
            galleryList: result,
            currentType: event.type,
            clearError: true,
          ),
        );
      } else if (event.type == 'video') {
        emit(
          state.copyWith(
            status: GalleryStatus.success,
            videoList: result,
            currentType: event.type,
            clearError: true,
          ),
        );
      } else if (event.type == 'certificate') {
        emit(
          state.copyWith(
            status: GalleryStatus.success,
            certificateList: result,
            currentType: event.type,
            clearError: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: GalleryStatus.failure,
          currentType: event.type,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _onRefreshGallery(
    RefreshGalleryEvent event,
    Emitter<GalleryState> emit,
  ) async {
    try {
      final result = await getGalleryDetails(type: event.type);

      if (event.type == 'gallery') {
        emit(
          state.copyWith(
            status: GalleryStatus.success,
            galleryList: result,
            currentType: event.type,
            clearError: true,
          ),
        );
      } else if (event.type == 'video') {
        emit(
          state.copyWith(
            status: GalleryStatus.success,
            videoList: result,
            currentType: event.type,
            clearError: true,
          ),
        );
      } else if (event.type == 'certificate') {
        emit(
          state.copyWith(
            status: GalleryStatus.success,
            certificateList: result,
            currentType: event.type,
            clearError: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: GalleryStatus.failure,
          currentType: event.type,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
