import 'package:flutter/material.dart';

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
        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF202923),
          ),
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder.all(color: const Color(0xFFDCE7DF)),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFEAF6EE)),
                children: [
                  _tableCell('Dealer', isHeader: true),
                  _tableCell('Farmer', isHeader: true),
                  _tableCell('Location', isHeader: true),
                  _tableCell('Total Visits', isHeader: true),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(color: Colors.white),
                children: [
                  _tableCell('$totalDealerVisits'),
                  _tableCell('$totalFarmerVisits'),
                  _tableCell('$totalLocations'),
                  _tableCell('$totalVisits'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 12 : 14,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w800,
          color: isHeader ? const Color(0xFF287A4B) : const Color(0xFF202923),
        ),
      ),
    );
  }
}
