import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
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
        : DateFormat("dd-MM-yyyy").format(date!);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: context.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),

              const SizedBox(height: 7),

              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: context.primaryColor,
                    size: 18,
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(formattedDate, style: AppTextStyles.labelLarge),
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
