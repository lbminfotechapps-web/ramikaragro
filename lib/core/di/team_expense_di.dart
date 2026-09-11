import 'package:demo/core/api_constant/dio_client.dart';
import 'package:demo/core/di/auth_di.dart';
import 'package:demo/features/expense/data/repositories/team_expense_repository_impl.dart';

import '../../features/expense/data/datasources/team_expense_remote_datasource.dart';
import '../../features/expense/domain/repositories/team_expense_repository.dart';
import '../../features/expense/domain/usecases/get_team_expenses_usecase.dart';
import '../../features/expense/domain/usecases/update_team_expense_usecase.dart';
import '../../features/expense/presentation/bloc/team_expense_bloc.dart';

Future<void> initTeamExpenseFeature() async {
  // ---------------------------------------------------------
  // 1. DataSource
  // ---------------------------------------------------------
  if (!sl.isRegistered<TeamExpenseRemoteDatasource>()) {
    sl.registerLazySingleton<TeamExpenseRemoteDatasource>(
      () => TeamExpenseRemoteDatasource(
       sl<DioClient>(),
      ),
    );
  }

  // ---------------------------------------------------------
  // 2. Repository
  // ---------------------------------------------------------
  if (!sl.isRegistered<TeamExpenseRepository>()) {
    sl.registerLazySingleton<TeamExpenseRepository>(
      () => TeamExpenseRemoteImpl(
        sl<TeamExpenseRemoteDatasource>(),
      ),
    );
  }

  // ---------------------------------------------------------
  // 3. Get Team Expenses UseCase
  // ---------------------------------------------------------
  if (!sl.isRegistered<GetTeamExpensesUsecase>()) {
    sl.registerLazySingleton<GetTeamExpensesUsecase>(
      () => GetTeamExpensesUsecase(
        repository: sl<TeamExpenseRepository>(),
      ),
    );
  }

  // ---------------------------------------------------------
  // 4. Update Team Expense UseCase
  // ---------------------------------------------------------
  if (!sl.isRegistered<UpdateTeamExpenseUsecase>()) {
    sl.registerLazySingleton<UpdateTeamExpenseUsecase>(
      () => UpdateTeamExpenseUsecase(
        repository: sl<TeamExpenseRepository>(),
      ),
    );
  }

  // ---------------------------------------------------------
  // 5. Bloc
  // ---------------------------------------------------------
  if (!sl.isRegistered<TeamExpenseBloc>()) {
    sl.registerFactory<TeamExpenseBloc>(
      () => TeamExpenseBloc(
        getTeamExpensesUsecase:
            sl<GetTeamExpensesUsecase>(),
        updateTeamExpenseUsecase:
            sl<UpdateTeamExpenseUsecase>(),
      ),
    );
  }
}