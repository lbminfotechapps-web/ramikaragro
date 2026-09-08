import 'dart:convert';
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
      debugPrint('==========================================');
      debugPrint('FARMER REMARK HISTORY API');
      debugPrint('FARMER ID = [$farmerId]');
      debugPrint('==========================================');

      final formData = FormData.fromMap({'farmer_id': farmerId});

      debugPrint('Sending FormData: farmer_id = $farmerId');

      final response = await dioClient.client.post(
        '/farmer_remark_list',
        data: formData,
      );

      debugPrint('==========================================');
      debugPrint('RAW HISTORY RESPONSE');
      debugPrint('STATUS CODE = ${response.statusCode}');
      debugPrint('RESPONSE TYPE = ${response.data.runtimeType}');
      debugPrint('RESPONSE DATA = ${response.data}');
      debugPrint('==========================================');

      final data = response.data;

      if (data is String) {
        final decoded = jsonDecode(data);

        if (decoded is Map) {
          final responseMap = Map<String, dynamic>.from(decoded);

          final historyData = responseMap['data'];

          if (historyData is List) {
            final result = historyData
                .whereType<Map>()
                .map(
                  (item) =>
                      RemarkListModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList();

            debugPrint('PARSED HISTORY COUNT = ${result.length}');

            return result;
          }

          if (responseMap['status'] == 'no_records') {
            debugPrint('API returned no_records');
            return [];
          }
        }
      }

      if (data is Map) {
        final responseMap = Map<String, dynamic>.from(data);

        final historyData = responseMap['data'];

        if (historyData is List) {
          return historyData
              .whereType<Map>()
              .map(
                (item) =>
                    RemarkListModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();
        }
      }

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) =>
                  RemarkListModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('==========================================');
      debugPrint('HISTORY DIO ERROR');
      debugPrint('MESSAGE = ${e.message}');
      debugPrint('STATUS = ${e.response?.statusCode}');
      debugPrint('RESPONSE = ${e.response?.data}');
      debugPrint('==========================================');

      rethrow;
    } catch (e, stackTrace) {
      debugPrint('HISTORY ERROR = $e');
      debugPrint('STACKTRACE = $stackTrace');

      rethrow;
    }
  }
}
