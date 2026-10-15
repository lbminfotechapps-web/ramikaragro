import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/employee_output_bloc.dart';
import '../bloc/employee_output_state.dart';

class EmployeeOutputDetailsDialog extends StatelessWidget {
  final String employeeName;
  final String fromDate;
  final String toDate;

  const EmployeeOutputDetailsDialog({
    super.key,
    required this.employeeName,
    required this.fromDate,
    required this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: context.cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 750,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            _buildHeader(context),

            // API RESPONSE
            Flexible(
              child: BlocBuilder<EmployeeOutputBloc, EmployeeOutputState>(
                builder: (context, state) {
                  if (state.status == EmployeeOutputStatus.loading) {
                    return Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state.status == EmployeeOutputStatus.failure) {
                    return _buildMessage(
                      context,
                      Icons.error_outline,
                      state.errorMessage ?? 'Unable to load details',
                    );
                  }

                  final response = state.employeeOutRepoDetailsEntity;

                  if (response == null) {
                    return Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final records = response.result;

                  if (records.isEmpty) {
                    return _buildMessage(
                      context,
                      Icons.inbox_outlined,
                      'No employee details found',
                    );
                  }

                  double totalExpense = 0;
                  double totalKm = 0;
                  int totalPresent = 0;

                  for (final item in records) {
                    totalExpense += double.tryParse(item.totalExpense) ?? 0;

                    totalKm += double.tryParse(item.totalKilometer) ?? 0;

                    if (item.presentStatus.trim().toUpperCase() == 'P') {
                      totalPresent++;
                    }
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SUMMARY CARDS
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                context,
                                title: 'Expense',
                                value: '₹${totalExpense.toStringAsFixed(2)}',

                                color: context.appColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _summaryCard(
                                context,
                                title: 'Kilometer',
                                value: totalKm.toStringAsFixed(1),

                                color: context.appColors.tertiary,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _summaryCard(
                                context,
                                title: 'Present',
                                value: '$totalPresent',

                                color: context.primaryColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Daily Expense & Attendance',
                          style: AppTextStyles.listTitle.copyWith(
                            color: context.cardTextColor,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // DETAILS TABLE
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 570,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Table(
                                border: TableBorder.all(
                                  color: context.borderColor,
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(1.5),
                                  1: FlexColumnWidth(1.2),
                                  2: FlexColumnWidth(),
                                  3: FlexColumnWidth(),
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  // TABLE HEADER
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: context.primaryColor.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                    children: [
                                      _tableCell(
                                        context,
                                        'Date',
                                        isHeader: true,
                                      ),
                                      _tableCell(
                                        context,
                                        'Expense (₹)',
                                        isHeader: true,
                                      ),
                                      _tableCell(context, 'KM', isHeader: true),
                                      _tableCell(
                                        context,
                                        'Status',
                                        isHeader: true,
                                      ),
                                    ],
                                  ),

                                  // DATA ROWS
                                  for (
                                    var index = 0;
                                    index < records.length;
                                    index++
                                  )
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: index.isEven
                                            ? context.cardBackgroundColor
                                            : context
                                                  .appColors
                                                  .surfaceContainerHighest,
                                      ),
                                      children: [
                                        _tableCell(
                                          context,
                                          records[index].date,
                                        ),
                                        _tableCell(
                                          context,
                                          records[index].totalExpense,
                                        ),
                                        _tableCell(
                                          context,
                                          records[index].totalKilometer,
                                        ),
                                        _statusCell(
                                          context,
                                          records[index].presentStatus,
                                        ),
                                      ],
                                    ),

                                  // TOTAL ROW
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: context.primaryColor.withValues(
                                        alpha: 0.08,
                                      ),
                                    ),
                                    children: [
                                      _tableCell(
                                        context,
                                        'TOTAL',
                                        isTotal: true,
                                      ),
                                      _tableCell(
                                        context,
                                        totalExpense.toStringAsFixed(2),
                                        isTotal: true,
                                      ),
                                      _tableCell(
                                        context,
                                        totalKm.toStringAsFixed(1),
                                        isTotal: true,
                                      ),
                                      _tableCell(
                                        context,
                                        'P - $totalPresent',
                                        isTotal: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Total records: ${records.length}',
                          style: AppTextStyles.caption.copyWith(
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // FOOTER
            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: context.primaryColor),
                  label: Text(
                    'Close',
                    style: AppTextStyles.body.copyWith(
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.primaryColor.withValues(alpha: 0.08),
            child: Icon(Icons.person_outline, color: context.primaryColor),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employeeName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 3),
                Text(
                  '$fromDate  to  $toDate',
                  style: AppTextStyles.caption.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String value,

    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.headingMedium.copyWith(color: color),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: AppTextStyles.helperText.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCell(
    BuildContext context,
    String value, {
    bool isHeader = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: AppTextStyles.buttonSmall.copyWith(
          fontWeight: isHeader || isTotal ? FontWeight.w800 : FontWeight.w500,
          color: isHeader || isTotal
              ? context.primaryColor
              : context.cardTextColor,
        ),
      ),
    );
  }

  Widget _statusCell(BuildContext context, String status) {
    final normalized = status.trim().toUpperCase();

    final isPresent = normalized == 'P';

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isPresent
                ? context.primaryColor.withValues(alpha: 0.08)
                : context.appColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            normalized,
            style: AppTextStyles.buttonSmall.copyWith(
              color: isPresent ? context.primaryColor : context.appColors.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, IconData icon, String message) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: context.secondaryTextColor),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}
