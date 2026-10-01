import 'dart:convert';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/gallery/data/model/gallery_model.dart';
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

      final requestedType = type.trim().toUpperCase();
      final galleryType = requestedType == 'CERTIFICATE'
          ? 'CERTIFICATES'
          : requestedType;

      void addGallery(Map<dynamic, dynamic> record) {
        final gallery = GalleryModel.fromJson(
          Map<String, dynamic>.from(record),
        );
        if (gallery.galleryType.trim().toUpperCase() == galleryType) {
          galleries.add(gallery);
        }
      }

      for (final record in result) {
        if (record is! Map) continue;

        // Support both flat gallery records and the existing crop-grouped response.
        final details = record['gallary_details'];
        if (details is List) {
          for (final gallery in details) {
            if (gallery is Map) addGallery(gallery);
          }
        } else if (record.containsKey('fld_gallery_id')) {
          addGallery(record);
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
