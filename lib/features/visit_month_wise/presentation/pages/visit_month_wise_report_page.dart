import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/secure_storage/secure_storage.dart';
import '../../../../core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/visit_day_wise.dart';
import '../../domain/entities/visit_frequency.dart';
import '../../domain/entities/visit_geo_wise.dart';
import '../../domain/entities/visit_hour_wise.dart';
import '../../domain/entities/visit_month_wise.dart';
import '../../domain/entities/visit_report_employee.dart';
import '../../domain/entities/visit_top_employee.dart';
import '../../domain/entities/visit_top_list.dart';

import '../bloc/visit_month_wise_bloc.dart';
import '../bloc/visit_month_wise_event.dart';
import '../bloc/visit_month_wise_state.dart';

class VisitMonthWiseReportPage extends StatefulWidget {
  const VisitMonthWiseReportPage({super.key});

  @override
  State<VisitMonthWiseReportPage> createState() =>
      _VisitMonthWiseReportPageState();
}

class _VisitMonthWiseReportPageState extends State<VisitMonthWiseReportPage> {
  // ============================================================
  // COLORS
  // ============================================================

  Color get _primary => context.primaryColor;
  Color get _primaryDark => context.primaryColor;

  Color get _blue => context.appColors.secondary;
  Color get _purple => context.appColors.tertiary;
  Color get _orange => context.appColors.error;

  Color get _background => context.backgroundColor;
  Color get _border => context.borderColor;

  Color get _text => context.cardTextColor;
  Color get _muted => context.secondaryTextColor;

  // ============================================================
  // EMPLOYEE
  // ============================================================

  final TextEditingController _employeeController = TextEditingController();

  final FocusNode _employeeFocusNode = FocusNode();

  Timer? _searchTimer;

  String _loginUserId = '';

  String _selectedEmployeeId = '';

  String _selectedEmployeeName = '';

  bool _showEmployeeList = false;

  // ============================================================
  // FILTER
  // ============================================================

  bool _filterExpanded = false;

  // ============================================================
  // DATE
  // CURRENT DATE FOR BOTH
  // ============================================================

  DateTime _fromDate = DateTime.now();

  DateTime _toDate = DateTime.now();

  // ============================================================
  // LOGIN
  // ============================================================

  bool _loginLoaded = false;

  // ============================================================
  // SCROLL CONTROLLERS
  // ============================================================

  final ScrollController _dayTableController = ScrollController();

  final ScrollController _hourTableController = ScrollController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogin();
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();

    _employeeController.dispose();

    _employeeFocusNode.dispose();

    _dayTableController.dispose();

