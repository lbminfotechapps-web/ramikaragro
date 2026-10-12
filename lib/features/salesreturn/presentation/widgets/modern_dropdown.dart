import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../../../core/theme/app_theme_context.dart';

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
        Row(
          children: [
            Icon(icon, size: 16.sp, color: context.primaryColor),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: context.primaryTextColor,
              ),
            ),
          ],
        ),

        SizedBox(height: 8.h),

        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,

          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.primaryColor,
            size: 23.sp,
          ),

          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),

          dropdownColor: context.cardBackgroundColor,

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: context.secondaryTextColor,
            ),

            prefixIcon: Container(
              margin: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: context.primaryColor, size: 19.sp),
            ),

            filled: true,
            fillColor: context.appTheme.inputBackground,

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
                color: context.borderColor.withValues(alpha: 0.7),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: context.primaryColor, width: 1.4),
            ),
          ),

          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
