import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:solufine/core/api_constant/api_client.dart';

class MonthlyCollectionRemoteDataSource {
  final Dio dio;

  MonthlyCollectionRemoteDataSource({required this.dio});

  Future<String> submit({
    required int userId,
    required String monthYear,
    required List<Map<String, dynamic>> targets,
  }) async {
    try {
      final response = await dio.post(
        ApiClient.addMonthlyCollection,
        data: FormData.fromMap({
          'user_id': userId.toString(),
          'month_year': monthYear,
          'targets': jsonEncode(targets),
        }),
        options: Options(responseType: ResponseType.plain),
      );
      if (kDebugMode) {
        debugPrint('add_monthly_collection URL: ${response.requestOptions.uri}');
        debugPrint('add_monthly_collection status: ${response.statusCode}');
        debugPrint('add_monthly_collection raw response: ${response.data}');
      }
      final dynamic data = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      if (data is! Map) {
        throw const FormatException('Invalid response from collection service.');
      }
      final message = data['message']?.toString();
      if (response.statusCode != 200 || data['status'] != true) {
        throw Exception(message ?? 'Failed to save collection targets.');
      }
      return message ?? 'Collection targets saved successfully.';
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('add_monthly_collection error status: ${e.response?.statusCode}');
        debugPrint('add_monthly_collection error response: ${e.response?.data}');
        debugPrint('add_monthly_collection error: ${e.message}');
      }
      dynamic data = e.response?.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } on FormatException {
          // Use the transport message for non-JSON error responses.
        }
      }
      throw Exception(
        (data is Map ? data['message']?.toString() : null) ??
            e.message ??
            'Failed to save collection targets.',
      );
    } on FormatException {
      throw Exception('Invalid response from collection service.');
    }
  }
}
