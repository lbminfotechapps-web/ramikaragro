import 'package:flutter/material.dart';

class EmployeeOutputEmpty
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmployeeOutputEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 45,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,

            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFEAF6EE),
              shape:
                  BoxShape.circle,
            ),

            child: Icon(
              icon,
              size: 30,
              color:
                  const Color(0xFF287A4B),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
              color:
                  Color(0xFF202923),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 11,
              color:
                  Color(0xFF7A837E),
            ),
          ),
        ],
      ),
    );
  }
}