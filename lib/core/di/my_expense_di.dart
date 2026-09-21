import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/expense/data/datasources/my_expense_remote_datasource.dart';
import 'package:solufine/features/expense/data/repositories/my_expense_repository_impl.dart';
import 'package:solufine/features/expense/domain/repositories/my_expense_repository.dart';
import 'package:solufine/features/expense/domain/usecases/get_my_expenses_usecase.dart';
import 'package:solufine/features/expense/presentation/bloc/my_expense_bloc.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> initMyExpenseFeature() async {
  // =========================================================
  // DATA SOURCE
  // =========================================================

  if (!sl.isRegistered<MyExpenseRemoteDataSource>()) {
    sl.registerLazySingleton<MyExpenseRemoteDataSource>(
      () => MyExpenseRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
      ),
    );
  }

  // =========================================================
  // REPOSITORY
  // =========================================================

  if (!sl.isRegistered<MyExpenseRepository>()) {
    sl.registerLazySingleton<MyExpenseRepository>(
      () => MyExpenseRepositoryImpl(
        remoteDataSource: sl<MyExpenseRemoteDataSource>(),
      ),
    );
  }

  // =========================================================
  // USE CASE
  // =========================================================

  if (!sl.isRegistered<GetMyExpensesUseCase>()) {
    sl.registerLazySingleton<GetMyExpensesUseCase>(
      () => GetMyExpensesUseCase(
        repository: sl<MyExpenseRepository>(),
      ),
    );
  }

  // =========================================================
  // BLOC
  // =========================================================

  if (!sl.isRegistered<MyExpenseBloc>()) {
    sl.registerFactory<MyExpenseBloc>(
      () => MyExpenseBloc(
        getMyExpensesUseCase: sl<GetMyExpensesUseCase>(),
      ),
    );
  }
}