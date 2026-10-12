import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:flutter/material.dart';

class DealerFilter extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onChanged;

  const DealerFilter({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final fromDate = today.subtract(Duration(days: selectedDays));

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 7),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: context.primaryColor,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Follow-up Period',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: context.primaryTextColor,
                    ),
                  ),
                ),
                Text(
                  '${_formatDate(fromDate)} - ${_formatDate(today)}',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Day selection
          Row(
            children: [
              _button(context, 30, '30'),
              _button(context, 45, '45'),
              _button(context, 60, '60'),
              _button(context, 90, '90'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, int days, String title) {
    final selected = selectedDays == days;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: selected ? null : () => onChanged(days),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? context.primaryColor
                    : context.appTheme.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? context.primaryColor : context.borderColor,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: context.primaryColor.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? context.onPrimaryColor
                          : context.primaryTextColor,
                    ),
                  ),
                  Text(
                    'Days',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? context.onPrimaryColor.withValues(alpha: 0.85)
                          : context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }
}
