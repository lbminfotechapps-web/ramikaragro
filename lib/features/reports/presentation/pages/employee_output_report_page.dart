import 'dart:async';

import 'package:demo/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:demo/features/reports/domain/entities/assign_employee.dart';
import 'package:demo/features/reports/presentation/bloc/employee_output_bloc.dart';
import 'package:demo/features/reports/presentation/bloc/employee_output_event.dart';
import 'package:demo/features/reports/presentation/bloc/employee_output_state.dart';

import '../widgets/employee_output_card.dart';
import '../widgets/employee_output_empty.dart';
import '../widgets/employee_output_filter.dart';
import '../widgets/employee_output_statistics.dart';

class EmployeeOutputReportPage extends StatefulWidget {
  final String userId;

  const EmployeeOutputReportPage({super.key, required this.userId});

  @override
  State<EmployeeOutputReportPage> createState() =>
      _EmployeeOutputReportPageState();
}

class _EmployeeOutputReportPageState extends State<EmployeeOutputReportPage> {
  // ============================================================
  // CONTROLLER
  // ============================================================

  final TextEditingController employeeController = TextEditingController();

  // ============================================================
  // FILTER VALUES
  // ============================================================

  late String fromDate;
  late String toDate;

  String employeeId = '';

  // ============================================================
  // UI STATE
  // ============================================================

  bool showFilters = false;

