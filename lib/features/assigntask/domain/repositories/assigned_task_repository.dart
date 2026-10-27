import '../entities/assigned_task.dart';

abstract class AssignedTaskRepository {
  Future<List<AssignedTask>> getAssignedTasks({
    required String loginUserId,
    required AssignedTaskFilter filter,
  });
}