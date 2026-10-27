
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:solufine/core/api_constant/api_client.dart';

import '../../domain/entities/task_entity.dart';

class CreatedTaskModel {
  static String read(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key]?.toString().trim() ?? '';

      if (value.isNotEmpty &&
          value.toLowerCase() != 'null') {
        return value;
      }
    }

    return '';
  }

  static DateTime parseDateTime(
    String date,
    String time,
  ) {
    DateTime? parsed = DateTime.tryParse(date.trim());

    if (parsed == null) {
      for (final format in [
        'dd/MM/yyyy',
        'dd-MM-yyyy',
        'yyyy-MM-dd',
        'dd MMM yyyy',
      ]) {
        try {
          parsed = DateFormat(format).parseStrict(date.trim());
          break;
        } catch (_) {}
      }
    }

    if (parsed == null) {
      throw FormatException('Invalid date: $date');
    }

    final inputTime = time.trim();

    if (inputTime.isEmpty) return parsed;

    final match = RegExp(
      r'^(\d{1,2})[.:](\d{2})(?::\d{2})?$',
    ).firstMatch(inputTime);

    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);

      if (hour < 24 && minute < 60) {
        return DateTime(
          parsed.year,
          parsed.month,
          parsed.day,
          hour,
          minute,
        );
      }
    }

    for (final format in ['hh:mm a', 'h:mm a']) {
      try {
        final timePart = DateFormat(format)
            .parseStrict(inputTime.toUpperCase());

        return DateTime(
          parsed.year,
          parsed.month,
          parsed.day,
          timePart.hour,
          timePart.minute,
        );
      } catch (_) {}
    }

    throw FormatException('Invalid time: $time');
  }

  static DateTime? parseCompletedDate(String text) {
    final value = text.trim();

    if (value.isEmpty) return null;

    for (final format in [
      'dd/MM/yyyy hh:mm a',
      'dd/MM/yyyy h:mm a',
      'dd-MM-yyyy hh:mm a',
      'yyyy-MM-dd HH:mm:ss',
    ]) {
      try {
        return DateFormat(format).parseStrict(value);
      } catch (_) {}
    }

    return DateTime.tryParse(value);
  }

  static TaskPriority parsePriority(String value) {
    switch (value.trim().toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
    
      default:
        return TaskPriority.medium;
    }
  }

  static TaskStatus parseStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case '0':
      case 'pending':
        return TaskStatus.pending;

      case '1':
      case 'completed':
      case 'complete':
      case 'done':
        return TaskStatus.completed;


      default:
        debugPrint('Unknown task status: $value');
        return TaskStatus.pending;
    }
  }

  static String? imageUrl(String? filename) {
    final value = filename?.trim() ?? '';

    if (value.isEmpty ||
        value.toLowerCase() == 'null') {
      return null;
    }

    final uri = Uri.tryParse(value);

    if (uri != null &&
        (uri.scheme == 'http' ||
            uri.scheme == 'https') &&
        uri.hasAuthority) {
      return value;
    }

    // Only accept a filename from the API, not
    // arbitrary directory traversal or another host.
    if (value.contains('/') ||
        value.contains('\\') ||
        value == '.' ||
        value == '..') {
      return null;
    }

    return Uri.parse(ApiClient.baseUrlForAssignTask)
        .resolve(Uri.encodeComponent(value))
        .toString();
  }

  static TaskEntity fromJson(
    Map<String, dynamic> json,
  ) {
    final id = read(json, [
      'fld_task_id',
      'task_id',
      'id',
    ]);

    if (id.isEmpty) {
      throw const FormatException('Missing task ID');
    }

    final assignedAt = parseDateTime(
      read(json, ['fld_task_date', 'task_date']),
      read(json, ['fld_task_time', 'task_time']),
    );

    final dueAt = parseDateTime(
      read(json, ['fld_due_date', 'due_date']),
      read(json, ['fld_due_time', 'due_time']),
    );

    final originalName = read(json, ['fld_image']);
    final completionName =
        read(json, ['fld_completed_image']);

    final task = TaskEntity(
      id: id,
      employeeId: read(json, [
        'fld_assign_to_id',
        'fld_assign_user_id',
        'assign_user_id',
        'emp_id',
      ]),
      employeeName: read(json, [
        'fld_adm_name',
        'employee_name',
      ]),
      title: read(json, ['fld_title', 'title']),
      description: read(
        json,
        ['fld_description', 'description'],
      ),
      assignedAt: assignedAt,
      dueAt: dueAt,
      createdAt: assignedAt,
      priority: parsePriority(
        read(json, ['fld_priority_level']),
      ),
      status: parseStatus(
        read(json, ['fld_status']),
      ),
      imageName: originalName.isEmpty
          ? null
          : originalName,
      imageUrl: imageUrl(originalName),
      completedImageName: completionName.isEmpty
          ? null
          : completionName,
      completedImageUrl: imageUrl(completionName),
      completionRemark: read(json, ['fld_remark']),
      completedAt: parseCompletedDate(
        read(json, ['fld_completed_date']),
      ),
      overdueStatus: read(
        json,
        ['fld_overdue_status'],
      ),
    );

    debugPrint('======== CREATED TASK ========');
    debugPrint('Task ID: ${task.id}');
    debugPrint('Title: ${task.title}');
    debugPrint('Employee ID: ${task.employeeId}');
    debugPrint('Status: ${task.status.label}');
    debugPrint('Task image: ${task.imageUrl}');
    debugPrint(
      'Completed image: ${task.completedImageUrl}',
    );
    debugPrint(
      'Completed remark: ${task.completionRemark}',
    );

    return task;
  }
}
