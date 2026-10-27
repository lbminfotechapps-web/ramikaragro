
enum TaskPriority {
  low,
  medium,
  high,
}

enum TaskStatus {
  pending,
  completed,
 
}

extension TaskPriorityLabel on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low => 'Low',
        TaskPriority.medium => 'Medium',
        TaskPriority.high => 'High',
  
      };
}

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
        TaskStatus.pending => 'Pending',
        TaskStatus.completed => 'Completed',
       
      };
}

class EmployeeEntity {
  final String id;
  final String name;

  const EmployeeEntity({
    required this.id,
    required this.name,
  });
}

class TaskEntity {
  final String id;
  final String employeeId;
  final String employeeName;
  final String title;
  final String description;
  final DateTime assignedAt;
  final DateTime dueAt;
  final DateTime createdAt;
  final TaskPriority priority;
  final TaskStatus status;

  // Local photo selected while creating task.
  final String? attachmentPath;

  // Task attachment returned by API.
  final String? imageName;
  final String? imageUrl;

  // Completion data returned by API.
  final String? completedImageName;
  final String? completedImageUrl;
  final String? completionRemark;
  final DateTime? completedAt;
  final String overdueStatus;

  const TaskEntity({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.title,
    required this.description,
    required this.assignedAt,
    required this.dueAt,
    required this.createdAt,
    required this.priority,
    required this.status,
    this.attachmentPath,
    this.imageName,
    this.imageUrl,
    this.completedImageName,
    this.completedImageUrl,
    this.completionRemark,
    this.completedAt,
    this.overdueStatus = '0',
  });
}

class TaskFilter {
  final String query;
  final String? employeeId;
  final TaskPriority? priority;
  final TaskStatus? status;
  final DateTime? fromDate;
  final DateTime? toDate;

  const TaskFilter({
    this.query = '',
    this.employeeId,
    this.priority,
    this.status,
    this.fromDate,
    this.toDate,
  });

  bool matches(TaskEntity task) {
    final q = query.trim().toLowerCase();

    if (q.isNotEmpty &&
        !task.title.toLowerCase().contains(q) &&
        !task.description.toLowerCase().contains(q) &&
        !task.employeeName.toLowerCase().contains(q)) {
      return false;
    }

    if (employeeId != null &&
        task.employeeId != employeeId) {
      return false;
    }

    if (priority != null && task.priority != priority) {
      return false;
    }

    if (status != null && task.status != status) {
      return false;
    }

    final date = DateTime(
      task.assignedAt.year,
      task.assignedAt.month,
      task.assignedAt.day,
    );

    if (fromDate != null) {
      final start = DateTime(
        fromDate!.year,
        fromDate!.month,
        fromDate!.day,
      );

      if (date.isBefore(start)) return false;
    }

    if (toDate != null) {
      final end = DateTime(
        toDate!.year,
        toDate!.month,
        toDate!.day,
      );

      if (date.isAfter(end)) return false;
    }

    return true;
  }
}
