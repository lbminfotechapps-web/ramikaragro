import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/core/api_constant/dio_client.dart';
import 'package:solufine/features/visit_month_wise/data/datasources/visit_month_wise_remote_datasource.dart';
import 'package:solufine/features/visit_month_wise/data/repositories/visit_month_wise_repository_impl.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_month_wise_usecase.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_day_wise_usecase.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_hour_wise_usecase.dart';
import 'package:solufine/features/visit_month_wise/domain/usecases/get_visit_report_employees_usecase.dart';
import 'package:solufine/features/visit_month_wise/presentation/bloc/visit_month_wise_bloc.dart';
import 'package:solufine/features/visit_month_wise/presentation/pages/visit_month_wise_report_page.dart';

void main() {
  final client = DioClient();
  late Interceptor interceptor;
  dynamic body;
  setUp(() {
    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response(requestOptions: options, statusCode: 200, data: body),
        );
      },
    );
    client.client.interceptors.add(interceptor);
  });
  tearDown(() => client.client.interceptors.remove(interceptor));

  for (final status in [true, false, null]) {
    testWidgets('empty response (status $status) keeps all report designs', (
      tester,
    ) async {
      body = jsonEncode({
        'status': status ?? false,
        'message': status == null ? 'Access denied' : 'RECORD NOT FOUND.',
        'result': [],
      });
      FlutterSecureStorage.setMockInitialValues({
        'user_data': jsonEncode({'user_id': '7', 'user_name': 'Test Employee'}),
      });
      tester.view.physicalSize = const Size(1000, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = VisitMonthWiseRepositoryImpl(
        remoteDataSource: VisitMonthWiseRemoteDataSourceImpl(dioClient: client),
      );
      final bloc = VisitMonthWiseBloc(
        getVisitMonthWiseUseCase: GetVisitMonthWiseUseCase(repository),
        getVisitDayWiseUseCase: GetVisitDayWiseUseCase(repository),
        getVisitHourWiseUseCase: GetVisitHourWiseUseCase(repository),
        getVisitReportEmployeesUseCase: GetVisitReportEmployeesUseCase(
          repository,
        ),
      );
      addTearDown(bloc.close);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: const VisitMonthWiseReportPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in ['Month', 'Day of Month', 'Hrs of Day']) {
        expect(find.text(label), findsOneWidget);
      }
      for (final period in ['month', 'day', 'hour']) {
        expect(find.text('No $period wise visit data found'), findsOneWidget);
      }
      expect(find.text('TOTAL'), findsNWidgets(4));
      expect(find.byIcon(Icons.inbox_outlined), findsNWidgets(3));
      if (status != null) {
        expect(bloc.state.report!.total.totalVisits, 0);
        expect(bloc.state.dayWiseReport!.total.totalVisits, 0);
        expect(bloc.state.hourWiseReport!.total.totalVisits, 0);
      } else {
        expect(find.text('Access denied'), findsNWidgets(3));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  test('API failures remain errors instead of empty reports', () async {
    body = {'status': false, 'result': [], 'message': 'Access denied'};
    final source = VisitMonthWiseRemoteDataSourceImpl(dioClient: client);
    for (final load in [
      source.getVisitMonthWise,
      source.getVisitDayWise,
      source.getVisitHourWise,
    ]) {
      await expectLater(
        load(fromDate: '2026-10-01', toDate: '2026-10-08', employeeId: '7'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Access denied'),
          ),
        ),
      );
    }
  });
}
