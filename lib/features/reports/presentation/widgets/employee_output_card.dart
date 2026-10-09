import 'package:flutter/material.dart';

import '../../domain/entities/employee_output_report.dart';

class EmployeeOutputCard extends StatelessWidget {
  final List<EmployeeOutputReport> reports;
  final ValueChanged<EmployeeOutputReport> onEmployeeTap;

  const EmployeeOutputCard({
    super.key,
    required this.reports,
    required this.onEmployeeTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 560
            ? 560.0
            : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                  4: FlexColumnWidth(1.2),
                },
                defaultVerticalAlignment:
                    TableCellVerticalAlignment.middle,
                border: TableBorder.all(
                  color: const Color(0xFFDCE7DF),
                ),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF6EE),
                    ),
                    children: [
                      _cell(
                        'Employee Name',
                        isHeader: true,
                        isName: true,
                      ),
                      _cell('Dealer', isHeader: true),
                      _cell('Farmer', isHeader: true),
                      _cell('Location', isHeader: true),
                      _cell('Total Visits', isHeader: true),
                    ],
                  ),

                  for (var index = 0;
                      index < reports.length;
                      index++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? Colors.white
                            : const Color(0xFFF7F9F8),
                      ),
                      children: [
                        _clickableCell(
                          reports[index].empName,
                          reports[index],
                          isName: true,
                        ),
                        _clickableCell(
                          reports[index].outletCnt,
                          reports[index],
                        ),
                        _clickableCell(
                          reports[index].farmerCnt,
                          reports[index],
                        ),
                        _clickableCell(
                          reports[index].currentCnt,
                          reports[index],
                        ),
                        _clickableCell(
                          reports[index].totalVisits,
                          reports[index],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _clickableCell(
    String value,
    EmployeeOutputReport report, {
    bool isName = false,
  }) {
    return InkWell(
      onTap: () => onEmployeeTap(report),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),
        child: Row(
          mainAxisAlignment: isName
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                value,
                textAlign: isName
                    ? TextAlign.left
                    : TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isName
                      ? const Color(0xFF287A4B)
                      : const Color(0xFF202923),
                ),
              ),
            ),
            if (isName) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Color(0xFF287A4B),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cell(
    String value, {
    bool isHeader = false,
    bool isName = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      child: Text(
        value,
        textAlign:
            isName ? TextAlign.left : TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              isHeader ? FontWeight.w800 : FontWeight.w600,
          color: isHeader
              ? const Color(0xFF287A4B)
              : const Color(0xFF202923),
        ),
      ),
    );
  }
}
