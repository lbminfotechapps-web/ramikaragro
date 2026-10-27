
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<EmployeeEntity>> getEmployees();

  Future<List<TaskEntity>> getTasks(
    TaskFilter filter,
  );

  Future<void> createTask(
    TaskEntity task,
  );

  Future<void> completeTask({
    required String taskId,
    required String remark,
    String? imagePath,
  });
}
