
import 'package:demo/features/home/doman/home_entity/social_media.dart';

abstract class SocialMediaRepository {
  Future<List<SocialMedia>> getSocialMedia({
    required String userId,
  });
}