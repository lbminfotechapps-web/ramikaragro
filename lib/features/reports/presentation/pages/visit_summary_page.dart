import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_colors.dart';
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
  State<VisitSummaryPage> createState() => _VisitSummaryPageState();
}

class _VisitSummaryPageState extends State<VisitSummaryPage> {
  final TextEditingController employeeController =
      TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;

  String selectedStatus = 'All Status';

  bool showFilters = false;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    fromDate = today;
    toDate = today;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  @override
  void dispose() {
    employeeController.dispose();
    super.dispose();
  }

  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';

    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return '';

    return DateFormat('dd MMM yyyy').format(date);
  }

  void _loadReport() {
    if (fromDate == null || toDate == null) {
      return;
    }

    context.read<VisitReportBloc>().add(
          GetVisitReportEvent(
            logUserId: widget.userId,
            userId: widget.userId,
            fromDate: _formatDateForApi(fromDate),
            toDate: _formatDateForApi(toDate),
          ),
        );
  }

  Future<void> _selectFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      fromDate = picked;

      if (toDate != null && toDate!.isBefore(picked)) {
        toDate = picked;
      }
    });
  }

  Future<void> _selectToDate() async {
    final initialDate = toDate ?? fromDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      toDate = picked;
    });
  }

  void _resetFilters() {
    final today = DateTime.now();

    setState(() {
      employeeController.clear();
      selectedStatus = 'All Status';
      fromDate = today;
      toDate = today;
    });

    _loadReport();
  }

  List<VisitReport> _filterReports(List<VisitReport> reports) {
    if (selectedStatus == 'All Status') {
      return reports;
    }

    return reports.where((report) {
      return report.status.toLowerCase() ==
          selectedStatus.toLowerCase();
    }).toList();
  }

  int _toInt(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  int _presentCount(List<VisitReport> reports) {
    return reports.where((e) {
      return e.status.toLowerCase() == 'present';
    }).length;
  }

  int _absentCount(List<VisitReport> reports) {
    return reports.where((e) {
      return e.status.toLowerCase() == 'absent';
    }).length;
  }

  int _dealerVisits(List<VisitReport> reports) {
    return reports.fold(
      0,
      (sum, item) => sum + _toInt(item.dealerVisit),
    );
  }

  int _farmerVisits(List<VisitReport> reports) {
    return reports.fold(
      0,
      (sum, item) => sum + _toInt(item.farmerVisit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor:  const Color(0xFF287A4B),
        surfaceTintColor: Colors.white,

        title: const Text(
          'Visit Summary',
          style: TextStyle(
            color: AppColors.backgroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: AppColors.backgroundColor,
          ),
          onPressed: () {
           context.go(AppRouter.home);
          },
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.backgroundColor,
            ),
            onPressed: _loadReport,
          ),
        ],
      ),

      body: BlocBuilder<VisitReportBloc, VisitReportState>(
        builder: (context, state) {
          if (state.status == VisitReportStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF287A4B),
              ),
            );
          }

          if (state.status == VisitReportStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 52,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      state.errorMessage ?? 'Unable to load report',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 18),

                    ElevatedButton(
                      onPressed: _loadReport,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final reports = _filterReports(state.reports);

          return RefreshIndicator(
            color: const Color(0xFF287A4B),
            onRefresh: () async {
              _loadReport();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                14,
                12,
                14,
                24,
              ),
              children: [
                /// FILTER
                VisitSummaryFilter(
                  employeeController: employeeController,
                  fromDate: _formatDateForDisplay(fromDate),
                  toDate: _formatDateForDisplay(toDate),
                  selectedStatus: selectedStatus,
                  expanded: showFilters,

                  onExpandChanged: () {
                    setState(() {
                      showFilters = !showFilters;
                    });
                  },

                  onFromDateTap: _selectFromDate,
                  onToDateTap: _selectToDate,

                  onStatusChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },

                  onReset: _resetFilters,

                  onSearch: _loadReport,
                ),

                const SizedBox(height: 14),

                /// STATISTICS
                VisitSummaryStatistics(
                  total: reports.length,
                  present: _presentCount(reports),
                  absent: _absentCount(reports),
                  dealerVisits: _dealerVisits(reports),
                  farmerVisits: _farmerVisits(reports),
                ),

                const SizedBox(height: 16),

                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Visit Details',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2924),
                      ),
                    ),

                    Text(
                      '${reports.length} Records',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A746E),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// REPORT LIST
                if (reports.isEmpty)
                  const VisitSummaryEmpty()
                else
                  ...reports.map(
                    (report) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: VisitSummaryCard(
                        report: report,
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