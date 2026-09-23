import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_colors.dart';

class ModernDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const ModernDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // LABEL
        // ==========================================================

        Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        // ==========================================================
        // DROPDOWN
        // ==========================================================

        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,

          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 23.sp,
          ),

          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),

          dropdownColor: Colors.white,

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),

            prefixIcon: Container(
              margin: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 19.sp,
              ),
            ),

            filled: true,
            fillColor: Colors.white,

            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: AppColors.border.withOpacity(0.7),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
          ),

          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}