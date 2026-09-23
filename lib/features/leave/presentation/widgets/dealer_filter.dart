import 'package:flutter/material.dart';

class DealerFilter extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onChanged;

  const DealerFilter({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  static const Color primaryGreen = Color(0xFF168A4A);
  static const Color darkText = Color(0xFF17212B);
  static const Color greyText = Color(0xFF667085);
  static const Color borderColor = Color(0xFFE7ECE9);
  static const Color backgroundColor = Color(0xFFF5F8F6);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final fromDate = today.subtract(
      Duration(days: selectedDays),
    );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
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
                    color: primaryGreen.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Follow-up Period',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                ),
                Text(
                  '${_formatDate(fromDate)} - ${_formatDate(today)}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: greyText,
                  ),
                ),
              ],
            ),
          ),

          // Day selection
          Row(
            children: [
              _button(30, '30'),
              _button(45, '45'),
              _button(60, '60'),
              _button(90, '90'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button(
    int days,
    String title,
  ) {
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
                    ? primaryGreen
                    : backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? primaryGreen
                      : borderColor,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.18),
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
                          ? Colors.white
                          : darkText,
                    ),
                  ),
                  Text(
                    'Days',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white.withOpacity(0.85)
                          : greyText,
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