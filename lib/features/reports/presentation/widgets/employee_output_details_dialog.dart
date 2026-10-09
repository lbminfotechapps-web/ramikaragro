import 'package:flutter/material.dart';
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
      backgroundColor: Colors.white,
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
                    return const Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state.status == EmployeeOutputStatus.failure) {
                    return _buildMessage(
                      Icons.error_outline,
                      state.errorMessage ?? 'Unable to load details',
                    );
                  }

                  final response = state.employeeOutRepoDetailsEntity;

                  if (response == null) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final records = response.result;

                  if (records.isEmpty) {
                    return _buildMessage(
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
                                title: 'Expense',
                                value: '₹${totalExpense.toStringAsFixed(2)}',

                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _summaryCard(
                                title: 'Kilometer',
                                value: totalKm.toStringAsFixed(1),

                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _summaryCard(
                                title: 'Present',
                                value: '$totalPresent',

                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Daily Expense & Attendance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF202923),
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
                                  color: const Color(0xFFDCE7DF),
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
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEAF6EE),
                                    ),
                                    children: [
                                      _tableCell('Date', isHeader: true),
                                      _tableCell('Expense (₹)', isHeader: true),
                                      _tableCell('KM', isHeader: true),
                                      _tableCell('Status', isHeader: true),
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
                                            ? Colors.white
                                            : const Color(0xFFF7F9F8),
                                      ),
                                      children: [
                                        _tableCell(records[index].date),
                                        _tableCell(records[index].totalExpense),
                                        _tableCell(
                                          records[index].totalKilometer,
                                        ),
                                        _statusCell(
                                          records[index].presentStatus,
                                        ),
                                      ],
                                    ),

                                  // TOTAL ROW
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFDDF1E4),
                                    ),
                                    children: [
                                      _tableCell('TOTAL', isTotal: true),
                                      _tableCell(
                                        totalExpense.toStringAsFixed(2),
                                        isTotal: true,
                                      ),
                                      _tableCell(
                                        totalKm.toStringAsFixed(1),
                                        isTotal: true,
                                      ),
                                      _tableCell(
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
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
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
                  icon: const Icon(Icons.close,color: Colors.green,),
                  label: const Text('Close',style: TextStyle(color: Colors.green,),),
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
      decoration: const BoxDecoration(
        color: Color(0xFFEAF6EE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFD2E9D8),
            child: Icon(Icons.person_outline, color: Color(0xFF287A4B)),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$fromDate  to  $toDate',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
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
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _tableCell(
    String value, {
    bool isHeader = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader || isTotal ? FontWeight.w800 : FontWeight.w500,
          color: isHeader || isTotal
              ? const Color(0xFF287A4B)
              : const Color(0xFF202923),
        ),
      ),
    );
  }

  Widget _statusCell(String status) {
    final normalized = status.trim().toUpperCase();

    final isPresent = normalized == 'P';

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isPresent
                ? const Color(0xFFE2F5E9)
                : const Color(0xFFFFE9E9),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            normalized,
            style: TextStyle(
              color: isPresent
                  ? const Color(0xFF16834B)
                  : const Color(0xFFD33B3B),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(IconData icon, String message) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
