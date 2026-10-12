import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

class EmployeeOutputEmpty extends StatelessWidget {
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

      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),

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
              shape: BoxShape.circle,
            ),

            child: Icon(icon, size: 30, color: context.primaryColor),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: context.cardTextColor,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: context.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}
