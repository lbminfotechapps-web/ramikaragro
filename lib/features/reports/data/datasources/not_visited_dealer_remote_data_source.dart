
import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/features/reports/data/modles/not_visited_dealer_model.dart';
import 'package:dio/dio.dart';


class NotVisitedDealerRemoteDataSource {
  final DioClient dioClient;

  NotVisitedDealerRemoteDataSource({
    required this.dioClient,
  });

  // ============================================================
  // GET NOT VISITED DEALERS
  // ============================================================

  Future<List<NotVisitedDealerModel>> getNotVisitedDealers({
    required int days,
    required int startLimit,
  }) async {
    try {
      final formData = FormData.fromMap({
        'days': days,
        'startLimit': startLimit,
      });

     print(''); print('========================================');
      print('NOT VISITED DEALER API'); print('========================================'); print('Endpoint : ${ApiClient.getLastThirtyNotVisited}'); print('days : $days'); print('startLimit : $startLimit'); print('========================================'); final response = await dioClient.client.post( ApiClient.getLastThirtyNotVisited, data: formData, options: Options( responseType: ResponseType.plain, ), );
      print('');
      print('========================================');
      print('NOT VISITED DEALER RESPONSE');
      print('========================================');
      print('Status Code : ${response.statusCode}');
      print('Response    : ${response.data}');
      print('========================================');

      // ==========================================================
      // PARSE RESPONSE
      // ==========================================================

      dynamic responseData = response.data;

      if (responseData is String) {
        String responseString = responseData.trim();

        // Remove PHP warning/output before JSON.
        final jsonStart = responseString.indexOf('{');

        if (jsonStart >= 0) {
          responseString =
              responseString.substring(jsonStart);
        }

        responseData = jsonDecode(responseString);
      }

      if (responseData is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format from server.',
        );
      }

      // ==========================================================
      // STATUS
      // ==========================================================

      final bool status =
          responseData['status'] == true ||
          responseData['status']
                  ?.toString()
                  .toLowerCase() ==
              'true';

      if (!status) {
        throw Exception(
          responseData['message']?.toString() ??
              'Unable to fetch not visited dealers.',
        );
      }

      // ==========================================================
      // RESULT
      // ==========================================================

      final dynamic result = responseData['result'];

      if (result == null) {
        return [];
      }

      if (result is! List) {
        throw Exception(
          'Invalid dealer result format.',
        );
      }

      final dealers = result
          .whereType<Map>()
          .map(
            (json) => NotVisitedDealerModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();

      print('');
      print('========================================');
      print('PARSED NOT VISITED DEALERS');
      print('========================================');
      print('Received dealers : ${dealers.length}');
      print('========================================');

      return dealers;
    } on DioException catch (e) {
      print('');
      print('========================================');
      print('NOT VISITED DEALER DIO ERROR');
      print('========================================');
      print('Message  : ${e.message}');
      print('Error    : ${e.error}');
      print('Response : ${e.response?.data}');
      print('========================================');

      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            'Network error while fetching dealers.',
      );
    } catch (e) {
      print('');
      print('========================================');
      print('NOT VISITED DEALER ERROR');
      print('========================================');
      print(e);
      print('========================================');

      rethrow;
    }
  }
}

