import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/reports/data/datasources/monthly_performance_remote_datasource.dart';
import 'package:solufine/features/reports/data/modles/application_phase_model.dart';
import 'package:solufine/features/reports/data/repositories/monthly_performance_repository_impl.dart';
import 'package:solufine/features/reports/domain/usecases/get_application_phase_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_area_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_daily_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_expense_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_hourly_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_monthly_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_report_financial_years.dart';
import 'package:solufine/features/reports/domain/usecases/get_top_dealer_performance_usecase.dart';
import 'package:solufine/features/reports/presentation/bloc/monthly_performance_bloc.dart';
import 'package:solufine/features/reports/presentation/bloc/monthly_performance_event.dart';
import 'package:solufine/features/reports/presentation/bloc/monthly_performance_state.dart';

void main() {
  final client = DioClient();
  late Interceptor interceptor;
  dynamic body;
  setUp(() {
    body = {'status': true, 'result': 1, 'message': 'RECORD FOUND.'};
    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        expect(options.method, 'GET');
        expect(
          options.uri.toString(),
          'https://agroaicrm.com/solufine_agritech/mobileapi/Mobile_app_for_businessplus_kotlin_new/get_application_phase',
        );
        handler.resolve(
          Response(requestOptions: options, statusCode: 200, data: body),
        );
      },
    );
    client.client.interceptors.add(interceptor);
  });
  tearDown(() => client.client.interceptors.remove(interceptor));

  MonthlyPerformanceBloc createBloc() {
    final repository = MonthlyPerformanceRepositoryImpl(
      remoteDataSource: MonthlyPerformanceRemoteDataSourceImpl(
        dioClient: client,
      ),
    );
    return MonthlyPerformanceBloc(
      getApplicationPhaseUseCase: GetApplicationPhaseUseCase(repository),
      getMonthlyPerformanceUseCase: GetMonthlyPerformanceUseCase(repository),
      getReportFinancialYears: GetReportFinancialYears(repository),
      getDailyPerformanceUseCase: GetDailyPerformanceUseCase(repository),
      getHourlyPerformanceUseCase: GetHourlyPerformanceUseCase(repository),
      getAreaPerformanceUseCase: GetAreaPerformanceUseCase(repository),
      getTopDealerPerformanceUseCase: GetTopDealerPerformanceUseCase(
        repository,
      ),
      getExpensePerformanceUseCase: GetExpensePerformanceUseCase(repository),
    );
  }

  for (final asText in [false, true]) {
    test(
      'phase 1 flows from API through repository/use case/BLoC ($asText)',
      () async {
        if (asText) body = jsonEncode(body);
        final bloc = createBloc();
        addTearDown(bloc.close);
        final states = <MonthlyPerformanceState>[];
        final subscription = bloc.stream.listen(states.add);
        addTearDown(subscription.cancel);
        final completed = bloc.stream.firstWhere(
          (s) => s.applicationPhaseStatus == ApplicationPhaseStatus.success,
        );
        bloc.add(const GetApplicationPhaseEvent());
        final state = await completed;
        expect(state.applicationPhase, 1);
        expect(state.isVisitOnlyPhase, isTrue);
        expect(
          states.first.applicationPhaseStatus,
          ApplicationPhaseStatus.loading,
        );
        expect(state.copyWith().isVisitOnlyPhase, isTrue);

        body = {'status': true, 'result': 2};
        final refreshed = bloc.stream.firstWhere(
          (s) =>
              s.applicationPhaseStatus == ApplicationPhaseStatus.success &&
              s.applicationPhase == 2,
        );
        bloc.add(const GetApplicationPhaseEvent());
        expect((await refreshed).isVisitOnlyPhase, isFalse);
      },
    );
  }

  for (final response in [
    {'status': false, 'message': 'Phase unavailable'},
    {'status': true, 'result': 'invalid'},
    {'status': true},
    [],
    '<html>Unavailable</html>',
  ]) {
    test(
      'invalid or failed phase response enters retry state: $response',
      () async {
        body = response;
        final bloc = createBloc();
        addTearDown(bloc.close);
        final failed = bloc.stream.firstWhere(
          (s) => s.applicationPhaseStatus == ApplicationPhaseStatus.failure,
        );
        bloc.add(const GetApplicationPhaseEvent());
        expect((await failed).applicationPhaseError, isNotEmpty);

        body = {'status': true, 'result': 1};
        final retried = bloc.stream.firstWhere(
          (s) => s.applicationPhaseStatus == ApplicationPhaseStatus.success,
        );
        bloc.add(const GetApplicationPhaseEvent());
        final state = await retried;
        expect(state.isVisitOnlyPhase, isTrue);
        expect(state.applicationPhaseError, isNull);
      },
    );
  }

  test('numeric string phase is supported', () {
    expect(ApplicationPhaseModel.fromJson({'result': '1'}).isVisitOnly, isTrue);
    expect(ApplicationPhaseModel.fromJson({'result': 0}).isVisitOnly, isFalse);
  });
}
