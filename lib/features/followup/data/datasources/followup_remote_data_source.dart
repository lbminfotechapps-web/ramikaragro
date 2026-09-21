import 'dart:convert';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';

import '../models/followup_model.dart';

abstract class FollowupRemoteDataSource {
  Future<List<FollowupModel>> getUpcomingFollowup({
    required String fromDate,
    required String toDate,
    required String type,
    required String userId,
  });
}

class FollowupRemoteDataSourceImpl
    implements FollowupRemoteDataSource {
  final DioClient dioClient;

  FollowupRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<List<FollowupModel>> getUpcomingFollowup({
    required String fromDate,
    required String toDate,
    required String type,
    required String userId,
  }) async {
    try {
      final requestData = {
        'fromDate': fromDate,
        'toDate': toDate,
        'type': type,
        'user_id': userId,
      };

      print(
        '================ UPCOMING FOLLOWUP REQUEST ================',
      );

      print(
        'URL: ${ApiClient.baseUrl}${ApiClient.upcomingNextFollowup}',
      );

      print('REQUEST DATA: $requestData');

      final response = await dioClient.client.post(
        ApiClient.upcomingNextFollowup,
        data: FormData.fromMap(requestData),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE DATA: ${response.data}');

      print(
        '============================================================',
      );

      // ---------------------------------------------------------
      // Convert response to Map
      // ---------------------------------------------------------

      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (responseData is! Map) {
        throw Exception(
          'Invalid API response format',
        );
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(responseData);

      // ---------------------------------------------------------
      // Check status
      // API response:
      // "status": true
      // ---------------------------------------------------------

      final dynamic status = data['status'];

      final bool isSuccess =
          status == true ||
          status == 1 ||
          status == '1' ||
          status == 'true';

      if (!isSuccess) {
        throw Exception(
          data['message']?.toString() ??
              'No followup records found',
        );
      }

      // ---------------------------------------------------------
      // Get data
      // ---------------------------------------------------------

      final dynamic result = data['data'];

      if (result == null) {
        return [];
      }

      if (result is! List) {
        throw Exception(
          'Invalid followup data format',
        );
      }

      // ---------------------------------------------------------
      // Convert JSON to Model
      // ---------------------------------------------------------

      final List<FollowupModel> followups = result
          .whereType<Map>()
          .map(
            (json) => FollowupModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();

      print(
        'FOLLOWUP COUNT: ${followups.length}',
      );

      return followups;
    } on DioException catch (e) {
      print(
        '================ UPCOMING FOLLOWUP ERROR ================',
      );

      print(
        'STATUS CODE: ${e.response?.statusCode}',
      );

      print(
        'URL: ${e.requestOptions.uri}',
      );

      print(
        'REQUEST DATA: ${e.requestOptions.data}',
      );

      print(
        'RESPONSE DATA: ${e.response?.data}',
      );

      print(
        '==========================================================',
      );

      throw Exception(
        'Followup API error: '
        '${e.response?.statusCode ?? 'Unknown'}',
      );
    } catch (e) {
      print(
        'UPCOMING FOLLOWUP API ERROR: $e',
      );

      rethrow;
    }
  }
}