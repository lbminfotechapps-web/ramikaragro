import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'leave_date_selector.dart';

class LeaveFilterCard extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const LeaveFilterCard({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onFromDateTap,
    required this.onToDateTap,
    required this.onApply,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                LeaveDateSelector(
                  label: "From Date",
                  date: fromDate,
                  onTap: onFromDateTap,
                ),

                const SizedBox(width: 10),

                LeaveDateSelector(
                  label: "To Date",
                  date: toDate,
                  onTap: onToDateTap,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClear,
                    child: const Text(
                      "Clear",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onApply,
                    child: const Text(
                      "Apply",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat(
      "yyyy-MM-dd",
    ).format(date);
  }
}