import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:solufine/features/quickchartreport/data/datasource/galleryremotedatasource.dart';
import 'package:solufine/features/quickchartreport/data/model/galleryresponsemodel%20.dart';

import '../../../../core/api_constant/dio_client.dart';

class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {
  final DioClient dioClient;

  GalleryRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<GalleryResponseModel> getGallery() async {
    try {
      final Response response = await dioClient.client.post(
        '/get_quick_refrence_chart',
      );

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data.trim());
      }
      if (data is! Map) {
        throw const FormatException(
          'Invalid quick reference response: expected a JSON object',
        );
      }
      return GalleryResponseModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      rethrow;
    }
  }
}
