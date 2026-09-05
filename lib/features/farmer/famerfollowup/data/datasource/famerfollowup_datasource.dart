import 'dart:io';

import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/farmer/famerfollowup/data/model/submitFollowup_mode.dart';
import 'package:demo/features/farmer/farmerregistration/data/model/baseresponse_model.dart';
import 'package:dio/dio.dart';

class FamerfollowupDatasource {
  final DioClient dioClient;

  FamerfollowupDatasource({required this.dioClient});

  Future<SubmitFollowupModel> submitFollowup({
    required int farmerId,
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
      'farmer_id': farmerId.toString(),
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

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);

      if (await file.exists()) {
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
    }

    final response = await dioClient.client.post(
      '/add_remark_farmer',
      data: formData,
    );

    return SubmitFollowupModel.fromJson(response.data);
  }
}
