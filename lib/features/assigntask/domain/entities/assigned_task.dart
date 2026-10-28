
class AssignedTask {
  const AssignedTask({
    required this.id,
    required this.assigneeId,
    required this.assigneeName,
    required this.assignFromId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.taskDate,
    required this.dueDate,
    required this.image,
    required this.completedImage,
    required this.remark,
    required this.completedDate,
    required this.overdueStatus,
  });

  final String id;
  final String assigneeId;
  final String assigneeName;
  final String assignFromId;
  final String title;
  final String description;
  final String priority;
  final String status;

  final DateTime? taskDate;
  final DateTime? dueDate;

  final String image;
  final String completedImage;
  final String remark;
  final String completedDate;
  final String overdueStatus;

  String get statusText {
    switch (status) {
      case '0':
        return 'Pending';
      case '1':
        return 'Completed';
      default:
        return status.isEmpty
            ? 'Unknown'
            : 'Status $status';
    }
  }

  bool get isOverdue => overdueStatus.trim() == '1';
}

// =====================================================
// API FILTER
// =====================================================

class AssignedTaskFilter {
  const AssignedTaskFilter({
    this.priority = '',
    this.status = '',
    this.fromDate,
    this.toDate,
    this.employeeId = '',
  });

  final String priority;
  final String status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String employeeId;

  AssignedTaskFilter copyWith({
    String? priority,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String? employeeId,
    bool clearDate = false,
    bool clearToDate = false,
  }) {
    return AssignedTaskFilter(
      priority: priority ?? this.priority,
      status: status ?? this.status,
      fromDate: clearDate
          ? null
          : fromDate ?? this.fromDate,
      toDate: clearToDate ? null : toDate ?? this.toDate,
      employeeId: employeeId ?? this.employeeId,
    );
  }
}

// =====================================================
// EMPLOYEE DROPDOWN MODEL
// =====================================================

class AssignedTaskEmployee {
  const AssignedTaskEmployee({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}