    _hourTableController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _apiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _displayDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _reportPeriod(String fromDate, String toDate) {
    try {
      return '${DateFormat('dd/MM/yyyy').format(DateTime.parse(fromDate))} - '
          '${DateFormat('dd/MM/yyyy').format(DateTime.parse(toDate))}';
    } catch (_) {
      return '${_displayDate(_fromDate)} - '
          '${_displayDate(_toDate)}';
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _loadLogin() async {
    final Map<String, dynamic>? data = await SecureStorage.instance
        .getUserData();

    if (!mounted) {
      return;
    }

    final String userId = data?['user_id']?.toString().trim() ?? '';

    final String userName = data?['user_name']?.toString().trim() ?? '';

    setState(() {
      _loginUserId = userId;

      _selectedEmployeeId = userId;

      _selectedEmployeeName = userName;

      _employeeController.text = userName;

      _loginLoaded = true;
    });

    if (userId.isNotEmpty) {
      _searchEmployees('');

      _loadReport();
    }
  }

  // ============================================================
  // EMPLOYEE SEARCH
  // ============================================================

  void _searchEmployees(String search) {
    if (_loginUserId.isEmpty) {
      return;
    }

    context.read<VisitMonthWiseBloc>().add(
      SearchVisitReportEmployeesEvent(
        userId: _loginUserId,
        searchText: search.trim(),
      ),
    );
  }

  void _onEmployeeChanged(String value) {
    _searchTimer?.cancel();

    setState(() {
      _showEmployeeList = true;

      if (value.trim() != _selectedEmployeeName) {
        _selectedEmployeeId = '';
      }
    });

    _searchTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) {
        return;
      }

      _searchEmployees(value);
    });
  }

  void _selectEmployee(VisitReportEmployee employee) {
    setState(() {
      _selectedEmployeeId = employee.id;

      _selectedEmployeeName = employee.name;

      _employeeController.text = employee.name;

      _showEmployeeList = false;
    });

    context.read<VisitMonthWiseBloc>().add(
      const ClearVisitReportEmployeesEvent(),
    );

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // FROM DATE
  // ============================================================

  Future<void> _pickFromDate() async {
    final DateTime? date = await showDatePicker(
      context: context,

      initialDate: _fromDate,

      firstDate: DateTime(2020),

      lastDate: _toDate,
    );

    if (date == null || !mounted) {
      return;
    }

    setState(() {
      _fromDate = date;
    });
  }

  // ============================================================
  // TO DATE
  // ============================================================

  Future<void> _pickToDate() async {
    final DateTime? date = await showDatePicker(
      context: context,

      initialDate: _toDate.isBefore(_fromDate) ? _fromDate : _toDate,

      firstDate: _fromDate,

      lastDate: DateTime.now(),
    );

    if (date == null || !mounted) {
      return;
    }

    setState(() {
      _toDate = date;
    });
  }

  // ============================================================
  // LOAD ALL REPORTS
  // ============================================================

  void _loadReport() {
    if (_selectedEmployeeId.isEmpty) {
      _showMessage('Please select employee');

      return;
    }

    if (_fromDate.isAfter(_toDate)) {
      _showMessage('From date cannot be after To date');

      return;
    }

    setState(() {
      _showEmployeeList = false;

      _filterExpanded = false;
    });

    FocusScope.of(context).unfocus();

    final VisitMonthWiseBloc bloc = context.read<VisitMonthWiseBloc>();

    final String fromDate = _apiDate(_fromDate);

    final String toDate = _apiDate(_toDate);

    final String employeeId = _selectedEmployeeId;

    // ==========================================================
    // MONTH
    // ==========================================================

    bloc.add(
      LoadVisitMonthWiseEvent(
        fromDate: fromDate,
        toDate: toDate,
        employeeId: employeeId,
      ),
    );

    // ==========================================================
    // DAY
    // ==========================================================

    bloc.add(
      LoadVisitDayWiseEvent(
        fromDate: fromDate,
        toDate: toDate,
        employeeId: employeeId,
      ),
    );

    // ==========================================================
    // HOUR
    // ==========================================================

    bloc.add(
      LoadVisitHourWiseEvent(
        fromDate: fromDate,
        toDate: toDate,
        employeeId: employeeId,
      ),
    );

    // ==========================================================
    // FREQUENCY
    // ==========================================================

    bloc.add(
      LoadVisitFrequencyEvent(
        fromDate: fromDate,
        toDate: toDate,
        employeeId: employeeId,
      ),
    );

    // ==========================================================
    // GEO WISE
    // ==========================================================

    bloc.add(
      LoadVisitGeoWiseEvent(
        fromDate: fromDate,
        toDate: toDate,
        employeeId: employeeId,
      ),
    );

    // ==========================================================
    // TOP DEALER / FARMER LIST
    // ==========================================================

    bloc.add(
      LoadVisitTopListEvent(
        fromDate: fromDate,
        toDate: toDate,
        employeeId: employeeId,
      ),
    );

    // ==========================================================
    // TOP EMPLOYEE
    // ==========================================================

    bloc.add(
      LoadVisitTopEmployeeEvent(
        fromDate: fromDate,
        toDate: toDate,
        employeeId: employeeId,
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(value)),
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
        title: 'Visit Analysis Reports',
        backgroundColor: context.primaryColor,
        titleStyle: TextStyle(color: context.onPrimaryColor),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: context.onPrimaryColor,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),

        showBackButton: true,

        actionIcon: Icons.refresh_rounded,

        onActionIconTap: _loadReport,
      ),

      body: !_loginLoaded
          ? Center(child: CircularProgressIndicator(color: _primary))
          : BlocBuilder<VisitMonthWiseBloc, VisitMonthWiseState>(
              builder: (context, state) {
                return RefreshIndicator(
                  color: _primary,

                  onRefresh: () async {
                    _loadReport();
                  },

                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),

                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 18),

                    children: [
                      // ====================================
                      // FILTER
                      // ====================================
                      _filterCard(state),

                      SizedBox(height: 8),

                      // ====================================
                      // MONTH WISE
                      // ====================================
                      if (state.status == VisitMonthWiseStatus.loading)
                        _loadingCard('Loading Month Wise Report...')
                      else if (state.status == VisitMonthWiseStatus.failure &&
                          !_isNoRecordsMessage(state.errorMessage))
                        _errorCard(
                          state.errorMessage ??
                              'Unable to load month wise report',
                        )
                      else
                        _monthWiseReportCard(
                          state.report ?? _emptyMonthReport(),
                        ),

                      SizedBox(height: 8),

                      // ====================================
                      // DAY WISE
                      // ====================================
                      if (state.dayWiseStatus == VisitDayWiseStatus.loading)
                        _loadingCard('Loading Day Wise Report...')
                      else if (state.dayWiseStatus ==
                              VisitDayWiseStatus.failure &&
                          !_isNoRecordsMessage(state.dayWiseError))
                        _errorCard(
                          state.dayWiseError ??
                              'Unable to load day wise report',
                        )
                      else
                        _dayWiseReportCard(
                          state.dayWiseReport ?? _emptyDayReport(),
                        ),

                      SizedBox(height: 8),

                      // ====================================
                      // HOUR WISE
                      // ====================================
                      if (state.hourWiseStatus == VisitHourWiseStatus.loading)
                        _loadingCard('Loading Hour Wise Report...')
                      else if (state.hourWiseStatus ==
                              VisitHourWiseStatus.failure &&
                          !_isNoRecordsMessage(state.hourWiseError))
                        _errorCard(
                          state.hourWiseError ??
                              'Unable to load hour wise report',
                        )
                      else
                        _hourWiseReportCard(
                          state.hourWiseReport ?? _emptyHourReport(),
                        ),

                      SizedBox(height: 8),

                      // ====================================
                      // VISIT FREQUENCY
                      // ====================================
                      if (state.frequencyStatus == VisitFrequencyStatus.loading)
                        _loadingCard('Loading Visit Frequency...')
                      else if (state.frequencyStatus ==
                              VisitFrequencyStatus.failure &&
                          !_isNoRecordsMessage(state.frequencyError))
                        _errorCard(
                          state.frequencyError ??
                              'Unable to load visit frequency',
                        )
                      else
                        _visitFrequencySection(
                          state.frequencyReport ?? _emptyFrequencyReport(),
                        ),

                      SizedBox(height: 8),

                      // ====================================
                      // GEO WISE
                      // ====================================
                      if (state.geoWiseStatus == VisitGeoWiseStatus.loading)
                        _loadingCard('Loading Geo Wise Report...')
                      else if (state.geoWiseStatus ==
                              VisitGeoWiseStatus.failure &&
                          !_isNoRecordsMessage(state.geoWiseError))
                        _errorCard(
                          state.geoWiseError ??
                              'Unable to load geo wise report',
                        )
                      else
                        _geoWiseSection(
                          state.geoWiseReport ?? _emptyGeoReport(),
                        ),

                      SizedBox(height: 8),

                      // ====================================
                      // TOP DEALERS / FARMERS
                      // ====================================
                      if (state.topListStatus == VisitTopListStatus.loading)
                        _loadingCard('Loading Top Visit List...')
                      else if (state.topListStatus ==
                              VisitTopListStatus.failure &&
                          !_isNoRecordsMessage(state.topListError))
                        _errorCard(
                          state.topListError ?? 'Unable to load top visit list',
                        )
                      else
                        _topVisitSection(
                          state.topListReport ?? _emptyTopListReport(),
                        ),

                      SizedBox(height: 8),

                      // ====================================
                      // TOP EMPLOYEE
                      // ====================================
                      if (state.topEmployeeStatus ==
                          VisitTopEmployeeStatus.loading)
                        _loadingCard('Loading Top Employee Report...')
                      else if (state.topEmployeeStatus ==
                              VisitTopEmployeeStatus.failure &&
                          !_isNoRecordsMessage(state.topEmployeeError))
                        _errorCard(
                          state.topEmployeeError ??
                              'Unable to load top employee report',
                        )
                      else
                        _topEmployeeCard(
                          state.topEmployeeReport ?? _emptyTopEmployeeReport(),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _filterCard(VisitMonthWiseState state) {
    return Container(
      decoration: _cardDecoration(),

      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),

            onTap: () {
              setState(() {
                _filterExpanded = !_filterExpanded;

                if (!_filterExpanded) {
                  _showEmployeeList = false;
                }
              });

              if (!_filterExpanded) {
                FocusScope.of(context).unfocus();
              }
            },

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),

              child: Row(
                children: [
                  _iconBox(Icons.tune_rounded, _primary, size: 30),

                  SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Report Filter',

                          style: TextStyle(
                            color: _text,

                            fontSize: 12,

                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        SizedBox(height: 1),

                        Text(
                          'Employee & date selection',

                          style: TextStyle(
                            color: _muted,

                            fontSize: 7.5,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedRotation(
                    turns: _filterExpanded ? .5 : 0,

                    duration: const Duration(milliseconds: 180),

                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,

                      color: _primary,

                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),

            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(9, 0, 9, 9),

              child: Column(
                children: [
                  Divider(height: 1, color: _border),

                  SizedBox(height: 8),

                  _filterFields(state),

                  _employeeSuggestions(state),
                ],
              ),
            ),

            crossFadeState: _filterExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,

            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER FIELDS
  // ============================================================

  Widget _filterFields(VisitMonthWiseState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 700) {
          return Row(
            children: [
              Expanded(flex: 4, child: _employeeField(state)),

              SizedBox(width: 7),

              Expanded(
                flex: 2,
                child: _dateField(
                  label: 'From Date',

                  value: _displayDate(_fromDate),

                  onTap: _pickFromDate,
                ),
              ),

              SizedBox(width: 7),

              Expanded(
                flex: 2,
                child: _dateField(
                  label: 'To Date',

                  value: _displayDate(_toDate),

                  onTap: _pickToDate,
                ),
              ),

              SizedBox(width: 7),

              SizedBox(width: 120, height: 40, child: _viewButton()),
            ],
          );
        }

        return Column(
          children: [
            _employeeField(state),

            SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: _dateField(
                    label: 'From Date',

                    value: _displayDate(_fromDate),

                    onTap: _pickFromDate,
                  ),
                ),

                SizedBox(width: 6),

                Expanded(
                  child: _dateField(
                    label: 'To Date',

                    value: _displayDate(_toDate),

                    onTap: _pickToDate,
                  ),
                ),
              ],
            ),

            SizedBox(height: 7),

            SizedBox(width: double.infinity, height: 40, child: _viewButton()),
          ],
        );
      },
    );
  }

  // ============================================================
  // EMPLOYEE FIELD
  // ============================================================

  Widget _employeeField(VisitMonthWiseState state) {
    return SizedBox(
      height: 40,

      child: TextField(
        controller: _employeeController,

        focusNode: _employeeFocusNode,

        onTap: () {
          setState(() {
            _showEmployeeList = true;
          });

          _searchEmployees(_employeeController.text);
        },

        onChanged: _onEmployeeChanged,

        style: TextStyle(
          fontSize: 9,

          color: _text,

          fontWeight: FontWeight.w600,
        ),

        decoration: InputDecoration(
          labelText: 'Employee',

          hintText: 'Search employee',

          prefixIcon: Icon(
            Icons.person_search_outlined,

            size: 16,

            color: _primary,
          ),

          suffixIcon: state.employeeStatus == VisitReportEmployeeStatus.loading
              ? Padding(
                  padding: EdgeInsets.all(12),

                  child: SizedBox(
                    width: 13,

                    height: 13,

                    child: CircularProgressIndicator(
                      strokeWidth: 2,

                      color: _primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.keyboard_arrow_down_rounded,

                  size: 17,

                  color: _muted,
                ),

          filled: true,

          fillColor: context.appColors.surfaceContainerHighest,

          contentPadding: const EdgeInsets.symmetric(horizontal: 8),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),

            borderSide: BorderSide(color: _border),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),

            borderSide: BorderSide(color: _primary),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE LIST
  // ============================================================

  Widget _employeeSuggestions(VisitMonthWiseState state) {
    if (!_showEmployeeList || state.employees.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 150),

      margin: const EdgeInsets.only(top: 6),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,

        border: Border.all(color: _border),

        borderRadius: BorderRadius.circular(9),
      ),

      child: ListView.separated(
        shrinkWrap: true,

        padding: EdgeInsets.zero,

        itemCount: state.employees.length,

        separatorBuilder: (context, index) =>
            Divider(height: 1, color: _border),

        itemBuilder: (context, index) {
          final VisitReportEmployee employee = state.employees[index];

          return InkWell(
            onTap: () {
              _selectEmployee(employee);
            },

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),

              child: Row(
                children: [
                  _iconBox(Icons.person_outline, _primary, size: 26),

                  SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      employee.name,

                      style: TextStyle(
                        color: _text,

                        fontSize: 9,

                        fontWeight: FontWeight.w600,
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

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 40,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(9),

        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,

            prefixIcon: Icon(
              Icons.calendar_month_outlined,

              size: 15,

              color: _primary,
            ),

            filled: true,

            fillColor: context.appColors.surfaceContainerHighest,

            contentPadding: const EdgeInsets.symmetric(horizontal: 8),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),

              borderSide: BorderSide(color: _border),
            ),
          ),

          child: Text(
            value,

            style: TextStyle(
              color: _text,

              fontSize: 9,

              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VIEW BUTTON
  // ============================================================

  Widget _viewButton() {
    return ElevatedButton.icon(
      onPressed: _loadReport,

      icon: Icon(Icons.analytics_outlined, size: 15),

      label: Text('View Report'),

      style: ElevatedButton.styleFrom(
        elevation: 0,

        backgroundColor: _primary,

        foregroundColor: context.onPrimaryColor,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),

        textStyle: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ============================================================
  // EMPTY REPORTS
  // ============================================================

  VisitMonthWiseReport _emptyMonthReport() {
    return VisitMonthWiseReport(
      fromDate: _apiDate(_fromDate),

      toDate: _apiDate(_toDate),

      items: const [],

      total: const VisitMonthWiseTotal(
        dealerVisits: 0,
        farmerVisits: 0,
        totalVisits: 0,
        uniqueDealers: 0,
        uniqueFarmers: 0,
        uniqueCustomers: 0,
        avgVisitsDealer: 0,
        avgVisitsFarmer: 0,
      ),
    );
  }

  VisitDayWiseReport _emptyDayReport() {
    return VisitDayWiseReport(
      fromDate: _apiDate(_fromDate),

      toDate: _apiDate(_toDate),

      items: const [],

      total: const VisitDayWiseTotal(
        dealerVisits: 0,
        farmerVisits: 0,
        totalVisits: 0,
        uniqueDealers: 0,
        uniqueFarmers: 0,
        uniqueCustomers: 0,
        avgVisitsDealer: 0,
        avgVisitsFarmer: 0,
      ),
    );
  }

  VisitHourWiseReport _emptyHourReport() {
    return VisitHourWiseReport(
      fromDate: _apiDate(_fromDate),

      toDate: _apiDate(_toDate),

      items: const [],

      total: const VisitHourWiseTotal(
        dealerVisits: 0,
        farmerVisits: 0,
        totalVisits: 0,
        uniqueDealers: 0,
        uniqueFarmers: 0,
        uniqueCustomers: 0,
        avgVisitsDealer: 0,
        avgVisitsFarmer: 0,
        avgVisits: 0,
      ),
    );
  }

  VisitFrequencyReport _emptyFrequencyReport() {
    return VisitFrequencyReport(
      dealer: const VisitFrequencyGroup(total: 0, buckets: []),

      farmer: const VisitFrequencyGroup(total: 0, buckets: []),

      fromDate: _apiDate(_fromDate),

      toDate: _apiDate(_toDate),
    );
  }

  VisitTopListReport _emptyTopListReport() {
    return VisitTopListReport(
      dealer: const VisitTopListGroup(count: 0, items: [], totalVisits: 0),
      farmer: const VisitTopListGroup(count: 0, items: [], totalVisits: 0),
      fromDate: _apiDate(_fromDate),
      toDate: _apiDate(_toDate),
    );
  }

  VisitTopEmployeeReport _emptyTopEmployeeReport() {
    return VisitTopEmployeeReport(
      items: const [],
      total: const VisitTopEmployeeTotal(
        dealerVisits: 0,
        uniqueDealers: 0,
        avgVisitsDealer: 0,
        farmerVisits: 0,
        uniqueFarmers: 0,
        avgVisitsFarmer: 0,
        totalVisits: 0,
      ),
      periodLabel: '',
      fromDate: _apiDate(_fromDate),
      toDate: _apiDate(_toDate),
    );
  }

  VisitGeoWiseReport _emptyGeoReport() {
    const VisitGeoTotal emptyTotal = VisitGeoTotal(
      dealerVisits: 0,
      farmerVisits: 0,
      totalVisits: 0,
      unique: 0,
    );

    return VisitGeoWiseReport(
      stateSection: const VisitGeoSection(
        count: 0,
        items: [],
        total: emptyTotal,
      ),

      districtSection: const VisitGeoSection(
        count: 0,
        items: [],
        total: emptyTotal,
      ),

      talukaSection: const VisitGeoSection(
        count: 0,
        items: [],
        total: emptyTotal,
      ),

      fromDate: _apiDate(_fromDate),

      toDate: _apiDate(_toDate),
    );
  }

  // ============================================================
  // MONTH REPORT
  // ============================================================

  Widget _monthWiseReportCard(VisitMonthWiseReport report) {
    return Container(
      decoration: _cardDecoration(),

      clipBehavior: Clip.antiAlias,

      child: Column(
        children: [
          _sectionHeader(
            title: 'MONTH WISE VISIT ANALYSIS',

            subtitle:
                'Seasonal progress tracking across active operational months',

            fromDate: report.fromDate,

            toDate: report.toDate,

            color: _primary,
          ),

          Divider(height: 1, color: _border),

          if (report.items.isNotEmpty) ...[
            _summaryRow(
              totalVisits: report.total.totalVisits,

              dealerVisits: report.total.dealerVisits,

              farmerVisits: report.total.farmerVisits,

              uniqueCustomers: report.total.uniqueCustomers,
            ),

            Divider(height: 1, color: _border),
          ],

          _monthWiseTable(report),
        ],
      ),
    );
  }

  // ============================================================
  // DAY REPORT
  // ============================================================

  Widget _dayWiseReportCard(VisitDayWiseReport report) {
    return Container(
      decoration: _cardDecoration(),

      clipBehavior: Clip.antiAlias,

      child: Column(
        children: [
          _sectionHeader(
            title: 'DAY WISE VISIT ANALYSIS',

            subtitle: 'Micro-level daily field execution metrics',

            fromDate: report.fromDate,

            toDate: report.toDate,

            color: _blue,
          ),

          Divider(height: 1, color: _border),

          _dayWiseTable(report),
        ],
      ),
    );
  }

  // ============================================================
  // HOUR REPORT
  // ============================================================

  Widget _hourWiseReportCard(VisitHourWiseReport report) {
    final VisitHourWiseItem? peakHour = _findPeakHour(report.items);

    return Container(
      decoration: _cardDecoration(),

      clipBehavior: Clip.antiAlias,

      child: Column(
        children: [
          if (report.items.isNotEmpty)
            _hourWiseHeader(report: report, peakHour: peakHour)
          else
            _sectionHeader(
              title: 'HRS WISE VISIT ANALYSIS',

              subtitle: 'Peak field hours distribution',

              fromDate: report.fromDate,

              toDate: report.toDate,

              color: _orange,
            ),

          Divider(height: 1, color: _border),

          _hourWiseTable(report),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required String fromDate,
    required String toDate,
    required Color color,
  }) {
    final String period = _reportPeriod(fromDate, toDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),

      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,

            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: TextStyle(
                    color: _text,

                    fontSize: 11.5,

                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  subtitle,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: _muted,

                    fontSize: 7.2,

                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 6),

          _periodBadge(period: period, color: color),
        ],
      ),
    );
  }

  Widget _periodBadge({required String period, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),

      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),

        borderRadius: BorderRadius.circular(6),
      ),

      child: Text(
        '$period Period',

        style: TextStyle(
          color: color,

          fontSize: 6.8,

          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // HOUR HEADER
  // ============================================================

  Widget _hourWiseHeader({
    required VisitHourWiseReport report,
    required VisitHourWiseItem? peakHour,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),

      child: LayoutBuilder(
        builder: (context, constraints) {
          final Widget title = Row(
            children: [
              Container(
                width: 7,
                height: 7,

                decoration: BoxDecoration(
                  color: _orange,

                  shape: BoxShape.circle,
                ),
              ),

              SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'HRS WISE VISIT ANALYSIS',

                      style: TextStyle(
                        color: _text,

                        fontSize: 11.5,

                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 2),

                    Text(
                      'Peak field hours distribution',

                      style: TextStyle(
                        color: _muted,

                        fontSize: 7.2,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final Widget badges = Wrap(
            spacing: 5,
            runSpacing: 4,

            alignment: WrapAlignment.end,

            children: [
              _hourBadge(
                icon: Icons.schedule_rounded,

                text: peakHour == null
                    ? 'Peak hour: -'
                    : 'Peak hour: '
                          '${_hourLabelWithMinutes(peakHour.label)} '
                          '(${peakHour.totalVisits} visits)',

                foreground: context.appColors.tertiary,

                background: context.appColors.tertiary.withValues(alpha: 0.12),
              ),

              _hourBadge(
                text:
                    'Dealer Avg: '
                    '${report.total.avgVisitsDealer.toStringAsFixed(2)}',

                foreground: _primaryDark,

                background: context.primaryColor.withValues(alpha: 0.08),
              ),

              _hourBadge(
                text:
                    'Farmer Avg: '
                    '${report.total.avgVisitsFarmer.toStringAsFixed(2)}',

                foreground: _blue,

                background: context.appColors.secondary.withValues(alpha: 0.08),
              ),
            ],
          );

          if (constraints.maxWidth >= 700) {
            return Row(
              children: [
                Expanded(flex: 4, child: title),

                SizedBox(width: 8),

                Flexible(flex: 6, child: badges),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              title,

              SizedBox(height: 6),

              Align(alignment: Alignment.centerRight, child: badges),
            ],
          );
        },
      ),
    );
  }

  Widget _hourBadge({
    IconData? icon,
    required String text,
    required Color foreground,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),

      decoration: BoxDecoration(
        color: background,

        borderRadius: BorderRadius.circular(6),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: foreground),

            SizedBox(width: 3),
          ],

          Text(
            text,

            style: TextStyle(
              color: foreground,

              fontSize: 7,

              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  VisitHourWiseItem? _findPeakHour(List<VisitHourWiseItem> items) {
    if (items.isEmpty) {
      return null;
    }

    VisitHourWiseItem? result;

    for (final item in items) {
      if (result == null || item.totalVisits > result.totalVisits) {
        result = item;
      }
    }

    if (result == null || result.totalVisits == 0) {
      return null;
    }

    return result;
  }

  String _hourLabelWithMinutes(String label) {
    final String value = label.trim();

    if (value.isEmpty) {
      return '-';
    }

    if (value.contains(':')) {
      return value;
    }

    final List<String> parts = value.split(' ');

    if (parts.length == 2) {
      return '${parts[0]}:00 ${parts[1]}';
    }

    return value;
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _summaryRow({
    required int totalVisits,
    required int dealerVisits,
    required int farmerVisits,
    required int uniqueCustomers,
  }) {
    return Padding(
      padding: const EdgeInsets.all(6),

      child: Row(
        children: [
          Expanded(
            child: _summaryTile(
              'TOTAL',
              '$totalVisits',
              Icons.groups_2_outlined,
              _primary,
            ),
          ),

          SizedBox(width: 4),

          Expanded(
            child: _summaryTile(
              'DEALER',
              '$dealerVisits',
              Icons.storefront_outlined,
              _blue,
            ),
          ),

          SizedBox(width: 4),

          Expanded(
            child: _summaryTile(
              'FARMER',
              '$farmerVisits',
              Icons.agriculture_outlined,
              _purple,
            ),
          ),

          SizedBox(width: 4),

          Expanded(
            child: _summaryTile(
              'UNIQUE',
              '$uniqueCustomers',
              Icons.people_alt_outlined,
              _orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(String title, String value, IconData icon, Color color) {
    return Container(
      height: 44,

      padding: const EdgeInsets.symmetric(horizontal: 6),

      decoration: BoxDecoration(
        color: context.appColors.surfaceContainerHighest,

        borderRadius: BorderRadius.circular(8),

        border: Border.all(color: _border),
      ),

      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,

            decoration: BoxDecoration(
              color: color.withValues(alpha: .08),

              borderRadius: BorderRadius.circular(7),
            ),

            child: Icon(icon, color: color, size: 13),
          ),

          SizedBox(width: 5),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  value,

                  style: TextStyle(
                    color: _text,

                    fontSize: 12,

                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 2),

                Text(
                  title,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: _muted,

                    fontSize: 6,

                    fontWeight: FontWeight.w700,
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
  // MONTH TABLE
  // ============================================================

  Widget _monthWiseTable(VisitMonthWiseReport report) {
    const List<double> widths = [78, 92, 102, 112, 92, 102, 112];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: SizedBox(
        width: widths.reduce((a, b) => a + b),

        child: Column(
          children: [
            _tableRow(
              values: const [
                'Month',
                'Dealer Visits',
                'Unique Dealer',
                'Avg / Dealer',
                'Farmer Visits',
                'Unique Farmer',
                'Avg / Farmer',
              ],

              widths: widths,

              header: true,
            ),

            if (report.items.isEmpty)
              SizedBox(
                width: widths.reduce((a, b) => a + b),

                child: _emptyData('No month wise visit data found'),
              ),

            ...List.generate(report.items.length, (index) {
              final VisitMonthWiseItem item = report.items[index];

              return _tableRow(
                values: [
                  item.month,

                  '${item.dealerVisits}',

                  '${item.uniqueDealers}',

                  item.avgVisitsDealer.toStringAsFixed(2),

                  '${item.farmerVisits}',

                  '${item.uniqueFarmers}',

                  item.avgVisitsFarmer.toStringAsFixed(2),
                ],

                widths: widths,

                alternate: index.isOdd,

                firstBold: true,
              );
            }),

            if (report.items.isNotEmpty)
              _tableRow(
                values: [
                  'TOTAL',

                  '${report.total.dealerVisits}',

                  '${report.total.uniqueDealers}',

                  report.total.avgVisitsDealer.toStringAsFixed(2),

                  '${report.total.farmerVisits}',

                  '${report.total.uniqueFarmers}',

                  report.total.avgVisitsFarmer.toStringAsFixed(2),
                ],

                widths: widths,

                total: true,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DAY TABLE
  // ============================================================

  Widget _dayWiseTable(VisitDayWiseReport report) {
    const List<double> widths = [82, 92, 102, 112, 92, 102, 112];

    final double totalWidth = widths.reduce((a, b) => a + b);

    if (report.items.isEmpty) {
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: SizedBox(
              width: totalWidth,

              child: _tableRow(
                values: const [
                  'Day of Month',
                  'Dealer Visits',
                  'Unique Dealer',
                  'Avg / Dealer',
                  'Farmer Visits',
                  'Unique Farmer',
                  'Avg / Farmer',
                ],

                widths: widths,

                header: true,
              ),
            ),
          ),

          _emptyData('No day wise visit data found'),
        ],
      );
    }

    return SizedBox(
      height: 430,

      child: Scrollbar(
        controller: _dayTableController,

        thumbVisibility: true,

        child: SingleChildScrollView(
          controller: _dayTableController,

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: SizedBox(
              width: totalWidth,

              child: Column(
                children: [
                  _tableRow(
                    values: const [
                      'Day of Month',
                      'Dealer Visits',
                      'Unique Dealer',
                      'Avg / Dealer',
                      'Farmer Visits',
                      'Unique Farmer',
                      'Avg / Farmer',
                    ],

                    widths: widths,

                    header: true,
                  ),

                  ...List.generate(report.items.length, (index) {
                    final VisitDayWiseItem item = report.items[index];

                    return _tableRow(
                      values: [
                        item.dayLabel,

                        '${item.dealerVisits}',

                        '${item.uniqueDealers}',

                        item.avgVisitsDealer.toStringAsFixed(2),

                        '${item.farmerVisits}',

                        '${item.uniqueFarmers}',

                        item.avgVisitsFarmer.toStringAsFixed(2),
                      ],

                      widths: widths,

                      alternate: index.isOdd,

                      firstBold: true,
                    );
                  }),

                  _tableRow(
                    values: [
                      'TOTAL',

                      '${report.total.dealerVisits}',

                      '${report.total.uniqueDealers}',

                      report.total.avgVisitsDealer.toStringAsFixed(2),

                      '${report.total.farmerVisits}',

                      '${report.total.uniqueFarmers}',

                      report.total.avgVisitsFarmer.toStringAsFixed(2),
                    ],

                    widths: widths,

                    total: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HOUR TABLE
  // ============================================================

  Widget _hourWiseTable(VisitHourWiseReport report) {
    const List<double> widths = [84, 88, 100, 112, 88, 100, 112];

    final double totalWidth = widths.reduce((a, b) => a + b);

    if (report.items.isEmpty) {
      return Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: SizedBox(
              width: totalWidth,

              child: _hourTableRow(
                values: const [
                  'Hrs of Day',
                  'Dealer Visit',
                  'Unique Dealer',
                  'Avg Visits / Dealer',
                  'Farmer Visit',
                  'Unique Farmer',
                  'Avg Visits / Farmer',
                ],

                widths: widths,

                header: true,
              ),
            ),
          ),

          _emptyData('No hour wise visit data found'),
        ],
      );
    }

    return SizedBox(
      height: 365,

      child: Scrollbar(
        controller: _hourTableController,

        thumbVisibility: true,

        child: SingleChildScrollView(
          controller: _hourTableController,

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            child: SizedBox(
              width: totalWidth,

              child: Column(
                children: [
                  _hourTableRow(
                    values: const [
                      'Hrs of Day',
                      'Dealer Visit',
                      'Unique Dealer',
                      'Avg Visits / Dealer',
                      'Farmer Visit',
                      'Unique Farmer',
                      'Avg Visits / Farmer',
                    ],

                    widths: widths,

                    header: true,
                  ),

                  ...List.generate(report.items.length, (index) {
                    final VisitHourWiseItem item = report.items[index];

                    return _hourTableRow(
                      values: [
                        _hourLabelWithMinutes(item.label),

                        '${item.dealerVisits}',

                        '${item.uniqueDealers}',

                        item.avgVisitsDealer.toStringAsFixed(2),

                        '${item.farmerVisits}',

                        '${item.uniqueFarmers}',

                        item.avgVisitsFarmer.toStringAsFixed(2),
                      ],

                      widths: widths,

                      alternate: index.isOdd,
                    );
                  }),

                  _hourTableRow(
                    values: [
                      'TOTAL',

                      '${report.total.dealerVisits}',

                      '${report.total.uniqueDealers}',

                      report.total.avgVisitsDealer.toStringAsFixed(2),

                      '${report.total.farmerVisits}',

                      '${report.total.uniqueFarmers}',

                      report.total.avgVisitsFarmer.toStringAsFixed(2),
                    ],

                    widths: widths,

                    total: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VISIT FREQUENCY
  // ============================================================

  Widget _visitFrequencySection(VisitFrequencyReport report) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: _frequencyCard(
                  title: 'DEALER VISIT FREQUENCY',

                  subtitle: 'Frequency of visits across unique dealer accounts',

                  group: report.dealer,

                  type: 'Dealer',

                  accent: context.primaryColor,

                  fromDate: report.fromDate,

                  toDate: report.toDate,
                ),
              ),

              SizedBox(width: 8),

              Expanded(
                child: _frequencyCard(
                  title: 'FARMER VISIT FREQUENCY',

                  subtitle:
                      'Frequency of visits across unique farmer relationships',

                  group: report.farmer,

                  type: 'Farmer',

                  accent: context.appColors.secondary,

                  fromDate: report.fromDate,

                  toDate: report.toDate,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _frequencyCard(
              title: 'DEALER VISIT FREQUENCY',

              subtitle: 'Frequency of visits across unique dealer accounts',

              group: report.dealer,

              type: 'Dealer',

              accent: context.primaryColor,

              fromDate: report.fromDate,

              toDate: report.toDate,
            ),

            SizedBox(height: 8),

            _frequencyCard(
              title: 'FARMER VISIT FREQUENCY',

              subtitle:
                  'Frequency of visits across unique farmer relationships',

              group: report.farmer,

              type: 'Farmer',

              accent: context.appColors.secondary,

              fromDate: report.fromDate,

              toDate: report.toDate,
            ),
          ],
        );
      },
    );
  }

  Widget _frequencyCard({
    required String title,
    required String subtitle,
    required VisitFrequencyGroup group,
    required String type,
    required Color accent,
    required String fromDate,
    required String toDate,
  }) {
    final bool hasData = group.buckets.isNotEmpty;

    return Container(
      decoration: _cardDecoration(),

      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          _frequencyHeader(
            title: title,

            subtitle: subtitle,

            accent: accent,

            fromDate: fromDate,

            toDate: toDate,

            total: group.total,

            type: type,
          ),

          Divider(height: 1, color: _border),

          if (!hasData)
            _frequencyEmpty(type: type, accent: accent)
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),

              child: Column(
                children: List.generate(group.buckets.length, (index) {
                  final VisitFrequencyBucket bucket = group.buckets[index];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == group.buckets.length - 1 ? 0 : 9,
                    ),

                    child: _frequencyRow(
                      bucket: bucket,

                      type: type,

                      accent: accent,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _frequencyHeader({
    required String title,
    required String subtitle,
    required Color accent,
    required String fromDate,
    required String toDate,
    required int total,
    required String type,
  }) {
    final String period = _reportPeriod(fromDate, toDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,

                decoration: BoxDecoration(
                  color: accent,

                  shape: BoxShape.circle,
                ),
              ),

              SizedBox(width: 7),

              Expanded(
                child: Text(
                  title,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    color: _text,

                    fontSize: 11.5,

                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              if (total > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),

                  decoration: BoxDecoration(
                    color: context.appColors.surfaceContainerHighest,

                    borderRadius: BorderRadius.circular(5),
                  ),

                  child: Text(
                    '$total ${type}s',

                    style: TextStyle(
                      color: _muted,

                      fontSize: 6.7,

                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 4),

          Wrap(
            spacing: 6,
            runSpacing: 4,

            crossAxisAlignment: WrapCrossAlignment.center,

            children: [
              Text(
                subtitle,

                style: TextStyle(
                  color: _muted,

                  fontSize: 7.4,

                  fontWeight: FontWeight.w500,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),

                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .08),

                  borderRadius: BorderRadius.circular(5),
                ),

                child: Text(
                  '$period Period',

                  style: TextStyle(
                    color: accent,

                    fontSize: 6.8,

                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _frequencyRow({
    required VisitFrequencyBucket bucket,
    required String type,
    required Color accent,
  }) {
    final double progress = (bucket.percentage / 100.0).clamp(0.0, 1.0);

    final String name = type == 'Dealer' ? 'Dealers' : 'Farmers';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                bucket.label,

                style: TextStyle(
                  color: context.secondaryTextColor,

                  fontSize: 8.5,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(width: 6),

            Text(
              '${bucket.count} $name '
              '(${bucket.percentage.toStringAsFixed(1)}%)',

              style: TextStyle(
                color: context.cardTextColor,

                fontSize: 7.6,

                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        SizedBox(height: 5),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),

          child: SizedBox(
            height: 6,

            child: Stack(
              children: [
                Container(color: context.borderColor),

                if (progress > 0)
                  FractionallySizedBox(
                    widthFactor: progress,

                    child: Container(color: accent),
                  ),

                if (progress == 0)
                  Align(
                    alignment: Alignment.centerLeft,

                    child: Container(
                      width: 5,
                      height: 5,

                      margin: const EdgeInsets.only(left: 1),

                      decoration: BoxDecoration(
                        color: accent,

                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _frequencyEmpty({required String type, required Color accent}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 12),

      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: accent.withValues(alpha: .07),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(Icons.bar_chart_rounded, color: accent, size: 19),
          ),

          SizedBox(height: 8),

          Text(
            'No Data Found',

            style: TextStyle(
              color: _text,

              fontSize: 10,

              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 3),

          Text(
            'No ${type.toLowerCase()} visit frequency data found for the selected period.',

            textAlign: TextAlign.center,

            style: TextStyle(
              color: _muted,

              fontSize: 7.4,

              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GEO WISE
  // ============================================================

  Widget _geoWiseSection(VisitGeoWiseReport report) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ======================================================
        // LARGE TABLET / DESKTOP
        // 3 CARDS IN ONE ROW
        // ======================================================

        if (constraints.maxWidth >= 1050) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Expanded(
                child: _geoWiseCard(
                  title: 'STATE-WISE VISIT ANALYSIS',

                  subtitle: 'State level breakdown',

                  section: report.stateSection,

                  accent: _primary,

                  emptyMessage: 'No state-wise visit data found',
                ),
              ),

              SizedBox(width: 8),

              Expanded(
                child: _geoWiseCard(
                  title: 'DISTRICT-WISE VISIT ANALYSIS',

                  subtitle: 'District level breakdown',

                  section: report.districtSection,

                  accent: _blue,

                  emptyMessage: 'No district-wise visit data found',
                ),
              ),

              SizedBox(width: 8),

              Expanded(
                child: _geoWiseCard(
                  title: 'TALUKA-WISE VISIT ANALYSIS',

                  subtitle: 'Taluka level breakdown',

                  section: report.talukaSection,

                  accent: _purple,

                  emptyMessage: 'No taluka-wise visit data found',
                ),
              ),
            ],
          );
        }

        // ======================================================
        // MEDIUM
        // STATE + DISTRICT
        // TALUKA BELOW
        // ======================================================

        if (constraints.maxWidth >= 680) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Expanded(
                    child: _geoWiseCard(
                      title: 'STATE-WISE VISIT ANALYSIS',

                      subtitle: 'State level breakdown',

                      section: report.stateSection,

                      accent: _primary,

                      emptyMessage: 'No state-wise visit data found',
                    ),
                  ),

                  SizedBox(width: 8),

                  Expanded(
                    child: _geoWiseCard(
                      title: 'DISTRICT-WISE VISIT ANALYSIS',

                      subtitle: 'District level breakdown',

                      section: report.districtSection,

                      accent: _blue,

                      emptyMessage: 'No district-wise visit data found',
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              _geoWiseCard(
                title: 'TALUKA-WISE VISIT ANALYSIS',

                subtitle: 'Taluka level breakdown',

                section: report.talukaSection,

                accent: _purple,

                emptyMessage: 'No taluka-wise visit data found',
              ),
            ],
          );
        }

        // ======================================================
        // MOBILE
        // ======================================================

        return Column(
          children: [
            _geoWiseCard(
              title: 'STATE-WISE VISIT ANALYSIS',

              subtitle: 'State level breakdown',

              section: report.stateSection,

              accent: _primary,

              emptyMessage: 'No state-wise visit data found',
            ),

            SizedBox(height: 8),

            _geoWiseCard(
              title: 'DISTRICT-WISE VISIT ANALYSIS',

              subtitle: 'District level breakdown',

              section: report.districtSection,

              accent: _blue,

              emptyMessage: 'No district-wise visit data found',
            ),

            SizedBox(height: 8),

            _geoWiseCard(
              title: 'TALUKA-WISE VISIT ANALYSIS',

              subtitle: 'Taluka level breakdown',

              section: report.talukaSection,

              accent: _purple,

              emptyMessage: 'No taluka-wise visit data found',
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // GEO CARD
  // ============================================================

  Widget _geoWiseCard({
    required String title,
    required String subtitle,
    required VisitGeoSection section,
    required Color accent,
    required String emptyMessage,
  }) {
    return Container(
      decoration: _cardDecoration(),

      clipBehavior: Clip.antiAlias,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          // =====================================================
          // HEADER
          // =====================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),

            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,

                  decoration: BoxDecoration(
                    color: accent,

                    shape: BoxShape.circle,
                  ),
                ),

                SizedBox(width: 7),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: _text,

                          fontSize: 10.8,

                          fontWeight: FontWeight.w900,

                          letterSpacing: .15,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        subtitle,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: _muted,

                          fontSize: 7,

                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 5),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .08),

                    borderRadius: BorderRadius.circular(6),
                  ),

                  child: Text(
                    '${section.count} '
                    '${section.count == 1 ? 'Area' : 'Areas'}',

                    style: TextStyle(
                      color: accent,

                      fontSize: 6.8,

                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: _border),

          // =====================================================
          // DATA
          // =====================================================
          if (section.items.isEmpty)
            _geoEmptyData(message: emptyMessage, accent: accent)
          else
            _geoWiseTable(section),
        ],
      ),
    );
  }

  // ============================================================
  // GEO TABLE
  // ============================================================

  Widget _geoWiseTable(VisitGeoSection section) {
    const List<double> widths = [165, 70, 70, 70, 70];

    final double totalWidth = widths.reduce((a, b) => a + b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: SizedBox(
        width: totalWidth,

        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            _geoTableRow(
              values: const ['Name', 'Dealer', 'Farmer', 'Total', 'Unique'],

              widths: widths,

              header: true,
            ),

            // ==================================================
            // DATA
            // ==================================================
            ...List.generate(section.items.length, (index) {
              final VisitGeoItem item = section.items[index];

              return _geoTableRow(
                values: [
                  item.name,

                  '${item.dealerVisits}',

                  '${item.farmerVisits}',

                  '${item.totalVisits}',

                  '${item.unique}',
                ],

                widths: widths,

                alternate: index.isOdd,
              );
            }),

            // ==================================================
            // TOTAL
            // ==================================================
            _geoTableRow(
              values: [
                'Total',

                '${section.total.dealerVisits}',

                '${section.total.farmerVisits}',

                '${section.total.totalVisits}',

                '${section.total.unique}',
              ],

              widths: widths,

              total: true,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GEO TABLE ROW
  // ============================================================

  Widget _geoTableRow({
    required List<String> values,
    required List<double> widths,
    bool header = false,
    bool total = false,
    bool alternate = false,
  }) {
    return Container(
      height: header
          ? 32
          : total
          ? 34
          : 32,

      color: header
          ? context.appColors.surfaceContainerHighest
          : total
          ? context.appColors.surfaceContainerHighest
          : alternate
          ? context.appColors.surfaceContainerHighest
          : context.cardBackgroundColor,

      child: Row(
        children: List.generate(values.length, (index) {
          Color valueColor = _text;

          // Dealer
          if (!header && index == 1) {
            valueColor = _primaryDark;
          }

          // Farmer
          if (!header && index == 2) {
            valueColor = _blue;
          }

          // Unique
          if (!header && index == 4) {
            valueColor = _purple;
          }

          return Container(
            width: widths[index],

            height: double.infinity,

            alignment: index == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,

            padding: const EdgeInsets.symmetric(horizontal: 7),

            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: _border, width: .55),

                bottom: BorderSide(color: _border, width: .55),
              ),
            ),

            child: Text(
              values[index],

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              textAlign: index == 0 ? TextAlign.left : TextAlign.right,

              style: TextStyle(
                color: header ? context.secondaryTextColor : valueColor,

                fontSize: header ? 7.4 : 7.9,

                fontWeight: header || total || index == 0
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // GEO EMPTY
  // ============================================================

  Widget _geoEmptyData({required String message, required Color accent}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            width: 36,
            height: 36,

            decoration: BoxDecoration(
              color: accent.withValues(alpha: .07),

              borderRadius: BorderRadius.circular(9),
            ),

            child: Icon(Icons.location_on_outlined, color: accent, size: 18),
          ),

          SizedBox(height: 7),

          Text(
            'No Data Found',

            style: TextStyle(
              color: _text,

              fontSize: 9.5,

              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 3),

          Text(
            message,

            textAlign: TextAlign.center,

            style: TextStyle(
              color: _muted,

              fontSize: 7.2,

              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP DEALERS / FARMERS
  // ============================================================

  Widget _topVisitSection(VisitTopListReport report) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _topVisitCard(
                  title: 'TOP DEALERS VISITED',
                  group: report.dealer,
                  type: 'Dealer',
                  accent: _primary,
                  fromDate: report.fromDate,
                  toDate: report.toDate,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _topVisitCard(
                  title: 'TOP FARMERS VISITED',
                  group: report.farmer,
                  type: 'Farmer',
                  accent: _blue,
                  fromDate: report.fromDate,
                  toDate: report.toDate,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _topVisitCard(
              title: 'TOP DEALERS VISITED',
              group: report.dealer,
              type: 'Dealer',
              accent: _primary,
              fromDate: report.fromDate,
              toDate: report.toDate,
            ),
            SizedBox(height: 8),
            _topVisitCard(
              title: 'TOP FARMERS VISITED',
              group: report.farmer,
              type: 'Farmer',
              accent: _blue,
              fromDate: report.fromDate,
              toDate: report.toDate,
            ),
          ],
        );
      },
    );
  }

  Widget _topVisitCard({
    required String title,
    required VisitTopListGroup group,
    required String type,
    required Color accent,
    required String fromDate,
    required String toDate,
  }) {
    final String period = _reportPeriod(fromDate, toDate);

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _text,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .12,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$period Period',
                    style: TextStyle(
                      color: accent,
                      fontSize: 6.7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _border),
          if (group.items.isEmpty)
            _topListEmpty(type: type, accent: accent)
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: List.generate(group.items.length, (index) {
                  final VisitTopListItem item = group.items[index];
                  return _topVisitRow(
                    item: item,
                    accent: accent,
                    isLast: index == group.items.length - 1,
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: _topVisitTotal(
                count: group.count,
                totalVisits: group.totalVisits,
                accent: accent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _topVisitRow({
    required VisitTopListItem item,
    required Color accent,
    required bool isLast,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: context.borderColor, width: .8)),
      ),
      child: Row(
        children: [
          // ==========================================
          // RANK
          // ==========================================
          _rankCircle(rank: item.rank),

          SizedBox(width: 8),

          // ==========================================
          // NAME
          // ==========================================
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 8.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(width: 8),

          // ==========================================
          // VISIT COUNT
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: context.appColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${item.visitCount} '
              '${item.visitCount == 1 ? 'visit' : 'visits'}',
              style: TextStyle(
                color: accent,
                fontSize: 7.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rankCircle({required int rank}) {
    final Color background;
    final Color foreground;

    switch (rank) {
      case 1:
        background = context.appColors.tertiary.withValues(alpha: 0.12);
        foreground = context.appColors.tertiary;
        break;
      case 2:
        background = context.appColors.surfaceContainerHighest;
        foreground = context.secondaryTextColor;
        break;
      case 3:
        background = context.appColors.tertiary.withValues(alpha: 0.12);
        foreground = context.appColors.tertiary;
        break;
      default:
        background = context.appColors.surfaceContainerHighest;
        foreground = _muted;
    }

    return Container(
      width: 21,
      height: 21,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        '$rank',
        style: TextStyle(
          color: foreground,
          fontSize: 7.4,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _topVisitTotal({
    required int count,
    required int totalVisits,
    required Color accent,
  }) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'TOP $count TOTAL',
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 7.7,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '$totalVisits ${totalVisits == 1 ? 'visit' : 'visits'}',
            style: TextStyle(
              color: accent,
              fontSize: 7.8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topListEmpty({required String type, required Color accent}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.emoji_events_outlined, color: accent, size: 18),
          ),
          SizedBox(height: 7),
          Text(
            'No Data Found',
            style: TextStyle(
              color: _text,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 3),
          Text(
            'No top ${type.toLowerCase()} visit data found for the selected period.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 7.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP EMPLOYEE
  // ============================================================

  Widget _topEmployeeCard(VisitTopEmployeeReport report) {
    final String period = _reportPeriod(report.fromDate, report.toDate);

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // =====================================================
          // HEADER
          // =====================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final Widget heading = Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOP EMPLOYEE VISITED',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _text,
                              fontSize: 11.2,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .12,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            report.periodLabel.trim().isNotEmpty
                                ? 'Individual officer field activities • ${report.periodLabel}'
                                : 'Individual officer field activities, unique coverage & productivity ratios',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _muted,
                              fontSize: 7.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final Widget periodBadge = Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$period Period',
                    style: TextStyle(
                      color: _blue,
                      fontSize: 6.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );

                if (constraints.maxWidth >= 560) {
                  return Row(
                    children: [
                      Expanded(child: heading),
                      SizedBox(width: 8),
                      periodBadge,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    heading,
                    SizedBox(height: 6),
                    Align(alignment: Alignment.centerRight, child: periodBadge),
                  ],
                );
              },
            ),
          ),

          Divider(height: 1, color: _border),

          if (report.items.isEmpty)
            _topEmployeeEmpty()
          else
            _topEmployeeTable(report),
        ],
      ),
    );
  }

  // ============================================================
  // TOP EMPLOYEE TABLE
  // ============================================================

  Widget _topEmployeeTable(VisitTopEmployeeReport report) {
    const List<double> widths = [220, 86, 112, 96, 86, 96, 112, 86];

    final double totalWidth = widths.reduce((a, b) => a + b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        child: Column(
          children: [
            _topEmployeeTableRow(
              values: const [
                'Employee Name',
                'Dealer Visits',
                'Avg Visits / Dealer',
                'Unique Dealers',
                'Farmer Visits',
                'Unique Farmers',
                'Avg Visits / Farmer',
                'Total Visits',
              ],
              widths: widths,
              header: true,
            ),

            ...List.generate(report.items.length, (index) {
              final VisitTopEmployeeItem item = report.items[index];

              return _topEmployeeTableRow(
                values: [
                  item.userName,
                  '${item.dealerVisits}',
                  item.avgVisitsDealer.toStringAsFixed(2),
                  '${item.uniqueDealers}',
                  '${item.farmerVisits}',
                  '${item.uniqueFarmers}',
                  item.avgVisitsFarmer.toStringAsFixed(2),
                  '${item.totalVisits}',
                ],
                widths: widths,
                rank: item.rank,
                alternate: index.isOdd,
              );
            }),

            _topEmployeeTableRow(
              values: [
                'TOTAL OFFICER CONTRIBUTION',
                '${report.total.dealerVisits}',
                report.total.avgVisitsDealer.toStringAsFixed(2),
                '${report.total.uniqueDealers}',
                '${report.total.farmerVisits}',
                '${report.total.uniqueFarmers}',
                report.total.avgVisitsFarmer.toStringAsFixed(2),
                '${report.total.totalVisits}',
              ],
              widths: widths,
              total: true,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP EMPLOYEE TABLE ROW
  // ============================================================

  Widget _topEmployeeTableRow({
    required List<String> values,
    required List<double> widths,
    bool header = false,
    bool total = false,
    bool alternate = false,
    int? rank,
  }) {
    return Container(
      constraints: BoxConstraints(
        minHeight: header
            ? 34
            : total
            ? 36
            : 34,
      ),
      color: header
          ? context.appColors.surfaceContainerHighest
          : total
          ? context.appColors.surfaceContainerHighest
          : alternate
          ? context.appColors.surfaceContainerHighest
          : context.cardBackgroundColor,
      child: Row(
        children: List.generate(values.length, (index) {
          Color valueColor = _text;

          if (!header && index == 1) {
            valueColor = _primaryDark;
          } else if (!header && index == 4) {
            valueColor = _blue;
          } else if (!header && index == 7) {
            valueColor = _purple;
          }

          return Container(
            width: widths[index],
            constraints: BoxConstraints(
              minHeight: header
                  ? 34
                  : total
                  ? 36
                  : 34,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: index == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: _border, width: .55),
                bottom: BorderSide(color: _border, width: .55),
              ),
            ),
            child: index == 0 && rank != null && !header && !total
                ? Row(
                    children: [
                      _employeeRankBadge(rank: rank),
                      SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          values[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _text,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    values[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: index == 0 ? TextAlign.left : TextAlign.right,
                    style: TextStyle(
                      color: header ? context.secondaryTextColor : valueColor,
                      fontSize: header ? 7.5 : 8,
                      fontWeight: header || total || index == 0
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // EMPLOYEE RANK BADGE
  // ============================================================

  Widget _employeeRankBadge({required int rank}) {
    Color background;
    Color foreground;

    if (rank == 1) {
      background = context.appColors.tertiary.withValues(alpha: 0.12);
      foreground = context.appColors.tertiary;
    } else if (rank == 2) {
      background = context.appColors.surfaceContainerHighest;
      foreground = context.secondaryTextColor;
    } else if (rank == 3) {
      background = context.appColors.tertiary.withValues(alpha: 0.12);
      foreground = context.appColors.tertiary;
    } else {
      background = context.appColors.surfaceContainerHighest;
      foreground = _muted;
    }

    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        '$rank',
        style: TextStyle(
          color: foreground,
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ============================================================
  // TOP EMPLOYEE EMPTY
  // ============================================================

  Widget _topEmployeeEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.groups_2_outlined, color: _purple, size: 19),
          ),
          SizedBox(height: 7),
          Text(
            'No Employee Data Found',
            style: TextStyle(
              color: _text,
              fontSize: 9.8,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 3),
          Text(
            'No employee visit contribution was found for the selected period.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 7.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMON TABLE ROW
  // ============================================================

  Widget _tableRow({
    required List<String> values,
    required List<double> widths,
    bool header = false,
    bool total = false,
    bool alternate = false,
    bool firstBold = false,
  }) {
    return Container(
      height: header
          ? 34
          : total
          ? 36
          : 32,

      color: header
          ? context.appColors.surfaceContainerHighest
          : total
          ? context.appColors.surfaceContainerHighest
          : alternate
          ? context.appColors.surfaceContainerHighest
          : context.cardBackgroundColor,

      child: Row(
        children: List.generate(values.length, (index) {
          return Container(
            width: widths[index],

            height: double.infinity,

            alignment: index == 0 ? Alignment.centerLeft : Alignment.center,

            padding: const EdgeInsets.symmetric(horizontal: 7),

            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: _border, width: .6),

                bottom: BorderSide(color: _border, width: .6),
              ),
            ),

            child: Text(
              values[index],

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              textAlign: index == 0 ? TextAlign.left : TextAlign.center,

              style: TextStyle(
                color: header
                    ? context.secondaryTextColor
                    : index == 4
                    ? _blue
                    : _text,

                fontSize: header ? 7.7 : 8.2,

                fontWeight: header || total || (firstBold && index == 0)
                    ? FontWeight.w800
                    : FontWeight.w500,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // HOUR TABLE ROW
  // ============================================================

  Widget _hourTableRow({
    required List<String> values,
    required List<double> widths,
    bool header = false,
    bool total = false,
    bool alternate = false,
  }) {
    return Container(
      height: header
          ? 34
          : total
          ? 36
          : 31,

      color: header
          ? context.appColors.surfaceContainerHighest
          : total
          ? context.appColors.surfaceContainerHighest
          : alternate
          ? context.appColors.surfaceContainerHighest
          : context.cardBackgroundColor,

      child: Row(
        children: List.generate(values.length, (index) {
          Color valueColor = _text;

          if (!header && (index == 1 || index == 3)) {
            valueColor = _primaryDark;
          }

          if (!header && (index == 4 || index == 6)) {
            valueColor = _blue;
          }

          return Container(
            width: widths[index],

            height: double.infinity,

            alignment: index == 0 ? Alignment.centerLeft : Alignment.center,

            padding: const EdgeInsets.symmetric(horizontal: 7),

            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: _border, width: .55),

                bottom: BorderSide(color: _border, width: .55),
              ),
            ),

            child: Text(
              values[index],

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              textAlign: index == 0 ? TextAlign.left : TextAlign.center,

              style: TextStyle(
                color: header ? context.secondaryTextColor : valueColor,

                fontSize: header ? 7.6 : 8,

                fontWeight: header || total ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // NO RECORD CHECK
  // ============================================================

  bool _isNoRecordsMessage(String? message) {
    final String normalized = (message ?? '').toLowerCase().replaceAll(
      RegExp(r'[^a-z]'),
      '',
    );

    return const [
      'norecordfound',
      'norecordsfound',
      'nodatafound',
      'recordnotfound',
    ].contains(normalized);
  }

  // ============================================================
  // EMPTY DATA
  // ============================================================

  Widget _emptyData(String message) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.08),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(Icons.inbox_outlined, color: _muted, size: 20),
          ),

          SizedBox(height: 8),

          Text(
            'No Data Found',

            style: TextStyle(
              color: _text,

              fontSize: 10,

              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 3),

          Text(
            message,

            textAlign: TextAlign.center,

            style: TextStyle(
              color: _muted,

              fontSize: 7.5,

              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 7),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),

            decoration: BoxDecoration(
              color: context.appColors.surfaceContainerHighest,

              borderRadius: BorderRadius.circular(5),

              border: Border.all(color: _border),
            ),

            child: Text(
              'Try changing employee or date range',

              style: TextStyle(
                color: _muted,

                fontSize: 6.7,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _loadingCard(String message) {
    return Container(
      height: 76,

      decoration: _cardDecoration(),

      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,

          children: [
            SizedBox(
              width: 18,
              height: 18,

              child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
            ),

            SizedBox(width: 8),

            Text(
              message,

              style: TextStyle(
                color: _muted,

                fontSize: 9,

                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(11),

      decoration: _cardDecoration(),

      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,

            color: context.appColors.error,

            size: 18,
          ),

          SizedBox(width: 7),

          Expanded(
            child: Text(
              message,

              style: TextStyle(
                color: _text,

                fontSize: 9,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          TextButton(
            onPressed: _loadReport,

            child: Text('Retry', style: TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  Widget _iconBox(IconData icon, Color color, {double size = 34}) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),

        borderRadius: BorderRadius.circular(8),
      ),

      child: Icon(icon, color: color, size: size * .5),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: context.cardBackgroundColor,

      borderRadius: BorderRadius.circular(12),

      border: Border.all(color: _border),

      boxShadow: [
        BoxShadow(
          color: context.appColors.shadow.withValues(alpha: .02),

          blurRadius: 8,

          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
