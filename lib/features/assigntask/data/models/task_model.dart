
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.title,
    required super.description,
    required super.assignedAt,
    required super.dueAt,
    required super.priority,
    required super.status,
    required super.createdAt,
    super.attachmentPath,
  });

  factory TaskModel.fromEntity(TaskEntity task) {
    return TaskModel(
      id: task.id,
      employeeId: task.employeeId,
      employeeName: task.employeeName,
      title: task.title,
      description: task.description,
      assignedAt: task.assignedAt,
      dueAt: task.dueAt,
      priority: task.priority,
      status: task.status,
      createdAt: task.createdAt,
      attachmentPath: task.attachmentPath,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    TaskPriority parsePriority() {
      final value = json['priority']?.toString() ?? '';
      return TaskPriority.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TaskPriority.medium,
      );
    }

    TaskStatus parseStatus() {
      final value = json['status']?.toString() ?? '';
      return TaskStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TaskStatus.pending,
      );
    }

    return TaskModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      assignedAt: DateTime.parse(
        json['assignedAt'].toString(),
      ),
      dueAt: DateTime.parse(json['dueAt'].toString()),
      priority: parsePriority(),
      status: parseStatus(),
      createdAt: DateTime.parse(
        json['createdAt'].toString(),
      ),
      attachmentPath: json['attachmentPath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'employeeName': employeeName,
    'title': title,
    'description': description,
    'assignedAt': assignedAt.toIso8601String(),
    'dueAt': dueAt.toIso8601String(),
    'priority': priority.name,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'attachmentPath': attachmentPath,
  };
}
