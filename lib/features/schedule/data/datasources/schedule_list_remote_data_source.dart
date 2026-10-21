
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api_constant/api_client.dart';
import '../../../../core/api_constant/dio_client.dart';

abstract class ScheduleListRemoteDataSource {
  Future<List<Map<String, dynamic>>> getSchedules(
    Map<String, String> postData,
  );

  Future<List<Map<String, dynamic>>> searchFarmers(
    String farmerName,
  );
}

class ScheduleListRemoteDataSourceImpl
    implements ScheduleListRemoteDataSource {
  final DioClient dioClient;

  const ScheduleListRemoteDataSourceImpl({
    required this.dioClient,
  });

  Map<String, dynamic> _parseResponse(
    dynamic responseData,
  ) {
    dynamic data = responseData;

    if (data is String) {
      data = jsonDecode(data.trim());
    }

    if (data is! Map) {
      throw const FormatException(
        'Invalid server response.',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  List<Map<String, dynamic>> _parseResult(
    dynamic responseData,
  ) {
    final json = _parseResponse(responseData);

    final status = json['status'];
    final success = status == true ||
        status == 1 ||
        status.toString().toLowerCase() == 'true';

    final result = json['result'];
    final message = json['message']?.toString() ?? '';

    if (!success) {
      if (result is List && result.isEmpty) {
        return [];
      }

      if (message.toLowerCase().contains('no record')) {
        return [];
      }

      throw Exception(
        message.isEmpty
            ? 'Unable to load schedules.'
            : message,
      );
    }

    if (result is! List) {
      throw const FormatException(
        'Expected a result array.',
      );
    }

    return result.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'Invalid result item.',
        );
      }

      return Map<String, dynamic>.from(item);
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getSchedules(
    Map<String, String> postData,
  ) async {
    debugPrint('========== GET SCHEDULE LIST ==========');

    postData.forEach((key, value) {
      debugPrint('$key: $value');
    });

    final response = await dioClient.client.post<dynamic>(
      ApiClient.getScheduleList,
      data: postData,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );

    debugPrint(
      'GET SCHEDULE RESPONSE: ${response.data}',
    );

    return _parseResult(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> searchFarmers(
    String farmerName,
  ) async {
    final response = await dioClient.client.post<dynamic>(
      ApiClient.getScheduleFarmerList,
      data: {
        'farmerName': farmerName,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );

    return _parseResult(response.data);
  }
}
