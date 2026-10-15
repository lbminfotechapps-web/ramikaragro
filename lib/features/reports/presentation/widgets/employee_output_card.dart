import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

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
        final width = constraints.maxWidth < 560 ? 560.0 : constraints.maxWidth;

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
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(color: context.borderColor),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.08),
                    ),
                    children: [
                      _cell(
                        context,
                        'Employee Name',
                        isHeader: true,
                        isName: true,
                      ),
                      _cell(context, 'Dealer', isHeader: true),
                      _cell(context, 'Farmer', isHeader: true),
                      _cell(context, 'Location', isHeader: true),
                      _cell(context, 'Total Visits', isHeader: true),
                    ],
                  ),

                  for (var index = 0; index < reports.length; index++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? context.cardBackgroundColor
                            : context.appColors.surfaceContainerHighest,
                      ),
                      children: [
                        _clickableCell(
                          context,
                          reports[index].empName,
                          reports[index],
                          isName: true,
                        ),
                        _clickableCell(
                          context,
                          reports[index].outletCnt,
                          reports[index],
                        ),
                        _clickableCell(
                          context,
                          reports[index].farmerCnt,
                          reports[index],
                        ),
                        _clickableCell(
                          context,
                          reports[index].currentCnt,
                          reports[index],
                        ),
                        _clickableCell(
                          context,
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
    BuildContext context,
    String value,
    EmployeeOutputReport report, {
    bool isName = false,
  }) {
    return InkWell(
      onTap: () => onEmployeeTap(report),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Row(
          mainAxisAlignment: isName
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                value,
                textAlign: isName ? TextAlign.left : TextAlign.center,
                style: AppTextStyles.buttonSmall.copyWith(
                  color: isName ? context.primaryColor : context.cardTextColor,
                ),
              ),
            ),
            if (isName) ...[
              const SizedBox(width: 5),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: context.primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    String value, {
    bool isHeader = false,
    bool isName = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        value,
        textAlign: isName ? TextAlign.left : TextAlign.center,
        style: AppTextStyles.buttonSmall.copyWith(
          fontWeight: isHeader ? FontWeight.w800 : FontWeight.w600,
          color: isHeader ? context.primaryColor : context.cardTextColor,
        ),
      ),
    );
  }
}
