
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:solufine/core/api_constant/api_client.dart';

import '../../domain/entities/assigned_task.dart';
import '../models/assigned_task_model.dart';

// ======================================================
// ABSTRACT DATA SOURCE
// ======================================================

abstract class AssignedTaskRemoteDataSource {
  Future<List<AssignedTaskModel>> getAssignedTasks({
    required String loginUserId,
    required AssignedTaskFilter filter,
  });
}

// ======================================================
// IMPLEMENTATION
// ======================================================

class AssignedTaskRemoteDataSourceImpl
    implements AssignedTaskRemoteDataSource {

  const AssignedTaskRemoteDataSourceImpl(this.dio);

  final Dio dio;

  @override
  Future<List<AssignedTaskModel>> getAssignedTasks({
    required String loginUserId,
    required AssignedTaskFilter filter,
  }) async {

    // ==================================================
    // 1. VALIDATE USER ID
    // ==================================================

    if (loginUserId.trim().isEmpty ||
        loginUserId.trim() == '0') {
      throw StateError('Please log in again.');
    }

    // ==================================================
    // 2. PREPARE PARAMETERS
    // ==================================================

    final params = <String, String>{
      'login_user_id': loginUserId.trim(),
      'priority_level': filter.priority,
      'status': filter.status,
      'from_date': filter.fromDate == null
          ? ''
          : DateFormat('dd/MM/yyyy')
              .format(filter.fromDate!),
      'emp_id': filter.employeeId,
    };

    debugPrint('======================================');
    debugPrint('ASSIGNED TASK API REQUEST');
    debugPrint('PARAMETERS: $params');
    debugPrint('======================================');

    try {

      // ================================================
      // 3. API CALL
      // ================================================

      final response = await dio.post<dynamic>(
        ApiClient.assignedTaskList,
        data: params,
        options: Options(
          contentType:
              Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );

      debugPrint('======================================');
      debugPrint('ASSIGNED TASK API RESPONSE');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint(
        'RESPONSE TYPE: ${response.data.runtimeType}',
      );
      debugPrint('RESPONSE: ${response.data}');
      debugPrint('======================================');

      // ================================================
      // 4. HANDLE JSON STRING OR MAP
      // ================================================

      dynamic raw = response.data;

      if (raw is String) {
        raw = jsonDecode(raw);
      }

      if (raw is! Map) {
        throw const FormatException(
          'Invalid assigned task API response',
        );
      }

      final data = Map<String, dynamic>.from(raw);

      // ================================================
      // 5. CHECK API STATUS
      // ================================================

      final success = data['status'] == true ||
          data['status']
                  ?.toString()
                  .toLowerCase() ==
              'true';

      debugPrint('API STATUS: ${data['status']}');
      debugPrint('API MESSAGE: ${data['message']}');

      if (!success) {
        final message = (data['message'] ??
                'Unable to load assigned tasks')
            .toString();

        if (message.toLowerCase().contains('no record') ||
            message.toLowerCase().contains('not found')) {
          return [];
        }

        throw StateError(message);
      }

      // ================================================
      // 6. GET RESULT LIST
      // ================================================

      final result = data['result'];

      if (result == null) {
        debugPrint('TASK RESULT IS NULL');
        return [];
      }

      if (result is! List) {
        throw const FormatException(
          'Invalid assigned task result list',
        );
      }

      debugPrint(
        'TOTAL TASKS FROM API: ${result.length}',
      );

      // ================================================
      // 7. CONVERT JSON TO MODEL
      // ================================================

      final tasks = <AssignedTaskModel>[];

      for (final item in result) {
        if (item is! Map) {
          throw const FormatException(
            'Invalid task object',
          );
        }

        final model = AssignedTaskModel.fromJson(
          Map<String, dynamic>.from(item),
        );

        tasks.add(model);

        debugPrint('------------------------------');
        debugPrint('TASK ID: ${model.id}');
        debugPrint('TASK TITLE: ${model.title}');
        debugPrint('TASK PRIORITY: ${model.priority}');
        debugPrint('TASK STATUS: ${model.status}');
      }

      debugPrint('======================================');
      debugPrint('FINAL PARSED TASKS: ${tasks.length}');
      debugPrint('======================================');

      return tasks;

    } on DioException catch (e) {

      debugPrint('ASSIGNED TASK DIO ERROR: ${e.message}');
      debugPrint('STATUS CODE: ${e.response?.statusCode}');
      debugPrint('ERROR RESPONSE: ${e.response?.data}');

      rethrow;

    } catch (e, stackTrace) {

      debugPrint('ASSIGNED TASK PARSE ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      rethrow;
    }
  }
}
