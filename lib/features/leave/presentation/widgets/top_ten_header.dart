import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:flutter/material.dart';


class TopTenHeader extends StatelessWidget {
  final int selectedDays;
  final int count;

  const TopTenHeader({
    super.key,
    required this.selectedDays,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.20),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: context.onPrimaryColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: context.onPrimaryColor,
              size: 29,
            ),
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Dealer Performance',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: context.onPrimaryColor,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Top 10 dealers in last $selectedDays days',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.onPrimaryColor.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: context.onPrimaryColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelLarge.copyWith(
                color: context.onPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
