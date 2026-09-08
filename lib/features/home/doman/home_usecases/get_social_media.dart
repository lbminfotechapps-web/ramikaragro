

import 'package:demo/features/home/doman/home_entity/social_media.dart';
import 'package:demo/features/home/doman/home_repository/social_media_repository.dart';

class GetSocialMedia {
  final SocialMediaRepository repository;

  GetSocialMedia({
    required this.repository,
  });

  Future<List<SocialMedia>> call({
    required String userId,
  }) async {
    return await repository.getSocialMedia(
      userId: userId,
    );
  }
}