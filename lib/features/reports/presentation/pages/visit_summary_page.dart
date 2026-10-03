import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/assign_employee.dart';
import '../../domain/entities/visit_report.dart';

import '../bloc/employee_output_bloc.dart';
import '../bloc/employee_output_event.dart';
import '../bloc/employee_output_state.dart';

import '../bloc/visit_report_bloc.dart';
import '../bloc/visit_report_event.dart';
import '../bloc/visit_report_state.dart';

import '../widgets/visit_summary_statistics.dart';
import '../widgets/visit_summary_card.dart';
import '../widgets/visit_summary_empty.dart';

class VisitSummaryPage extends StatefulWidget {
  final String userId;

  const VisitSummaryPage({
    super.key,
    required this.userId,
  });

  @override
  State<VisitSummaryPage> createState() =>
      _VisitSummaryPageState();
}

class _VisitSummaryPageState
    extends State<VisitSummaryPage> {
  // ============================================================
  // EMPLOYEE
  // ============================================================

  final TextEditingController employeeController =
      TextEditingController();

  final FocusNode employeeFocusNode =
      FocusNode();

  Timer? employeeSearchTimer;

  String selectedEmployeeId = '';

  String selectedEmployeeName = '';

  String loginEmployeeId = '';

  String loginEmployeeName = '';

  bool loginEmployeeLoaded = false;

  bool showEmployeeList = false;

  // ============================================================
  // DATE
  // ============================================================

  DateTime? fromDate;
  DateTime? toDate;

  // ============================================================
  // STATUS
  // ============================================================

  String selectedStatus =
      'All Status';

  // ============================================================
  // FILTER
  // ============================================================

  bool showFilters = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final DateTime today =
        DateTime.now();

    fromDate = today;
    toDate = today;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        _loadLoginEmployee();
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    employeeSearchTimer?.cancel();

    employeeController.dispose();
    employeeFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD LOGIN EMPLOYEE
  // ============================================================

  Future<void> _loadLoginEmployee() async {
    try {
      final userData =
          await SecureStorage.instance.getUserData();

      if (!mounted) {
        return;
      }

      final String storedUserId =
          userData?['user_id']
                  ?.toString()
                  .trim() ??
              '';

      final String storedUserName =
          userData?['user_name']
                  ?.toString()
                  .trim() ??
              '';

      final String userId =
          widget.userId.trim().isNotEmpty
              ? widget.userId.trim()
              : storedUserId;

      final String userName =
          storedUserName.isNotEmpty
              ? storedUserName
              : 'Logged-in Employee';

      setState(() {
        loginEmployeeId =
            userId;

        loginEmployeeName =
            userName;

        // ========================================
        // DEFAULT EMPLOYEE = LOGIN EMPLOYEE
        // ========================================

        selectedEmployeeId =
            userId;

        selectedEmployeeName =
            userName;

        employeeController.text =
            userName;

        loginEmployeeLoaded =
            true;
      });

      debugPrint(
        '==========================================',
      );

      debugPrint(
        'VISIT SUMMARY LOGIN EMPLOYEE',
      );

      debugPrint(
        'ID   : $loginEmployeeId',
      );

      debugPrint(
        'NAME : $loginEmployeeName',
      );

      debugPrint(
        '==========================================',
      );

      _loadReport();
    } catch (e) {
      debugPrint(
        'LOGIN EMPLOYEE ERROR => $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        loginEmployeeId =
            widget.userId.trim();

        loginEmployeeName =
            'Logged-in Employee';

        selectedEmployeeId =
            loginEmployeeId;

        selectedEmployeeName =
            loginEmployeeName;

        employeeController.text =
            loginEmployeeName;

        loginEmployeeLoaded =
            true;
      });

      _loadReport();
    }
  }

  // ============================================================
  // DATE FORMAT API
  // ============================================================

  String _formatDateForApi(
    DateTime? date,
  ) {
    if (date == null) {
      return '';
    }

    return DateFormat(
      'dd-MM-yyyy',
    ).format(
      date,
    );
  }

  // ============================================================
  // DATE FORMAT UI
  // ============================================================

  String _formatDateForDisplay(
    DateTime? date,
  ) {
    if (date == null) {
      return '';
    }

    return DateFormat(
      'dd MMM yyyy',
    ).format(
      date,
    );
  }

  // ============================================================
  // LOAD VISIT REPORT
  // ============================================================

  void _loadReport() {
    if (fromDate == null ||
        toDate == null) {
      return;
    }

    final String apiEmployeeId =
        selectedEmployeeId.trim();

    debugPrint(
      '==========================================',
    );

    debugPrint(
      'GET VISIT REPORT',
    );

    debugPrint(
      'LOGIN USER ID    : ${widget.userId}',
    );

    debugPrint(
      'EMPLOYEE USER ID : $apiEmployeeId',
    );

    debugPrint(
      'EMPLOYEE NAME    : $selectedEmployeeName',
    );

    debugPrint(
      'FROM DATE        : ${_formatDateForApi(fromDate)}',
    );

    debugPrint(
      'TO DATE          : ${_formatDateForApi(toDate)}',
    );

    debugPrint(
      'STATUS           : $selectedStatus',
    );

    debugPrint(
      '==========================================',
    );

    context
        .read<VisitReportBloc>()
        .add(
          GetVisitReportEvent(
            logUserId:
                widget.userId,

            userId:
                apiEmployeeId,

            fromDate:
                _formatDateForApi(
              fromDate,
            ),

            toDate:
                _formatDateForApi(
              toDate,
            ),
          ),
        );
  }

  // ============================================================
  // FILTER OPEN / CLOSE
  // ============================================================

  void _toggleFilter() {
    FocusScope.of(context)
        .unfocus();

    setState(() {
      showFilters =
          !showFilters;

      if (!showFilters) {
        showEmployeeList =
            false;
      }
    });
  }

  // ============================================================
  // LOAD EMPLOYEES
  // ============================================================

  void _loadEmployees({
    String? search,
  }) {
    if (!mounted) {
      return;
    }

    context
        .read<EmployeeOutputBloc>()
        .add(
          SearchEmployeesEvent(
            logUserId:
                widget.userId,

            search:
                search ??
                    employeeController.text
                        .trim(),
          ),
        );
  }

  // ============================================================
  // EMPLOYEE FIELD TAP
  // ============================================================

  void _onEmployeeFieldTap() {
    setState(() {
      showEmployeeList =
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
    employeeSearchTimer?.cancel();

    final String search =
        value.trim();

    if (selectedEmployeeId.isNotEmpty &&
        search != selectedEmployeeName) {
      setState(() {
        selectedEmployeeId =
            '';

        selectedEmployeeName =
            '';

        showEmployeeList =
            true;
      });
    } else {
      setState(() {
        showEmployeeList =
            true;
      });
    }

    if (search.isEmpty) {
      selectedEmployeeId =
          '';

      selectedEmployeeName =
          'All Employees';

      _loadEmployees(
        search: '',
      );

      return;
    }

    employeeSearchTimer =
        Timer(
      const Duration(
        milliseconds: 400,
      ),
      () {
        if (!mounted) {
          return;
        }

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
      selectedEmployeeId =
          id;

      selectedEmployeeName =
          name;

      employeeController.text =
          name;

      employeeController.selection =
          TextSelection.collapsed(
        offset:
            name.length,
      );

      showEmployeeList =
          false;
    });

    context
        .read<EmployeeOutputBloc>()
        .add(
          const ClearEmployeeSuggestionsEvent(),
        );

    FocusScope.of(context)
        .unfocus();
  }

  // ============================================================
  // CLEAR EMPLOYEE
  // ============================================================

  void _clearEmployee() {
    employeeSearchTimer?.cancel();

    setState(() {
      employeeController.clear();

      selectedEmployeeId =
          '';

      selectedEmployeeName =
          'All Employees';

      showEmployeeList =
          true;
    });

    _loadEmployees(
      search: '',
    );

    employeeFocusNode.requestFocus();
  }

  // ============================================================
  // FROM DATE
  // ============================================================

  Future<void> _selectFromDate() async {
    final DateTime? picked =
        await showDatePicker(
      context:
          context,

      initialDate:
          fromDate ??
              DateTime.now(),

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime.now(),

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
                0xFF287A4B,
              ),
            ),
          ),

          child:
              child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      fromDate =
          picked;

      if (toDate != null &&
          toDate!.isBefore(
            picked,
          )) {
        toDate =
            picked;
      }
    });
  }

  // ============================================================
  // TO DATE
  // ============================================================

  Future<void> _selectToDate() async {
    final DateTime initialDate =
        toDate ??
            fromDate ??
            DateTime.now();

    final DateTime? picked =
        await showDatePicker(
      context:
          context,

      initialDate:
          initialDate,

      firstDate:
          fromDate ??
              DateTime(2020),

      lastDate:
          DateTime.now(),

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
                0xFF287A4B,
              ),
            ),
          ),

          child:
              child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      toDate =
          picked;
    });
  }

  // ============================================================
  // SEARCH REPORT
  // ============================================================

  void _searchReport() {
    FocusScope.of(context)
        .unfocus();

    if (employeeController.text
            .trim()
            .isNotEmpty &&
        selectedEmployeeId.isEmpty &&
        selectedEmployeeName !=
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
      showEmployeeList =
          false;

      showFilters =
          false;
    });

    _loadReport();
  }

  // ============================================================
  // RESET FILTER
  // ============================================================

  void _resetFilters() {
    employeeSearchTimer?.cancel();

    final DateTime today =
        DateTime.now();

    setState(() {
      // ========================================
      // RESET EMPLOYEE TO LOGIN EMPLOYEE
      // ========================================

      selectedEmployeeId =
          loginEmployeeId;

      selectedEmployeeName =
          loginEmployeeName;

      employeeController.text =
          loginEmployeeName;

      // ========================================
      // RESET DATE
      // ========================================

      fromDate =
          today;

      toDate =
          today;

      // ========================================
      // RESET STATUS
      // ========================================

      selectedStatus =
          'All Status';

      showEmployeeList =
          false;

      showFilters =
          false;
    });

    context
        .read<EmployeeOutputBloc>()
        .add(
          const ClearEmployeeSuggestionsEvent(),
        );

    FocusScope.of(context)
        .unfocus();

    _loadReport();
  }

  // ============================================================
  // LOCAL STATUS FILTER
  // ============================================================

  List<VisitReport> _filterReports(
    List<VisitReport> reports,
  ) {
    if (selectedStatus ==
        'All Status') {
      return reports;
    }

    return reports.where(
      (
        report,
      ) {
        return report.status
                .toLowerCase() ==
            selectedStatus
                .toLowerCase();
      },
    ).toList();
  }

  // ============================================================
  // STRING -> INT
  // ============================================================

  int _toInt(
    String value,
  ) {
    return int.tryParse(
          value.trim(),
        ) ??
        0;
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  int _presentCount(
    List<VisitReport> reports,
  ) {
    return reports.where(
      (
        e,
      ) {
        return e.status
                .toLowerCase() ==
            'present';
      },
    ).length;
  }

  int _absentCount(
    List<VisitReport> reports,
  ) {
    return reports.where(
      (
        e,
      ) {
        return e.status
                .toLowerCase() ==
            'absent';
      },
    ).length;
  }

  int _dealerVisits(
    List<VisitReport> reports,
  ) {
    return reports.fold(
      0,
      (
        sum,
        item,
      ) =>
          sum +
          _toInt(
            item.dealerVisit,
          ),
    );
  }

  int _farmerVisits(
    List<VisitReport> reports,
  ) {
    return reports.fold(
      0,
      (
        sum,
        item,
      ) =>
          sum +
          _toInt(
            item.farmerVisit,
          ),
    );
  }

  // ============================================================
  // INPUT BORDER
  // ============================================================

  OutlineInputBorder _inputBorder({
    Color color =
        const Color(
      0xFFE5EAE7,
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
  // EMPLOYEE LIST
  // ============================================================

  Widget _buildEmployeeList(
    EmployeeOutputState state,
  ) {
    if (state.employeeLoading) {
      return const Padding(
        padding:
            EdgeInsets.only(
          top: 5,
        ),
        child:
            LinearProgressIndicator(
          minHeight:
              2,
          color:
              Color(
            0xFF287A4B,
          ),
        ),
      );
    }

    if (!showEmployeeList) {
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
                  17,
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
                  selectedEmployeeId;

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
                          0xFF287A4B,
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
                        0xFF287A4B,
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
              // HEADER
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
                            0xFF287A4B,
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
                              'Filter Visit Summary',
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
                              '${selectedEmployeeName.isEmpty ? 'All Employees' : selectedEmployeeName} • ${_formatDateForDisplay(fromDate)}',
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
                            showFilters
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
              // FILTER BODY
              // ================================================

              if (showFilters) ...[
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
                            employeeController,
                        focusNode:
                            employeeFocusNode,
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
                              0xFF287A4B,
                            ),
                          ),
                          suffixIcon:
                              employeeController
                                      .text
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
                              0xFF287A4B,
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
                      // DATE ROW
                      // ========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _DateField(
                              title:
                                  'From',
                              value:
                                  _formatDateForDisplay(
                                fromDate,
                              ),
                              onTap:
                                  _selectFromDate,
                            ),
                          ),

                          const SizedBox(
                            width:
                                7,
                          ),

                          Expanded(
                            child:
                                _DateField(
                              title:
                                  'To',
                              value:
                                  _formatDateForDisplay(
                                toDate,
                              ),
                              onTap:
                                  _selectToDate,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height:
                            9,
                      ),

                      // ========================================
                      // STATUS
                      // ========================================

                      const _FilterLabel(
                        icon:
                            Icons
                                .fact_check_outlined,
                        title:
                            'Status',
                      ),

                      const SizedBox(
                        height:
                            4,
                      ),

                      DropdownButtonFormField<
                          String>(
                        value:
                            selectedStatus,
                        isDense:
                            true,
                        decoration:
                            InputDecoration(
                          filled:
                              true,
                          fillColor:
                              const Color(
                            0xFFF7F9F8,
                          ),
                          prefixIcon:
                              const Icon(
                            Icons
                                .filter_list_rounded,
                            size:
                                18,
                            color:
                                Color(
                              0xFF287A4B,
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal:
                                8,
                            vertical:
                                8,
                          ),
                          border:
                              _inputBorder(),
                          enabledBorder:
                              _inputBorder(),
                          focusedBorder:
                              _inputBorder(
                            color:
                                const Color(
                              0xFF287A4B,
                            ),
                          ),
                        ),
                        items:
                            const [
                          DropdownMenuItem(
                            value:
                                'All Status',
                            child:
                                Text(
                              'All Status',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'Present',
                            child:
                                Text(
                              'Present',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                                'Absent',
                            child:
                                Text(
                              'Absent',
                            ),
                          ),
                        ],
                        onChanged:
                            (
                          value,
                        ) {
                          if (value ==
                              null) {
                            return;
                          }

                          setState(() {
                            selectedStatus =
                                value;
                          });
                        },
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
                                  _resetFilters,
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
                                  0xFF287A4B,
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (!loginEmployeeLoaded) {
      return Scaffold(
        backgroundColor:
            AppColors.backgroundColor,
        appBar:
            CustomAppBar(
          title:
              'Visit Summary',
          showBackButton:
              true,
          onBackTap:
              () =>
                  context.go(
            AppRouter.home,
          ),
        ),
        body:
            const Center(
          child:
              CircularProgressIndicator(
            color:
                Color(
              0xFF287A4B,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.backgroundColor,

      appBar:
          CustomAppBar(
        title:
            'Visit Summary',

        showBackButton:
            true,

        actionIcon:
            Icons.refresh_rounded,

        onBackTap:
            () =>
                context.go(
          AppRouter.home,
        ),

        onActionIconTap:
            _loadReport,
      ),

      body:
          BlocBuilder<
              VisitReportBloc,
              VisitReportState>(
        builder:
            (
          context,
          state,
        ) {
          // ================================================
          // FILTER DATA
          // ================================================

          final List<VisitReport> reports =
              _filterReports(
            state.reports,
          );

          return RefreshIndicator(
            color:
                const Color(
              0xFF287A4B,
            ),

            onRefresh:
                () async {
              _loadReport();
            },

            child:
                ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding:
                  const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                20,
              ),

              children: [
                // ============================================
                // FILTER ALWAYS VISIBLE
                // ============================================

                _buildFilter(),

                const SizedBox(
                  height:
                      10,
                ),

                // ============================================
                // LOADING
                // ============================================

                if (state.status ==
                    VisitReportStatus.loading)
                  const Padding(
                    padding:
                        EdgeInsets.only(
                      top:
                          100,
                    ),
                    child:
                        Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            Color(
                          0xFF287A4B,
                        ),
                      ),
                    ),
                  )

                // ============================================
                // FAILURE
                // ============================================

                else if (state.status ==
                    VisitReportStatus.failure)
                  _ErrorView(
                    message:
                        state.errorMessage ??
                            'Unable to load report',

                    onRetry:
                        _loadReport,
                  )

                // ============================================
                // CONTENT
                // ============================================

                else ...[
                  VisitSummaryStatistics(
                    total:
                        reports.length,

                    present:
                        _presentCount(
                      reports,
                    ),

                    absent:
                        _absentCount(
                      reports,
                    ),

                    dealerVisits:
                        _dealerVisits(
                      reports,
                    ),

                    farmerVisits:
                        _farmerVisits(
                      reports,
                    ),
                  ),

                  const SizedBox(
                    height:
                        12,
                  ),

                  Row(
                    children: [
                      const Expanded(
                        child:
                            Text(
                          'Visit Details',
                          style:
                              TextStyle(
                            fontSize:
                                15,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                Color(
                              0xFF1F2924,
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
                            14,
                          ),
                        ),
                        child:
                            Text(
                          '${reports.length} Records',
                          style:
                              const TextStyle(
                            fontSize:
                                10.5,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                Color(
                              0xFF287A4B,
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

                  if (reports.isEmpty)
                    const VisitSummaryEmpty()
                  else
                    ...reports.map(
                      (
                        report,
                      ) =>
                          Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              8,
                        ),
                        child:
                            VisitSummaryCard(
                          report:
                              report,
                        ),
                      ),
                    ),
                ],
              ],
            ),
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
            0xFF287A4B,
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
// DATE FIELD
// ============================================================================

class _DateField
    extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap:
          onTap,
      borderRadius:
          BorderRadius.circular(
        9,
      ),
      child:
          Container(
        height:
            47,
        padding:
            const EdgeInsets.symmetric(
          horizontal:
              8,
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
              0xFFE5EAE7,
            ),
          ),
        ),
        child:
            Row(
          children: [
            const Icon(
              Icons
                  .calendar_month_outlined,
              size:
                  16,
              color:
                  Color(
                0xFF287A4B,
              ),
            ),

            const SizedBox(
              width:
                  6,
            ),

            Expanded(
              child:
                  Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize:
                          9,
                      color:
                          Color(
                        0xFF7A827D,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        1,
                  ),

                  Text(
                    value,
                    maxLines:
                        1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize:
                          10.5,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          Color(
                        0xFF303934,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    return Padding(
      padding:
          const EdgeInsets.only(
        top:
            80,
      ),
      child:
          Column(
        children: [
          const Icon(
            Icons
                .error_outline_rounded,
            size:
                45,
            color:
                Colors.redAccent,
          ),

          const SizedBox(
            height:
                8,
          ),

          const Text(
            'Something went wrong',
            style:
                TextStyle(
              fontSize:
                  16,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height:
                5,
          ),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize:
                  12,
              color:
                  Colors.grey,
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
                0xFF287A4B,
              ),
              foregroundColor:
                  Colors.white,
              elevation:
                  0,
            ),
          ),
        ],
      ),
    );
  }
}