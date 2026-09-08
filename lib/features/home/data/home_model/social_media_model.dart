
import 'package:demo/features/home/doman/home_entity/social_media.dart';

class SocialMediaModel extends SocialMedia {
  const SocialMediaModel({
    required super.type,
    required super.link,
  });

  factory SocialMediaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SocialMediaModel(
      type: json['type']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
    );
  }
}