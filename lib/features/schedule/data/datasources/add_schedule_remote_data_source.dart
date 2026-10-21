
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';

abstract class AddScheduleRemoteDataSource {
  Future<Map<String, dynamic>> submit(
    Map<String, dynamic> payload,
  );
}

class AddScheduleRemoteDataSourceImpl
    implements AddScheduleRemoteDataSource {
  final DioClient dioClient;

  const AddScheduleRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<Map<String, dynamic>> submit(
    Map<String, dynamic> payload,
  ) async {
    final postData = <String, dynamic>{
      'empId': payload['empId'].toString(),
      'plotId': payload['plotId'].toString(),
      'farmerId': payload['farmerId'].toString(),
      'scheduleDate': payload['scheduleDate'].toString(),
      'details': jsonEncode(payload['details']),
    };

    debugPrint('========== ADD SCHEDULE REQUEST ==========');
    debugPrint('empId: ${postData['empId']}');
    debugPrint('plotId: ${postData['plotId']}');
    debugPrint('farmerId: ${postData['farmerId']}');
    debugPrint('scheduleDate: ${postData['scheduleDate']}');
    debugPrint('details: ${postData['details']}');

    try {
      final response =
          await dioClient.client.post<dynamic>(
        ApiClient.addSchedule,
        data: postData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      dynamic body = response.data;

      if (body is String) {
        body = jsonDecode(body.trim());
      }

      if (body is! Map) {
        throw const FormatException(
          'Invalid Add Schedule API response',
        );
      }

      final result = Map<String, dynamic>.from(body);

      debugPrint('========== ADD SCHEDULE RESPONSE ==========');
      debugPrint('HTTP STATUS: ${response.statusCode}');
      debugPrint(jsonEncode(result));

      return result;
    } on DioException catch (error) {
      debugPrint('========== ADD SCHEDULE ERROR ==========');
      debugPrint('MESSAGE: ${error.message}');
      debugPrint('HTTP STATUS: ${error.response?.statusCode}');
      debugPrint('RESPONSE: ${error.response?.data}');
      rethrow;
    }
  }
}
