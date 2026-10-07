import 'package:solufine/features/quickchartreport/data/model/gallerymodel%20.dart';

class GalleryResponseModel {
  final bool status;
  final List<GalleryModel> result;
  final String message;

  const GalleryResponseModel({
    required this.status,
    required this.result,
    required this.message,
  });

  factory GalleryResponseModel.fromJson(Map<String, dynamic> json) {
    return GalleryResponseModel(
      status: json['status'] == true,
      result: (json['result'] as List? ?? [])
          .map((e) => GalleryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}
