
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';

import '../../domain/entities/task_entity.dart';
import '../models/created_task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskEntity>> getCreatedTaskList(
    TaskFilter filter,
  );

  Future<void> addTask(TaskEntity task);

  Future<void> completeTask({
    required String taskId,
    required String remark,
    String? imagePath,
  });
}

class TaskRemoteDataSourceImpl
    implements TaskRemoteDataSource {
  final DioClient dioClient;

  const TaskRemoteDataSourceImpl({
    required this.dioClient,
  });

  Future<String> _userId() async {
    final data =
        await SecureStorage.instance.getUserData();

    final id = (data?['user_id'] ??
            data?['userId'] ??
            '')
        .toString()
        .trim();

    if (id.isEmpty ||
        id == '0' ||
        id.toLowerCase() == 'null') {
      throw Exception('Please login again');
    }

    return id;
  }

  Map<String, dynamic> _responseMap(dynamic data) {
    final decoded =
        data is String ? jsonDecode(data.trim()) : data;

    if (decoded is! Map) {
      throw const FormatException(
        'Invalid JSON response',
      );
    }

    return Map<String, dynamic>.from(decoded);
  }

  bool _success(dynamic value) =>
      value == true ||
      value == 1 ||
      value.toString().toLowerCase() == 'true' ||
      value.toString() == '1';

  void _log(
    String label,
    Map<String, dynamic> fields,
  ) {
    debugPrint('========== $label ==========');

    for (final entry in fields.entries) {
      if (entry.value is MultipartFile) {
        final file = entry.value as MultipartFile;

        debugPrint(
          '${entry.key}: ${file.filename} '
          '(${file.length} bytes)',
        );
      } else {
        debugPrint('${entry.key}: ${entry.value}');
      }
    }
  }

  // =====================================================
  // CREATED TASK LIST
  // =====================================================

  @override
  Future<List<TaskEntity>> getCreatedTaskList(
    TaskFilter filter,
  ) async {
    final params = <String, dynamic>{
      'login_user_id': await _userId(),
      'priority_level': filter.priority?.label ?? '',
      'status': filter.status == TaskStatus.pending
          ? '0'
          : filter.status == TaskStatus.completed
              ? '1'
              : filter.status?.label ?? '',
      'from_date': filter.fromDate == null
          ? ''
          : DateFormat('dd-MM-yyyy').format(
              filter.fromDate!,
            ),
      'emp_id': filter.employeeId ?? '',
    };

    _log('CREATED TASK LIST', params);

    final response =
        await dioClient.client.post<dynamic>(
      ApiClient.createdTaskList,
      data: FormData.fromMap(params),
      options: Options(
        headers: {'Accept': 'application/json'},
      ),
    );

    debugPrint(
      'TASK LIST RAW RESPONSE: ${response.data}',
    );

    final json = _responseMap(response.data);

    if (!_success(json['status'])) {
      final message =
          (json['message'] ?? 'Failed to load tasks')
              .toString();

      if (message.toLowerCase().contains('no record')) {
        return [];
      }

      throw Exception(message);
    }

    final result = json['result'];

    final rows = result is List
        ? result
        : (result is Map
            ? (result['data'] ?? result['tasks'])
            : null);

    if (rows == null) return [];

    if (rows is! List) {
      throw const FormatException(
        'Expected result array',
      );
    }

    final tasks = <TaskEntity>[];

    for (final row in rows) {
      if (row is! Map) {
        throw const FormatException(
          'Invalid task row',
        );
      }

      tasks.add(
        CreatedTaskModel.fromJson(
          Map<String, dynamic>.from(row),
        ),
      );
    }

    tasks.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    debugPrint('MAPPED TASKS: ${tasks.length}');

    return tasks;
  }

  // =====================================================
  // CREATE TASK
  // =====================================================

  @override
  Future<void> addTask(TaskEntity task) async {
    final fields = <String, dynamic>{
      'login_user_id': await _userId(),
      'assign_user_id': task.employeeId,
      'title': task.title.trim(),
      'description': task.description.trim(),
      'task_date':
          DateFormat('dd-MM-yyyy').format(task.assignedAt),
      'task_time':
          DateFormat('HH.mm').format(task.assignedAt),
      'due_date':
          DateFormat('dd-MM-yyyy').format(task.dueAt),
      'due_time':
          DateFormat('HH.mm').format(task.dueAt),
      'priority_level': task.priority.label,
    };

    if (task.attachmentPath?.isNotEmpty == true) {
      final file = File(task.attachmentPath!);

      if (!await file.exists()) {
        throw Exception('Task image not found');
      }

      fields['task_photo'] =
          await MultipartFile.fromFile(
        file.path,
        filename:
            'task_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: DioMediaType.parse('image/jpeg'),
      );
    }

    _log('ADD TASK', fields);

    final response =
        await dioClient.client.post<dynamic>(
      ApiClient.addTask,
      data: FormData.fromMap(fields),
      options: Options(
        contentType: Headers.multipartFormDataContentType,
      ),
    );

    final json = _responseMap(response.data);

    if (!_success(json['status'])) {
      throw Exception(
        json['message']?.toString() ??
            'Add task failed',
      );
    }
  }

  // =====================================================
  // COMPLETE TASK
  // =====================================================

  @override
  Future<void> completeTask({
    required String taskId,
    required String remark,
    String? imagePath,
  }) async {
    final fields = <String, dynamic>{
      'login_user_id': await _userId(),
      'taskId': taskId.trim(),
      'taskStatus': '1',
      'remark': remark.trim(),
    };

    final path = imagePath?.trim() ?? '';

    if (path.isNotEmpty) {
      final photo = File(path);

      if (!await photo.exists()) {
        throw Exception('Completion photo not found');
      }

      fields['complete_photo'] =
          await MultipartFile.fromFile(
        photo.path,
        filename:
            'completion_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: DioMediaType.parse('image/jpeg'),
      );
    }

    _log('UPDATE TASK STATUS', fields);

    try {
      final response =
          await dioClient.client.post<dynamic>(
        ApiClient.updateTaskStatus,
        data: FormData.fromMap(fields),
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint(
        'UPDATE TASK STATUS RESPONSE: ${response.data}',
      );

      final json = _responseMap(response.data);

      if (!_success(json['status'])) {
        throw Exception(
          json['message']?.toString() ??
              'Task completion failed',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'UPDATE TASK DIO ERROR: ${e.message}',
      );
      debugPrint('RESPONSE: ${e.response?.data}');
      rethrow;
    }
  }
}
