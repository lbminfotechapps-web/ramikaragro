import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/visit_report.dart';

import '../bloc/visit_report_bloc.dart';
import '../bloc/visit_report_event.dart';
import '../bloc/visit_report_state.dart';

import '../widgets/visit_summary_filter.dart';
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

class _VisitSummaryPageState extends State<VisitSummaryPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController employeeController =
      TextEditingController();

  // ============================================================
  // SELECTED EMPLOYEE ID
  // ============================================================

  /// Empty means no employee selected/entered.
  ///
  /// Example:
  ///
  /// selectedEmployeeId = ''
  /// API:
  /// userId = ''
  ///
  /// If employee ID = 15:
  ///
  /// selectedEmployeeId = '15'
  /// API:
  /// userId = '15'
  String selectedEmployeeId = '';

  // ============================================================
  // DATE
  // ============================================================

  DateTime? fromDate;
  DateTime? toDate;

  // ============================================================
  // STATUS
  // ============================================================

  String selectedStatus = 'All Status';

  // ============================================================
  // FILTER EXPAND
  // ============================================================

  bool showFilters = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    fromDate = today;
    toDate = today;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _loadReport();
        }
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    employeeController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATE FORMAT FOR API
  // ============================================================

  String _formatDateForApi(DateTime? date) {
    if (date == null) {
      return '';
    }

    return DateFormat(
      'dd-MM-yyyy',
    ).format(date);
  }

  // ============================================================
  // DATE FORMAT FOR UI
  // ============================================================

  String _formatDateForDisplay(
    DateTime? date,
  ) {
    if (date == null) {
      return '';
    }

    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }

  // ============================================================
  // EMPLOYEE CHANGED
  // ============================================================

  void _onEmployeeChanged(
    String value,
  ) {
    setState(() {
      selectedEmployeeId =
          value.trim();
    });

    debugPrint(
      '==========================================',
    );

    debugPrint(
      'EMPLOYEE ID CHANGED',
    );

    debugPrint(
      'EMPLOYEE ID: $selectedEmployeeId',
    );

    debugPrint(
      '==========================================',
    );
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  void _loadReport() {
    if (fromDate == null ||
        toDate == null) {
      return;
    }

    // IMPORTANT:
    //
    // widget.userId
    // = logged-in/current user
    //
    // selectedEmployeeId
    // = employee filter ID
    //
    // If employee is empty:
    // userId = ''

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
      'EMPLOYEE FIELD   : ${employeeController.text}',
    );

    debugPrint(
      'FROM DATE        : ${_formatDateForApi(fromDate)}',
    );

    debugPrint(
      'TO DATE          : ${_formatDateForApi(toDate)}',
    );

    debugPrint(
      '==========================================',
    );

    context.read<VisitReportBloc>().add(
      GetVisitReportEvent(
        // ======================================================
        // LOGIN USER
        // ======================================================

        logUserId: widget.userId,

        // ======================================================
        // EMPLOYEE FILTER
        //
        // Empty:
        // userId = ''
        //
        // Employee ID entered:
        // userId = '15'
        // ======================================================

        userId: apiEmployeeId,

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
  // FROM DATE
  // ============================================================

  Future<void> _selectFromDate() async {
    final picked =
        await showDatePicker(
      context: context,

      initialDate:
          fromDate ??
          DateTime.now(),

      firstDate:
          DateTime(2020),

      lastDate:
          DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      fromDate = picked;

      // If To Date is before new From Date,
      // make both dates same.
      if (toDate != null &&
          toDate!.isBefore(
            picked,
          )) {
        toDate = picked;
      }
    });
  }

  // ============================================================
  // TO DATE
  // ============================================================

  Future<void> _selectToDate() async {
    final initialDate =
        toDate ??
        fromDate ??
        DateTime.now();

    final picked =
        await showDatePicker(
      context: context,

      initialDate:
          initialDate,

      firstDate:
          fromDate ??
          DateTime(2020),

      lastDate:
          DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      toDate = picked;
    });
  }

  // ============================================================
  // RESET FILTER
  // ============================================================

  void _resetFilters() {
    final today =
        DateTime.now();

    setState(() {
      // Clear employee TextField
      employeeController.clear();

      // IMPORTANT:
      // Clear API employee ID
      selectedEmployeeId = '';

      // Reset status
      selectedStatus =
          'All Status';

      // Reset dates
      fromDate = today;
      toDate = today;
    });

    debugPrint(
      '==========================================',
    );

    debugPrint(
      'FILTER RESET',
    );

    debugPrint(
      'EMPLOYEE ID: EMPTY',
    );

    debugPrint(
      'LOGIN USER ID: ${widget.userId}',
    );

    debugPrint(
      '==========================================',
    );

    // Reload without employee filter
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
      (report) {
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
  // PRESENT COUNT
  // ============================================================

  int _presentCount(
    List<VisitReport> reports,
  ) {
    return reports.where(
      (e) {
        return e.status
                .toLowerCase() ==
            'present';
      },
    ).length;
  }

  // ============================================================
  // ABSENT COUNT
  // ============================================================

  int _absentCount(
    List<VisitReport> reports,
  ) {
    return reports.where(
      (e) {
        return e.status
                .toLowerCase() ==
            'absent';
      },
    ).length;
  }

  // ============================================================
  // DEALER VISIT COUNT
  // ============================================================

  int _dealerVisits(
    List<VisitReport> reports,
  ) {
    return reports.fold(
      0,
      (sum, item) =>
          sum +
          _toInt(
            item.dealerVisit,
          ),
    );
  }

  // ============================================================
  // FARMER VISIT COUNT
  // ============================================================

  int _farmerVisits(
    List<VisitReport> reports,
  ) {
    return reports.fold(
      0,
      (sum, item) =>
          sum +
          _toInt(
            item.farmerVisit,
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
    return Scaffold(
      backgroundColor:
          AppColors.backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: CustomAppBar(
        title:
            'Visit Summary',

        showBackButton:
            true,

        actionIcon:
            Icons.refresh_rounded,

        onBackTap: () =>
            context.go(
          AppRouter.home,
        ),

        onActionIconTap:
            _loadReport,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: BlocBuilder<
          VisitReportBloc,
          VisitReportState>(
        builder:
            (context, state) {
          // ====================================================
          // LOADING
          // ====================================================

          if (state.status ==
              VisitReportStatus
                  .loading) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(
                  0xFF287A4B,
                ),
              ),
            );
          }

          // ====================================================
          // FAILURE
          // ====================================================

          if (state.status ==
              VisitReportStatus
                  .failure) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  24,
                ),

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons
                          .error_outline_rounded,

                      size:
                          52,

                      color:
                          Colors.redAccent,
                    ),

                    const SizedBox(
                      height:
                          12,
                    ),

                    const Text(
                      'Something went wrong',

                      style:
                          TextStyle(
                        fontSize:
                            17,

                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height:
                          6,
                    ),

                    Text(
                      state.errorMessage ??
                          'Unable to load report',

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        color:
                            Colors.grey,

                        fontSize:
                            13,
                      ),
                    ),

                    const SizedBox(
                      height:
                          18,
                    ),

                    ElevatedButton(
                      onPressed:
                          _loadReport,

                      child:
                          const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ====================================================
          // FILTER REPORT
          // ====================================================

          final reports =
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
                  const EdgeInsets.only(
                left:
                    16,
                right:
                    16,
              ),

              children: [
                // ==============================================
                // FILTER
                // ==============================================

                VisitSummaryFilter(
                  employeeController:
                      employeeController,

                  fromDate:
                      _formatDateForDisplay(
                    fromDate,
                  ),

                  toDate:
                      _formatDateForDisplay(
                    toDate,
                  ),

                  selectedStatus:
                      selectedStatus,

                  expanded:
                      showFilters,

                  onExpandChanged:
                      () {
                    setState(() {
                      showFilters =
                          !showFilters;
                    });
                  },

                  // ============================================
                  // EMPLOYEE
                  //
                  // THIS IS THE FIX.
                  //
                  // Do NOT use:
                  // onEmployeeSelected
                  // onEmployeeClear
                  //
                  // Current VisitSummaryFilter expects:
                  // onEmployeeChanged
                  // ============================================

                  onEmployeeChanged:
                      _onEmployeeChanged,

                  onFromDateTap:
                      _selectFromDate,

                  onToDateTap:
                      _selectToDate,

                  onStatusChanged:
                      (value) {
                    setState(() {
                      selectedStatus =
                          value;
                    });
                  },

                  onReset:
                      _resetFilters,

                  onSearch:
                      _loadReport,
                ),

                const SizedBox(
                  height:
                      14,
                ),

                // ==============================================
                // STATISTICS
                // ==============================================

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
                      16,
                ),

                // ==============================================
                // HEADER
                // ==============================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [
                    const Text(
                      'Visit Details',

                      style:
                          TextStyle(
                        fontSize:
                            17,

                        fontWeight:
                            FontWeight
                                .w800,

                        color:
                            Color(
                          0xFF1F2924,
                        ),
                      ),
                    ),

                    Text(
                      '${reports.length} Records',

                      style:
                          const TextStyle(
                        fontSize:
                            12,

                        fontWeight:
                            FontWeight
                                .w600,

                        color:
                            Color(
                          0xFF6A746E,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height:
                      10,
                ),

                // ==============================================
                // REPORT LIST
                // ==============================================

                if (reports.isEmpty)
                  const VisitSummaryEmpty()
                else
                  ...reports.map(
                    (report) =>
                        Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom:
                            12,
                      ),

                      child:
                          VisitSummaryCard(
                        report:
                            report,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}