
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetEmployees {
  final TaskRepository repository;

  const GetEmployees(this.repository);

  Future<List<EmployeeEntity>> call() {
    return repository.getEmployees();
  }
}

class GetTasks {
  final TaskRepository repository;

  const GetTasks(this.repository);

  Future<List<TaskEntity>> call(TaskFilter filter) {
    return repository.getTasks(filter);
  }
}

class CreateTask {
  final TaskRepository repository;

  const CreateTask(this.repository);

  Future<void> call(TaskEntity task) {
    if (task.employeeId.trim().isEmpty ||
        task.title.trim().isEmpty ||
        task.description.trim().isEmpty) {
      throw Exception('Complete all required task fields');
    }

    if (!task.dueAt.isAfter(task.assignedAt)) {
      throw Exception(
        'Due date/time must be after assign date/time',
      );
    }

    return repository.createTask(task);
  }
}

class CompleteTask {
  final TaskRepository repository;

  const CompleteTask(this.repository);

  Future<void> call({
    required String taskId,
    required String remark,
    String? imagePath,
  }) {
    if (taskId.trim().isEmpty) {
      throw Exception('Invalid task ID');
    }

    if (remark.trim().isEmpty) {
      throw Exception('Enter completion remark');
    }

    return repository.completeTask(
      taskId: taskId,
      remark: remark,
      imagePath: imagePath,
    );
  }
}
