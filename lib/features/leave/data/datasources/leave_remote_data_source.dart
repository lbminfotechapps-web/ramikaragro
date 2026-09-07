
import 'dart:convert';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:http/http.dart' as http;


import '../models/leave_model.dart';

abstract class LeaveRemoteDataSource {
  Future<List<LeaveModel>> getLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
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
  final http.Client client;

  LeaveRemoteDataSourceImpl({
    required this.client,
  });

  @override
  Future<List<LeaveModel>> getLeaveList({
    required String userId,
    required String fromDate,
    required String toDate,
    required int startLimit,
  }) async {
    final uri = Uri.parse(
      '${ApiClient.baseUrl}${ApiClient.getMyLeaveList}',
    );

    final params = <String, String>{
      'userId': userId,
      'fromDate': fromDate,
      'toDate': toDate,
      'startLimit': startLimit.toString(),
    };

    try {
      final response = await client
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
            },
            body: params,
          )
          .timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Server error: ${response.statusCode}',
        );
      }

      if (response.body.isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);

      // API directly returns List
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(LeaveModel.fromJson)
            .toList();
      }

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      final bool success = _isSuccess(
        decoded['status'],
      );

      // API returned false/no records
      if (!success) {
        return [];
      }

      final dynamic result =
          decoded['result'] ?? decoded['data'];

      if (result is! List) {
        return [];
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(LeaveModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception(
        _cleanErrorMessage(e),
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
    final uri = Uri.parse(
      '${ApiClient.baseUrl}${ApiClient.addLeave}',
    );

    final params = <String, String>{
      'userId': userId,
      'strFromDate': fromDate,
      'strEndDate': endDate,
      'spStartLeaveType': startLeaveType,
      'spEndLeaveType': endLeaveType,
      'strTotalLeaveDays': totalLeaveDays,
      'reason': reason,
    };

    try {
      final response = await client
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
            },
            body: params,
          )
          .timeout(
            const Duration(seconds: 30),
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Server error: ${response.statusCode}',
        );
      }

      if (response.body.isEmpty) {
        throw Exception('Empty server response');
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      final bool success = _isSuccess(
        decoded['status'],
      );

      if (!success) {
        final message =
            decoded['message'] ??
            decoded['msg'] ??
            decoded['error'] ??
            'Unable to apply leave';

        throw Exception(
          message.toString(),
        );
      }

      return (
        decoded['message'] ??
        decoded['msg'] ??
        'Leave applied successfully'
      ).toString();
    } catch (e) {
      throw Exception(
        _cleanErrorMessage(e),
      );
    }
  }

  bool _isSuccess(dynamic value) {
    if (value == true) {
      return true;
    }

    if (value is int && value == 1) {
      return true;
    }

    final String text =
        value?.toString().toLowerCase() ?? '';

    return text == 'true' || text == '1';
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}

