import 'package:equatable/equatable.dart';

abstract class SocialMediaEvent extends Equatable {
  const SocialMediaEvent();

  @override
  List<Object?> get props => [];
}

class GetSocialMediaEvent extends SocialMediaEvent {
  final String userId;

  const GetSocialMediaEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [
        userId,
      ];
}