import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/error/exceptions.dart';
import 'package:demo/features/leave/data/models/team_leave_model.dart';
import 'package:dio/dio.dart';


abstract class TeamLeaveRemoteDataSource {
  Future<List<TeamLeaveModel>> getTeamLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required String searchText,
  });

  Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String userId,
    required String remark,
    required String status,
  });
}

class TeamLeaveRemoteDataSourceImpl
    implements TeamLeaveRemoteDataSource {
  final DioClient dioClient;

  TeamLeaveRemoteDataSourceImpl({
    required this.dioClient,
  });

  dynamic _parseResponse(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }

    return data;
  }

  @override
  Future<List<TeamLeaveModel>> getTeamLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required String searchText,
  }) async {
    try {
      final requestData = {
        'userId': userId,
        'fromDate': fromDate,
        'toDate': toDate,
        'startLimit': startLimit.toString(),
        'searchText': searchText,
      };

      final response = await dioClient.client.post(
        ApiClient.getMyEmployeeLeaveList,
        data: requestData,
        options: Options(
          contentType:
              Headers.formUrlEncodedContentType,
          validateStatus: (status) =>
              status != null && status < 600,
        ),
      );

      print('======================================');
      print('TEAM LEAVE LIST API');
      print('URL = ${response.requestOptions.uri}');
      print('REQUEST = $requestData');
      print('STATUS = ${response.statusCode}');
      print('RESPONSE = ${response.data}');
      print('======================================');

      if (response.statusCode != 200) {
        throw ServerException(
          'Server error: ${response.statusCode}',
        );
      }

      final data = _parseResponse(response.data);

      if (data is! Map) {
        throw ServerException(
          'Invalid server response',
        );
      }

      if (data['status'] != true) {
        throw ServerException(
          data['message']?.toString() ??
              'Unable to fetch leave list',
        );
      }

      final result = data['result'];

      if (result == null) {
        return [];
      }

      if (result is! List) {
        throw ServerException(
          'Invalid leave list response',
        );
      }

      return result
          .whereType<Map>()
          .map(
            (item) => TeamLeaveModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print(
        'TEAM LEAVE DIO ERROR = ${e.message}',
      );

      throw NetworkException(
        e.message ?? 'Network error occurred',
      );
    } catch (e) {
      print(
        'TEAM LEAVE ERROR = $e',
      );

      throw NetworkException(
        e.toString(),
      );
    }
  }

  @override
  Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String userId,
    required String remark,
    required String status,
  }) async {
    try {
      final requestData = {
        'leaveId': leaveId,
        'userId': userId,
        'strRemark': remark,
        'status': status,
      };

      final response = await dioClient.client.post(
        // Replace with your actual update-status endpoint
        '/updateLeaveStatus',
        data: requestData,
        options: Options(
          contentType:
              Headers.formUrlEncodedContentType,
          validateStatus: (status) =>
              status != null && status < 600,
        ),
      );

      print('======================================');
      print('UPDATE LEAVE STATUS API');
      print('URL = ${response.requestOptions.uri}');
      print('REQUEST = $requestData');
      print('STATUS = ${response.statusCode}');
      print('RESPONSE = ${response.data}');
      print('======================================');

      if (response.statusCode != 200) {
        throw ServerException(
          'Server error: ${response.statusCode}',
        );
      }

      final data = _parseResponse(response.data);

      if (data is! Map) {
        throw ServerException(
          'Invalid server response',
        );
      }

      return Map<String, dynamic>.from(data);
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Network error occurred',
      );
    } catch (e) {
      throw NetworkException(
        e.toString(),
      );
    }
  }
}