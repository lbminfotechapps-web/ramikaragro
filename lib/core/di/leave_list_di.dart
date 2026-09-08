import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/features/leave/data/datasources/leave_remote_data_source.dart';
import 'package:demo/features/leave/data/repositories/leave_repository_impl.dart';
import 'package:demo/features/leave/domain/repositories/leave_repository.dart';
import 'package:demo/features/leave/domain/usecases/add_leave.dart';
import 'package:demo/features/leave/domain/usecases/get_leave_list.dart';
import 'package:demo/features/leave/presentation/bloc/leave_bloc.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> initLeaveListDi() async {
  // ============================================================
  // SECURE STORAGE
  // ============================================================

  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(
      () => SecureStorage.instance,
    );
  }

  // ============================================================
  // DATA SOURCE
  // ============================================================

  if (!sl.isRegistered<LeaveRemoteDataSource>()) {
    sl.registerLazySingleton<LeaveRemoteDataSource>(
      () => LeaveRemoteDataSourceImpl(
        dioClient: DioClient(),
      ),
    );
  }

  // ============================================================
  // REPOSITORY
  // ============================================================

  if (!sl.isRegistered<LeaveRepository>()) {
    sl.registerLazySingleton<LeaveRepository>(
      () => LeaveRepositoryImpl(
        remoteDataSource: sl<LeaveRemoteDataSource>(),
      ),
    );
  }

  // ============================================================
  // GET LEAVE LIST USE CASE
  // ============================================================

  if (!sl.isRegistered<GetLeaveList>()) {
    sl.registerLazySingleton<GetLeaveList>(
      () => GetLeaveList(
        sl<LeaveRepository>(),
      ),
    );
  }

  // ============================================================
  // ADD LEAVE USE CASE
  // ============================================================

  if (!sl.isRegistered<AddLeave>()) {
    sl.registerLazySingleton<AddLeave>(
      () => AddLeave(
        sl<LeaveRepository>(),
      ),
    );
  }

  // ============================================================
  // LEAVE BLOC
  // ============================================================

  if (!sl.isRegistered<LeaveBloc>()) {
    sl.registerFactory<LeaveBloc>(
      () => LeaveBloc(
        getLeaveList: sl<GetLeaveList>(),
        addLeave: sl<AddLeave>(),
        secureStorage: sl<SecureStorage>(),
      ),
    );
  }
}