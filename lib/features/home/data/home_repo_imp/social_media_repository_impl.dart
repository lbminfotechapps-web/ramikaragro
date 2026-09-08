

import 'package:demo/features/home/data/home_datasource/social_media_remote_datasource.dart';
import 'package:demo/features/home/doman/home_entity/social_media.dart';
import 'package:demo/features/home/doman/home_repository/social_media_repository.dart';

class SocialMediaRepositoryImpl
    implements SocialMediaRepository {
  final SocialMediaRemoteDataSource remoteDataSource;

  SocialMediaRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<SocialMedia>> getSocialMedia({
    required String userId,
  }) async {
    return await remoteDataSource.getSocialMedia(
      userId: userId,
    );
  }
}