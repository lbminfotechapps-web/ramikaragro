
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task_usecases.dart';

abstract class TaskEvent {
  const TaskEvent();
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class ApplyTaskFilters extends TaskEvent {
  final TaskFilter filter;

  const ApplyTaskFilters(this.filter);
}

class AddTask extends TaskEvent {
  final TaskEntity task;

  const AddTask(this.task);
}

class SubmitTaskCompletion extends TaskEvent {
  final String taskId;
  final String remark;
  final String? imagePath;

  const SubmitTaskCompletion({
    required this.taskId,
    required this.remark,
    this.imagePath,
  });
}

class _TaskFetchFinished extends TaskEvent {
  final int requestId;
  final List<TaskEntity>? tasks;
  final Object? error;

  const _TaskFetchFinished({
    required this.requestId,
    this.tasks,
    this.error,
  });
}

class _EmployeesLoaded extends TaskEvent {
  final List<EmployeeEntity>? employees;
  final Object? error;

  const _EmployeesLoaded({
    this.employees,
    this.error,
  });
}

enum TaskLoadStatus {
  initial,
  loading,
  success,
  failure,
}

class TaskState {
  final TaskLoadStatus loadStatus;
  final List<TaskEntity> tasks;
  final List<EmployeeEntity> employees;
  final TaskFilter filter;

  final bool saving;
  final bool completing;
  final bool error;
  final String message;

  final int saveCounter;
  final int notificationId;
  final int completionCounter;
  final int completionFailureCounter;

  const TaskState({
    this.loadStatus = TaskLoadStatus.initial,
    this.tasks = const [],
    this.employees = const [],
    this.filter = const TaskFilter(),
    this.saving = false,
    this.completing = false,
    this.error = false,
    this.message = '',
    this.saveCounter = 0,
    this.notificationId = 0,
    this.completionCounter = 0,
    this.completionFailureCounter = 0,
  });

  List<TaskEntity> get filteredTasks =>
      tasks.where(filter.matches).toList();

  int get total => filteredTasks.length;

  int get pending => filteredTasks
      .where((task) => task.status == TaskStatus.pending)
      .length;

  int get completed => filteredTasks
      .where((task) => task.status == TaskStatus.completed)
      .length;

  TaskState copyWith({
    TaskLoadStatus? loadStatus,
    List<TaskEntity>? tasks,
    List<EmployeeEntity>? employees,
    TaskFilter? filter,
    bool? saving,
    bool? completing,
    bool? error,
    String? message,
    int? saveCounter,
    int? notificationId,
    int? completionCounter,
    int? completionFailureCounter,
  }) {
    return TaskState(
      loadStatus: loadStatus ?? this.loadStatus,
      tasks: tasks ?? this.tasks,
      employees: employees ?? this.employees,
      filter: filter ?? this.filter,
      saving: saving ?? this.saving,
      completing: completing ?? this.completing,
      error: error ?? this.error,
      message: message ?? this.message,
      saveCounter: saveCounter ?? this.saveCounter,
      notificationId: notificationId ?? this.notificationId,
      completionCounter:
          completionCounter ?? this.completionCounter,
      completionFailureCounter: completionFailureCounter ??
          this.completionFailureCounter,
    );
  }
}

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetEmployees getEmployees;
  final GetTasks getTasks;
  final CreateTask createTask;
  final CompleteTask completeTask;

  int _requestId = 0;

  TaskBloc({
    required this.getEmployees,
    required this.getTasks,
    required this.createTask,
    required this.completeTask,
  }) : super(const TaskState()) {
    on<LoadTasks>(_onLoad);
    on<ApplyTaskFilters>(_onFilter);
    on<AddTask>(_onAdd);
    on<SubmitTaskCompletion>(_onCompletion);
    on<_TaskFetchFinished>(_onFetchFinished);
    on<_EmployeesLoaded>(_onEmployeesLoaded);
  }

