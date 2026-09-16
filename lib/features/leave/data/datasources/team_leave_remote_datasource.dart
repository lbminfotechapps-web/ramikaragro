import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/error/exceptions.dart';
import 'package:demo/features/leave/data/models/team_leave_model.dart';
import 'package:dio/dio.dart';

abstract class TeamLeaveRemoteDataSource {
  // ==========================================================
  // GET TEAM LEAVE LIST
  // ==========================================================

  Future<List<TeamLeaveModel>> getTeamLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required String searchText,
  });

  // ==========================================================
  // UPDATE LEAVE STATUS
  // ==========================================================

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

  // ==========================================================
  // COMMON RESPONSE PARSER
  // ==========================================================

  dynamic _parseJsonResponse(dynamic responseData) {
    // --------------------------------------------------------
    // Dio already decoded JSON
    // --------------------------------------------------------

    if (responseData is Map) {
      return responseData;
    }

    // --------------------------------------------------------
    // Dio returned JSON as String
    // --------------------------------------------------------

    if (responseData is String) {
      final rawResponse = responseData.trim();

      if (rawResponse.isEmpty) {
        throw ServerException(
          'Empty server response',
        );
      }

      print('');
      print('========== RESPONSE STRING ==========');
      print(rawResponse);
      print('======================================');

      // ------------------------------------------------------
      // Normal JSON
      // Example:
      // {"status":true,"result":[],"message":"success"}
      // ------------------------------------------------------

      try {
        return jsonDecode(rawResponse);
      } catch (_) {
        // ----------------------------------------------------
        // Ignore here.
        //
        // The response may contain PHP warning/HTML before
        // the actual JSON.
        // ----------------------------------------------------
      }

      // ------------------------------------------------------
      // PHP WARNING + JSON
      //
      // Example:
      //
      // <div>
      //   PHP Warning...
      // </div>
      // {"status":true,"result":"success"}
      //
      // Find the first JSON object.
      // ------------------------------------------------------

      final jsonStart = rawResponse.indexOf('{');

      if (jsonStart == -1) {
        throw ServerException(
          'Invalid server response. JSON not found.',
        );
      }

      final jsonString =
          rawResponse.substring(jsonStart).trim();

      print('');
      print('========== EXTRACTED JSON ==========');
      print(jsonString);
      print('=====================================');

      try {
        return jsonDecode(jsonString);
      } catch (e) {
        print('JSON DECODE ERROR: $e');

        throw ServerException(
          'Unable to parse server response',
        );
      }
    }

    // --------------------------------------------------------
    // Unsupported response type
    // --------------------------------------------------------

    throw ServerException(
      'Invalid server response format',
    );
  }

  // ==========================================================
  // CHECK HTTP STATUS
  // ==========================================================

  void _checkHttpStatus(Response response) {
    print('HTTP STATUS: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw ServerException(
        'Server error: ${response.statusCode}',
      );
    }
  }

  // ==========================================================
  // GET TEAM LEAVE LIST
  // ==========================================================

  @override
  Future<List<TeamLeaveModel>> getTeamLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
    required String searchText,
  }) async {
    try {
      // ------------------------------------------------------
      // Request
      // ------------------------------------------------------

      final requestData = {
        'userId': userId,
        'fromDate': fromDate,
        'toDate': toDate,
        'startLimit': startLimit.toString(),
        'searchText': searchText,
      };

      print('');
      print('========================================');
      print('       GET TEAM LEAVE LIST API');
      print('========================================');

      print(
        'URL: '
        '${ApiClient.baseUrl}'
        '${ApiClient.getMyEmployeeLeaveList}',
      );

      print('REQUEST: $requestData');

      print('========================================');

      // ------------------------------------------------------
      // API call
      // ------------------------------------------------------

      final response = await dioClient.client.post(
        ApiClient.getMyEmployeeLeaveList,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,

          // Do not let Dio throw automatically for 4xx/5xx.
          // We handle it manually.
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      // ------------------------------------------------------
      // Response
      // ------------------------------------------------------

      print('');
      print('========== TEAM LEAVE RESPONSE ==========');
      print('STATUS: ${response.statusCode}');
      print(
        'TYPE: ${response.data.runtimeType}',
      );
      print('RAW RESPONSE: ${response.data}');
      print('==========================================');

      // ------------------------------------------------------
      // Check HTTP status
      // ------------------------------------------------------

      _checkHttpStatus(response);

      // ------------------------------------------------------
      // Parse response
      // ------------------------------------------------------

      final parsedData =
          _parseJsonResponse(response.data);

      print('');
      print('========== PARSED TEAM LEAVE ==========');
      print(
        'TYPE: ${parsedData.runtimeType}',
      );
      print('DATA: $parsedData');
      print('========================================');

      // ------------------------------------------------------
      // Response must be Map
      // ------------------------------------------------------

      if (parsedData is! Map) {
        throw ServerException(
          'Invalid server response format',
        );
      }

      final data =
          Map<String, dynamic>.from(parsedData);

      // ------------------------------------------------------
      // API status
      // ------------------------------------------------------

      final apiStatus = data['status'];

      print(
        'API STATUS: $apiStatus',
      );

      final bool success =
          apiStatus == true ||
          apiStatus
                  ?.toString()
                  .toLowerCase() ==
              'true';

      if (!success) {
        throw ServerException(
          data['message']?.toString() ??
              'Unable to fetch team leave list',
        );
      }

      // ------------------------------------------------------
      // Result
      // ------------------------------------------------------

      final result = data['result'];

      print(
        'RESULT TYPE: ${result.runtimeType}',
      );

      print(
        'RESULT: $result',
      );

      // ------------------------------------------------------
      // No records
      // ------------------------------------------------------

      if (result == null) {
        print(
          'TEAM LEAVE RESULT IS NULL',
        );

        return [];
      }

      // ------------------------------------------------------
      // Result must be List
      // ------------------------------------------------------

      if (result is! List) {
        throw ServerException(
          'Invalid leave result format',
        );
      }

      // ------------------------------------------------------
      // Convert JSON → Model
      // ------------------------------------------------------

      final List<TeamLeaveModel> leaves = [];

      for (final item in result) {
        if (item is! Map) {
          print(
            'SKIPPING INVALID LEAVE ITEM: $item',
          );

          continue;
        }

        final json =
            Map<String, dynamic>.from(item);

        print('');
        print('---------- MAPPING LEAVE ----------');
        print('JSON: $json');

        try {
          final leave =
              TeamLeaveModel.fromJson(json);

          print(
            'LEAVE ID: ${leave.leaveId}',
          );

          print(
            'EMPLOYEE: ${leave.employeeName}',
          );

          print(
            'STATUS: ${leave.status}',
          );

          leaves.add(leave);
        } catch (e, stackTrace) {
          print(
            'LEAVE MODEL MAPPING ERROR: $e',
          );

          print(stackTrace);

          // If one bad record exists, don't necessarily
          // destroy the complete list.
          continue;
        }
      }

      // ------------------------------------------------------
      // Final result
      // ------------------------------------------------------

      print('');
      print('========================================');
      print(
        'TOTAL TEAM LEAVES: ${leaves.length}',
      );
      print('========================================');

      return leaves;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      print('');
      print('========================================');
      print('       TEAM LEAVE DIO ERROR');
      print('========================================');

      print('MESSAGE: ${e.message}');
      print('TYPE: ${e.type}');
      print('ERROR: ${e.error}');
      print('RESPONSE: ${e.response?.data}');

      print('STACK TRACE:');
      print(stackTrace);

      print('========================================');

      throw NetworkException(
        e.message ?? 'Network error occurred',
      );
    } catch (e, stackTrace) {
      print('');
      print('========================================');
      print('       TEAM LEAVE ERROR');
      print('========================================');

      print('ERROR: $e');
      print('STACK TRACE: $stackTrace');

      print('========================================');

      throw NetworkException(
        e.toString(),
      );
    }
  }

  // ==========================================================
  // UPDATE LEAVE STATUS
  // ==========================================================

  @override
  Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String userId,
    required String remark,
    required String status,
  }) async {
    try {
      // ------------------------------------------------------
      // Request data
      // ------------------------------------------------------

      final requestData = {
        'leaveId': leaveId,
        'userId': userId,
        'strRemark': remark,
        'status': status,
      };

      print('');
      print('========================================');
      print('       UPDATE LEAVE STATUS API');
      print('========================================');

      print(
        'URL: '
        '${ApiClient.baseUrl}'
        '${ApiClient.updateLeaveStatus}',
      );

      print('REQUEST: $requestData');

      print('');
      print('LEAVE ID: $leaveId');
      print('USER ID: $userId');
      print('REMARK: $remark');
      print('STATUS: $status');

      if (status == '1') {
        print('ACTION: APPROVE');
      } else if (status == '2') {
        print('ACTION: REJECT');
      } else {
        print('ACTION: UNKNOWN');
      }

      print('========================================');

      // ------------------------------------------------------
      // API call
      // ------------------------------------------------------

      final response = await dioClient.client.post(
        ApiClient.updateLeaveStatus,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,

          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      // ------------------------------------------------------
      // Raw response
      // ------------------------------------------------------

      print('');
      print('========================================');
      print('       UPDATE LEAVE RESPONSE');
      print('========================================');

      print(
        'HTTP STATUS: ${response.statusCode}',
      );

      print(
        'RESPONSE TYPE: '
        '${response.data.runtimeType}',
      );

      print(
        'RAW RESPONSE: ${response.data}',
      );

      print('========================================');

      // ------------------------------------------------------
      // HTTP status
      // ------------------------------------------------------

      _checkHttpStatus(response);

      // ------------------------------------------------------
      // Parse response
      //
      // Handles:
      //
      // 1. Map
      // 2. JSON String
      // 3. PHP warning + JSON
      // ------------------------------------------------------

      final parsedData =
          _parseJsonResponse(response.data);

      print('');
      print('========================================');
      print('       PARSED UPDATE RESPONSE');
      print('========================================');

      print(
        'TYPE: ${parsedData.runtimeType}',
      );

      print(
        'DATA: $parsedData',
      );

      print('========================================');

      // ------------------------------------------------------
      // Check Map
      // ------------------------------------------------------

      if (parsedData is! Map) {
        throw ServerException(
          'Invalid update response format',
        );
      }

      final result =
          Map<String, dynamic>.from(parsedData);

      // ------------------------------------------------------
      // API status
      // ------------------------------------------------------

      final apiStatus = result['status'];

      final bool success =
          apiStatus == true ||
          apiStatus
                  ?.toString()
                  .toLowerCase() ==
              'true';

      print('');
      print('========================================');
      print('       UPDATE API RESULT');
      print('========================================');

      print(
        'STATUS: ${result['status']}',
      );

      print(
        'RESULT: ${result['result']}',
      );

      print(
        'MESSAGE: ${result['message']}',
      );

      print(
        'SUCCESS: $success',
      );

      print('========================================');

      // ------------------------------------------------------
      // API returned failure
      // ------------------------------------------------------

      if (!success) {
        throw ServerException(
          result['message']?.toString() ??
              'Unable to update leave status',
        );
      }

      // ------------------------------------------------------
      // SUCCESS
      // ------------------------------------------------------

      print('');
      print('****************************************');
      print('      LEAVE STATUS UPDATE SUCCESS');
      print('****************************************');

      if (status == '1') {
        print('Leave APPROVED successfully');
      } else if (status == '2') {
        print('Leave REJECTED successfully');
      }

      print(
        'Message: ${result['message']}',
      );

      print('****************************************');
      print('');

      return result;
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on DioException catch (e, stackTrace) {
      print('');
      print('========================================');
      print('       UPDATE LEAVE DIO ERROR');
      print('========================================');

      print('MESSAGE: ${e.message}');
      print('TYPE: ${e.type}');
      print('ERROR: ${e.error}');
      print(
        'STATUS: ${e.response?.statusCode}',
      );
      print(
        'RESPONSE: ${e.response?.data}',
      );

      print('STACK TRACE:');
      print(stackTrace);

      print('========================================');

      throw NetworkException(
        e.message ?? 'Network error occurred',
      );
    } catch (e, stackTrace) {
      print('');
      print('========================================');
      print('       UPDATE LEAVE ERROR');
      print('========================================');

      print('ERROR: $e');

      print('STACK TRACE:');
      print(stackTrace);

      print('========================================');

      throw NetworkException(
        e.toString(),
      );
    }
  }
}