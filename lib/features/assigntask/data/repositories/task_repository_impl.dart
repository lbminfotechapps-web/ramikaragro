
import 'package:solufine/core/secure_storage/secure_storage.dart';

import 'package:solufine/features/reports/domain/usecases/get_employees.dart'
    as reports;

import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remote;
  final reports.GetEmployees searchEmployees;

  const TaskRepositoryImpl({
    required this.remote,
    required this.searchEmployees,
  });

  @override
  Future<List<EmployeeEntity>> getEmployees() async {
    final data =
        await SecureStorage.instance.getUserData();

    final userId =
        (data?['user_id'] ?? data?['userId'] ?? '')
            .toString()
            .trim();

    if (userId.isEmpty || userId == '0') {
      throw Exception('Please login again');
    }

    final records = await searchEmployees(
      logUserId: userId,
      search: '',
    );

    final byId = <String, EmployeeEntity>{};

    for (final employee in records) {
      final id = employee.fldId.toString().trim();
      final name = employee.fldAdmName.toString().trim();

      if (id.isEmpty ||
          id == '0' ||
          id.toLowerCase() == 'null' ||
          name.isEmpty ||
          name.toLowerCase() == 'null') {
        continue;
      }

      byId[id] = EmployeeEntity(
        id: id,
        name: name,
      );
    }

    return byId.values.toList()
      ..sort(
        (a, b) => a.name.compareTo(b.name),
      );
  }

  @override
  Future<List<TaskEntity>> getTasks(
    TaskFilter filter,
  ) {
    return remote.getCreatedTaskList(filter);
  }

  @override
  Future<void> createTask(TaskEntity task) {
    return remote.addTask(task);
  }

  @override
  Future<void> completeTask({
    required String taskId,
    required String remark,
    String? imagePath,
  }) {
    return remote.completeTask(
      taskId: taskId,
      remark: remark,
      imagePath: imagePath,
    );
  }
}
