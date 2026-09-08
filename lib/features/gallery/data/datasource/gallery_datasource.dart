import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/gallery/data/model/gallery_model.dart';
import 'package:dio/dio.dart';

class GalleryDatasource {
  final DioClient dioClient;

  GalleryDatasource({required this.dioClient});

  Future<List<GalleryModel>> getGalleryData({required String type}) async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getGalleryDetails,
        data: FormData.fromMap({'type': type}),
      );

      print('========== GALLERY RESPONSE ==========');
      print('Type: ${response.data.runtimeType}');
      print('Data: ${response.data}');
      print('======================================');

      dynamic data = response.data;

      // Dio may return JSON as String
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is! Map) {
        throw Exception('Invalid gallery response format');
      }

      final Map<String, dynamic> responseData = Map<String, dynamic>.from(data);

      if (responseData['status'] != true) {
        throw Exception(
          responseData['message']?.toString() ??
              'Failed to fetch gallery details',
        );
      }

      final List<dynamic> result = responseData['result'] as List? ?? [];

      final List<GalleryModel> galleries = [];

      // result = crop list
      for (final crop in result) {
        if (crop is! Map) continue;

        final Map<String, dynamic> cropData = Map<String, dynamic>.from(crop);

        // Get gallary_details from each crop
        final List<dynamic> galleryDetails =
            cropData['gallary_details'] as List? ?? [];

        for (final gallery in galleryDetails) {
          if (gallery is! Map) continue;

          galleries.add(
            GalleryModel.fromJson(Map<String, dynamic>.from(gallery)),
          );
        }
      }

      return galleries;
    } on DioException catch (e) {
      print('========== GALLERY DIO ERROR ==========');
      print('Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');
      print('=======================================');

      throw Exception('Failed to fetch gallery details: ${e.message}');
    } catch (e) {
      print('Gallery error: $e');
      throw Exception('Failed to fetch gallery details: $e');
    }
  }
}
