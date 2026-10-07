import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solufine/features/quickchartreport/domain/usecases/galleryusecase.dart';
import 'package:solufine/features/quickchartreport/presentation/bloc/galleryevent.dart';
import 'package:solufine/features/quickchartreport/presentation/bloc/gallerystate.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GetGallery getGallery;

  GalleryBloc({required this.getGallery}) : super(const GalleryState()) {
    on<GetGalleryEvent>(_onGetGallery);
  }

  Future<void> _onGetGallery(
    GetGalleryEvent event,
    Emitter<GalleryState> emit,
  ) async {
    emit(state.copyWith(status: GalleryStatus.loading, message: ''));

    try {
      final result = await getGallery();

      emit(
        state.copyWith(
          status: GalleryStatus.success,
          galleryList: result,
          message: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: GalleryStatus.failure, message: e.toString()),
      );
    }
  }
}
