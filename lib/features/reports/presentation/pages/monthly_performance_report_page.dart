import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/secure_storage/secure_storage.dart';
import '../../../../core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/assign_employee.dart';
import '../../domain/entities/area_performance.dart';
import '../../domain/entities/daily_performance.dart';
import '../../domain/entities/expense_performance.dart';
import '../../domain/entities/hourly_performance.dart';
import '../../domain/entities/monthly_performance.dart';
import '../../domain/entities/report_financial_year.dart';
import '../../domain/entities/top_dealer_performance.dart';

import '../bloc/employee_output_bloc.dart';
import '../bloc/employee_output_event.dart';
import '../bloc/employee_output_state.dart';

import '../bloc/monthly_performance_bloc.dart';
import '../bloc/monthly_performance_event.dart';
import '../bloc/monthly_performance_state.dart';

class MonthlyPerformanceReportPage extends StatefulWidget {
  const MonthlyPerformanceReportPage({super.key});

  @override
  State<MonthlyPerformanceReportPage> createState() =>
      _MonthlyPerformanceReportPageState();
}

class _MonthlyPerformanceReportPageState
    extends State<MonthlyPerformanceReportPage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color _primary = Color(0xFF14804A);
  static const Color _primaryDark = Color(0xFF0B6539);

  static const Color _blue = Color(0xFF3977D5);
  static const Color _red = Color(0xFFE45B55);
  static const Color _dispatchColor = Color(0xFF7FAF3E);
  static const Color _collectionColor = Color(0xFF17A99A);
  static const Color _purple = Color(0xFF7357D8);
  static const Color _orange = Color(0xFFF59E0B);

  static const Color _background = Color(0xFFF5F7F9);
  static const Color _cardColor = Colors.white;
  static const Color _border = Color(0xFFE7EBEF);

  static const Color _text = Color(0xFF17212B);
  static const Color _secondaryText = Color(0xFF75808E);

  static const Color _softGreen = Color(0xFFF0F8F4);
  static const Color _softBlue = Color(0xFFF2F6FC);

  // ============================================================
  // TABLE WIDTHS
  // ============================================================

  static const double _checkWidth = 28;
  static const double _monthWidth = 58;
  static const double _dayWidth = 50;
  static const double _hourWidth = 88;
  static const double _areaWidth = 96;
  static const double _rankWidth = 42;
  static const double _dealerWidth = 150;
  static const double _talukaWidth = 78;
  static const double _topVisitWidth = 48;
  static const double _lastVisitWidth = 82;

  static const double _visitWidth = 40;
  static const double _orderWidth = 84;
  static const double _dispatchWidth = 84;
  static const double _collectionWidth = 78;
  static const double _avgWidth = 44;
  static const double _shareWidth = 64;

  // Expense table
  static const double _expenseParameterWidth = 125;
  static const double _expenseAmountWidth = 76;
  static const double _expenseShareWidth = 62;

  // ============================================================
  // LOGIN
  // ============================================================

  String _loginEmployeeId = '';
  String _loginEmployeeName = '';
  bool _loginLoaded = false;

  // ============================================================
  // EMPLOYEE
  // ============================================================

  String _selectedEmployeeId = '';
  String _selectedEmployeeName = '';

  final TextEditingController _employeeController = TextEditingController();

  final FocusNode _employeeFocusNode = FocusNode();

  Timer? _employeeTimer;

  bool _showEmployeeList = false;

  // ============================================================
  // FINANCIAL YEAR
  // ============================================================

  ReportFinancialYear? _selectedFinancialYear;

  // ============================================================
  // MONTH
  // ============================================================

  final Set<String> _selectedMonthKeys = {};

  // ============================================================
  // UI
  // ============================================================

  bool _filterExpanded = false;
  bool _showAmountPerformance = true;
  bool _showAreaDealerChart = true;
  bool _initialReportLoaded = false;

  bool get _visitOnly =>
      context.read<MonthlyPerformanceBloc>().state.isVisitOnlyPhase;

  double get _businessColumnsWidth =>
      _visitOnly ? 0 : _orderWidth + _dispatchWidth + _collectionWidth;

  void _fetchApplicationPhase() {
    context.read<MonthlyPerformanceBloc>().add(
      const GetApplicationPhaseEvent(),
    );
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _fetchApplicationPhase();
      _loadLogin();
    });
  }

  @override
  void dispose() {
    _employeeTimer?.cancel();
    _employeeController.dispose();
    _employeeFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _loadLogin() async {
    final Map<String, dynamic>? data = await SecureStorage.instance
        .getUserData();

    if (!mounted) return;

    final String userId = data?['user_id']?.toString().trim() ?? '';

    final String userName = data?['user_name']?.toString().trim() ?? '';

    setState(() {
      _loginEmployeeId = userId;
      _loginEmployeeName = userName;

      _selectedEmployeeId = userId;
      _selectedEmployeeName = userName;

      _employeeController.text = userName;

      _loginLoaded = true;
    });

    if (userId.isNotEmpty) {
      context.read<MonthlyPerformanceBloc>().add(
        const GetReportFinancialYearsEvent(),
      );
    }
  }

  // ============================================================
  // DEFAULT FY
  // ============================================================

  ReportFinancialYear? _defaultFY(List<ReportFinancialYear> years) {
    if (years.isEmpty) return null;

    final DateTime now = DateTime.now();

    for (final fy in years) {
      final DateTime? from = DateTime.tryParse(fy.fromDate);

      final DateTime? to = DateTime.tryParse(fy.toDate);

      if (from == null || to == null) {
        continue;
      }

      final DateTime end = DateTime(to.year, to.month, to.day, 23, 59, 59);

      if (!now.isBefore(from) && !now.isAfter(end)) {
        return fy;
      }
    }

    return years.last;
  }

  // ============================================================
  // MONTH PARAMETER
  // ============================================================

  String _selectedMonthParameter() {
    final List<String> months = _selectedMonthKeys.toList()..sort();

    return months.join(',');
  }

  // ============================================================
  // FETCH REPORT
  // ============================================================

  void _fetchReport() {
    if (_selectedFinancialYear == null || _selectedEmployeeId.isEmpty) {
      return;
    }

    context.read<MonthlyPerformanceBloc>().add(
      GetMonthlyPerformanceEvent(
        employeeId: _selectedEmployeeId,
        financialYear: _selectedFinancialYear!.id,
      ),
    );
  }

  // ============================================================
  // FETCH DAILY
  // ============================================================

  void _fetchDailyReport() {
    if (_selectedEmployeeId.isEmpty ||
        _selectedFinancialYear == null ||
        _selectedMonthKeys.isEmpty) {
      return;
    }

    context.read<MonthlyPerformanceBloc>().add(
      GetDailyPerformanceEvent(
        employeeId: _selectedEmployeeId,
        financialYear: _selectedFinancialYear!.id,
        selectedMonths: _selectedMonthParameter(),
      ),
    );
  }

  // ============================================================
  // FETCH HOURLY
  // ============================================================

  void _fetchHourlyReport() {
    if (_selectedEmployeeId.isEmpty ||
        _selectedFinancialYear == null ||
        _selectedMonthKeys.isEmpty) {
      return;
    }

    context.read<MonthlyPerformanceBloc>().add(
      GetHourlyPerformanceEvent(
        employeeId: _selectedEmployeeId,
        financialYear: _selectedFinancialYear!.id,
        selectedMonths: _selectedMonthParameter(),
      ),
    );
  }

  void _clearDailyReport() {
    context.read<MonthlyPerformanceBloc>().add(
      const ClearDailyPerformanceEvent(),
    );
  }

  void _clearHourlyReport() {
    context.read<MonthlyPerformanceBloc>().add(
      const ClearHourlyPerformanceEvent(),
    );
  }

  // ============================================================
  // FETCH AREA-WISE
  // ============================================================

  void _fetchAreaReport() {
    if (_selectedEmployeeId.isEmpty ||
        _selectedFinancialYear == null ||
        _selectedMonthKeys.isEmpty) {
      return;
    }

    context.read<MonthlyPerformanceBloc>().add(
      GetAreaPerformanceEvent(
        employeeId: _selectedEmployeeId,
        financialYear: _selectedFinancialYear!.id,
        selectedMonths: _selectedMonthParameter(),
      ),
    );
  }

  void _clearAreaReport() {
    context.read<MonthlyPerformanceBloc>().add(
      const ClearAreaPerformanceEvent(),
    );
  }

  // ============================================================
  // FETCH TOP DEALERS
  // ============================================================

  void _fetchTopDealersReport() {
    if (_selectedEmployeeId.isEmpty ||
        _selectedFinancialYear == null ||
        _selectedMonthKeys.isEmpty) {
      return;
    }

    context.read<MonthlyPerformanceBloc>().add(
      GetTopDealerPerformanceEvent(
        employeeId: _selectedEmployeeId,
        financialYear: _selectedFinancialYear!.id,
        selectedMonths: _selectedMonthParameter(),
      ),
    );
  }

  void _clearTopDealersReport() {
    context.read<MonthlyPerformanceBloc>().add(
      const ClearTopDealerPerformanceEvent(),
    );
  }

  // ============================================================
  // FETCH EXPENSE
  // ============================================================

  void _fetchExpenseReport() {
    if (_selectedEmployeeId.isEmpty ||
        _selectedFinancialYear == null ||
        _selectedMonthKeys.isEmpty) {
      return;
    }

    context.read<MonthlyPerformanceBloc>().add(
      GetExpensePerformanceEvent(
        employeeId: _selectedEmployeeId,
        financialYear: _selectedFinancialYear!.id,
        selectedMonths: _selectedMonthParameter(),
      ),
    );
  }

  void _clearExpenseReport() {
    context.read<MonthlyPerformanceBloc>().add(
      const ClearExpensePerformanceEvent(),
    );
  }

  // ============================================================
  // EMPLOYEE
  // ============================================================

  void _loadEmployees({String? search}) {
    if (_loginEmployeeId.isEmpty) {
      return;
    }

    context.read<EmployeeOutputBloc>().add(
      SearchEmployeesEvent(
        logUserId: _loginEmployeeId,
        search: search ?? _employeeController.text.trim(),
      ),
    );
  }

  void _employeeSearch(String value) {
    _employeeTimer?.cancel();

    setState(() {
      _showEmployeeList = true;

      if (value.trim() != _selectedEmployeeName) {
        _selectedEmployeeId = '';
      }
    });

    _employeeTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      _loadEmployees(search: value.trim());
    });
  }

  void _selectEmployee(AssignEmployee employee) {
    final String id = employee.fldId.toString().trim();

    final String name = employee.fldAdmName.trim();

    setState(() {
      _selectedEmployeeId = id;
      _selectedEmployeeName = name;

      _employeeController.text = name;

      _showEmployeeList = false;

      _selectedMonthKeys.clear();
    });

    _clearDailyReport();
    _clearHourlyReport();
    _clearAreaReport();
    _clearTopDealersReport();
    _clearExpenseReport();

    context.read<EmployeeOutputBloc>().add(
      const ClearEmployeeSuggestionsEvent(),
    );

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // VIEW REPORT
  // ============================================================

  void _viewReport() {
    FocusScope.of(context).unfocus();

    if (_selectedFinancialYear == null) {
      _message('Please select financial year');

      return;
    }

    if (_selectedEmployeeId.isEmpty) {
      _message('Please select employee');

      return;
    }

    setState(() {
      _filterExpanded = false;
      _showEmployeeList = false;
      _selectedMonthKeys.clear();
    });

    _clearDailyReport();
    _clearHourlyReport();
    _clearAreaReport();
    _clearTopDealersReport();
    _clearExpenseReport();

    _fetchReport();
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(value)),
      );
  }

  // ============================================================
  // MONTH SUMMARY
  // ============================================================

  List<MonthlyPerformanceItem> _selectedMonths(MonthlyPerformance report) {
    return report.months
        .where((item) => _selectedMonthKeys.contains(item.monthKey))
        .toList();
  }

  _MonthSummary _summary(MonthlyPerformance report) {
    final selected = _selectedMonths(report);

    if (selected.isEmpty) {
      return const _MonthSummary(
        visits: 0,
        average: 0,
        bestMonth: '-',
        orderAmount: 0,
        orderCount: 0,
        dispatchAmount: 0,
        dispatchCount: 0,
        collection: 0,
        visitShare: 0,
      );
    }

    int visits = 0;
    double average = 0;

    double order = 0;
    int orderCount = 0;

    double dispatch = 0;
    int dispatchCount = 0;

    double collection = 0;
    double share = 0;

    int best = -1;
    String bestMonth = '-';

    for (final item in selected) {
      visits += item.visits;
      average += item.dailyVisitAvg;

      order += item.orderAmount;
      orderCount += item.orderCount;

      dispatch += item.dispatchAmount;
      dispatchCount += item.dispatchCount;

      collection += item.paymentCollection;

      share += item.visitShare;

      if (item.visits > best) {
        best = item.visits;
        bestMonth = item.month;
      }
    }

    return _MonthSummary(
      visits: visits,
      average: average / selected.length,
      bestMonth: bestMonth,
      orderAmount: order,
      orderCount: orderCount,
      dispatchAmount: dispatch,
      dispatchCount: dispatchCount,
      collection: collection,
      visitShare: share,
    );
  }

  _DailySummary _dailySummary(DailyPerformance report) {
    int activeDays = 0;
    int highestVisits = 0;

    String bestDay = '-';

    for (final item in report.days) {
      if (item.visits > 0) {
        activeDays++;
      }

      if (item.visits > highestVisits) {
        highestVisits = item.visits;

        bestDay = '${item.dayKey} (${item.visits})';
      }
    }

    return _DailySummary(
      totalVisits: report.totalVisits,
      activeDays: activeDays,
      bestDay: bestDay,
      highestVisits: highestVisits,
    );
  }

  _HourlySummary _hourlySummary(HourlyPerformance report) {
    int activeHours = 0;
    int highestVisits = 0;

    String peakHour = '-';

    for (final item in report.hours) {
      if (item.visits > 0 ||
          item.orderAmount > 0 ||
          item.dispatchAmount > 0 ||
          item.collectionAmount > 0) {
        activeHours++;
      }

      if (item.visits > highestVisits) {
        highestVisits = item.visits;
        peakHour = item.hourLabel;
      }
    }

    return _HourlySummary(
      peakHour: peakHour,
      highestVisits: highestVisits,
      activeHours: activeHours,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      appBar: CustomAppBar(
        title: 'Sales Person Statistics',
        showBackButton: true,

        onBackTap: () {
          context.go(AppRouter.home);
        },

        actionIcon: Icons.refresh_rounded,

        onActionIconTap: () {
          _fetchApplicationPhase();
          _fetchReport();

          if (_selectedMonthKeys.isNotEmpty) {
            _fetchDailyReport();
            _fetchHourlyReport();
            _fetchAreaReport();
            _fetchTopDealersReport();
            _fetchExpenseReport();
          }
        },
      ),

      body: !_loginLoaded
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : BlocConsumer<MonthlyPerformanceBloc, MonthlyPerformanceState>(
              listener: (context, state) {
                if (state.financialYearStatus == FinancialYearStatus.success &&
                    _selectedFinancialYear == null &&
                    state.financialYears.isNotEmpty) {
                  final fy = _defaultFY(state.financialYears);

                  if (fy != null) {
                    setState(() {
                      _selectedFinancialYear = fy;
                    });

                    if (!_initialReportLoaded) {
                      _initialReportLoaded = true;

                      _fetchReport();
                    }
                  }
                }
              },

              builder: (context, state) {
                if (state.applicationPhaseStatus ==
                        ApplicationPhaseStatus.initial ||
                    state.applicationPhaseStatus ==
                        ApplicationPhaseStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: _primary),
                  );
                }
                if (state.applicationPhaseStatus ==
                    ApplicationPhaseStatus.failure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _errorCard(
                          state.applicationPhaseError ??
                              'Unable to load application phase',
                        ),
                        TextButton(
                          onPressed: _fetchApplicationPhase,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: _primary,

                  onRefresh: () async {
                    _fetchApplicationPhase();
                    _fetchReport();

                    if (_selectedMonthKeys.isNotEmpty) {
                      _fetchDailyReport();
                      _fetchHourlyReport();
                      _fetchAreaReport();
                      _fetchTopDealersReport();
                      _fetchExpenseReport();
                    }
                  },

                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),

                    padding: const EdgeInsets.fromLTRB(7, 7, 7, 18),

                    children: [
                      _filterCard(state),

                      const SizedBox(height: 8),

                      if (state.status == MonthlyPerformanceStatus.loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 55),
                          child: Center(
                            child: CircularProgressIndicator(color: _primary),
                          ),
                        ),

                      if (state.status == MonthlyPerformanceStatus.failure)
                        _errorCard(
                          state.errorMessage ?? 'Unable to load report',
                        ),

                      if (state.status == MonthlyPerformanceStatus.success &&
                          state.report != null)
                        _dashboard(state.report!, state),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ============================================================
  // FILTER CARD
  // ============================================================

  Widget _filterCard(MonthlyPerformanceState state) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),

            onTap: () {
              setState(() {
                _filterExpanded = !_filterExpanded;
              });
            },

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: _softGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: _primary,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Performance Report',
                          style: TextStyle(
                            color: _text,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _selectedEmployeeName.isEmpty
                                    ? 'Select Employee'
                                    : _selectedEmployeeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _secondaryText,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                '•',
                                style: TextStyle(color: _secondaryText),
                              ),
                            ),

                            Text(
                              _selectedFinancialYear?.label ?? 'FY',
                              style: const TextStyle(
                                color: _primary,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  AnimatedRotation(
                    turns: _filterExpanded ? .5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F7F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: _secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _filterExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,

            firstChild: const SizedBox.shrink(),

            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: [
                  const Divider(height: 1, color: _border),

                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _employeeField()),

                      const SizedBox(width: 7),

                      Expanded(flex: 3, child: _fyField(state)),
                    ],
                  ),

                  BlocBuilder<EmployeeOutputBloc, EmployeeOutputState>(
                    builder: (context, employeeState) {
                      return _employeeList(employeeState);
                    },
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: _viewReport,

                      icon: const Icon(Icons.analytics_outlined, size: 16),

                      label: const Text('View Performance'),

                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPLOYEE FIELD
  // ============================================================

  Widget _employeeField() {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: _employeeController,
        focusNode: _employeeFocusNode,

        onTap: () {
          setState(() {
            _showEmployeeList = true;
          });

          _loadEmployees();
        },

        onChanged: _employeeSearch,

        style: const TextStyle(
          fontSize: 9.5,
          color: _text,
          fontWeight: FontWeight.w600,
        ),

        decoration: InputDecoration(
          labelText: 'Employee',
          hintText: 'Search employee',

          prefixIcon: const Icon(
            Icons.person_search_outlined,
            size: 16,
            color: _primary,
          ),

          prefixIconConstraints: const BoxConstraints(minWidth: 36),

          labelStyle: const TextStyle(fontSize: 9, color: _secondaryText),

          hintStyle: const TextStyle(fontSize: 9, color: _secondaryText),

          filled: true,
          fillColor: const Color(0xFFF8FAFB),

          contentPadding: const EdgeInsets.symmetric(horizontal: 8),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary, width: 1.2),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FY FIELD
  // ============================================================

  Widget _fyField(MonthlyPerformanceState state) {
    return SizedBox(
      height: 42,
      child: DropdownButtonFormField<ReportFinancialYear>(
        value: _selectedFinancialYear,

        isExpanded: true,

        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),

        decoration: InputDecoration(
          labelText: 'FY',

          labelStyle: const TextStyle(fontSize: 8.5, color: _secondaryText),

          filled: true,
          fillColor: const Color(0xFFF8FAFB),

          contentPadding: const EdgeInsets.symmetric(horizontal: 8),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _primary),
          ),
        ),

        items: state.financialYears
            .map(
              (fy) => DropdownMenuItem<ReportFinancialYear>(
                value: fy,
                child: Text(
                  _shortFY(fy.label),
                  style: const TextStyle(
                    color: _text,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),

        onChanged: (value) {
          setState(() {
            _selectedFinancialYear = value;

            _selectedMonthKeys.clear();
          });

          _clearDailyReport();
          _clearHourlyReport();
          _clearAreaReport();
          _clearTopDealersReport();
          _clearExpenseReport();
        },
      ),
    );
  }

  // ============================================================
  // EMPLOYEE LIST
  // ============================================================

  Widget _employeeList(EmployeeOutputState state) {
    if (!_showEmployeeList) {
      return const SizedBox.shrink();
    }

    if (state.employeeLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 5),
        child: LinearProgressIndicator(minHeight: 2, color: _primary),
      );
    }

    if (state.employees.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      margin: const EdgeInsets.only(top: 5),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(9),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,

        itemCount: state.employees.length,

        separatorBuilder: (context, index) {
          return const Divider(height: 1, color: _border);
        },

        itemBuilder: (context, index) {
          final employee = state.employees[index];

          return InkWell(
            onTap: () {
              _selectEmployee(employee);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 27,
                    height: 27,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: _softGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: _primary,
                      size: 14,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      employee.fldAdmName,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: _secondaryText,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _shortFY(String label) {
    final parts = label.split('-');

    if (parts.length != 2 || parts[1].length < 2) {
      return label;
    }

    return '${parts[0]}-${parts[1].substring(parts[1].length - 2)}';
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _dashboard(MonthlyPerformance report, MonthlyPerformanceState state) {
    final selected = _selectedMonths(report);

    final summary = _summary(report);

    return Column(
      children: [
        _monthlyTable(report, summary),

        const SizedBox(height: 8),

        _monthlyCard(selected, summary),

        if (_selectedMonthKeys.isNotEmpty) ...[
          const SizedBox(height: 8),

          _dailySection(state),

          const SizedBox(height: 10),

          _hourlySection(state),

          const SizedBox(height: 8),

          _areaSection(state),

          const SizedBox(height: 8),

          _topDealersSection(state),

          const SizedBox(height: 8),

          _expenseSection(state),
        ],
      ],
    );
  }

  // ============================================================
  // MONTH TABLE
  // ============================================================

  Widget _monthlyTable(MonthlyPerformance report, _MonthSummary summary) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _sectionHeader(
              number: '${_selectedMonthKeys.length}/${report.months.length}',
              title: 'Monthly Details',
              subtitle:
                  'Select months for daily, hourly, area, dealer and expense analysis',
              color: _primary,
            ),
          ),
          _detailTableViewport(
            width:
                _checkWidth +
                _monthWidth +
                _visitWidth +
                _businessColumnsWidth +
                _avgWidth +
                _shareWidth,
            header: _monthlyHeader(),
            rows: List.generate(
              report.months.length,
              (index) => _monthlyRow(report.months[index], index),
            ),
            total: _monthlyTotal(summary),
          ),
        ],
      ),
    );
  }

  Widget _monthlyHeader() {
    return Container(
      height: 30 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFF1F5F8),
      child: Row(
        children: [
          _headerCell('', _checkWidth),

          _headerCell('MONTH', _monthWidth),

          _headerCell('VISITS', _visitWidth, center: true),

          if (!_visitOnly) _headerCell('ORDERS', _orderWidth, center: true),

          if (!_visitOnly)
            _headerCell('DISPATCH', _dispatchWidth, center: true),

          if (!_visitOnly)
            _headerCell('COLLECTION', _collectionWidth, center: true),

          _headerCell('AVG', _avgWidth, center: true),

          _headerCell('SHARE', _shareWidth, center: true),
        ],
      ),
    );
  }

  Widget _monthlyRow(MonthlyPerformanceItem item, int index) {
    final bool selected = _selectedMonthKeys.contains(item.monthKey);

    return Container(
      height: 34 * MediaQuery.textScalerOf(context).scale(1),
      color: selected
          ? const Color(0xFFF0FAF5)
          : index.isEven
          ? Colors.white
          : const Color(0xFFFAFBFC),

      child: Row(
        children: [
          SizedBox(
            width: _checkWidth,
            child: Transform.scale(
              scale: .72,
              child: Checkbox(
                value: selected,

                activeColor: _primary,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),

                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedMonthKeys.add(item.monthKey);
                    } else {
                      _selectedMonthKeys.remove(item.monthKey);
                    }
                  });

                  if (_selectedMonthKeys.isEmpty) {
                    _clearDailyReport();
                    _clearHourlyReport();
                    _clearAreaReport();
                    _clearTopDealersReport();
                    _clearExpenseReport();
                  } else {
                    _fetchDailyReport();
                    _fetchHourlyReport();
                    _fetchAreaReport();
                    _fetchTopDealersReport();
                    _fetchExpenseReport();
                  }
                },
              ),
            ),
          ),

          _bodyCell(
            item.month,
            _monthWidth,
            bold: selected,
            valueColor: selected ? _primaryDark : _text,
          ),

          _bodyCell('${item.visits}', _visitWidth, center: true),

          if (!_visitOnly)
            _amountCountCell(
              amount: item.orderAmount,
              count: item.orderCount,
              width: _orderWidth,
              color: _red,
            ),

          if (!_visitOnly)
            _amountCountCell(
              amount: item.dispatchAmount,
              count: item.dispatchCount,
              width: _dispatchWidth,
              color: _dispatchColor,
            ),

          if (!_visitOnly)
            _bodyCell(
              _number(item.paymentCollection),
              _collectionWidth,
              center: true,
            ),

          _bodyCell(
            item.dailyVisitAvg.toStringAsFixed(2),
            _avgWidth,
            center: true,
          ),

          _percentageCell(item.visitShare, _shareWidth),
        ],
      ),
    );
  }

  Widget _monthlyTotal(_MonthSummary summary) {
    return Container(
      height: 38 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFEDF4F8),
      child: Row(
        children: [
          const SizedBox(width: _checkWidth),

          _bodyCell('TOTAL', _monthWidth, bold: true),

          _bodyCell('${summary.visits}', _visitWidth, center: true, bold: true),

          if (!_visitOnly)
            _amountCountCell(
              amount: summary.orderAmount,
              count: summary.orderCount,
              width: _orderWidth,
              color: _red,
            ),

          if (!_visitOnly)
            _amountCountCell(
              amount: summary.dispatchAmount,
              count: summary.dispatchCount,
              width: _dispatchWidth,
              color: _dispatchColor,
            ),

          if (!_visitOnly)
            _bodyCell(
              _number(summary.collection),
              _collectionWidth,
              center: true,
              bold: true,
            ),

          _bodyCell(
            summary.average.toStringAsFixed(2),
            _avgWidth,
            center: true,
            bold: true,
          ),

          _bodyCell(
            '${summary.visitShare.toStringAsFixed(2)}%',
            _shareWidth,
            center: true,
            bold: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONTH PERFORMANCE CARD
  // ============================================================

  Widget _monthlyCard(
    List<MonthlyPerformanceItem> selected,
    _MonthSummary summary,
  ) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _sectionHeader(
            number: '02',
            title: 'Performance Analysis',
            subtitle: 'Selected months performance overview',
            color: _primary,
          ),

          Row(
            children: [
              Expanded(
                child: _miniKpi('TOTAL VISITS', '${summary.visits}', _blue),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: _miniKpi(
                  'DAILY AVG',
                  summary.average.toStringAsFixed(2),
                  _primary,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: _miniKpi('BEST MONTH', summary.bestMonth, _purple),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (!_visitOnly)
            Container(
              height: 44,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F7),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _modernChartTab(
                      'Amount',
                      Icons.currency_rupee_rounded,
                      _showAmountPerformance,
                      () {
                        setState(() {
                          _showAmountPerformance = true;
                        });
                      },
                    ),
                  ),

                  Expanded(
                    child: _modernChartTab(
                      'Visits',
                      Icons.groups_outlined,
                      !_showAmountPerformance,
                      () {
                        setState(() {
                          _showAmountPerformance = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          !_visitOnly && _showAmountPerformance
              ? _monthlyAmountChart(selected)
              : _monthlyVisitChart(selected),
        ],
      ),
    );
  }

  // ============================================================
  // DAILY
  // ============================================================

  Widget _dailySection(MonthlyPerformanceState state) {
    if (state.dailyStatus == DailyPerformanceStatus.loading) {
      return _loadingCard('Loading daily performance...');
    }

    if (state.dailyStatus == DailyPerformanceStatus.failure) {
      return _errorCard(state.dailyError ?? 'Unable to load daily report');
    }

    if (state.dailyReport == null) {
      return const SizedBox.shrink();
    }

    return _dailyCard(state.dailyReport!);
  }

  Widget _dailyCard(DailyPerformance report) {
    final summary = _dailySummary(report);

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _sectionHeader(
            number: '03',
            title: 'Daily Performance',
            subtitle: 'Day-wise visits and business activity',
            color: _blue,
          ),

          Row(
            children: [
              Expanded(
                child: _miniKpi('VISITS', '${summary.totalVisits}', _blue),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: _miniKpi(
                  'ACTIVE DAYS',
                  '${summary.activeDays}',
                  _primary,
                ),
              ),

              const SizedBox(width: 5),

              Expanded(child: _miniKpi('BEST DAY', summary.bestDay, _purple)),

              const SizedBox(width: 5),

              Expanded(
                child: _miniKpi(
                  'MAX VISITS',
                  '${summary.highestVisits}',
                  _orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          _chartTitle(
            icon: Icons.show_chart_rounded,
            title: 'Daily Activity',
            subtitle: _visitOnly
                ? 'Visits by day'
                : 'Visits and business amount trend',
          ),

          const SizedBox(height: 5),

          _dailyCombinedChart(report.days),

          const SizedBox(height: 12),

          _dailyTable(report),
        ],
      ),
    );
  }

  // ============================================================
  // HOURLY
  // ============================================================

  Widget _hourlySection(MonthlyPerformanceState state) {
    if (state.hourlyStatus == HourlyPerformanceStatus.loading) {
      return _loadingCard('Loading hourly performance...');
    }

    if (state.hourlyStatus == HourlyPerformanceStatus.failure) {
      return _errorCard(state.hourlyError ?? 'Unable to load hourly report');
    }

    if (state.hourlyReport == null) {
      return const SizedBox.shrink();
    }

    return _hourlyCard(state.hourlyReport!);
  }

  Widget _hourlyCard(HourlyPerformance report) {
    final summary = _hourlySummary(report);

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _sectionHeader(
            number: '04',
            title: 'Hourly Performance',
            subtitle: 'Time-wise productivity and visit activity',
            color: _purple,
          ),

          Row(
            children: [
              Expanded(
                child: _compactInfo(
                  icon: Icons.schedule_rounded,
                  title: 'Peak Hour',
                  value: summary.peakHour,
                  color: _orange,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: _compactInfo(
                  icon: Icons.groups_rounded,
                  title: 'Peak Visits',
                  value: '${summary.highestVisits}',
                  color: _blue,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: _compactInfo(
                  icon: Icons.timelapse_rounded,
                  title: 'Active Hours',
                  value: '${summary.activeHours}',
                  color: _primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          _chartTitle(
            icon: Icons.timeline_rounded,
            title: 'Hourly Activity',
            subtitle: _visitOnly
                ? 'Visits by hour'
                : 'Visits, orders, dispatch and collection',
          ),

          const SizedBox(height: 5),

          _hourlyCombinedChart(report.hours),

          const SizedBox(height: 12),

          _hourlyTable(report),
        ],
      ),
    );
  }

  // ============================================================
  // AREA-WISE PERFORMANCE
  // ============================================================

  Widget _areaSection(MonthlyPerformanceState state) {
    if (state.areaStatus == AreaPerformanceStatus.loading) {
      return _loadingCard('Loading area-wise performance...');
    }

    if (state.areaStatus == AreaPerformanceStatus.failure) {
      return _errorCard(state.areaError ?? 'Unable to load area-wise report');
    }

    if (state.areaReport == null) {
      return const SizedBox.shrink();
    }

    return _areaCard(state.areaReport!);
  }

  Widget _areaCard(AreaPerformance report) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _sectionHeader(
            number: '05',
            title: 'Area-wise Dealer Coverage',
            subtitle: _visitOnly
                ? 'Unique dealer coverage by area / taluka'
                : 'Unique dealer coverage and business performance by area / taluka',
            color: _collectionColor,
          ),

          const SizedBox(height: 8),

          if (!_visitOnly)
            Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F7),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _modernChartTab(
                      'Dealer Coverage',
                      Icons.donut_large_rounded,
                      (_visitOnly || _showAreaDealerChart),
                      () {
                        setState(() {
                          _showAreaDealerChart = true;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _modernChartTab(
                      'Amount Performance',
                      Icons.bar_chart_rounded,
                      !(_visitOnly || _showAreaDealerChart),
                      () {
                        setState(() {
                          _showAreaDealerChart = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 760) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _areaChartPanel(report)),
                    const SizedBox(width: 8),
                    Expanded(flex: 6, child: _areaTable(report)),
                  ],
                );
              }

              return Column(
                children: [
                  _areaChartPanel(report),
                  const SizedBox(height: 8),
                  _areaTable(report),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _areaChartPanel(AreaPerformance report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (_visitOnly || _showAreaDealerChart)
                      ? 'Area Distribution'
                      : 'Amount Performance',
                  style: const TextStyle(
                    color: _text,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                (_visitOnly || _showAreaDealerChart)
                    ? 'Dealer count'
                    : 'Business amount',
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if ((_visitOnly || _showAreaDealerChart))
            _areaDealerDonut(report)
          else
            _areaAmountChart(report),
        ],
      ),
    );
  }

  int _areaCoverageTotal(AreaPerformance report) {
    return report.areas.fold<int>(0, (sum, area) => sum + area.visits);
  }

  Widget _areaDealerDonut(AreaPerformance report) {
    final data = report.areas.where((e) => e.visits > 0).toList();

    if (data.isEmpty) {
      return _areaEmptyState('No dealer coverage available');
    }

    final double total = data.fold(
      0,
      (sum, item) => sum + item.visits.toDouble(),
    );

    return SizedBox(
      height: 205,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 41,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    sections: List.generate(data.length, (index) {
                      final item = data[index];
                      final value = item.visits.toDouble();
                      final percentage = total <= 0 ? 0 : value / total * 100;

                      return PieChartSectionData(
                        value: value,
                        color: _areaColor(index),
                        radius: 42,
                        title: percentage >= 8
                            ? '${percentage.toStringAsFixed(0)}%'
                            : '',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    }),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_areaCoverageTotal(report)}',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Dealers',
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 4,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (context, index) {
                final item = data[index];
                return Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _areaColor(index),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.areaName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.visits}',
                      style: TextStyle(
                        color: _areaColor(index),
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _areaAmountChart(AreaPerformance report) {
    final data = report.areas
        .where(
          (e) =>
              e.orderAmount > 0 ||
              e.dispatchAmount > 0 ||
              e.collectionAmount > 0,
        )
        .toList();

    if (data.isEmpty) {
      return _areaEmptyState('No amount performance available');
    }

    final labels = data.map((e) => e.areaName).toList();

    double peak = 0;
    for (final item in data) {
      peak = [
        peak,
        item.orderAmount,
        item.dispatchAmount,
        item.collectionAmount,
      ].reduce((a, b) => a > b ? a : b);
    }

    final maxY = _amountMax(peak) * 1.15;

    return _chartSurface(
      names: const ['Orders', 'Dispatch', 'Collection'],
      colors: const [_red, _dispatchColor, _collectionColor],
      pointCount: data.length,
      pointWidth: 66,
      axisHint: 'Amount by area (₹)',
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: _chartGrid(maxY),
          borderData: FlBorderData(show: false),
          titlesData: _readableChartAxes(labels, maxY, money: true),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final names = ['Orders', 'Dispatch', 'Collection'];
                return BarTooltipItem(
                  '${labels[groupIndex]} · ${names[rodIndex]}\n₹${_number(rod.toY)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          barGroups: List.generate(data.length, (index) {
            final item = data[index];
            final values = [
              item.orderAmount,
              item.dispatchAmount,
              item.collectionAmount,
            ];
            const colors = [_red, _dispatchColor, _collectionColor];

            return BarChartGroupData(
              x: index,
              barsSpace: 3,
              barRods: List.generate(
                values.length,
                (series) => BarChartRodData(
                  toY: values[series],
                  width: 9,
                  color: colors[series],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _areaEmptyState(String text) {
    return SizedBox(
      height: 170,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_outlined,
              color: Color(0xFFB5BEC8),
              size: 28,
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _areaTable(AreaPerformance report) {
    return _simpleTable(
      title: 'Area-wise Count',
      child: _detailTableViewport(
        width: _areaWidth + _visitWidth + _businessColumnsWidth + _shareWidth,
        header: _areaTableHeader(),
        rows: List.generate(
          report.areas.length,
          (index) => _areaRow(report.areas[index], index),
        ),
        total: _areaTotal(report),
      ),
    );
  }

  Widget _areaTableHeader() {
    return Container(
      height: 28 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFF1F5F8),
      child: Row(
        children: [
          _headerCell('AREA / TALUKA', _areaWidth),
          _headerCell('DEALERS', _visitWidth, center: true),
          if (!_visitOnly) _headerCell('ORDER', _orderWidth, center: true),
          if (!_visitOnly)
            _headerCell('DISPATCH', _dispatchWidth, center: true),
          if (!_visitOnly)
            _headerCell('COLLECTION', _collectionWidth, center: true),
          _headerCell('SHARE', _shareWidth, center: true),
        ],
      ),
    );
  }

  Widget _areaRow(AreaPerformanceItem item, int index) {
    return Container(
      height: 34 * MediaQuery.textScalerOf(context).scale(1),
      color: index.isEven ? Colors.white : const Color(0xFFFAFBFC),
      child: Row(
        children: [
          _bodyCell(item.areaName, _areaWidth, bold: item.visits > 0),
          _bodyCell(
            '${item.visits}',
            _visitWidth,
            center: true,
            bold: item.visits > 0,
            valueColor: item.visits > 0 ? _collectionColor : _secondaryText,
          ),
          if (!_visitOnly)
            _amountCountCell(
              amount: item.orderAmount,
              count: item.orderCount,
              width: _orderWidth,
              color: _red,
            ),
          if (!_visitOnly)
            _amountCountCell(
              amount: item.dispatchAmount,
              count: item.dispatchCount,
              width: _dispatchWidth,
              color: _dispatchColor,
            ),
          if (!_visitOnly)
            _bodyCell(
              _number(item.collectionAmount),
              _collectionWidth,
              center: true,
              bold: item.collectionAmount > 0,
            ),
          _percentageCell(item.visitShare, _shareWidth),
        ],
      ),
    );
  }

  Widget _areaTotal(AreaPerformance report) {
    return Container(
      height: 34 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFEDF4F8),
      child: Row(
        children: [
          _bodyCell('TOTAL', _areaWidth, bold: true),
          _bodyCell(
            '${_areaCoverageTotal(report)}',
            _visitWidth,
            center: true,
            bold: true,
            valueColor: _collectionColor,
          ),
          if (!_visitOnly)
            _amountCountCell(
              amount: report.totalOrderAmount,
              count: report.totalOrderCount,
              width: _orderWidth,
              color: _red,
            ),
          if (!_visitOnly)
            _amountCountCell(
              amount: report.totalDispatchAmount,
              count: report.totalDispatchCount,
              width: _dispatchWidth,
              color: _dispatchColor,
            ),
          if (!_visitOnly)
            _bodyCell(
              _number(report.totalCollection),
              _collectionWidth,
              center: true,
              bold: true,
            ),
          _bodyCell(
            '${report.totalVisitShare.toStringAsFixed(2)}%',
            _shareWidth,
            center: true,
            bold: true,
          ),
        ],
      ),
    );
  }

  Color _areaColor(int index) {
    const colors = [
      Color(0xFF3977D5),
      Color(0xFFE45B55),
      Color(0xFF7FAF3E),
      Color(0xFF17A99A),
      Color(0xFF7357D8),
      Color(0xFFF59E0B),
      Color(0xFF0EA5E9),
      Color(0xFFEC4899),
    ];

    return colors[index % colors.length];
  }

  // ============================================================
  // TOP DEALERS
  // ============================================================

  Widget _topDealersSection(MonthlyPerformanceState state) {
    if (state.topDealerStatus == TopDealerPerformanceStatus.loading) {
      return _loadingCard('Loading top dealer report...');
    }

    if (state.topDealerStatus == TopDealerPerformanceStatus.failure) {
      return _errorCard(
        state.topDealerError ?? 'Unable to load top dealer report',
      );
    }

    if (state.topDealerReport == null) {
      return const SizedBox.shrink();
    }

    return _topDealerCard(state.topDealerReport!);
  }

  Widget _topDealerCard(TopDealerPerformance report) {
    final String topDealer = report.dealers.isEmpty
        ? '-'
        : report.dealers.first.name;
    final int topVisits = report.dealers.isEmpty
        ? 0
        : report.dealers.first.visits;

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _sectionHeader(
            number: '06',
            title: 'Most Visited Dealers',
            subtitle: 'Top dealers ranked by total visit count',
            color: const Color(0xFF215081),
          ),

          const SizedBox(height: 7),

          // Compact summary strip
          Row(
            children: [
              Expanded(
                child: _topDealerKpi(
                  icon: Icons.groups_2_outlined,
                  title: 'TOTAL VISITS',
                  value: '${report.totalVisits}',
                  color: _blue,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 2,
                child: _topDealerKpi(
                  icon: Icons.emoji_events_outlined,
                  title: 'TOP DEALER',
                  value: topDealer,
                  subtitle: '$topVisits visits',
                  color: _orange,
                ),
              ),
              if (!_visitOnly) const SizedBox(width: 5),
              if (!_visitOnly)
                Expanded(
                  child: _topDealerKpi(
                    icon: Icons.payments_outlined,
                    title: 'COLLECTION',
                    value: '₹${_number(report.totalCollectionAmount)}',
                    color: _collectionColor,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 7),

          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              children: [
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E4C79), Color(0xFF2D6FA3)],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Top Dealer Ranking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.13),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          report.financialYearLabel.isEmpty
                              ? 'TOP 10'
                              : '${report.financialYearLabel}  •  TOP 10',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 6.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _topDealerTable(report),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topDealerKpi({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.055),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withOpacity(.11),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 6.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .15,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 6.2,
                      height: 1,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topDealerTable(TopDealerPerformance report) {
    final double width =
        _rankWidth +
        _dealerWidth +
        _talukaWidth +
        _topVisitWidth +
        _businessColumnsWidth +
        _lastVisitWidth;

    return _detailTableViewport(
      width: width,
      header: _topDealerHeader(),
      rows: List.generate(
        report.dealers.length,
        (index) => _topDealerRow(report.dealers[index], index),
      ),
      total: _topDealerTotal(report),
    );
  }

  Widget _topDealerHeader() {
    return Container(
      height: 30 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFE9F1F8),
      child: Row(
        children: [
          _headerCell('RANK', _rankWidth, center: true),
          _headerCell('DEALER', _dealerWidth),
          _headerCell('TALUKA', _talukaWidth),
          _headerCell('VISITS', _topVisitWidth, center: true),
          if (!_visitOnly) _headerCell('ORDER', _orderWidth, center: true),
          if (!_visitOnly)
            _headerCell('DISPATCH', _dispatchWidth, center: true),
          if (!_visitOnly)
            _headerCell('COLLECTION', _collectionWidth, center: true),
          _headerCell('LAST VISIT', _lastVisitWidth, center: true),
        ],
      ),
    );
  }

  Widget _topDealerRow(TopDealerItem item, int index) {
    return Container(
      height: 34 * MediaQuery.textScalerOf(context).scale(1),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFAFBFC),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF0F2F4), width: .6),
        ),
      ),
      child: Row(
        children: [
          _detailCell(
            width: _rankWidth,
            child: Center(child: _topDealerRankBadge(item.rank)),
          ),
          _bodyCell(
            item.name.isEmpty ? 'Unknown Dealer' : item.name,
            _dealerWidth,
            bold: item.rank <= 3,
          ),
          _bodyCell(item.city.trim().isEmpty ? '-' : item.city, _talukaWidth),
          _detailCell(
            width: _topVisitWidth,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(minWidth: 25),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${item.visits}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF1F67B1),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          if (!_visitOnly)
            _topAmountCountCell(
              amount: item.orderAmount,
              count: item.orderCount,
              width: _orderWidth,
              color: _red,
              countText: 'Orders',
            ),
          if (!_visitOnly)
            _topAmountCountCell(
              amount: item.dispatchAmount,
              count: item.dispatchCount,
              width: _dispatchWidth,
              color: _blue,
              countText: 'Dispatch',
            ),
          if (!_visitOnly)
            _bodyCell(
              '₹${_number(item.collectionAmount)}',
              _collectionWidth,
              center: true,
              bold: item.collectionAmount > 0,
              valueColor: item.collectionAmount > 0
                  ? _collectionColor
                  : _secondaryText,
            ),
          _bodyCell(
            item.lastVisit.isEmpty ? '-' : item.lastVisit,
            _lastVisitWidth,
            center: true,
          ),
        ],
      ),
    );
  }

  Widget _topDealerTotal(TopDealerPerformance report) {
    return Container(
      height: 36 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFEDF4F8),
      child: Row(
        children: [
          _detailCell(width: _rankWidth, child: const SizedBox.shrink()),
          _bodyCell('TOTAL', _dealerWidth, bold: true),
          _bodyCell('-', _talukaWidth, center: true),
          _bodyCell(
            '${report.totalVisits}',
            _topVisitWidth,
            center: true,
            bold: true,
            valueColor: _blue,
          ),
          if (!_visitOnly)
            _topAmountCountCell(
              amount: report.totalOrderAmount,
              count: report.totalOrderCount,
              width: _orderWidth,
              color: _red,
              countText: 'Orders',
              bold: true,
            ),
          if (!_visitOnly)
            _topAmountCountCell(
              amount: report.totalDispatchAmount,
              count: report.totalDispatchCount,
              width: _dispatchWidth,
              color: _blue,
              countText: 'Dispatch',
              bold: true,
            ),
          if (!_visitOnly)
            _bodyCell(
              '₹${_number(report.totalCollectionAmount)}',
              _collectionWidth,
              center: true,
              bold: true,
              valueColor: _collectionColor,
            ),
          _detailCell(width: _lastVisitWidth, child: const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _topAmountCountCell({
    required double amount,
    required int count,
    required double width,
    required Color color,
    required String countText,
    bool bold = false,
  }) {
    return _detailCell(
      width: width,
      child: Tooltip(
        message: '₹${_number(amount)} • $count $countText',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₹${_number(amount)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: amount > 0 ? color : _secondaryText,
                  fontSize: 9.5,
                  fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
                  height: 1.05,
                ),
              ),
              Text(
                '$count $countText',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 6.7,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topDealerRankBadge(int rank) {
    Color background;
    Color foreground;

    switch (rank) {
      case 1:
        background = const Color(0xFFFFE9A8);
        foreground = const Color(0xFF8A6500);
        break;
      case 2:
        background = const Color(0xFFE9EDF2);
        foreground = const Color(0xFF617081);
        break;
      case 3:
        background = const Color(0xFFF5DDCA);
        foreground = const Color(0xFF9B5B29);
        break;
      default:
        background = const Color(0xFFEAF2FA);
        foreground = const Color(0xFF215081);
    }

    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        '$rank',
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ============================================================
  // EXPENSE PERFORMANCE
  // ============================================================

  Widget _expenseSection(MonthlyPerformanceState state) {
    if (state.expenseStatus == ExpensePerformanceStatus.loading) {
      return _loadingCard('Loading expense performance...');
    }

    if (state.expenseStatus == ExpensePerformanceStatus.failure) {
      return _errorCard(state.expenseError ?? 'Unable to load expense report');
    }

    if (state.expenseReport == null) {
      return const SizedBox.shrink();
    }

    return _expenseCard(state.expenseReport!);
  }

  Widget _expenseCard(ExpensePerformance report) {
    final String monthLabel = _monthText(report.selectedMonths);

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _sectionHeader(
            number: '07',
            title: monthLabel.isEmpty
                ? 'Expense Parameter-wise'
                : 'Expense Parameter-wise $monthLabel',
            subtitle: 'Expense distribution by parameter',
            color: _orange,
          ),

          const SizedBox(height: 7),

          // _expenseTotalCard(report),
          const SizedBox(height: 8),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 760) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _expenseChartPanel(report)),
                    const SizedBox(width: 8),
                    Expanded(flex: 6, child: _expenseTable(report)),
                  ],
                );
              }

              return Column(
                children: [
                  _expenseChartPanel(report),
                  const SizedBox(height: 8),
                  _expenseTable(report),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          //  _expenseSummaryStrip(report),
        ],
      ),
    );
  }

  Widget _expenseTotalCard(ExpensePerformance report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9EF), Color(0xFFFFFCF7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFF1E4CC)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _orange.withOpacity(.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: _orange,
              size: 18,
            ),
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL EXPENSE',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 6.7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Total expense for selected period',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 7.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹${_number(report.totalExpense)}',
            style: const TextStyle(
              color: _orange,
              fontSize: 20,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseChartPanel(ExpensePerformance report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Expense Distribution',
                  style: TextStyle(
                    color: _text,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Parameter amount',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          _expenseDonut(report),
        ],
      ),
    );
  }

  Widget _expenseDonut(ExpensePerformance report) {
    final List<ExpensePerformanceItem> data = report.expenses
        .where((item) => item.amount > 0)
        .toList();

    if (data.isEmpty) {
      return SizedBox(
        height: 190,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.donut_large_outlined,
                color: Color(0xFFB5BEC8),
                size: 28,
              ),
              const SizedBox(height: 5),
              const Text(
                'No expense amount available',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final double totalAmount = data.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    return SizedBox(
      height: 205,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 41,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    sections: List.generate(data.length, (index) {
                      final ExpensePerformanceItem item = data[index];

                      final double share = totalAmount <= 0
                          ? 0
                          : (item.amount / totalAmount) * 100;

                      return PieChartSectionData(
                        value: item.amount,
                        color: _expenseColor(index),
                        radius: 42,
                        title: share >= 8 ? '${share.toStringAsFixed(0)}%' : '',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    }),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${_number(report.totalExpense)}',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 15,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Expense',
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          Expanded(
            flex: 4,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              primary: false,
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (context, index) {
                final ExpensePerformanceItem item = data[index];

                return Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _expenseColor(index),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: Text(
                        item.parameterName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    Text(
                      '₹${_number(item.amount)}',
                      style: TextStyle(
                        color: _expenseColor(index),
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseTable(ExpensePerformance report) {
    return _simpleTable(
      title: 'Parameter-wise Expense',
      child: _detailTableViewport(
        width:
            _expenseParameterWidth +
            _expenseAmountWidth +
            _expenseShareWidth,
        header: _expenseHeader(),
        rows: List.generate(
          report.expenses.length,
          (index) => _expenseRow(report.expenses[index], index),
        ),
        total: _expenseTotalRow(report),
      ),
    );
  }

  Widget _expenseHeader() {
    return Container(
      height: 28 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFF1F5F8),
      child: Row(
        children: [
          _headerCell('EXPENSE PARAMETER', _expenseParameterWidth),
          _headerCell('AMOUNT', _expenseAmountWidth, center: true),
          _headerCell('SHARE', _expenseShareWidth, center: true),
        ],
      ),
    );
  }

  Widget _expenseRow(ExpensePerformanceItem item, int index) {
    return Container(
      height: 34 * MediaQuery.textScalerOf(context).scale(1),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : const Color(0xFFFAFBFC),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF0F2F4), width: .6),
        ),
      ),
      child: Row(
        children: [
          _bodyCell(
            item.parameterName,
            _expenseParameterWidth,
            bold: item.amount > 0,
          ),

          _bodyCell(
            '₹${_number(item.amount)}',
            _expenseAmountWidth,
            center: true,
            bold: item.amount > 0,
            valueColor: item.amount > 0 ? _orange : _secondaryText,
          ),

          _percentageCell(item.sharePercent, _expenseShareWidth),
        ],
      ),
    );
  }

  Widget _expenseTotalRow(ExpensePerformance report) {
    return Container(
      height: 34 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFFFF5E8),
      child: Row(
        children: [
          _bodyCell('TOTAL', _expenseParameterWidth, bold: true),

          _bodyCell(
            '₹${_number(report.totalExpense)}',
            _expenseAmountWidth,
            center: true,
            bold: true,
            valueColor: _orange,
          ),

          _bodyCell(
            '${report.totalShare.toStringAsFixed(2)}%',
            _expenseShareWidth,
            center: true,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _expenseSummaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.05),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: color, size: 13),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 6,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _expenseColor(int index) {
    const List<Color> colors = [
      Color(0xFF17A99A),
      Color(0xFF3977D5),
      Color(0xFFE45B55),
      Color(0xFF7FAF3E),
      Color(0xFF7357D8),
      Color(0xFFF59E0B),
      Color(0xFF0EA5E9),
      Color(0xFFEC4899),
    ];

    return colors[index % colors.length];
  }

  // ============================================================
  // DAILY CHART
  // ============================================================

  Widget _dailyCombinedChart(List<DailyPerformanceItem> data) {
    return _activityChart(
      labels: data.map((e) => e.dayKey).toList(),
      values: [
        data.map((e) => e.visits.toDouble()).toList(),
        data.map((e) => e.orderAmount).toList(),
        data.map((e) => e.dispatchAmount).toList(),
        data.map((e) => e.collectionAmount).toList(),
      ],
    );
  }

  Widget _hourlyCombinedChart(List<HourlyPerformanceItem> data) {
    return _activityChart(
      labels: data.map((e) => e.hourLabel).toList(),
      values: [
        data.map((e) => e.visits.toDouble()).toList(),
        data.map((e) => e.orderAmount).toList(),
        data.map((e) => e.dispatchAmount).toList(),
        data.map((e) => e.collectionAmount).toList(),
      ],
      hourly: true,
    );
  }

  static const _seriesColors = [_blue, _red, _dispatchColor, _collectionColor];
  static const _seriesNames = ['Visits', 'Orders', 'Dispatch', 'Collection'];

  Widget _activityChart({
    required List<String> labels,
    required List<List<double>> values,
    bool hourly = false,
  }) {
    if (labels.isEmpty) return _emptyChart();
    final visitPeak = values.first.reduce((a, b) => a > b ? a : b);
    final visitMax = ((visitPeak * 1.2 / 5).ceil().clamp(1, 1000000000) * 5)
        .toDouble();
    const visitInterval = 5.0;
    final amountMax =
        _amountMax(
          values.skip(1).expand((e) => e).reduce((a, b) => a > b ? a : b),
        ) *
        1.2;
    return _chartSurface(
      names: _visitOnly ? [_seriesNames.first] : _seriesNames,
      colors: _visitOnly ? [_seriesColors.first] : _seriesColors,
      pointCount: labels.length,
      pointWidth: hourly ? 72 : 42,
      axisHint: _visitOnly
          ? 'Number of visits'
          : 'Left: visits  •  Right: amount (₹)',
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!hourly)
            IgnorePointer(
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: visitMax,
                  alignment: BarChartAlignment.spaceAround,
                  titlesData: _readableChartAxes(
                    labels,
                    visitMax,
                    amountMax: _visitOnly ? null : amountMax,
                    interval: visitInterval,
                    hideLabels: true,
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                  barGroups: List.generate(
                    labels.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values.first[i],
                          width: 16,
                          color: _blue,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          LineChart(
            LineChartData(
              minX: -.5,
              maxX: labels.length - .5,
              minY: 0,
              maxY: visitMax,
              titlesData: _readableChartAxes(
                labels,
                visitMax,
                amountMax: _visitOnly ? null : amountMax,
                interval: visitInterval,
              ),
              gridData: _chartGrid(visitMax, interval: visitInterval),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final index = spot.x.round();
                    final series = spot.barIndex;
                    final value = values[series][index];
                    return LineTooltipItem(
                      '${labels[index]} · ${_seriesNames[series]}\n${series == 0 ? value.toInt().toString() : '₹${_number(value)}'}',
                      TextStyle(
                        color: _seriesColors[series],
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: List.generate(
                _visitOnly ? 1 : values.length,
                (series) => LineChartBarData(
                  spots: List.generate(
                    labels.length,
                    (i) => FlSpot(
                      i.toDouble(),
                      series == 0
                          ? values[series][i]
                          : _normalizeAmount(
                              values[series][i],
                              amountMax,
                              visitMax,
                            ),
                    ),
                  ),
                  isCurved: false,
                  color: series == 0 && !hourly
                      ? Colors.transparent
                      : _seriesColors[series],
                  barWidth: series == 0 ? 3 : 2.5,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: series == 0 && hourly,
                    color: _blue.withValues(alpha: .06),
                  ),
                  dotData: FlDotData(
                    show: series != 0 || hourly,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: _seriesColors[series],
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartSurface({
    required List<String> names,
    required List<Color> colors,
    required int pointCount,
    required double pointWidth,
    required Widget child,
    required String axisHint,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: List.generate(
              names.length,
              (i) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: colors[i],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    names[i],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            axisHint,
            style: const TextStyle(fontSize: 10, color: _secondaryText),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200 * MediaQuery.textScalerOf(context).scale(1),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth =
                    pointCount * pointWidth +
                    128 * MediaQuery.textScalerOf(context).scale(1);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: contentWidth > constraints.maxWidth
                        ? contentWidth
                        : constraints.maxWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 2),
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap a point for details • Swipe to explore',
            style: TextStyle(fontSize: 10, color: _secondaryText),
          ),
        ],
      ),
    );
  }

  FlGridData _chartGrid(double maxY, {double? interval}) => FlGridData(
    drawVerticalLine: false,
    horizontalInterval: interval ?? maxY / 4,
    getDrawingHorizontalLine: (value) => const FlLine(
      color: Color(0xFFE3E9F2),
      strokeWidth: 1,
      dashArray: [4, 4],
    ),
  );

  FlTitlesData _readableChartAxes(
    List<String> labels,
    double maxY, {
    double? amountMax,
    bool money = false,
    double? interval,
    bool hideLabels = false,
  }) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    Widget tick(String text, TitleMeta meta) => hideLabels
        ? const SizedBox.shrink()
        : SideTitleWidget(
            meta: meta,
            space: 5,
            fitInside: SideTitleFitInsideData.fromTitleMeta(
              meta,
              distanceFromEdge: 4,
            ),
            child: Text(
              text,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 11,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: Color(0xFF526174),
              ),
            ),
          );
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: (money ? 62 : 40) * textScale,
          interval: interval ?? maxY / 4,
          minIncluded: true,
          maxIncluded: true,
          getTitlesWidget: (value, meta) =>
              tick(money ? _amountAxis(value) : _number(value), meta),
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: amountMax != null,
          reservedSize: 62 * textScale,
          interval: interval ?? maxY / 4,
          minIncluded: true,
          maxIncluded: true,
          getTitlesWidget: (value, meta) =>
              tick(_amountAxis(value / maxY * (amountMax ?? 0)), meta),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 34 * textScale,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.round();
            if ((value - index).abs() > .01 ||
                index < 0 ||
                index >= labels.length) {
              return const SizedBox.shrink();
            }
            return tick(labels[index], meta);
          },
        ),
      ),
    );
  }

  Widget _dailyTable(DailyPerformance report) {
    return _simpleTable(
      title: 'Daily Details',
      child: _detailTableViewport(
        width: _dayWidth + _visitWidth + _businessColumnsWidth + _shareWidth,
        header: _dailyTableHeader(),
        rows: List.generate(
          report.days.length,
          (index) => _dailyRow(report.days[index], index),
        ),
        total: _dailyTotal(report),
      ),
    );
  }

  Widget _dailyTableHeader() {
    return Container(
      height: 30 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFF1F5F8),
      child: Row(
        children: [
          _headerCell('DAY', _dayWidth),

          _headerCell('VISITS', _visitWidth, center: true),

          if (!_visitOnly) _headerCell('ORDERS', _orderWidth, center: true),

          if (!_visitOnly)
            _headerCell('DISPATCH', _dispatchWidth, center: true),

          if (!_visitOnly)
            _headerCell('COLLECTION', _collectionWidth, center: true),

          _headerCell('SHARE', _shareWidth, center: true),
        ],
      ),
    );
  }

  Widget _dailyRow(DailyPerformanceItem item, int index) {
    return Container(
      height: 34 * MediaQuery.textScalerOf(context).scale(1),

      color: index.isEven ? Colors.white : const Color(0xFFFAFBFC),

      child: Row(
        children: [
          _bodyCell(item.dayKey, _dayWidth),

          _bodyCell('${item.visits}', _visitWidth, center: true),

          if (!_visitOnly)
            _amountCountCell(
              amount: item.orderAmount,
              count: item.orderCount,
              width: _orderWidth,
              color: _red,
            ),

          if (!_visitOnly)
            _amountCountCell(
              amount: item.dispatchAmount,
              count: item.dispatchCount,
              width: _dispatchWidth,
              color: _dispatchColor,
            ),

          if (!_visitOnly)
            _bodyCell(
              _number(item.collectionAmount),
              _collectionWidth,
              center: true,
            ),

          _percentageCell(item.visitShare, _shareWidth),
        ],
      ),
    );
  }

  Widget _dailyTotal(DailyPerformance report) {
    return _totalRow(
      first: 'TOTAL',
      firstWidth: _dayWidth,
      visits: report.totalVisits,
      orderAmount: report.totalOrderAmount,
      orderCount: report.totalOrderCount,
      dispatchAmount: report.totalDispatchAmount,
      dispatchCount: report.totalDispatchCount,
      collection: report.totalCollection,
      share: report.totalVisitShare,
    );
  }

  // ============================================================
  // HOURLY TABLE
  // ============================================================

  Widget _hourlyTable(HourlyPerformance report) {
    return _simpleTable(
      title: 'Hourly Details',
      child: _detailTableViewport(
        width: _hourWidth + _visitWidth + _businessColumnsWidth + _shareWidth,
        header: _hourHeader(),
        rows: List.generate(
          report.hours.length,
          (index) => _hourRow(report.hours[index], index),
        ),
        total: _hourTotal(report),
      ),
    );
  }

  Widget _detailTableViewport({
    required double width,
    required Widget header,
    required List<Widget> rows,
    required Widget total,
  }) {
    final double rowHeight = 34 * MediaQuery.textScalerOf(context).scale(1);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width > constraints.maxWidth
                  ? width
                  : constraints.maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  if (rows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'No details available',
                        style: TextStyle(color: _secondaryText, fontSize: 12),
                      ),
                    )
                  else
                    SizedBox(
                      height: rowHeight * (rows.length > 6 ? 6 : rows.length),
                      child: ListView.builder(
                        primary: false,
                        padding: EdgeInsets.zero,
                        itemExtent: rowHeight,
                        itemCount: rows.length,
                        itemBuilder: (context, index) => rows[index],
                      ),
                    ),
                  total,
                  if (rows.length > 6 || width > constraints.maxWidth)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        [
                          if (rows.length > 6)
                            'Scroll for all ${rows.length} rows',
                          if (width > constraints.maxWidth)
                            'Swipe for more columns',
                        ].join(' • '),
                        style: const TextStyle(
                          fontSize: 10,
                          color: _secondaryText,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _hourHeader() {
    return Container(
      height: 30 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFF1F5F8),
      child: Row(
        children: [
          _headerCell('HOUR', _hourWidth),

          _headerCell('VISITS', _visitWidth, center: true),

          if (!_visitOnly) _headerCell('ORDERS', _orderWidth, center: true),

          if (!_visitOnly)
            _headerCell('DISPATCH', _dispatchWidth, center: true),

          if (!_visitOnly)
            _headerCell('COLLECTION', _collectionWidth, center: true),

          _headerCell('SHARE', _shareWidth, center: true),
        ],
      ),
    );
  }

  Widget _hourRow(HourlyPerformanceItem item, int index) {
    return Container(
      height: 34 * MediaQuery.textScalerOf(context).scale(1),

      color: index.isEven ? Colors.white : const Color(0xFFFAFBFC),

      child: Row(
        children: [
          _bodyCell(item.hourLabel, _hourWidth),

          _bodyCell('${item.visits}', _visitWidth, center: true),

          if (!_visitOnly)
            _amountCountCell(
              amount: item.orderAmount,
              count: item.orderCount,
              width: _orderWidth,
              color: _red,
            ),

          if (!_visitOnly)
            _amountCountCell(
              amount: item.dispatchAmount,
              count: item.dispatchCount,
              width: _dispatchWidth,
              color: _dispatchColor,
            ),

          if (!_visitOnly)
            _bodyCell(
              _number(item.collectionAmount),
              _collectionWidth,
              center: true,
            ),

          _percentageCell(item.visitShare, _shareWidth),
        ],
      ),
    );
  }

  Widget _hourTotal(HourlyPerformance report) {
    return _totalRow(
      first: 'TOTAL',
      firstWidth: _hourWidth,
      visits: report.totalVisits,
      orderAmount: report.totalOrderAmount,
      orderCount: report.totalOrderCount,
      dispatchAmount: report.totalDispatchAmount,
      dispatchCount: report.totalDispatchCount,
      collection: report.totalCollection,
      share: report.totalVisitShare,
    );
  }

  // ============================================================
  // TOTAL ROW
  // ============================================================

  Widget _totalRow({
    required String first,
    required double firstWidth,
    required int visits,
    required double orderAmount,
    required int orderCount,
    required double dispatchAmount,
    required int dispatchCount,
    required double collection,
    required double share,
  }) {
    return Container(
      height: 38 * MediaQuery.textScalerOf(context).scale(1),
      color: const Color(0xFFEDF4F8),
      child: Row(
        children: [
          _bodyCell(first, firstWidth, bold: true),

          _bodyCell('$visits', _visitWidth, center: true, bold: true),

          if (!_visitOnly)
            _amountCountCell(
              amount: orderAmount,
              count: orderCount,
              width: _orderWidth,
              color: _red,
            ),

          if (!_visitOnly)
            _amountCountCell(
              amount: dispatchAmount,
              count: dispatchCount,
              width: _dispatchWidth,
              color: _dispatchColor,
            ),

          if (!_visitOnly)
            _bodyCell(
              _number(collection),
              _collectionWidth,
              center: true,
              bold: true,
            ),

          _bodyCell(
            '${share.toStringAsFixed(2)}%',
            _shareWidth,
            center: true,
            bold: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIMPLE TABLE
  // ============================================================

  Widget _simpleTable({required String title, required Widget child}) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: const Color(0xFFFAFBFC),
            child: Row(
              children: [
                const Icon(
                  Icons.table_rows_outlined,
                  size: 14,
                  color: _primary,
                ),

                const SizedBox(width: 6),

                Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // CELLS
  // ============================================================

  // Share extra table space using the same column weights in every row.
  // The month selection checkbox keeps its compact tap target width.
  Widget _detailCell({required double width, required Widget child}) {
    if (width == _checkWidth) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(flex: width.round(), child: child);
  }

  Widget _headerCell(String value, double width, {bool center = false}) {
    return _detailCell(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Align(
          alignment: center ? Alignment.center : Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF687789),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .25,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyCell(
    String value,
    double width, {
    bool center = false,
    bool bold = false,
    Color? valueColor,
  }) {
    return _detailCell(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Align(
          alignment: center ? Alignment.center : Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? _text,
              fontSize: 11,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _amountCountCell({
    required double amount,
    required int count,
    required double width,
    required Color color,
  }) {
    // return SizedBox(
    //   width: width,
    //   child: Tooltip(
    //     message: '${_number(amount)} • Count: $count',
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 3),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Text(
    //             _number(amount),
    //             maxLines: 1,
    //             overflow: TextOverflow.ellipsis,
    //             style: TextStyle(
    //               color: amount > 0 ? color : _secondaryText,
    //               fontSize: 10.5,
    //               fontWeight: FontWeight.w700,
    //               height: 1.15,
    //             ),
    //           ),
    //           Text(
    //             'Count: $count',
    //             maxLines: 1,
    //             overflow: TextOverflow.ellipsis,
    //             style: const TextStyle(
    //               color: _secondaryText,
    //               fontSize: 9,
    //               height: 1.15,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );

    return _detailCell(
      width: width,
      child: Tooltip(
        message: '${_number(amount)} / $count',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _number(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: amount > 0 ? color : _secondaryText,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 3),

              const Text(
                '/',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 3),

              Text(
                '$count',
                maxLines: 1,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _percentageCell(double value, double width) {
    return _detailCell(
      width: width,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: value > 0
                ? const Color(0xFFEDF8F2)
                : const Color(0xFFF4F5F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${value.toStringAsFixed(2)}%',
            style: TextStyle(
              color: value > 0 ? _primaryDark : _secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required String number,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontSize: 7,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // KPI
  // ============================================================

  Widget _miniKpi(String title, String value, Color color) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.055),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withOpacity(.10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 6,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactInfo({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.055),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 5.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CHART TITLE
  // ============================================================

  Widget _chartTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: _blue),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 1),

              Text(
                subtitle,
                style: const TextStyle(color: _secondaryText, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MODERN TAB
  // ============================================================

  Widget _modernChartTab(
    String title,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 5)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: selected ? _primary : _secondaryText),

            const SizedBox(width: 4),

            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? _primaryDark : _secondaryText,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CHART HELPERS
  // ============================================================

  double _normalizeAmount(double value, double amountMax, double visitMax) {
    if (amountMax <= 0) {
      return 0;
    }

    return (value / amountMax) * visitMax;
  }

  double _visitMax(int value) {
    if (value <= 10) return 10;
    if (value <= 20) return 20;
    if (value <= 30) return 30;
    if (value <= 50) return 50;

    return ((value / 10).ceil() * 10).toDouble();
  }

  double _amountMax(double value) {
    if (value <= 10000) return 10000;
    if (value <= 20000) return 20000;
    if (value <= 30000) return 30000;
    if (value <= 40000) return 40000;
    if (value <= 50000) return 50000;
    if (value <= 100000) {
      return 100000;
    }

    return ((value / 50000).ceil() * 50000).toDouble();
  }

  String _amountAxis(double value) {
    if (value <= 0) {
      return '₹0';
    }

    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    }

    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(0)}K';
    }

    return '₹${value.toInt()}';
  }

  // ============================================================
  // MONTHLY AMOUNT CHART
  // ============================================================

  Widget _monthlyAmountChart(List<MonthlyPerformanceItem> data) =>
      _monthlyChart(data, amount: true);

  Widget _monthlyVisitChart(List<MonthlyPerformanceItem> data) =>
      _monthlyChart(data, amount: false);

  Widget _monthlyChart(
    List<MonthlyPerformanceItem> data, {
    required bool amount,
  }) {
    if (data.isEmpty) return _emptyChart();
    final labels = data.map((e) => e.month).toList();
    final values = data
        .map(
          (e) => amount
              ? [e.orderAmount, e.dispatchAmount, e.paymentCollection]
              : [e.visits.toDouble()],
        )
        .toList();
    final peak = values.expand((e) => e).reduce((a, b) => a > b ? a : b);
    final maxY = amount
        ? ((peak * 1.2 / 10000).ceil().clamp(1, 1000000000) * 10000).toDouble()
        : _visitMax(peak.ceil()) * 1.2;
    final interval = amount ? 10000.0 : maxY / 4;
    final colors = amount ? [_red, _dispatchColor, _collectionColor] : [_blue];
    final names = amount ? ['Orders', 'Dispatch', 'Collection'] : ['Visits'];
    return _chartSurface(
      names: names,
      colors: colors,
      pointCount: data.length,
      pointWidth: amount ? 62 : 46,
      axisHint: amount ? 'Business amount (₹)' : 'Number of visits',
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: _chartGrid(maxY, interval: interval),
          borderData: FlBorderData(show: false),
          titlesData: _readableChartAxes(
            labels,
            maxY,
            money: amount,
            interval: interval,
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                '${labels[groupIndex]} · ${names[rodIndex]}\n${amount ? '₹${_number(rod.toY)}' : rod.toY.toInt().toString()}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          barGroups: List.generate(
            data.length,
            (index) => BarChartGroupData(
              x: index,
              barsSpace: 5,
              barRods: List.generate(
                values[index].length,
                (series) => BarChartRodData(
                  toY: values[index][series],
                  width: amount ? 12 : 20,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      colors[series].withValues(alpha: .65),
                      colors[series],
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingCard(String value) {
    return Container(
      height: 100,
      decoration: _cardDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(color: _secondaryText, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyChart() {
    return Container(
      height: 145,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, color: Color(0xFFB5BEC8), size: 30),

            SizedBox(height: 5),

            Text(
              'Select month to view graph',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 8.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border, width: .8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.035),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ============================================================
  // FORMAT
  // ============================================================

  String _monthText(List<String> months) {
    final List<String> result = [];

    for (final value in months) {
      final date = DateTime.tryParse('$value-01');

      if (date != null) {
        result.add(DateFormat('MMM-yy').format(date));
      }
    }

    return result.join(', ');
  }

  String _number(double value) {
    return NumberFormat('#,##0.##').format(value);
  }

  String _money(double value) {
    return '₹${_number(value)}';
  }
}

// ============================================================
// MONTH SUMMARY
// ============================================================

class _MonthSummary {
  final int visits;

  final double average;

  final String bestMonth;

  final double orderAmount;

  final int orderCount;

  final double dispatchAmount;

  final int dispatchCount;

  final double collection;

  final double visitShare;

  const _MonthSummary({
    required this.visits,
    required this.average,
    required this.bestMonth,
    required this.orderAmount,
    required this.orderCount,
    required this.dispatchAmount,
    required this.dispatchCount,
    required this.collection,
    required this.visitShare,
  });
}

// ============================================================
// DAILY SUMMARY
// ============================================================

class _DailySummary {
  final int totalVisits;

  final int activeDays;

  final String bestDay;

  final int highestVisits;

  const _DailySummary({
    required this.totalVisits,
    required this.activeDays,
    required this.bestDay,
    required this.highestVisits,
  });
}

// ============================================================
// HOURLY SUMMARY
// ============================================================

class _HourlySummary {
  final String peakHour;

  final int highestVisits;

  final int activeHours;

  const _HourlySummary({
    required this.peakHour,
    required this.highestVisits,
    required this.activeHours,
  });
}
