import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
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

  const EmployeeActivityReportPage({
    super.key,
    required this.userId,
  });

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

  final TextEditingController _employeeController =
      TextEditingController();

  final FocusNode _employeeFocusNode =
      FocusNode();

  Timer? _employeeSearchTimer;

  bool _showEmployeeList = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) return;

        _loadLoginEmployee();
      },
    );
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
      final userData =
          await SecureStorage.instance.getUserData();

      if (!mounted) return;

      final String storageUserId =
          userData?['user_id']
                  ?.toString()
                  .trim() ??
              '';

      final String storageUserName =
          userData?['user_name']
                  ?.toString()
                  .trim() ??
              '';

      // Route ID gets priority.
      final String loginId =
          widget.userId.trim().isNotEmpty
              ? widget.userId.trim()
              : storageUserId;

      final String loginName =
          storageUserName.isNotEmpty
              ? storageUserName
              : 'Logged-in Employee';

      setState(() {
        _loginEmployeeId =
            loginId;

        _loginEmployeeName =
            loginName;

        // ----------------------------------------
        // DEFAULT EMPLOYEE = LOGIN EMPLOYEE
        // ----------------------------------------

        _selectedEmployeeId =
            loginId;

        _selectedEmployeeName =
            loginName;

        _employeeController.text =
            loginName;

        _loginEmployeeLoaded =
            true;
      });

      debugPrint(
        '==========================================',
      );
      debugPrint(
        'LOGIN EMPLOYEE',
      );
      debugPrint(
        'ID   : $_loginEmployeeId',
      );
      debugPrint(
        'NAME : $_loginEmployeeName',
      );
      debugPrint(
        '==========================================',
      );

      _fetchActivities();
    } catch (e) {
      debugPrint(
        'LOGIN EMPLOYEE ERROR => $e',
      );

      if (!mounted) return;

      setState(() {
        _loginEmployeeId =
            widget.userId.trim();

        _loginEmployeeName =
            'Logged-in Employee';

        _selectedEmployeeId =
            _loginEmployeeId;

        _selectedEmployeeName =
            _loginEmployeeName;

        _employeeController.text =
            _loginEmployeeName;

        _loginEmployeeLoaded =
            true;
      });

      _fetchActivities();
    }
  }

  // ============================================================
  // FETCH ACTIVITY
  // ============================================================

  void _fetchActivities() {
    if (!mounted) return;

    final String searchDate =
        DateFormat(
      'yyyy-MM-dd',
    ).format(
      _selectedDate,
    );

    debugPrint(
      '==========================================',
    );
    debugPrint(
      'EMPLOYEE ACTIVITY REQUEST',
    );
    debugPrint(
      'LOGIN USER ID    : ${widget.userId}',
    );
    debugPrint(
      'EMPLOYEE USER ID : $_selectedEmployeeId',
    );
    debugPrint(
      'EMPLOYEE NAME    : $_selectedEmployeeName',
    );
    debugPrint(
      'DATE             : $searchDate',
    );
    debugPrint(
      '==========================================',
    );

    context
        .read<EmployeeActivityBloc>()
        .add(
          GetEmployeeActivityEvent(
            // Selected employee ID.
            //
            // Empty = all employees.
            userId:
                _selectedEmployeeId,

            searchDate:
                searchDate,

            // Login/current user.
            logUserId:
                widget.userId,
          ),
        );
  }

  // ============================================================
  // OPEN / CLOSE FILTER
  // ============================================================

  void _toggleFilter() {
    FocusScope.of(context)
        .unfocus();

    setState(() {
      _filterExpanded =
          !_filterExpanded;

      if (!_filterExpanded) {
        _showEmployeeList =
            false;
      }
    });
  }

  // ============================================================
  // LOAD EMPLOYEE
  // ============================================================

  void _loadEmployees({
    String? search,
  }) {
    if (!mounted) return;

    final String value =
        search ??
            _employeeController.text
                .trim();

    context
        .read<EmployeeOutputBloc>()
        .add(
          SearchEmployeesEvent(
            logUserId:
                widget.userId,

            search:
                value,
          ),
        );
  }

  // ============================================================
  // EMPLOYEE FIELD TAP
  // ============================================================

  void _onEmployeeFieldTap() {
    setState(() {
      _showEmployeeList =
          true;
    });

    _loadEmployees();
  }

  // ============================================================
  // EMPLOYEE SEARCH
  // ============================================================

  void _searchEmployee(
    String value,
  ) {
    _employeeSearchTimer?.cancel();

    final String search =
        value.trim();

    // User started manually changing employee.
    if (_selectedEmployeeId.isNotEmpty &&
        search != _selectedEmployeeName) {
      setState(() {
        _selectedEmployeeId =
            '';

        _selectedEmployeeName =
            '';

        _showEmployeeList =
            true;
      });
    } else {
      setState(() {
        _showEmployeeList =
            true;
      });
    }

    // Empty field can represent All Employees.
    if (search.isEmpty) {
      _selectedEmployeeId =
          '';

      _selectedEmployeeName =
          'All Employees';

      _loadEmployees(
        search: '',
      );

      return;
    }

    _employeeSearchTimer =
        Timer(
      const Duration(
        milliseconds: 400,
      ),
      () {
        if (!mounted) return;

        _loadEmployees(
          search:
              search,
        );
      },
    );
  }

  // ============================================================
  // SELECT EMPLOYEE
  // ============================================================

  void _selectEmployee(
    AssignEmployee employee,
  ) {
    final String id =
        employee.fldId
            .toString()
            .trim();

    final String name =
        employee.fldAdmName
            .trim();

    if (id.isEmpty ||
        name.isEmpty ||
        id.toLowerCase() ==
            'null' ||
        name.toLowerCase() ==
            'null') {
      return;
    }

    setState(() {
      _selectedEmployeeId =
          id;

      _selectedEmployeeName =
          name;

      _employeeController.text =
          name;

      _employeeController.selection =
          TextSelection.collapsed(
        offset:
            name.length,
      );

      _showEmployeeList =
          false;
    });

    context
        .read<EmployeeOutputBloc>()
        .add(
          const ClearEmployeeSuggestionsEvent(),
        );

    FocusScope.of(context)
        .unfocus();

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

      _selectedEmployeeId =
          '';

      _selectedEmployeeName =
          'All Employees';

      _showEmployeeList =
          true;
    });

    _loadEmployees(
      search: '',
    );

    _employeeFocusNode.requestFocus();
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? picked =
        await showDatePicker(
      context:
          context,

      initialDate:
          _selectedDate,

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime(2100),

      helpText:
          'Select Activity Date',

      builder:
          (
        context,
        child,
      ) {
        return Theme(
          data:
              Theme.of(
            context,
          ).copyWith(
            colorScheme:
                ColorScheme.fromSeed(
              seedColor:
                  const Color(
                0xFF168A45,
              ),
            ),
          ),

          child:
              child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedDate =
          picked;

      _showEmployeeList =
          false;
    });
  }

  String get _displayDate =>
      DateFormat(
        'dd-MM-yyyy',
      ).format(
        _selectedDate,
      );

  String get _dayName =>
      DateFormat(
        'EEEE',
      ).format(
        _selectedDate,
      );

  // ============================================================
  // SEARCH REPORT
  // ============================================================

  void _searchReport() {
    FocusScope.of(context)
        .unfocus();

    // User typed a name but did not select
    // employee from suggestion.
    if (_employeeController.text
            .trim()
            .isNotEmpty &&
        _selectedEmployeeId.isEmpty &&
        _selectedEmployeeName !=
            'All Employees') {
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Please select employee from the list',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      return;
    }

    context
        .read<EmployeeOutputBloc>()
        .add(
          const ClearEmployeeSuggestionsEvent(),
        );

    setState(() {
      _showEmployeeList =
          false;

      _filterExpanded =
          false;
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

      _selectedEmployeeId =
          _loginEmployeeId;

      _selectedEmployeeName =
          _loginEmployeeName;

      _employeeController.text =
          _loginEmployeeName;

      _selectedDate =
          DateTime.now();

      _showEmployeeList =
          false;

      _filterExpanded =
          false;
    });

    context
        .read<EmployeeOutputBloc>()
        .add(
          const ClearEmployeeSuggestionsEvent(),
        );

    FocusScope.of(context)
        .unfocus();

    _fetchActivities();
  }

  // ============================================================
  // COUNT
  // ============================================================

  int _countActivity(
    List<EmployeeActivity>
        activities,
    String value,
  ) {
    final String search =
        value.toUpperCase();

    int count = 0;

    for (final item
        in activities) {
      try {
        final String activityName =
            item.activityName
                .toString()
                .trim();

        if (activityName.isEmpty ||
            activityName
                    .toLowerCase() ==
                'null') {
          continue;
        }

        if (activityName
            .toUpperCase()
            .contains(
              search,
            )) {
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

    await context
        .read<
            EmployeeActivityBloc>()
        .stream
        .firstWhere(
          (state) =>
              state.status ==
                  EmployeeActivityStatus
                      .success ||
              state.status ==
                  EmployeeActivityStatus
                      .failure,
        );
  }

  // ============================================================
  // EMPLOYEE LIST
  // ============================================================

  Widget _buildEmployeeList(
    EmployeeOutputState state,
  ) {
    if (state.employeeLoading) {
      return const Padding(
        padding:
            EdgeInsets.only(
          top: 6,
        ),
        child:
            LinearProgressIndicator(
          minHeight:
              2,
          color:
              Color(
            0xFF168A45,
          ),
        ),
      );
    }

    if (!_showEmployeeList) {
      return const SizedBox
          .shrink();
    }

    if (state.employees.isEmpty) {
      return Container(
        margin:
            const EdgeInsets.only(
          top: 5,
        ),
        padding:
            const EdgeInsets.all(
          10,
        ),
        decoration:
            BoxDecoration(
          color:
              const Color(
            0xFFF7F9F8,
          ),
          borderRadius:
              BorderRadius.circular(
            8,
          ),
        ),
        child:
            const Row(
          children: [
            Icon(
              Icons
                  .person_search_outlined,
              size:
                  18,
              color:
                  Color(
                0xFF7A827D,
              ),
            ),
            SizedBox(
              width:
                  7,
            ),
            Text(
              'No employee found',
              style:
                  TextStyle(
                fontSize:
                    11.5,
                color:
                    Color(
                  0xFF7A827D,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin:
          const EdgeInsets.only(
        top: 5,
      ),
      constraints:
          const BoxConstraints(
        maxHeight:
            180,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          9,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFE4EAE6,
          ),
        ),
      ),
      child:
          ListView.separated(
        shrinkWrap:
            true,
        padding:
            EdgeInsets.zero,
        itemCount:
            state.employees.length,
        separatorBuilder:
            (
          _,
          __,
        ) =>
                const Divider(
          height:
              1,
        ),
        itemBuilder:
            (
          context,
          index,
        ) {
          final AssignEmployee employee =
              state.employees[
                  index];

          final String id =
              employee.fldId
                  .toString()
                  .trim();

          final String name =
              employee.fldAdmName
                  .trim();

          if (name.isEmpty) {
            return const SizedBox
                .shrink();
          }

          final bool selected =
              id ==
                  _selectedEmployeeId;

          return InkWell(
            onTap:
                () =>
                    _selectEmployee(
              employee,
            ),
            child:
                Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    10,
                vertical:
                    8,
              ),
              child:
                  Row(
                children: [
                  CircleAvatar(
                    radius:
                        14,
                    backgroundColor:
                        const Color(
                      0xFFE8F5EC,
                    ),
                    child:
                        Text(
                      name[0]
                          .toUpperCase(),
                      style:
                          const TextStyle(
                        fontSize:
                            10,
                        fontWeight:
                            FontWeight
                                .w800,
                        color:
                            Color(
                          0xFF168A45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width:
                        8,
                  ),
                  Expanded(
                    child:
                        Text(
                      name,
                      maxLines:
                          1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          TextStyle(
                        fontSize:
                            12,
                        fontWeight:
                            selected
                                ? FontWeight
                                    .w700
                                : FontWeight
                                    .w500,
                        color:
                            const Color(
                          0xFF303934,
                        ),
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons
                          .check_circle_rounded,
                      size:
                          17,
                      color:
                          Color(
                        0xFF168A45,
                      ),
                    )
                  else
                    const Icon(
                      Icons
                          .chevron_right_rounded,
                      size:
                          17,
                      color:
                          Color(
                        0xFF9AA19D,
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
  // FILTER UI
  // ============================================================

  Widget _buildFilter() {
    return BlocBuilder<
        EmployeeOutputBloc,
        EmployeeOutputState>(
      builder:
          (
        context,
        employeeState,
      ) {
        return Container(
          margin:
              const EdgeInsets.fromLTRB(
            12,
            10,
            12,
            0,
          ),
          decoration:
              BoxDecoration(
            color:
                Colors.white,
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black
                        .withOpacity(
                  0.035,
                ),
                blurRadius:
                    6,
                offset:
                    const Offset(
                  0,
                  2,
                ),
              ),
            ],
          ),
          child:
              Column(
            children: [
              // ================================================
              // FILTER HEADER
              // ================================================

              InkWell(
                onTap:
                    _toggleFilter,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                child:
                    Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal:
                        11,
                    vertical:
                        9,
                  ),
                  child:
                      Row(
                    children: [
                      Container(
                        height:
                            32,
                        width:
                            32,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFE8F5EC,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            8,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons
                              .filter_alt_outlined,
                          size:
                              17,
                          color:
                              Color(
                            0xFF168A45,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width:
                            8,
                      ),
                      Expanded(
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Filter Activity',
                              style:
                                  TextStyle(
                                fontSize:
                                    13,
                                fontWeight:
                                    FontWeight.w800,
                                color:
                                    Color(
                                  0xFF202522,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height:
                                  1,
                            ),
                            Text(
                              '${_selectedEmployeeName.isEmpty ? 'All Employees' : _selectedEmployeeName} • $_displayDate',
                              maxLines:
                                  1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                fontSize:
                                    10,
                                color:
                                    Color(
                                  0xFF7A827D,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns:
                            _filterExpanded
                                ? 0.5
                                : 0,
                        duration:
                            const Duration(
                          milliseconds:
                              180,
                        ),
                        child:
                            const Icon(
                          Icons
                              .keyboard_arrow_down_rounded,
                          size:
                              21,
                          color:
                              Color(
                            0xFF59645E,
                          ),
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
                const Divider(
                  height:
                      1,
                  color:
                      Color(
                    0xFFEAEDEA,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    10,
                    9,
                    10,
                    10,
                  ),
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ========================================
                      // EMPLOYEE
                      // ========================================

                      const _FilterLabel(
                        icon:
                            Icons
                                .person_outline_rounded,
                        title:
                            'Employee',
                      ),
                      const SizedBox(
                        height:
                            4,
                      ),
                      TextField(
                        controller:
                            _employeeController,
                        focusNode:
                            _employeeFocusNode,
                        onTap:
                            _onEmployeeFieldTap,
                        onChanged:
                            _searchEmployee,
                        style:
                            const TextStyle(
                          fontSize:
                              12,
                        ),
                        decoration:
                            InputDecoration(
                          hintText:
                              'Search employee',
                          filled:
                              true,
                          fillColor:
                              const Color(
                            0xFFF7F9F8,
                          ),
                          prefixIcon:
                              const Icon(
                            Icons
                                .search_rounded,
                            size:
                                18,
                            color:
                                Color(
                              0xFF168A45,
                            ),
                          ),
                          suffixIcon:
                              _employeeController.text
                                      .isNotEmpty
                                  ? IconButton(
                                      onPressed:
                                          _clearEmployee,
                                      visualDensity:
                                          VisualDensity.compact,
                                      icon:
                                          const Icon(
                                        Icons.close_rounded,
                                        size:
                                            17,
                                      ),
                                    )
                                  : null,
                          isDense:
                              true,
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal:
                                10,
                            vertical:
                                10,
                          ),
                          border:
                              _inputBorder(),
                          enabledBorder:
                              _inputBorder(),
                          focusedBorder:
                              _inputBorder(
                            color:
                                const Color(
                              0xFF168A45,
                            ),
                          ),
                        ),
                      ),

                      _buildEmployeeList(
                        employeeState,
                      ),

                      const SizedBox(
                        height:
                            9,
                      ),

                      // ========================================
                      // DATE
                      // ========================================

                      const _FilterLabel(
                        icon:
                            Icons
                                .calendar_month_outlined,
                        title:
                            'Activity Date',
                      ),
                      const SizedBox(
                        height:
                            4,
                      ),
                      InkWell(
                        onTap:
                            _selectDate,
                        borderRadius:
                            BorderRadius.circular(
                          9,
                        ),
                        child:
                            Container(
                          height:
                              42,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal:
                                10,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF7F9F8,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              9,
                            ),
                            border:
                                Border.all(
                              color:
                                  const Color(
                                0xFFE7ECE9,
                              ),
                            ),
                          ),
                          child:
                              Row(
                            children: [
                              const Icon(
                                Icons
                                    .calendar_today_rounded,
                                size:
                                    17,
                                color:
                                    Color(
                                  0xFF168A45,
                                ),
                              ),
                              const SizedBox(
                                width:
                                    8,
                              ),
                              Expanded(
                                child:
                                    Text(
                                  '$_displayDate  •  $_dayName',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        11.5,
                                    fontWeight:
                                        FontWeight.w600,
                                    color:
                                        Color(
                                      0xFF303934,
                                    ),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons
                                    .keyboard_arrow_down_rounded,
                                size:
                                    19,
                                color:
                                    Color(
                                  0xFF68736D,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                            9,
                      ),

                      // ========================================
                      // BUTTONS
                      // ========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton.icon(
                              onPressed:
                                  _resetFilter,
                              icon:
                                  const Icon(
                                Icons
                                    .restart_alt_rounded,
                                size:
                                    16,
                              ),
                              label:
                                  const Text(
                                'Reset',
                              ),
                              style:
                                  OutlinedButton.styleFrom(
                                foregroundColor:
                                    const Color(
                                  0xFF59645E,
                                ),
                                minimumSize:
                                    const Size(
                                  0,
                                  39,
                                ),
                                padding:
                                    EdgeInsets.zero,
                                side:
                                    const BorderSide(
                                  color:
                                      Color(
                                    0xFFD8DEDA,
                                  ),
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    9,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width:
                                8,
                          ),
                          Expanded(
                            child:
                                ElevatedButton.icon(
                              onPressed:
                                  _searchReport,
                              icon:
                                  const Icon(
                                Icons
                                    .search_rounded,
                                size:
                                    16,
                              ),
                              label:
                                  const Text(
                                'Search',
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xFF168A45,
                                ),
                                foregroundColor:
                                    Colors.white,
                                elevation:
                                    0,
                                minimumSize:
                                    const Size(
                                  0,
                                  39,
                                ),
                                padding:
                                    EdgeInsets.zero,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    9,
                                  ),
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

  OutlineInputBorder _inputBorder({
    Color color =
        const Color(
      0xFFE7ECE9,
    ),
  }) {
    return OutlineInputBorder(
      borderRadius:
          BorderRadius.circular(
        9,
      ),
      borderSide:
          BorderSide(
        color:
            color,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (!_loginEmployeeLoaded) {
      return Scaffold(
        backgroundColor:
            AppColors.backgroundColor,
        appBar:
            CustomAppBar(
          title:
              'Employee Activity',
          showBackButton:
              true,
          onBackTap:
              () =>
                  context.go(
            AppRouter.home,
          ),
        ),
        body:
            const _LoadingView(),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.backgroundColor,

      appBar:
          CustomAppBar(
        title:
            'Employee Activity',
        showBackButton:
            true,
        onBackTap:
            () =>
                context.go(
          AppRouter.home,
        ),
        actionIcon:
            Icons.refresh_rounded,
        onActionIconTap:
            _fetchActivities,
      ),

      body:
          BlocBuilder<
              EmployeeActivityBloc,
              EmployeeActivityState>(
        builder:
            (
          context,
          state,
        ) {
          final List<EmployeeActivity>
              activities =
              state.activities;

          return Column(
            children: [
              _buildFilter(),

              const SizedBox(
                height:
                    4,
              ),

              Expanded(
                child:
                    Builder(
                  builder:
                      (
                    context,
                  ) {
                    if (state.status ==
                        EmployeeActivityStatus
                            .loading) {
                      return const _LoadingView();
                    }

                    if (state.status ==
                        EmployeeActivityStatus
                            .failure) {
                      return _ErrorView(
                        message:
                            state.errorMessage ??
                                'Something went wrong',
                        onRetry:
                            _fetchActivities,
                      );
                    }

                    if (activities.isEmpty) {
                      return RefreshIndicator(
                        color:
                            const Color(
                          0xFF168A45,
                        ),
                        onRefresh:
                            _onRefresh,
                        child:
                            const _EmptyView(),
                      );
                    }

                    return RefreshIndicator(
                      color:
                          const Color(
                        0xFF168A45,
                      ),
                      onRefresh:
                          _onRefresh,
                      child:
                          _ActivityContent(
                        employeeName:
                            _selectedEmployeeName.isEmpty
                                ? 'All Employees'
                                : _selectedEmployeeName,
                        displayDate:
                            _displayDate,
                        dayName:
                            _dayName,
                        activities:
                            activities,
                        countIn:
                            _countActivity(
                          activities,
                          'IN PUNCH',
                        ),
                        countOut:
                            _countActivity(
                          activities,
                          'OUT PUNCH',
                        ),
                        countFarmer:
                            _countActivity(
                          activities,
                          'FARMER',
                        ),
                        countDealer:
                            _countActivity(
                          activities,
                          'DEALER',
                        ),
                        countLocation:
                            _countActivity(
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

class _FilterLabel
    extends StatelessWidget {
  final IconData icon;
  final String title;

  const _FilterLabel({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size:
              14,
          color:
              const Color(
            0xFF168A45,
          ),
        ),
        const SizedBox(
          width:
              4,
        ),
        Text(
          title,
          style:
              const TextStyle(
            fontSize:
                11,
            fontWeight:
                FontWeight.w700,
            color:
                Color(
              0xFF4E5953,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ACTIVITY CONTENT
// ============================================================================

class _ActivityContent
    extends StatelessWidget {
  final String employeeName;
  final String displayDate;
  final String dayName;

  final List<EmployeeActivity>
      activities;

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
  Widget build(
    BuildContext context,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.fromLTRB(
        12,
        6,
        12,
        20,
      ),

      children: [
        // ======================================================
        // SELECTED EMPLOYEE - COMPACT
        // ======================================================

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal:
                10,
            vertical:
                8,
          ),
          decoration:
              BoxDecoration(
            color:
                const Color(
              0xFFF3FAF5,
            ),
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            border:
                Border.all(
              color:
                  const Color(
                0xFFDCEFE2,
              ),
            ),
          ),
          child:
              Row(
            children: [
              Container(
                height:
                    32,
                width:
                    32,
                decoration:
                    const BoxDecoration(
                  shape:
                      BoxShape.circle,
                  color:
                      Color(
                    0xFFE1F4E7,
                  ),
                ),
                child:
                    const Icon(
                  Icons.person_rounded,
                  size:
                      17,
                  color:
                      Color(
                    0xFF168A45,
                  ),
                ),
              ),
              const SizedBox(
                width:
                    8,
              ),
              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      maxLines:
                          1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize:
                            12.5,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Color(
                          0xFF202522,
                        ),
                      ),
                    ),
                    Text(
                      '$displayDate • $dayName',
                      style:
                          const TextStyle(
                        fontSize:
                            9.5,
                        color:
                            Color(
                          0xFF6A746E,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height:
              12,
        ),

        // ======================================================
        // SUMMARY
        // ======================================================

        const Text(
          'Activity Summary',
          style:
              TextStyle(
            fontSize:
                15,
            fontWeight:
                FontWeight.w700,
            color:
                Color(
              0xFF202522,
            ),
          ),
        ),

        const SizedBox(
          height:
              7,
        ),

        SizedBox(
          height:
              55.h,
          child:
              ListView(
            scrollDirection:
                Axis.horizontal,
            physics:
                const BouncingScrollPhysics(),
            children: [
              ActivitySummaryCard(
                title:
                    'IN Punch',
                count:
                    countIn,
                icon:
                    Icons.login_rounded,
                color:
                    const Color(
                  0xFF168A45,
                ),
              ),
              const SizedBox(
                width:
                    8,
              ),
              ActivitySummaryCard(
                title:
                    'OUT Punch',
                count:
                    countOut,
                icon:
                    Icons.logout_rounded,
                color:
                    const Color(
                  0xFFE53935,
                ),
              ),
              const SizedBox(
                width:
                    8,
              ),
              ActivitySummaryCard(
                title:
                    'Farmer Visit',
                count:
                    countFarmer,
                icon:
                    Icons.agriculture_rounded,
                color:
                    const Color(
                  0xFFF28C28,
                ),
              ),
              const SizedBox(
                width:
                    8,
              ),
              ActivitySummaryCard(
                title:
                    'Dealer Visit',
                count:
                    countDealer,
                icon:
                    Icons.storefront_rounded,
                color:
                    const Color(
                  0xFF8E5AE8,
                ),
              ),
              const SizedBox(
                width:
                    8,
              ),
              ActivitySummaryCard(
                title:
                    'Location',
                count:
                    countLocation,
                icon:
                    Icons.location_on_rounded,
                color:
                    const Color(
                  0xFF1976D2,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height:
              15,
        ),

        // ======================================================
        // TIMELINE HEADER
        // ======================================================

        Row(
          children: [
            const Expanded(
              child:
                  Text(
                'Activity Timeline',
                style:
                    TextStyle(
                  fontSize:
                      15,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(
                    0xFF202522,
                  ),
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal:
                    8,
                vertical:
                    4,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFE8F5EC,
                ),
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
              child:
                  Text(
                '${activities.length} Activities',
                style:
                    const TextStyle(
                  fontSize:
                      10.5,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      Color(
                    0xFF168A45,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height:
              8,
        ),

        // ======================================================
        // TIMELINE
        // ======================================================

        ListView.builder(
          shrinkWrap:
              true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount:
              activities.length,
          itemBuilder:
              (
            context,
            index,
          ) {
            final EmployeeActivity activity =
                activities[
                    index];

            return ActivityTimelineItem(
              activity:
                  activity,
              isFirst:
                  index == 0,
              isLast:
                  index ==
                      activities.length -
                          1,
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

class _LoadingView
    extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Center(
      child:
          CircularProgressIndicator(
        color:
            Color(
          0xFF168A45,
        ),
        strokeWidth:
            2.5,
      ),
    );
  }
}

// ============================================================================
// EMPTY
// ============================================================================

class _EmptyView
    extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(
        20,
      ),
      children: const [
        SizedBox(
          height:
              65,
        ),
        Icon(
          Icons.event_busy_rounded,
          size:
              48,
          color:
              Color(
            0xFF168A45,
          ),
        ),
        SizedBox(
          height:
              12,
        ),
        Center(
          child:
              Text(
            'No Activity Found',
            style:
                TextStyle(
              fontSize:
                  17,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(
                0xFF202522,
              ),
            ),
          ),
        ),
        SizedBox(
          height:
              5,
        ),
        Center(
          child:
              Text(
            'No activity found for selected employee and date.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              fontSize:
                  11.5,
              color:
                  Color(
                0xFF7A827D,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ERROR
// ============================================================================

class _ErrorView
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size:
                  45,
              color:
                  Colors.redAccent,
            ),
            const SizedBox(
              height:
                  8,
            ),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontSize:
                    12,
              ),
            ),
            const SizedBox(
              height:
                  12,
            ),
            ElevatedButton.icon(
              onPressed:
                  onRetry,
              icon:
                  const Icon(
                Icons.refresh_rounded,
                size:
                    17,
              ),
              label:
                  const Text(
                'Retry',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF168A45,
                ),
                foregroundColor:
                    Colors.white,
                elevation:
                    0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}