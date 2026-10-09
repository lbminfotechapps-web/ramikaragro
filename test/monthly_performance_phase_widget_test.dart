import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:solufine/features/reports/data/modles/monthly_performance_model.dart';
import 'package:solufine/features/reports/data/modles/daily_performance_model.dart';
import 'package:solufine/features/reports/data/modles/hourly_performance_model.dart';
import 'package:solufine/features/reports/data/modles/area_performance_model.dart';
import 'package:solufine/features/reports/data/modles/top_dealer_performance_model.dart';
import 'package:solufine/features/reports/domain/repositories/monthly_performance_repository.dart';
import 'package:solufine/features/reports/domain/repositories/employee_output_repository.dart';
import 'package:solufine/features/reports/domain/usecases/get_application_phase_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_area_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_daily_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_expense_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_hourly_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_monthly_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_report_financial_years.dart';
import 'package:solufine/features/reports/domain/usecases/get_top_dealer_performance_usecase.dart';
import 'package:solufine/features/reports/domain/usecases/get_employee_output_report.dart';
import 'package:solufine/features/reports/domain/usecases/get_employees.dart';
import 'package:solufine/features/reports/presentation/bloc/monthly_performance_bloc.dart';
import 'package:solufine/features/reports/presentation/bloc/monthly_performance_event.dart';
import 'package:solufine/features/reports/presentation/bloc/monthly_performance_state.dart';
import 'package:solufine/features/reports/presentation/bloc/employee_output_bloc.dart';
import 'package:solufine/features/reports/presentation/pages/monthly_performance_report_page.dart';

class _UnusedRepository implements MonthlyPerformanceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedEmployeeRepository implements EmployeeOutputRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ReportBloc extends MonthlyPerformanceBloc {
  _ReportBloc(MonthlyPerformanceRepository r, MonthlyPerformanceState initial)
    : super(
        getApplicationPhaseUseCase: GetApplicationPhaseUseCase(r),
        getMonthlyPerformanceUseCase: GetMonthlyPerformanceUseCase(r),
        getReportFinancialYears: GetReportFinancialYears(r),
        getDailyPerformanceUseCase: GetDailyPerformanceUseCase(r),
        getHourlyPerformanceUseCase: GetHourlyPerformanceUseCase(r),
        getAreaPerformanceUseCase: GetAreaPerformanceUseCase(r),
        getTopDealerPerformanceUseCase: GetTopDealerPerformanceUseCase(r),
        getExpensePerformanceUseCase: GetExpensePerformanceUseCase(r),
      ) {
    emit(initial);
  }
  final events = <MonthlyPerformanceEvent>[];
  @override
  void add(MonthlyPerformanceEvent event) => events.add(event);
  void changePhase(int phase) => emit(state.copyWith(applicationPhase: phase));
}

void main() {
  testWidgets('phase controls all report columns, tabs, KPIs and chart series', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final row = <String, dynamic>{
      'month_key': '2026-10',
      'month_label': 'Oct-26',
      'day_key': '01',
      'hour_key': '09',
      'hour_label': '09:00',
      'area_name': 'Test Area',
      'name': 'Test Dealer',
      'visits': 23,
      'order_amount': 25000,
      'dispatch_amount': 15000,
      'collection_amount': 12000,
    };
    final json = <String, dynamic>{
      'status': true,
      'result': [row],
    };
    final bloc = _ReportBloc(
      _UnusedRepository(),
      MonthlyPerformanceState(
        applicationPhaseStatus: ApplicationPhaseStatus.success,
        applicationPhase: 1,
        status: MonthlyPerformanceStatus.success,
        report: MonthlyPerformanceModel.fromJson(json),
        dailyStatus: DailyPerformanceStatus.success,
        dailyReport: DailyPerformanceModel.fromJson(json),
        hourlyStatus: HourlyPerformanceStatus.success,
        hourlyReport: HourlyPerformanceModel.fromJson(json),
        areaStatus: AreaPerformanceStatus.success,
        areaReport: AreaPerformanceModel.fromJson(json),
        topDealerStatus: TopDealerPerformanceStatus.success,
        topDealerReport: TopDealerPerformanceModel.fromJson(json),
      ),
    );
    final employeeRepository = _UnusedEmployeeRepository();
    final employees = EmployeeOutputBloc(
      getEmployeeOutputReport: GetEmployeeOutputReport(employeeRepository),
      getEmployees: GetEmployees(employeeRepository),
    );
    addTearDown(bloc.close);
    addTearDown(employees.close);
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<MonthlyPerformanceBloc>.value(value: bloc),
            BlocProvider<EmployeeOutputBloc>.value(value: employees),
          ],
          child: const MonthlyPerformanceReportPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(bloc.events.whereType<GetApplicationPhaseEvent>(), hasLength(1));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    for (final title in [
      'Monthly Details',
      'Performance Analysis',
      'Daily Activity',
      'Daily Details',
      'Hourly Activity',
      'Hourly Details',
      'Area-wise Count',
      'Most Visited Dealers',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    for (final title in [
      'ORDER',
      'ORDERS',
      'DISPATCH',
      'COLLECTION',
      'Amount',
      'Amount Performance',
      'Orders',
      'Dispatch',
      'Collection',
    ]) {
      expect(find.text(title), findsNothing);
    }
    expect(find.textContaining('Right: amount'), findsNothing);
    final lines = tester.widgetList<LineChart>(find.byType(LineChart)).toList();
    expect(lines, hasLength(2));
    for (final chart in lines) {
      expect(chart.data.lineBarsData, hasLength(1));
      expect(chart.data.titlesData.rightTitles.sideTitles.showTitles, isFalse);
      expect(chart.data.titlesData.leftTitles.sideTitles.interval, 5);
    }
    expect(tester.takeException(), isNull);

    void expectColumnsFillTable() {
      for (final label in ['MONTH', 'DAY', 'HOUR', 'AREA / TALUKA', 'RANK']) {
        final rowFinder = find
            .ancestor(of: find.text(label), matching: find.byType(Row))
            .first;
        final row = tester.widget<Row>(rowFinder);
        final bounds = tester.getRect(rowFinder);
        final lastCell = tester.getRect(find.byWidget(row.children.last));
        expect(lastCell.right, closeTo(bounds.right, .1), reason: label);
        expect(row.children.whereType<Expanded>(), isNotEmpty, reason: label);
      }
      expect(tester.takeException(), isNull);
    }

    // Hidden columns redistribute their space at phone, tablet, and desktop widths.
    for (final width in [390.0, 800.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 6000);
      await tester.pumpAndSettle();
      expectColumnsFillTable();
      final monthly = tester
          .getSize(
            find
                .ancestor(of: find.text('MONTH'), matching: find.byType(Row))
                .first,
          )
          .width;
      expect(monthly, lessThanOrEqualTo(width));
    }

    bloc.changePhase(2);
    await tester.pumpAndSettle();
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Amount Performance'), findsOneWidget);
    expect(find.text('ORDERS'), findsNWidgets(3));
    expect(find.text('ORDER'), findsNWidgets(2));
    expect(find.text('DISPATCH'), findsNWidgets(5));
    expect(find.text('COLLECTION'), findsNWidgets(6));
    for (final width in [390.0, 800.0, 1200.0]) {
      tester.view.physicalSize = Size(width, 6000);
      await tester.pumpAndSettle();
      expectColumnsFillTable();
    }

    for (final chart in tester.widgetList<LineChart>(find.byType(LineChart))) {
      expect(chart.data.lineBarsData, hasLength(4));
      expect(chart.data.titlesData.rightTitles.sideTitles.showTitles, isTrue);
    }
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
