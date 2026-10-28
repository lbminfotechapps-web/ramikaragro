import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';

abstract class AddScheduleRemoteDataSource {
  Future<Map<String, dynamic>> submit(Map<String, dynamic> payload);
}

class AddScheduleRemoteDataSourceImpl implements AddScheduleRemoteDataSource {
  final DioClient dioClient;

  const AddScheduleRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> payload) async {
    final postData = <String, dynamic>{
      'empId': payload['empId'].toString(),
      'plotId': payload['plotId'].toString(),
      'farmerId': payload['farmerId'].toString(),
      'scheduleDate': payload['scheduleDate'].toString(),
      'details': jsonEncode(payload['details']),
      'remark': (payload['remark'] ?? '').toString(),
    };

    debugPrint('========== ADD SCHEDULE REQUEST ==========');
    final countsByDate = <String, int>{};
    for (final detail in payload['details'] as List) {
      final date = detail['date'].toString();
      countsByDate.update(date, (count) => count + 1, ifAbsent: () => 1);
    }
    debugPrint('TOTAL PRODUCTS: ${(payload['details'] as List).length}');
    debugPrint('PRODUCTS BY DATE: ${jsonEncode(countsByDate)}');
    debugPrint('PAYLOAD JSON:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(payload));
    debugPrint('POST DATA JSON:');
    debugPrint(jsonEncode(postData));
    debugPrint('empId: ${postData['empId']}');
    debugPrint('plotId: ${postData['plotId']}');
    debugPrint('farmerId: ${postData['farmerId']}');
    debugPrint('scheduleDate: ${postData['scheduleDate']}');
    debugPrint('details: ${postData['details']}');
    debugPrint('remark: ${postData['remark']}');

    try {
      final response = await dioClient.client.post<dynamic>(
        ApiClient.addSchedule,
        data: postData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          headers: {'Accept': 'application/json'},
        ),
      );

      dynamic body = response.data;

      if (body is String) {
        body = jsonDecode(body.trim());
      }

      if (body is! Map) {
        throw const FormatException('Invalid Add Schedule API response');
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