  String _error(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  void _fetch(TaskFilter filter) {
    final requestId = ++_requestId;

    getTasks(filter).then(
      (tasks) {
        if (!isClosed) {
          add(_TaskFetchFinished(
            requestId: requestId,
            tasks: tasks,
          ));
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!isClosed) {
          add(_TaskFetchFinished(
            requestId: requestId,
            error: error,
          ));
        }
      },
    );
  }

  void _loadEmployees() {
    getEmployees().then(
      (employees) {
        if (!isClosed) {
          add(_EmployeesLoaded(employees: employees));
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!isClosed) {
          add(_EmployeesLoaded(error: error));
        }
      },
    );
  }

  void _onLoad(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(
      loadStatus: TaskLoadStatus.loading,
      message: '',
      error: false,
    ));

    _loadEmployees();
    _fetch(state.filter);
  }

  void _onFilter(
    ApplyTaskFilters event,
    Emitter<TaskState> emit,
  ) {
    final before = state.filter;
    final after = event.filter;

    final remoteChanged =
        before.employeeId != after.employeeId ||
        before.priority != after.priority ||
        before.status != after.status ||
        before.fromDate != after.fromDate;

    if (!remoteChanged &&
        state.loadStatus == TaskLoadStatus.success) {
      emit(state.copyWith(filter: after));
      return;
    }

    emit(state.copyWith(
      filter: after,
      loadStatus: TaskLoadStatus.loading,
      message: '',
      error: false,
    ));

    _fetch(after);
  }

  void _onFetchFinished(
    _TaskFetchFinished event,
    Emitter<TaskState> emit,
  ) {
    if (event.requestId != _requestId) return;

    if (event.error != null) {
      emit(state.copyWith(
        loadStatus: TaskLoadStatus.failure,
        error: true,
        message: _error(event.error!),
        notificationId: state.notificationId + 1,
      ));

      return;
    }

    emit(state.copyWith(
      loadStatus: TaskLoadStatus.success,
      tasks: event.tasks ?? [],
      error: false,
      message: '',
    ));
  }

  void _onEmployeesLoaded(
    _EmployeesLoaded event,
    Emitter<TaskState> emit,
  ) {
    if (event.error != null) {
      emit(state.copyWith(
        message:
            'Could not load employees: ${_error(event.error!)}',
        error: true,
        notificationId: state.notificationId + 1,
      ));

      return;
    }

    emit(state.copyWith(
      employees: event.employees ?? [],
    ));
  }

  Future<void> _onAdd(
    AddTask event,
    Emitter<TaskState> emit,
  ) async {
    if (state.saving || state.completing) return;

    emit(state.copyWith(
      saving: true,
      message: '',
      error: false,
    ));

    try {
      await createTask(event.task);

      emit(state.copyWith(
        saving: false,
        saveCounter: state.saveCounter + 1,
        message: 'Task assigned successfully',
        error: false,
        notificationId: state.notificationId + 1,
      ));

      _fetch(state.filter);
    } catch (error) {
      emit(state.copyWith(
        saving: false,
        error: true,
        message: _error(error),
        notificationId: state.notificationId + 1,
      ));
    }
  }

  Future<void> _onCompletion(
    SubmitTaskCompletion event,
    Emitter<TaskState> emit,
  ) async {
    if (state.completing || state.saving) return;

    emit(state.copyWith(
      completing: true,
      error: false,
      message: '',
    ));

    try {
      await completeTask(
        taskId: event.taskId,
        remark: event.remark,
        imagePath: event.imagePath,
      );

      emit(state.copyWith(
        completing: false,
        error: false,
        completionCounter: state.completionCounter + 1,
        message: 'Task completed successfully',
        notificationId: state.notificationId + 1,
      ));

      // Fetch latest server status.
      _fetch(state.filter);
    } catch (error) {
      emit(state.copyWith(
        completing: false,
        error: true,
        completionFailureCounter:
            state.completionFailureCounter + 1,
        message: _error(error),
        notificationId: state.notificationId + 1,
      ));
    }
  }
}
