import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

import '../../domain/entities/employee_output_report.dart';

class EmployeeOutputStatistics extends StatelessWidget {
  final List<EmployeeOutputReport> reports;

  const EmployeeOutputStatistics({super.key, required this.reports});

  int _toInt(String value) {
    return int.tryParse(value) ?? 0;
  }

  int get totalDealerVisits {
    return reports.fold(0, (sum, item) => sum + _toInt(item.outletCnt));
  }

  int get totalFarmerVisits {
    return reports.fold(0, (sum, item) => sum + _toInt(item.farmerCnt));
  }

  int get totalLocations {
    return reports.fold(0, (sum, item) => sum + _toInt(item.currentCnt));
  }

  int get totalVisits {
    return reports.fold(0, (sum, item) => sum + _toInt(item.totalVisits));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: AppTextStyles.cardTitle.copyWith(color: context.cardTextColor),
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(color: context.borderColor),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.08),
                ),
                children: [
                  _tableCell(context, 'Dealer', isHeader: true),
                  _tableCell(context, 'Farmer', isHeader: true),
                  _tableCell(context, 'Location', isHeader: true),
                  _tableCell(context, 'Total Visits', isHeader: true),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: context.cardBackgroundColor),
                children: [
                  _tableCell(context, '$totalDealerVisits'),
                  _tableCell(context, '$totalFarmerVisits'),
                  _tableCell(context, '$totalLocations'),
                  _tableCell(context, '$totalVisits'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableCell(
    BuildContext context,
    String text, {
    bool isHeader = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: (isHeader ? AppTextStyles.tableHeader : AppTextStyles.tableCell)
            .copyWith(
              color: isHeader ? context.primaryColor : context.cardTextColor,
            ),
      ),
    );
  }
}
