import 'package:solufine/features/addexpense/data/datasource/expense_remote_datasource.dart';
import 'package:solufine/features/addexpense/data/repositories/expense_repository_impl.dart';
import 'package:solufine/features/addexpense/domain/repositories/expense_repository.dart';
import 'package:solufine/features/addexpense/domain/usecases/add_expense_usecase.dart';
import 'package:solufine/features/addexpense/domain/usecases/check_expense_status_usecase.dart';
import 'package:solufine/features/addexpense/domain/usecases/get_da_amount_usecase.dart';
import 'package:solufine/features/addexpense/domain/usecases/get_expense_days_usecase.dart';
import 'package:solufine/features/addexpense/domain/usecases/get_expense_parameters_usecase.dart';
import 'package:solufine/features/addexpense/domain/usecases/get_expense_vehicle_usecase.dart';
import 'package:solufine/features/addexpense/presentation/bloc/expense_bloc.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initExpenseDi() async {
  // Datasource
  sl.registerLazySingleton<ExpenseRemoteDatasource>(
    () => ExpenseRemoteDatasourceImpl(sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(sl<ExpenseRemoteDatasource>()),
  );

  // UseCases
  sl.registerLazySingleton(
    () => GetExpenseVehicleUseCase(sl<ExpenseRepository>()),
  );

  sl.registerLazySingleton(
    () => GetExpenseParametersUseCase(sl<ExpenseRepository>()),
  );

  sl.registerLazySingleton(() => GetDAAmountUseCase(sl<ExpenseRepository>()));

  sl.registerLazySingleton(
    () => GetExpenseDaysUseCase(sl<ExpenseRepository>()),
  );

  sl.registerLazySingleton(
    () => CheckExpenseStatusUseCase(sl<ExpenseRepository>()),
  );

  sl.registerLazySingleton(() => AddExpenseUseCase(sl<ExpenseRepository>()));

  // Bloc
  sl.registerFactory(
    () => ExpenseBloc(
      getVehicles: sl<GetExpenseVehicleUseCase>(),
      getParameters: sl<GetExpenseParametersUseCase>(),
      getDAAmount: sl<GetDAAmountUseCase>(),
      getExpenseDays: sl<GetExpenseDaysUseCase>(),
      checkStatus: sl<CheckExpenseStatusUseCase>(),
      addExpense: sl<AddExpenseUseCase>(),
    ),
  );
}
