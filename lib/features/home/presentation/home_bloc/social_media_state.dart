import 'package:demo/features/home/doman/home_entity/social_media.dart';
import 'package:equatable/equatable.dart';


enum SocialMediaStatus {
  initial,
  loading,
  success,
  failure,
}

class SocialMediaState extends Equatable {
  final SocialMediaStatus status;
  final List<SocialMedia> socialMedia;
  final String? errorMessage;

  const SocialMediaState({
    this.status = SocialMediaStatus.initial,
    this.socialMedia = const [],
    this.errorMessage,
  });

  SocialMediaState copyWith({
    SocialMediaStatus? status,
    List<SocialMedia>? socialMedia,
    String? errorMessage,
  }) {
    return SocialMediaState(
      status: status ?? this.status,
      socialMedia: socialMedia ?? this.socialMedia,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        socialMedia,
        errorMessage,
      ];
}