  Timer? _employeeSearchTimer;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    fromDate = today;
    toDate = today;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadReport();
    });
  }

  // ============================================================
  // BACK PRESS
  // ============================================================

  // void _handleBackPress() {
  //   if (!mounted) return;

  //   debugPrint('========================================');
  //   debugPrint('EMPLOYEE OUTPUT → BACK PRESSED');
  //   debugPrint('========================================');

  //   final NavigatorState navigator =
  //       Navigator.of(context);

  //   debugPrint(
  //     'CAN POP: ${navigator.canPop()}',
  //   );

  //   if (navigator.canPop()) {
  //     navigator.pop();
  //   } else {
  //     debugPrint(
  //       'NO PREVIOUS ROUTE FOUND',
  //     );
  //   }
  // }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  void _loadReport() {
    if (!mounted) return;

    context.read<EmployeeOutputBloc>().add(
      GetEmployeeOutputReportEvent(
        logUserId: widget.userId,
        employeeId: employeeId,
        fromDate: fromDate,
        toDate: toDate,
        employeeName: employeeController.text.trim(),
        startLimit: '0',
      ),
    );
  }

  // ============================================================
  // SEARCH EMPLOYEE
  // ============================================================

  void _searchEmployee(String value) {
    _employeeSearchTimer?.cancel();

    final String search = value.trim();

    if (mounted) {
      setState(() {});
    }

    if (search.isEmpty) {
      context.read<EmployeeOutputBloc>().add(
        const ClearEmployeeSuggestionsEvent(),
      );

      return;
    }

    _employeeSearchTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      context.read<EmployeeOutputBloc>().add(
        SearchEmployeesEvent(logUserId: widget.userId, search: search),
      );
    });
  }

  // ============================================================
  // SELECT EMPLOYEE
  // ============================================================

  void _selectEmployee(AssignEmployee employee) {
    setState(() {
      employeeId = employee.fldId.toString();

      employeeController.text = employee.fldAdmName.toString();
    });

    context.read<EmployeeOutputBloc>().add(
      const ClearEmployeeSuggestionsEvent(),
    );

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // CLEAR EMPLOYEE
  // ============================================================

  void _clearEmployee() {
    setState(() {
      employeeController.clear();
      employeeId = '';
    });

    context.read<EmployeeOutputBloc>().add(
      const ClearEmployeeSuggestionsEvent(),
    );
  }

  // ============================================================
  // FROM DATE
  // ============================================================

  Future<void> _selectFromDate() async {
    DateTime initialDate;

    try {
      initialDate = DateFormat('dd-MM-yyyy').parse(fromDate);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      fromDate = DateFormat('dd-MM-yyyy').format(picked);

      final DateTime currentTo = DateFormat('dd-MM-yyyy').parse(toDate);

      if (picked.isAfter(currentTo)) {
        toDate = fromDate;
      }
    });
  }

  // ============================================================
  // TO DATE
  // ============================================================

  Future<void> _selectToDate() async {
    DateTime initialDate;
    DateTime minimumDate;

    try {
      initialDate = DateFormat('dd-MM-yyyy').parse(toDate);
    } catch (_) {
      initialDate = DateTime.now();
    }

    try {
      minimumDate = DateFormat('dd-MM-yyyy').parse(fromDate);
    } catch (_) {
      minimumDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(minimumDate)
          ? minimumDate
          : initialDate,
      firstDate: minimumDate,
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      toDate = DateFormat('dd-MM-yyyy').format(picked);
    });
  }

  // ============================================================
  // RESET FILTERS
  // ============================================================

  void _resetFilters() {
    final String today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    _employeeSearchTimer?.cancel();

    setState(() {
      employeeController.clear();

      employeeId = '';

      fromDate = today;
      toDate = today;
    });

    context.read<EmployeeOutputBloc>().add(
      const ClearEmployeeSuggestionsEvent(),
    );

    FocusScope.of(context).unfocus();

    _loadReport();
  }

  // ============================================================
  // SEARCH REPORT
  // ============================================================

  void _searchReport() {
    FocusScope.of(context).unfocus();

    context.read<EmployeeOutputBloc>().add(
      const ClearEmployeeSuggestionsEvent(),
    );

    _loadReport();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshReport() async {
    _loadReport();

    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _employeeSearchTimer?.cancel();

    employeeController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        elevation: 0,

        backgroundColor: const Color(0xFF287A4B),

        foregroundColor: Colors.white,

        // ========================================================
        // MANUAL BACK ARROW
        // ========================================================
        automaticallyImplyLeading: false,

        leading: IconButton(
          onPressed: () {
            context.go(AppRouter.home);
          },

          icon: const Icon(Icons.arrow_back_rounded, size: 25),
        ),

        title: const Text(
          'Employee Output Report',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: BlocListener<EmployeeOutputBloc, EmployeeOutputState>(
        listener: (context, state) {
          if (state.status == EmployeeOutputStatus.failure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },

        child: RefreshIndicator(
          onRefresh: _refreshReport,

          child: BlocBuilder<EmployeeOutputBloc, EmployeeOutputState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================
                    _buildHeader(),

                    const SizedBox(height: 10),

                    // ==================================================
                    // FILTER
                    // ==================================================
                    EmployeeOutputFilter(
                      employeeController: employeeController,

                      employeeId: employeeId,

                      fromDate: fromDate,

                      toDate: toDate,

                      expanded: showFilters,

                      employees: state.employees,

                      employeeLoading: state.employeeLoading,

                      onExpandChanged: () {
                        setState(() {
                          showFilters = !showFilters;
                        });
                      },

                      onEmployeeChanged: _searchEmployee,

                      onEmployeeSelected: _selectEmployee,

                      onFromDateTap: _selectFromDate,

                      onToDateTap: _selectToDate,

                      onReset: _resetFilters,

                      onSearch: _searchReport,
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // LOADING
                    // ==================================================
                    if (state.status == EmployeeOutputStatus.loading)
                      _buildLoading()
                    // ==================================================
                    // ERROR
                    // ==================================================
                    else if (state.status == EmployeeOutputStatus.failure)
                      EmployeeOutputEmpty(
                        icon: Icons.error_outline_rounded,

                        title: 'Unable to load report',

                        subtitle: state.errorMessage ?? 'Please try again',
                      )
                    // ==================================================
                    // EMPTY
                    // ==================================================
                    else if (state.reports.isEmpty)
                      const EmployeeOutputEmpty(
                        icon: Icons.analytics_outlined,

                        title: 'No Output Found',

                        subtitle:
                            'No employee output records found for the selected filters.',
                      )
                    // ==================================================
                    // DATA
                    // ==================================================
                    else ...[
                      // ================================================
                      // STATISTICS
                      // ================================================
                      EmployeeOutputStatistics(reports: state.reports),

                      const SizedBox(height: 14),

                      // ================================================
                      // TITLE
                      // ================================================
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Employee Output',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF202923),
                              ),
                            ),
                          ),

                          Text(
                            '${state.reports.length} Employees',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7A837E),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ================================================
                      // CARDS
                      // ================================================
                      ListView.separated(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: state.reports.length,

                        separatorBuilder: (_, __) => const SizedBox(height: 8),

                        itemBuilder: (context, index) {
                          final report = state.reports[index];

                          return EmployeeOutputCard(report: report);
                        },
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF287A4B), Color(0xFF45A36A)],
        ),

        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.16),

              borderRadius: BorderRadius.circular(13),
            ),

            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Employee Output',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Track employee visits and productivity',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),

      child: Center(child: CircularProgressIndicator(color: Color(0xFF287A4B))),
    );
  }
}
