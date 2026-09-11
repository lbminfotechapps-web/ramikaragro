import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class CustomLoader extends StatelessWidget {
  final String? message;
  final double? size;
  final double? strokeWidth;
  final Color? color;
  final bool showMessage;

  const CustomLoader({
    super.key,
    this.message,
    this.size,
    this.strokeWidth,
    this.color,
    this.showMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final loaderColor = color ?? const Color(0xFF087C3A);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: (size ?? 42).w,
            height: (size ?? 42).h,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth ?? 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                loaderColor,
              ),
            ),
          ),

          if (showMessage && message != null) ...[
            SizedBox(height: 12.h),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}