import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/home/data/home_model/crop_schedule_model.dart';
import 'package:dio/dio.dart';

class CropScheduleRemoteDataSource {
  final DioClient dioClient;

  CropScheduleRemoteDataSource({
    required this.dioClient,
  });

  Future<List<CropScheduleModel>> getCropSchedules() async {
    try {
      print('================================');
      print('GET CROP SCHEDULE');
      print('URL: ${ApiClient.getCropsSchedule}');
      print('================================');

      final response = await dioClient.client.get(
        ApiClient.getCropsSchedule,
        options: Options(
          responseType: ResponseType.plain,
        ),
      );

      dynamic responseData = response.data;

      print('Response type: ${responseData.runtimeType}');
      print('Response: $responseData');

      // -----------------------------------------
      // Convert String JSON -> Map
      // -----------------------------------------

      if (responseData is String) {
        String responseString = responseData.trim();

        // In case PHP warning/output comes before JSON
        final jsonStart = responseString.indexOf('{');

        if (jsonStart >= 0) {
          responseString =
              responseString.substring(jsonStart);
        }

        responseData = jsonDecode(responseString);
      }

      // -----------------------------------------
      // Validate response
      // -----------------------------------------

      if (responseData is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format from server.',
        );
      }

      // -----------------------------------------
      // Status
      // -----------------------------------------

      final bool status =
          responseData['status'] == true ||
          responseData['status']
                  ?.toString()
                  .toLowerCase() ==
              'true';

      if (!status) {
        throw Exception(
          responseData['message']?.toString() ??
              'Unable to fetch crop schedule.',
        );
      }

      // -----------------------------------------
      // Result
      // -----------------------------------------

      final dynamic result = responseData['result'];

      if (result == null) {
        return [];
      }

      if (result is! List) {
        throw Exception(
          'Invalid crop schedule result format.',
        );
      }

      // -----------------------------------------
      // Convert JSON -> Model
      // -----------------------------------------

      final List<CropScheduleModel> schedules =
          result
              .whereType<Map>()
              .map(
                (json) => CropScheduleModel.fromJson(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList();

      print(
        'Crop schedules received: ${schedules.length}',
      );

      return schedules;
    } on DioException catch (e) {
      print('Dio error: ${e.message}');

      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            'Network error while fetching crop schedule.',
      );
    } catch (e) {
      print('Crop schedule error: $e');

      rethrow;
    }
  }
}