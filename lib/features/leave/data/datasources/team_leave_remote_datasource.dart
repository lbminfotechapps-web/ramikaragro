import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/core/error/exceptions.dart';
import 'package:solufine/features/leave/data/models/team_leave_model.dart';

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
      // ------------------------------------------------------

      try {
        return jsonDecode(rawResponse);
      } catch (_) {
        // Continue below.
        // Response may contain PHP warning/HTML before JSON.
      }

      // ------------------------------------------------------
      // PHP WARNING + JSON
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
      // ======================================================
      // REQUEST
      // ======================================================

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

      // ======================================================
      // API CALL
      // ======================================================

      final response = await dioClient.client.post(
        ApiClient.getMyEmployeeLeaveList,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,

          // Do not let Dio throw automatically.
          // We handle HTTP status manually.
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      // ======================================================
      // RAW RESPONSE
      // ======================================================

      print('');
      print('========== TEAM LEAVE RESPONSE ==========');
      print('STATUS: ${response.statusCode}');
      print(
        'TYPE: ${response.data.runtimeType}',
      );
      print(
        'RAW RESPONSE: ${response.data}',
      );
      print('==========================================');

      // ======================================================
      // CHECK HTTP STATUS
      // ======================================================

      _checkHttpStatus(response);

      // ======================================================
      // PARSE RESPONSE
      // ======================================================

      final parsedData = _parseJsonResponse(
        response.data,
      );

      print('');
      print('========== PARSED TEAM LEAVE ==========');
      print(
        'TYPE: ${parsedData.runtimeType}',
      );
      print(
        'DATA: $parsedData',
      );
      print('========================================');

      // ======================================================
      // RESPONSE MUST BE MAP
      // ======================================================

      if (parsedData is! Map) {
        throw ServerException(
          'Invalid server response format',
        );
      }

      final data = Map<String, dynamic>.from(
        parsedData,
      );

      // ======================================================
      // API STATUS
      // ======================================================

      final apiStatus = data['status'];

      print('');
      print('========================================');
      print('       TEAM LEAVE API STATUS');
      print('========================================');
      print('STATUS: $apiStatus');
      print('MESSAGE: ${data['message']}');
      print('========================================');

      final bool success =
          apiStatus == true ||
          apiStatus?.toString().toLowerCase() == 'true';

      // ======================================================
      // GET RESULT
      //
      // IMPORTANT:
      //
      // We get result BEFORE checking success because the
      // backend sends:
      //
      // status: false
      // message: No Record Found
      // result: []
      //
      // This should be treated as an empty list.
      // ======================================================

      final result = data['result'];

      print('');
      print('========== TEAM LEAVE RESULT ==========');
      print(
        'RESULT TYPE: ${result.runtimeType}',
      );
      print(
        'RESULT: $result',
      );
      print('========================================');

      // ======================================================
      // NO RECORDS
      //
      // Handles:
      //
      // {
      //   "status": false,
      //   "message": "No Record Found",
      //   "result": []
      // }
      //
      // AND:
      //
      // {
      //   "status": true,
      //   "result": []
      // }
      //
      // Both return an empty list.
      // ======================================================

      if (result is List && result.isEmpty) {
        print('');
        print('========================================');
        print('       TEAM LEAVE: NO RECORDS');
        print('========================================');
        print('API STATUS: $apiStatus');
        print(
          'MESSAGE: ${data['message']}',
        );
        print('RESULT COUNT: 0');
        print('Returning empty list...');
        print('========================================');

        return [];
      }

      // ======================================================
      // NULL RESULT
      // ======================================================

      if (result == null) {
        print('');
        print('========================================');
        print('TEAM LEAVE RESULT IS NULL');
        print('========================================');

        // If API says success and result is null,
        // consider it an empty list.
        if (success) {
          print(
            'API SUCCESS WITH NULL RESULT',
          );

          return [];
        }

        throw ServerException(
          data['message']?.toString() ??
              'Unable to fetch team leave list',
        );
      }

      // ======================================================
      // API FAILURE
      //
      // If status=false but result is NOT an empty list,
      // this is considered an actual API failure.
      // ======================================================

      if (!success) {
        print('');
        print('========================================');
        print('       TEAM LEAVE API FAILURE');
        print('========================================');
        print('STATUS: $apiStatus');
        print(
          'MESSAGE: ${data['message']}',
        );
        print(
          'RESULT: $result',
        );
        print('========================================');

        throw ServerException(
          data['message']?.toString() ??
              'Unable to fetch team leave list',
        );
      }

      // ======================================================
      // RESULT MUST BE LIST
      // ======================================================

      if (result is! List) {
        print('');
        print('========================================');
        print('INVALID TEAM LEAVE RESULT');
        print('========================================');
        print(
          'EXPECTED: List',
        );
        print(
          'ACTUAL: ${result.runtimeType}',
        );
        print(
          'VALUE: $result',
        );
        print('========================================');

        throw ServerException(
          'Invalid leave result format',
        );
      }

      // ======================================================
      // CONVERT JSON → MODEL
      // ======================================================

      final List<TeamLeaveModel> leaves = [];

      print('');
      print('========================================');
      print('       MAPPING TEAM LEAVE LIST');
      print('========================================');

      print(
        'TOTAL API RECORDS: ${result.length}',
      );

      print('========================================');

      for (final item in result) {
        // ----------------------------------------------------
        // Validate item
        // ----------------------------------------------------

        if (item is! Map) {
          print('');
          print(
            'SKIPPING INVALID LEAVE ITEM: $item',
          );

          continue;
        }

        final json = Map<String, dynamic>.from(
          item,
        );

        print('');
        print('---------- MAPPING LEAVE ----------');
        print(
          'JSON: $json',
        );

        try {
          final leave = TeamLeaveModel.fromJson(
            json,
          );

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
          print('');
          print(
            'LEAVE MODEL MAPPING ERROR: $e',
          );

          print('');
          print('STACK TRACE:');
          print(stackTrace);

          // One invalid record should not destroy
          // the complete leave list.
          continue;
        }
      }

      // ======================================================
      // FINAL RESULT
      // ======================================================

      print('');
      print('========================================');
      print('       TEAM LEAVE FINAL RESULT');
      print('========================================');
      print(
        'TOTAL TEAM LEAVES: ${leaves.length}',
      );
      print('========================================');

      return leaves;
    }

    // ========================================================
    // SERVER EXCEPTION
    // ========================================================

    on ServerException {
      print('');
      print('TEAM LEAVE SERVER EXCEPTION');
      rethrow;
    }

    // ========================================================
    // NETWORK EXCEPTION
    // ========================================================

    on NetworkException {
      print('');
      print('TEAM LEAVE NETWORK EXCEPTION');
      rethrow;
    }

    // ========================================================
    // DIO EXCEPTION
    // ========================================================

    on DioException catch (e, stackTrace) {
      print('');
      print('========================================');
      print('       TEAM LEAVE DIO ERROR');
      print('========================================');

      print(
        'MESSAGE: ${e.message}',
      );

      print(
        'TYPE: ${e.type}',
      );

      print(
        'ERROR: ${e.error}',
      );

      print(
        'STATUS: ${e.response?.statusCode}',
      );

      print(
        'RESPONSE: ${e.response?.data}',
      );

      print('');
      print('STACK TRACE:');
      print(stackTrace);

      print('========================================');

      throw NetworkException(
        e.message ?? 'Network error occurred',
      );
    }

    // ========================================================
    // UNKNOWN EXCEPTION
    // ========================================================

    catch (e, stackTrace) {
      print('');
      print('========================================');
      print('       TEAM LEAVE ERROR');
      print('========================================');

      print(
        'ERROR: $e',
      );

      print('');
      print('STACK TRACE:');
      print(stackTrace);

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
      // ======================================================
      // REQUEST DATA
      // ======================================================

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

      print(
        'REQUEST: $requestData',
      );

      print('');
      print(
        'LEAVE ID: $leaveId',
      );

      print(
        'USER ID: $userId',
      );

      print(
        'REMARK: $remark',
      );

      print(
        'STATUS: $status',
      );

      if (status == '1') {
        print('ACTION: APPROVE');
      } else if (status == '2') {
        print('ACTION: REJECT');
      } else {
        print('ACTION: UNKNOWN');
      }

      print('========================================');

      // ======================================================
      // API CALL
      // ======================================================

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

      // ======================================================
      // RAW RESPONSE
      // ======================================================

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

      // ======================================================
      // HTTP STATUS
      // ======================================================

      _checkHttpStatus(response);

      // ======================================================
      // PARSE RESPONSE
      // ======================================================

      final parsedData = _parseJsonResponse(
        response.data,
      );

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

      // ======================================================
      // CHECK MAP
      // ======================================================

      if (parsedData is! Map) {
        throw ServerException(
          'Invalid update response format',
        );
      }

      final result = Map<String, dynamic>.from(
        parsedData,
      );

      // ======================================================
      // API STATUS
      // ======================================================

      final apiStatus = result['status'];

      final bool success =
          apiStatus == true ||
          apiStatus?.toString().toLowerCase() == 'true';

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

      // ======================================================
      // API RETURNED FAILURE
      // ======================================================

      if (!success) {
        throw ServerException(
          result['message']?.toString() ??
              'Unable to update leave status',
        );
      }

      // ======================================================
      // SUCCESS
      // ======================================================

      print('');
      print('****************************************');
      print('      LEAVE STATUS UPDATE SUCCESS');
      print('****************************************');

      if (status == '1') {
        print(
          'Leave APPROVED successfully',
        );
      } else if (status == '2') {
        print(
          'Leave REJECTED successfully',
        );
      }

      print(
        'Message: ${result['message']}',
      );

      print('****************************************');
      print('');

      return result;
    }

    // ========================================================
    // SERVER EXCEPTION
    // ========================================================

    on ServerException {
      rethrow;
    }

    // ========================================================
    // NETWORK EXCEPTION
    // ========================================================

    on NetworkException {
      rethrow;
    }

    // ========================================================
    // DIO EXCEPTION
    // ========================================================

    on DioException catch (e, stackTrace) {
      print('');
      print('========================================');
      print('       UPDATE LEAVE DIO ERROR');
      print('========================================');

      print(
        'MESSAGE: ${e.message}',
      );

      print(
        'TYPE: ${e.type}',
      );

      print(
        'ERROR: ${e.error}',
      );

      print(
        'STATUS: ${e.response?.statusCode}',
      );

      print(
        'RESPONSE: ${e.response?.data}',
      );

      print('');
      print('STACK TRACE:');
      print(stackTrace);

      print('========================================');

      throw NetworkException(
        e.message ?? 'Network error occurred',
      );
    }

    // ========================================================
    // UNKNOWN EXCEPTION
    // ========================================================

    catch (e, stackTrace) {
      print('');
      print('========================================');
      print('       UPDATE LEAVE ERROR');
      print('========================================');

      print(
        'ERROR: $e',
      );

      print('');
      print('STACK TRACE:');
      print(stackTrace);

      print('========================================');

      throw NetworkException(
        e.toString(),
      );
    }
  }
}