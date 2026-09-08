import 'package:flutter/material.dart';

class VisitSummaryEmpty extends StatelessWidget {
  const VisitSummaryEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EE),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 31,
              color: Color(0xFF287A4B),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'No Visit Summary Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF28312C),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'There are no visit records for the selected date range.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7B847F),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}