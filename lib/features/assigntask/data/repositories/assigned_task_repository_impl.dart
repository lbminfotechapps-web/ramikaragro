import '../../domain/entities/assigned_task.dart';
import '../../domain/repositories/assigned_task_repository.dart';
import '../datasources/assigned_task_remote_data_source.dart';

class AssignedTaskRepositoryImpl
    implements AssignedTaskRepository {
  const AssignedTaskRepositoryImpl(this.remote);

  final AssignedTaskRemoteDataSource remote;

  @override
  Future<List<AssignedTask>> getAssignedTasks({
    required String loginUserId,
    required AssignedTaskFilter filter,
  }) {
    return remote.getAssignedTasks(
      loginUserId: loginUserId,
      filter: filter,
    );
  }
}