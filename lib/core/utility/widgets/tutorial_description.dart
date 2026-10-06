import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/app_tutorial_service.dart';

class TutorialDescription extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final bool isLast;

  const TutorialDescription({super.key, 
    required this.step,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ====================================================
          // STEP
          // ====================================================
          Text(
            step,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          // ====================================================
          // TITLE
          // ====================================================
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              color: Color(0xFF18231C),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          // ====================================================
          // DESCRIPTION
          // ====================================================
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF606A64),
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 14),

          // ====================================================
          // SKIP + NEXT
          // ====================================================
          Row(
            children: [
              TextButton(
                onPressed: () {
                  AppTutorialService.skip();
                },
                child: const Text(
                  'SKIP',
                  style: TextStyle(
                    color: Color(0xFF747C77),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(),

              FilledButton(
                onPressed: () {
                  AppTutorialService.next();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isLast ? 'DONE' : 'NEXT',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}