import 'package:demo/features/home/doman/home_usecases/get_social_media.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'social_media_event.dart';
import 'social_media_state.dart';

class SocialMediaBloc
    extends Bloc<SocialMediaEvent, SocialMediaState> {
  final GetSocialMedia getSocialMedia;

  SocialMediaBloc({
    required this.getSocialMedia,
  }) : super(const SocialMediaState()) {
    on<GetSocialMediaEvent>(_onGetSocialMedia);
  }

  Future<void> _onGetSocialMedia(
    GetSocialMediaEvent event,
    Emitter<SocialMediaState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SocialMediaStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final result = await getSocialMedia(
        userId: event.userId,
      );

      emit(
        state.copyWith(
          status: SocialMediaStatus.success,
          socialMedia: result,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SocialMediaStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}