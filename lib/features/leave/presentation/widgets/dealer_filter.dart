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
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _button(30, '30 Days'),
          _button(45, '45 Days'),
          _button(60, '60 Days'),
          _button(90, '90 Days'),
        ],
      ),
    );
  }

  Widget _button(
    int days,
    String title,
  ) {
    final selected =
        selectedDays == days;

    return Expanded(
      child: GestureDetector(
        onTap: selected
            ? null
            : () => onChanged(days),
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          margin:
              const EdgeInsets.symmetric(
            horizontal: 2,
          ),
          padding:
              const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2E7D32)
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
              color: selected
                  ? Colors.white
                  : const Color(0xFF667085),
            ),
          ),
        ),
      ),
    );
  }
}