import 'dart:io';

import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/farmer/famerfollowup/data/model/followuplist_model.dart';
import 'package:demo/features/farmer/famerfollowup/data/model/submitFollowup_mode.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class FamerfollowupDatasource {
  final DioClient dioClient;

  FamerfollowupDatasource({required this.dioClient});

  Future<SubmitFollowupModel> submitFollowup({
    required String farmerId,
    required String userId,
    required String followUpDate,
    required String followUpType,
    required String remark,
    required double latitude,
    required double longitude,
    required double networkLatitude,
    required double networkLongitude,
    required double gpsLatitude,
    required double gpsLongitude,
    required String geoAddress,
    required String networkInfo,
    required String batteryInfo,
    required String differenceByAndroid,
    required String statusOfFarmer,
    required String activityId,
    String? imagePath,
  }) async {
    final formData = FormData.fromMap({
      'differenceByAndroid': differenceByAndroid,
      'user_id': userId,
      'farmer_id': farmerId,
      'followUpDate': followUpDate,
      'followUpType': followUpType,
      'remark': remark,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'networkLatitude': networkLatitude.toString(),
      'networkLongitude': networkLongitude.toString(),
      'gpsLatitude': gpsLatitude.toString(),
      'gpsLongitude': gpsLongitude.toString(),
      'geoAddress': geoAddress,
      'strNetworkInfo': networkInfo,
      'strBatteryInfo': batteryInfo,
      'status_of_farmer': statusOfFarmer,
      'activityId': activityId,
    });

    // ---------------------------------------------------------
    // IMAGE
    // ---------------------------------------------------------

    if (imagePath != null && imagePath.trim().isNotEmpty) {
      final file = File(imagePath);

      final exists = await file.exists();

      debugPrint('==========================================');
      debugPrint('IMAGE INFORMATION');
      debugPrint('Image Path : $imagePath');
      debugPrint('File Exists: $exists');
      debugPrint('==========================================');

      if (exists) {
        final fileSize = await file.length();

        debugPrint('Image Size : $fileSize bytes');

        formData.files.add(
          MapEntry(
            'selfie_capture_image',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }
    } else {
      debugPrint('No image selected');
    }

    try {
      final response = await dioClient.client.post(
        '/add_remark_farmer',
        data: formData,
      );
      if (response.data is Map<String, dynamic>) {
        return SubmitFollowupModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      if (response.data is Map) {
        return SubmitFollowupModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      if (response.data is String) {
        return SubmitFollowupModel(status: response.data.toString());
      }

      throw Exception(
        'Unexpected API response type: ${response.data.runtimeType}',
      );
    } on DioException catch (e, stackTrace) {
      rethrow;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Future<List<RemarkListModel>> getRemarkHistory({
    required String farmerId,
  }) async {
    try {
      final response = await dioClient.client.post(
        '/farmer_remark_list',
        data: {'farmer_id': farmerId},
      );

      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) =>
                  RemarkListModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      if (data is Map) {
        // If API returns:
        // {"data":[...]}

        final list = data['data'];

        if (list is List) {
          return list
              .whereType<Map>()
              .map(
                (item) =>
                    RemarkListModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      debugPrint('HISTORY DIO ERROR: ${e.message}');
      debugPrint('STATUS: ${e.response?.statusCode}');
      debugPrint('DATA: ${e.response?.data}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('HISTORY ERROR: $e');
      debugPrint('STACK: $stackTrace');
      rethrow;
    }
  }
}
