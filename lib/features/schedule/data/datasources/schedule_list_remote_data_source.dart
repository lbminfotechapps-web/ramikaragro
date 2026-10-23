
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api_constant/api_client.dart';
import '../../../../core/api_constant/dio_client.dart';

abstract class ScheduleListRemoteDataSource {
  Future<String> deleteSchedule({
    required String scheduleId,
    required String empId,
  });

  Future<String> updateScheduleStatus({
    required String scheduleId,
    required String empId,
  });

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

  Map<String, dynamic> _parseResponse(dynamic responseData) {
    dynamic data = responseData;

    if (data is String) {
      data = jsonDecode(data.trim());
    }

    if (data is! Map) {
      throw const FormatException('Invalid server response.');
    }

    return Map<String, dynamic>.from(data);
  }

  bool _isSuccess(dynamic status) {
    return status == true ||
        status == 1 ||
        status.toString().toLowerCase() == 'true';
  }

  List<Map<String, dynamic>> _parseResult(dynamic responseData) {
    final json = _parseResponse(responseData);

    final success = _isSuccess(json['status']);
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
        message.isEmpty ? 'Unable to load records.' : message,
      );
    }

    if (result is! List) {
      throw const FormatException('Expected a result array.');
    }

    return result.map((item) {
      if (item is! Map) {
        throw const FormatException('Invalid result item.');
      }

      return Map<String, dynamic>.from(item);
    }).toList();
  }

  // ================= GET SCHEDULE LIST =================

  @override
  Future<List<Map<String, dynamic>>> getSchedules(
    Map<String, String> postData,
  ) async {
    debugPrint('========== GET SCHEDULE LIST ==========');
    debugPrint('Params: $postData');

    final response = await dioClient.client.post<dynamic>(
      ApiClient.getScheduleList,
      data: postData,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );

    debugPrint('Schedule Response: ${response.data}');

    return _parseResult(response.data);
  }

  // ================= SEARCH FARMERS =================

  @override
  Future<List<Map<String, dynamic>>> searchFarmers(
    String farmerName,
  ) async {
    final response = await dioClient.client.post<dynamic>(
      ApiClient.getScheduleFarmerList,
      data: {'farmerName': farmerName},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );

    return _parseResult(response.data);
  }

  // ================= DELETE SCHEDULE =================

  @override
  Future<String> deleteSchedule({
    required String scheduleId,
    required String empId,
  }) async {
    final params = {
      'scheduleId': scheduleId.trim(),
      'empId': empId.trim(),
    };

    final response = await dioClient.client.post<dynamic>(
      ApiClient.deleteSchedule,
      data: params,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.plain,
      ),
    );

    final body = _parseResponse(response.data);

    final message = body['message']?.toString().trim() ?? '';

    if (!_isSuccess(body['status'])) {
      throw Exception(
        message.isEmpty ? 'Unable to delete schedule.' : message,
      );
    }

    return message.isEmpty
        ? 'Schedule deleted successfully.'
        : message;
  }

  // ================= UPDATE SCHEDULE =================

  @override
  Future<String> updateScheduleStatus({
    required String scheduleId,
    required String empId,
  }) async {
    try {
      if (scheduleId.trim().isEmpty || empId.trim().isEmpty) {
        throw ArgumentError('Schedule ID and Employee ID are required.');
      }

      final params = <String, String>{
        'scheduleId': scheduleId.trim(),
        'empId': empId.trim(),
      };

      debugPrint('========== UPDATE SCHEDULE ==========');
      debugPrint('Params: $params');

      final response = await dioClient.client.post<dynamic>(
        ApiClient.updateSchedule,
        data: params,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
        ),
      );

      debugPrint('Update Response: ${response.data}');

      final body = _parseResponse(response.data);

      final success = _isSuccess(body['status']);

      final message =
          body['message']?.toString().trim() ?? '';

      if (!success) {
        throw Exception(
          message.isEmpty
              ? 'Unable to update schedule.'
              : message,
        );
      }

      return message.isEmpty
          ? 'Schedule updated successfully.'
          : message;
    } on DioException catch (e) {
      debugPrint('Update Schedule Dio Error: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Update Schedule Error: $e');
      rethrow;
    }
  }
}
