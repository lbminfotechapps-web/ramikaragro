
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';



import '../../domain/entities/assigned_task.dart';
import '../../domain/repositories/assigned_task_repository.dart';

// ======================================================
// EVENTS
// ======================================================

abstract class AssignedTaskEvent {
  const AssignedTaskEvent();
}

class LoadAssignedTasks extends AssignedTaskEvent {
  const LoadAssignedTasks({
    this.filter,
  });

  final AssignedTaskFilter? filter;
}

class ClearAssignedTaskFilters extends AssignedTaskEvent {
  const ClearAssignedTaskFilters();
}

// ======================================================
// STATE
// ======================================================

class AssignedTaskState {
  const AssignedTaskState({
    this.loading = false,
    this.tasks = const [],
    this.filter = const AssignedTaskFilter(),
    this.errorMessage = '',
  });

  final bool loading;
  final List<AssignedTask> tasks;
  final AssignedTaskFilter filter;
  final String errorMessage;

  AssignedTaskState copyWith({
    bool? loading,
    List<AssignedTask>? tasks,
    AssignedTaskFilter? filter,
    String? errorMessage,
  }) {
    return AssignedTaskState(
      loading: loading ?? this.loading,
      tasks: tasks ?? this.tasks,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ======================================================
// BLOC
// ======================================================

class AssignedTaskBloc
    extends Bloc<AssignedTaskEvent, AssignedTaskState> {

  AssignedTaskBloc({
    required this.repository,
  }) : super(const AssignedTaskState()) {
    on<LoadAssignedTasks>(_onLoadTasks);
    on<ClearAssignedTaskFilters>(_onClearFilters);
  }

  final AssignedTaskRepository repository;

  int _latestRequest = 0;

  // ======================================================
  // LOAD ASSIGNED TASKS
  // ======================================================

Future<void> _onLoadTasks(
  LoadAssignedTasks event,
  Emitter<AssignedTaskState> emit,
) async {
  final filter = event.filter ?? state.filter;
  final currentRequest = ++_latestRequest;

  emit(
    state.copyWith(
      loading: true,
      filter: filter,
      errorMessage: '',
    ),
  );

  try {
    // 1. Get user information from SecureStorage
    final userData =
        await SecureStorage.instance.getUserData();

    // 2. Get logged-in user ID
    final String loginUserId =
        userData?['user_id']?.toString().trim() ?? '';

    if (loginUserId.isEmpty || loginUserId == '0') {
      throw Exception(
        'User session not found. Please login again.',
      );
    }

    // 3. Call Assigned Task API
    final tasks = await repository.getAssignedTasks(
      loginUserId: loginUserId,
      filter: filter,
    );

    // 4. Ignore outdated responses
    if (isClosed || currentRequest != _latestRequest) {
      return;
    }

    // 5. Success
    emit(
      state.copyWith(
        loading: false,
        tasks: tasks,
        filter: filter,
        errorMessage: '',
      ),
    );
  } catch (e) {
    if (isClosed || currentRequest != _latestRequest) {
      return;
    }

    emit(
      state.copyWith(
        loading: false,
        tasks: const [],
        filter: filter,
        errorMessage: e.toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('Bad state: ', ''),
      ),
    );
  }
}
  // ======================================================
  // CLEAR ALL FILTERS
  // ======================================================

  void _onClearFilters(
    ClearAssignedTaskFilters event,
    Emitter<AssignedTaskState> emit,
  ) {
    add(
      const LoadAssignedTasks(
        filter: AssignedTaskFilter(),
      ),
    );
  }
}
