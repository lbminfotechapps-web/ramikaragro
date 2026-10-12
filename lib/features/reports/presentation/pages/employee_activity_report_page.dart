import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import 'package:solufine/features/reports/domain/entities/assign_employee.dart';
import 'package:solufine/features/reports/domain/entities/employee_activity.dart';

import '../bloc/employee_activity_bloc.dart';
import '../bloc/employee_activity_event.dart';
import '../bloc/employee_activity_state.dart';

import '../bloc/employee_output_bloc.dart';
import '../bloc/employee_output_event.dart';
import '../bloc/employee_output_state.dart';

import '../widgets/activity_summary_card.dart';
import '../widgets/activity_timeline_item.dart';

class EmployeeActivityReportPage extends StatefulWidget {
  final String userId;

  const EmployeeActivityReportPage({super.key, required this.userId});

  @override
  State<EmployeeActivityReportPage> createState() =>
      _EmployeeActivityReportPageState();
}

class _EmployeeActivityReportPageState
    extends State<EmployeeActivityReportPage> {
  // ============================================================
  // DATE
  // ============================================================

  DateTime _selectedDate = DateTime.now();

  // ============================================================
  // FILTER
  // ============================================================

  bool _filterExpanded = false;

  // ============================================================
  // LOGIN EMPLOYEE
  // ============================================================

  String _loginEmployeeId = '';
  String _loginEmployeeName = '';

  bool _loginEmployeeLoaded = false;

  // ============================================================
  // SELECTED EMPLOYEE
  // ============================================================

  String _selectedEmployeeId = '';
  String _selectedEmployeeName = '';

  final TextEditingController _employeeController = TextEditingController();

  final FocusNode _employeeFocusNode = FocusNode();

  Timer? _employeeSearchTimer;

  bool _showEmployeeList = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadLoginEmployee();
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _employeeSearchTimer?.cancel();
    _employeeController.dispose();
    _employeeFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD LOGIN EMPLOYEE
  // ============================================================

  Future<void> _loadLoginEmployee() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      if (!mounted) return;

      final String storageUserId =
          userData?['user_id']?.toString().trim() ?? '';

      final String storageUserName =
          userData?['user_name']?.toString().trim() ?? '';

      // Route ID gets priority.
      final String loginId = widget.userId.trim().isNotEmpty
          ? widget.userId.trim()
          : storageUserId;

      final String loginName = storageUserName.isNotEmpty
          ? storageUserName
          : 'Logged-in Employee';

      setState(() {
        _loginEmployeeId = loginId;

        _loginEmployeeName = loginName;

        // ----------------------------------------
        // DEFAULT EMPLOYEE = LOGIN EMPLOYEE
        // ----------------------------------------

        _selectedEmployeeId = loginId;

        _selectedEmployeeName = loginName;

        _employeeController.text = loginName;

        _loginEmployeeLoaded = true;
      });

      debugPrint('==========================================');
      debugPrint('LOGIN EMPLOYEE');
      debugPrint('ID   : $_loginEmployeeId');
      debugPrint('NAME : $_loginEmployeeName');
      debugPrint('==========================================');

      _fetchActivities();
    } catch (e) {
      debugPrint('LOGIN EMPLOYEE ERROR => $e');

      if (!mounted) return;

      setState(() {
        _loginEmployeeId = widget.userId.trim();

        _loginEmployeeName = 'Logged-in Employee';

        _selectedEmployeeId = _loginEmployeeId;

        _selectedEmployeeName = _loginEmployeeName;

        _employeeController.text = _loginEmployeeName;

        _loginEmployeeLoaded = true;
      });

      _fetchActivities();
    }
  }

  // ============================================================
  // FETCH ACTIVITY
  // ============================================================

  void _fetchActivities() {
    if (!mounted) return;

    final String searchDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    debugPrint('==========================================');
    debugPrint('EMPLOYEE ACTIVITY REQUEST');
    debugPrint('LOGIN USER ID    : ${widget.userId}');
    debugPrint('EMPLOYEE USER ID : $_selectedEmployeeId');
    debugPrint('EMPLOYEE NAME    : $_selectedEmployeeName');
    debugPrint('DATE             : $searchDate');
    debugPrint('==========================================');

    context.read<EmployeeActivityBloc>().add(
      GetEmployeeActivityEvent(
        // Selected employee ID.
        //
        // Empty = all employees.
        userId: _selectedEmployeeId,

        searchDate: searchDate,

        // Login/current user.
        logUserId: widget.userId,
      ),
    );
  }

  // ============================================================
  // OPEN / CLOSE FILTER
  // ============================================================

  void _toggleFilter() {
    FocusScope.of(context).unfocus();

    setState(() {
      _filterExpanded = !_filterExpanded;

      if (!_filterExpanded) {
        _showEmployeeList = false;
      }
    });
  }

  // ============================================================
  // LOAD EMPLOYEE
  // ============================================================

  void _loadEmployees({String? search}) {
    if (!mounted) return;

    final String value = search ?? _employeeController.text.trim();

    context.read<EmployeeOutputBloc>().add(
      SearchEmployeesEvent(logUserId: widget.userId, search: value),
    );
  }

  // ============================================================
  // EMPLOYEE FIELD TAP
  // ============================================================

  void _onEmployeeFieldTap() {
    setState(() {
      _showEmployeeList = true;
    });

    _loadEmployees();
  }

  // ============================================================
  // EMPLOYEE SEARCH
  // ============================================================

  void _searchEmployee(String value) {
    _employeeSearchTimer?.cancel();

    final String search = value.trim();

    // User started manually changing employee.
    if (_selectedEmployeeId.isNotEmpty && search != _selectedEmployeeName) {
      setState(() {
        _selectedEmployeeId = '';

        _selectedEmployeeName = '';

        _showEmployeeList = true;
      });
    } else {
      setState(() {
        _showEmployeeList = true;
      });
    }

    // Empty field can represent All Employees.
    if (search.isEmpty) {
      _selectedEmployeeId = '';

      _selectedEmployeeName = 'All Employees';

      _loadEmployees(search: '');

      return;
    }

    _employeeSearchTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      _loadEmployees(search: search);
    });
  }

  // ============================================================
  // SELECT EMPLOYEE
  // ============================================================

  void _selectEmployee(AssignEmployee employee) {
    final String id = employee.fldId.toString().trim();

    final String name = employee.fldAdmName.trim();

    if (id.isEmpty ||
        name.isEmpty ||
        id.toLowerCase() == 'null' ||
        name.toLowerCase() == 'null') {
      return;
    }

    setState(() {
      _selectedEmployeeId = id;

      _selectedEmployeeName = name;

      _employeeController.text = name;

      _employeeController.selection = TextSelection.collapsed(
        offset: name.length,
      );

      _showEmployeeList = false;
    });

    context.read<EmployeeOutputBloc>().add(
      const ClearEmployeeSuggestionsEvent(),
    );

    FocusScope.of(context).unfocus();

    debugPrint(
      'EMPLOYEE SELECTED => '
      'ID=$id | NAME=$name',
    );
  }

  // ============================================================
  // CLEAR EMPLOYEE
  // ============================================================

  void _clearEmployee() {
    _employeeSearchTimer?.cancel();

    setState(() {
      _employeeController.clear();

      _selectedEmployeeId = '';

      _selectedEmployeeName = 'All Employees';

      _showEmployeeList = true;
    });

    _loadEmployees(search: '');

    _employeeFocusNode.requestFocus();
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,

      initialDate: _selectedDate,

      firstDate: DateTime(2020),

      lastDate: DateTime(2100),

      helpText: 'Select Activity Date',

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: context.appColors),

          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;

      _showEmployeeList = false;
    });
  }

  String get _displayDate => DateFormat('dd-MM-yyyy').format(_selectedDate);

  String get _dayName => DateFormat('EEEE').format(_selectedDate);

  // ============================================================
  // SEARCH REPORT
  // ============================================================

  void _searchReport() {
    FocusScope.of(context).unfocus();

    // User typed a name but did not select
    // employee from suggestion.
    if (_employeeController.text.trim().isNotEmpty &&
        _selectedEmployeeId.isEmpty &&
        _selectedEmployeeName != 'All Employees') {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select employee from the list'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    context.read<EmployeeOutputBloc>().add(
      const ClearEmployeeSuggestionsEvent(),
    );

    setState(() {
      _showEmployeeList = false;

      _filterExpanded = false;
    });

    _fetchActivities();
  }

  // ============================================================
  // RESET
  // ============================================================

  void _resetFilter() {
    _employeeSearchTimer?.cancel();

    setState(() {
      // ----------------------------------------
      // RESET TO LOGIN EMPLOYEE
      // ----------------------------------------

      _selectedEmployeeId = _loginEmployeeId;

      _selectedEmployeeName = _loginEmployeeName;

      _employeeController.text = _loginEmployeeName;

      _selectedDate = DateTime.now();

      _showEmployeeList = false;

      _filterExpanded = false;
    });

    context.read<EmployeeOutputBloc>().add(
      const ClearEmployeeSuggestionsEvent(),
    );

    FocusScope.of(context).unfocus();

    _fetchActivities();
  }

  // ============================================================
  // COUNT
  // ============================================================

  int _countActivity(List<EmployeeActivity> activities, String value) {
    final String search = value.toUpperCase();

    int count = 0;

    for (final item in activities) {
      try {
        final String activityName = item.activityName.toString().trim();

        if (activityName.isEmpty || activityName.toLowerCase() == 'null') {
          continue;
        }

        if (activityName.toUpperCase().contains(search)) {
          count++;
        }
      } catch (_) {
        // Ignore malformed activity.
      }
    }

    return count;
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _onRefresh() async {
    _fetchActivities();

    await context.read<EmployeeActivityBloc>().stream.firstWhere(
      (state) =>
          state.status == EmployeeActivityStatus.success ||
          state.status == EmployeeActivityStatus.failure,
    );
  }

  // ============================================================
  // EMPLOYEE LIST
  // ============================================================

  Widget _buildEmployeeList(EmployeeOutputState state) {
    if (state.employeeLoading) {
      return Padding(
        padding: EdgeInsets.only(top: 6),
        child: LinearProgressIndicator(
          minHeight: 2,
          color: context.primaryColor,
        ),
      );
    }

    if (!_showEmployeeList) {
      return const SizedBox.shrink();
    }

    if (state.employees.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.appColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 18,
              color: context.secondaryTextColor,
            ),
            SizedBox(width: 7),
            Text(
              'No employee found',
              style: TextStyle(
                fontSize: 11.5,
                color: context.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 5),
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: context.borderColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state.employees.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final AssignEmployee employee = state.employees[index];

          final String id = employee.fldId.toString().trim();

          final String name = employee.fldAdmName.trim();

          if (name.isEmpty) {
            return const SizedBox.shrink();
          }

          final bool selected = id == _selectedEmployeeId;

          return InkWell(
            onTap: () => _selectEmployee(employee),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: context.primaryColor.withValues(
                      alpha: 0.08,
                    ),
                    child: Text(
                      name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: context.primaryTextColor,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 17,
                      color: context.primaryColor,
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 17,
                      color: context.secondaryTextColor,
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
  // FILTER UI
  // ============================================================

  Widget _buildFilter() {
    return BlocBuilder<EmployeeOutputBloc, EmployeeOutputState>(
      builder: (context, employeeState) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: context.appColors.shadow.withValues(alpha: 0.035),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ================================================
              // FILTER HEADER
              // ================================================
              InkWell(
                onTap: _toggleFilter,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.filter_alt_outlined,
                          size: 17,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter Activity',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: context.primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '${_selectedEmployeeName.isEmpty ? 'All Employees' : _selectedEmployeeName} • $_displayDate',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: context.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _filterExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 21,
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================================================
              // OPEN FILTER
              // ================================================
              if (_filterExpanded) ...[
                Divider(height: 1, color: context.borderColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========================================
                      // EMPLOYEE
                      // ========================================
                      const _FilterLabel(
                        icon: Icons.person_outline_rounded,
                        title: 'Employee',
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _employeeController,
                        focusNode: _employeeFocusNode,
                        onTap: _onEmployeeFieldTap,
                        onChanged: _searchEmployee,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Search employee',
                          filled: true,
                          fillColor: context.appColors.surfaceContainerHighest,
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: context.primaryColor,
                          ),
                          suffixIcon: _employeeController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: _clearEmployee,
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(Icons.close_rounded, size: 17),
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(
                            color: context.primaryColor,
                          ),
                        ),
                      ),

                      _buildEmployeeList(employeeState),

                      const SizedBox(height: 9),

                      // ========================================
                      // DATE
                      // ========================================
                      const _FilterLabel(
                        icon: Icons.calendar_month_outlined,
                        title: 'Activity Date',
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: context.appColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 17,
                                color: context.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$_displayDate  •  $_dayName',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: context.primaryTextColor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 19,
                                color: context.secondaryTextColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 9),

                      // ========================================
                      // BUTTONS
                      // ========================================
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _resetFilter,
                              icon: Icon(Icons.restart_alt_rounded, size: 16),
                              label: Text('Reset'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.secondaryTextColor,
                                minimumSize: const Size(0, 39),
                                padding: EdgeInsets.zero,
                                side: BorderSide(color: context.borderColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _searchReport,
                              icon: Icon(Icons.search_rounded, size: 16),
                              label: Text('Search'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primaryColor,
                                foregroundColor: context.onPrimaryColor,
                                elevation: 0,
                                minimumSize: const Size(0, 39),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  OutlineInputBorder _inputBorder({Color? color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: color ?? context.borderColor),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (!_loginEmployeeLoaded) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: CustomAppBar(
          backgroundColor: context.primaryColor,
          titleStyle: TextStyle(color: context.onPrimaryColor),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: context.onPrimaryColor,
            ),
            onPressed: () => context.go(AppRouter.home),
          ),
          title: 'Employee Activity',
          showBackButton: true,
          onBackTap: () => context.go(AppRouter.home),
        ),
        body: const _LoadingView(),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,

      appBar: CustomAppBar(
        backgroundColor: context.primaryColor,
        titleStyle: TextStyle(color: context.onPrimaryColor),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: context.onPrimaryColor,
          ),
          onPressed: () => context.go(AppRouter.home),
        ),
        title: 'Employee Activity',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
        actionIcon: Icons.refresh_rounded,
        onActionIconTap: _fetchActivities,
      ),

      body: BlocBuilder<EmployeeActivityBloc, EmployeeActivityState>(
        builder: (context, state) {
          final List<EmployeeActivity> activities = state.activities;

          return Column(
            children: [
              _buildFilter(),

              const SizedBox(height: 4),

              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.status == EmployeeActivityStatus.loading) {
                      return const _LoadingView();
                    }

                    if (state.status == EmployeeActivityStatus.failure) {
                      return _ErrorView(
                        message: state.errorMessage ?? 'Something went wrong',
                        onRetry: _fetchActivities,
                      );
                    }

                    if (activities.isEmpty) {
                      return RefreshIndicator(
                        color: context.primaryColor,
                        onRefresh: _onRefresh,
                        child: const _EmptyView(),
                      );
                    }

                    return RefreshIndicator(
                      color: context.primaryColor,
                      onRefresh: _onRefresh,
                      child: _ActivityContent(
                        employeeName: _selectedEmployeeName.isEmpty
                            ? 'All Employees'
                            : _selectedEmployeeName,
                        displayDate: _displayDate,
                        dayName: _dayName,
                        activities: activities,
                        countIn: _countActivity(activities, 'IN PUNCH'),
                        countOut: _countActivity(activities, 'OUT PUNCH'),
                        countFarmer: _countActivity(activities, 'FARMER'),
                        countDealer: _countActivity(activities, 'DEALER'),
                        countLocation: _countActivity(
                          activities,
                          'SHARE LOCATION',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// FILTER LABEL
// ============================================================================

class _FilterLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FilterLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.primaryColor),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.secondaryTextColor,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ACTIVITY CONTENT
// ============================================================================

class _ActivityContent extends StatelessWidget {
  final String employeeName;
  final String displayDate;
  final String dayName;

  final List<EmployeeActivity> activities;

  final int countIn;
  final int countOut;
  final int countFarmer;
  final int countDealer;
  final int countLocation;

  const _ActivityContent({
    required this.employeeName,
    required this.displayDate,
    required this.dayName,
    required this.activities,
    required this.countIn,
    required this.countOut,
    required this.countFarmer,
    required this.countDealer,
    required this.countLocation,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),

      children: [
        // ======================================================
        // SELECTED EMPLOYEE - COMPACT
        // ======================================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primaryColor.withValues(alpha: 0.08),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 17,
                  color: context.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: context.primaryTextColor,
                      ),
                    ),
                    Text(
                      '$displayDate • $dayName',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ======================================================
        // SUMMARY
        // ======================================================
        Text(
          'Activity Summary',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.primaryTextColor,
          ),
        ),

        const SizedBox(height: 7),

        SizedBox(
          height: 55.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              ActivitySummaryCard(
                title: 'IN Punch',
                count: countIn,
                icon: Icons.login_rounded,
                color: context.primaryColor,
              ),
              const SizedBox(width: 8),
              ActivitySummaryCard(
                title: 'OUT Punch',
                count: countOut,
                icon: Icons.logout_rounded,
                color: context.appColors.error,
              ),
              const SizedBox(width: 8),
              ActivitySummaryCard(
                title: 'Farmer Visit',
                count: countFarmer,
                icon: Icons.agriculture_rounded,
                color: context.appColors.secondary,
              ),
              const SizedBox(width: 8),
              ActivitySummaryCard(
                title: 'Dealer Visit',
                count: countDealer,
                icon: Icons.storefront_rounded,
                color: context.appColors.secondary,
              ),
              const SizedBox(width: 8),
              ActivitySummaryCard(
                title: 'Location',
                count: countLocation,
                icon: Icons.location_on_rounded,
                color: context.appColors.tertiary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // ======================================================
        // TIMELINE HEADER
        // ======================================================
        Row(
          children: [
            Expanded(
              child: Text(
                'Activity Timeline',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.primaryTextColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${activities.length} Activities',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ======================================================
        // TIMELINE
        // ======================================================
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final EmployeeActivity activity = activities[index];

            return ActivityTimelineItem(
              activity: activity,
              isFirst: index == 0,
              isLast: index == activities.length - 1,
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// LOADING
// ============================================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: context.primaryColor,
        strokeWidth: 2.5,
      ),
    );
  }
}

// ============================================================================
// EMPTY
// ============================================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        SizedBox(height: 65),
        Icon(Icons.event_busy_rounded, size: 48, color: context.primaryColor),
        SizedBox(height: 12),
        Center(
          child: Text(
            'No Activity Found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: context.primaryTextColor,
            ),
          ),
        ),
        SizedBox(height: 5),
        Center(
          child: Text(
            'No activity found for selected employee and date.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: context.secondaryTextColor),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ERROR
// ============================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 45,
              color: context.appColors.error,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: 17),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimaryColor,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
