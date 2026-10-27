
import '../../domain/entities/assigned_task.dart';

class AssignedTaskModel extends AssignedTask {
  const AssignedTaskModel({
    required super.id,
    required super.assigneeId,
    required super.assigneeName,
    required super.assignFromId,
    required super.title,
    required super.description,
    required super.priority,
    required super.status,
    required super.taskDate,
    required super.dueDate,
    required super.image,
    required super.completedImage,
    required super.remark,
    required super.completedDate,
    required super.overdueStatus,
  });

  static String _string(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static DateTime? _parseDateTime(
    String date,
    String time,
  ) {
    final parts = date.split('/');

    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null ||
        month == null ||
        year == null) {
      return null;
    }

    final clock = time
        .replaceAll(':', '.')
        .split('.');

    final hour =
        int.tryParse(clock.first) ?? 0;

    final minute = clock.length > 1
        ? int.tryParse(clock[1]) ?? 0
        : 0;

    if (hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    final result = DateTime(
      year,
      month,
      day,
      hour,
      minute,
    );

    if (result.year != year ||
        result.month != month ||
        result.day != day) {
      return null;
    }

    return result;
  }

  factory AssignedTaskModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AssignedTaskModel(
      id: _string(json['fld_task_id']),
      assigneeId:
          _string(json['fld_assign_to_id']),
      assigneeName:
          _string(json['fld_adm_name']),
      assignFromId:
          _string(json['fld_assign_from_id']),
      title: _string(json['fld_title']),
      description:
          _string(json['fld_description']),
      priority:
          _string(json['fld_priority_level']),
      status: _string(json['fld_status']),
      taskDate: _parseDateTime(
        _string(json['fld_task_date']),
        _string(json['fld_task_time']),
      ),
      dueDate: _parseDateTime(
        _string(json['fld_due_date']),
        _string(json['fld_due_time']),
      ),
      image: _string(json['fld_image']),
      completedImage:
          _string(json['fld_completed_image']),
      remark: _string(json['fld_remark']),
      completedDate:
          _string(json['fld_completed_date']),
      overdueStatus:
          _string(json['fld_overdue_status']),
    );
  }
}
