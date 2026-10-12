import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

class VisitSummaryEmpty extends StatelessWidget {
  const VisitSummaryEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 31,
              color: context.primaryColor,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'No Visit Summary Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.cardTextColor,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'There are no visit records for the selected date range.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: context.secondaryTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
