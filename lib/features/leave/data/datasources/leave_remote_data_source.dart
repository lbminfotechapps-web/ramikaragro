import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/api_constant/dio_client.dart';
import 'package:dio/dio.dart';


import '../../../../core/error/exceptions.dart';
import '../models/leave_model.dart';

abstract class LeaveRemoteDataSource {
  Future<List<LeaveModel>> getLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
  });

  Future<String> addLeave({
    required String userId,
    required String fromDate,
    required String endDate,
    required String startLeaveType,
    required String endLeaveType,
    required String totalLeaveDays,
    required String reason,
  });
}

class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  final DioClient dioClient;

  LeaveRemoteDataSourceImpl({
    required this.dioClient,
  });

  dynamic _parseResponse(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    }

    return data;
  }

  @override
  Future<List<LeaveModel>> getLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await dioClient.client.post(
        ApiClient.getMyLeaveList,
        data: {
          "userId": userId,
          "fromDate": fromDate,
          "toDate": toDate,
          "startLimit": "0",
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      print("========== LEAVE LIST API ==========");
      print("REQUEST = ${{
        "userId": userId,
        "fromDate": fromDate,
        "toDate": toDate,
        "startLimit": "0",
      }}");
      print("STATUS CODE = ${response.statusCode}");
      print("RESPONSE = ${response.data}");
      print("====================================");

      if (response.statusCode != 200) {
        throw ServerException(
          "Server error: ${response.statusCode}",
        );
      }

      final data = _parseResponse(response.data);

      if (data is! Map) {
        throw ServerException("Invalid server response");
      }

      if (data["status"] != true) {
        throw ServerException(
          data["message"]?.toString() ??
              "Unable to fetch leave list",
        );
      }

      final result = data["result"];

      if (result == null) {
        return [];
      }

      if (result is! List) {
        throw ServerException(
          "Invalid leave list response",
        );
      }

      return result
          .map(
            (item) => LeaveModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print("LEAVE LIST DIO ERROR = ${e.message}");

      throw NetworkException(
        e.message ?? "Network error occurred",
      );
    } catch (e) {
      print("LEAVE LIST ERROR = $e");

      throw NetworkException(
        e.toString(),
      );
    }
  }

  @override
  Future<String> addLeave({
    required String userId,
    required String fromDate,
    required String endDate,
    required String startLeaveType,
    required String endLeaveType,
    required String totalLeaveDays,
    required String reason,
  }) async {
    try {
      final requestData = {
        "userId": userId,
        "strFromDate": fromDate,
        "strEndDate": endDate,
        "spStartLeaveType": startLeaveType,
        "spEndLeaveType": endLeaveType,
        "strTotalLeaveDays": totalLeaveDays,
        "reason": reason,
      };

      final response = await dioClient.client.post(
        ApiClient.addLeave,
        data: requestData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      print("========== ADD LEAVE API ==========");
      print("REQUEST = $requestData");
      print("STATUS CODE = ${response.statusCode}");
      print("RESPONSE = ${response.data}");
      print("===================================");

      if (response.statusCode != 200) {
        throw ServerException(
          "Server error: ${response.statusCode}",
        );
      }

      final data = _parseResponse(response.data);

      if (data is! Map) {
        throw ServerException(
          "Invalid server response",
        );
      }

      if (data["status"] == true) {
        return data["message"]?.toString() ??
            "Leave applied successfully";
      }

      throw ServerException(
        data["message"]?.toString() ??
            "Unable to apply leave",
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      print("ADD LEAVE DIO ERROR = ${e.message}");

      throw NetworkException(
        e.message ?? "Network error occurred",
      );
    } catch (e) {
      print("ADD LEAVE ERROR = $e");

      throw NetworkException(
        e.toString(),
      );
    }
  }
}