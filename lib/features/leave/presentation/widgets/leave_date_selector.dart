import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaveDateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const LeaveDateSelector({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = date == null
        ? "Select Date"
        : DateFormat(
            "dd-MM-yyyy",
          ).format(date!);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
            ),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 7),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 18,
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}