import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:signature/signature.dart';

import '../../../../core/theme/app_theme_context.dart';

class SignatureSection extends StatefulWidget {
  final SignatureController controller;
  final VoidCallback onClear;
  final ValueChanged<Uint8List?> onSignatureChanged;

  const SignatureSection({
    super.key,
    required this.controller,
    required this.onClear,
    required this.onSignatureChanged,
  });

  @override
  State<SignatureSection> createState() => _SignatureSectionState();
}

class _SignatureSectionState extends State<SignatureSection> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_signatureChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_signatureChanged);
    super.dispose();
  }

  Future<void> _signatureChanged() async {
    if (widget.controller.isEmpty) {
      widget.onSignatureChanged(null);
      return;
    }

    final bytes = await widget.controller.toPngBytes();

    widget.onSignatureChanged(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.h, // COMPLETE CARD HEIGHT
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: context.appColors.shadow.withValues(alpha: 0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // HEADER
            SizedBox(
              height: 32.w,
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Icon(
                      Icons.draw_rounded,
                      color: context.primaryColor,
                      size: 17.sp,
                    ),
                  ),

                  SizedBox(width: 7.w),

                  Expanded(
                    child: Text(
                      'Signature *',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        color: context.primaryTextColor,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: widget.onClear,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: context.appColors.error,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 6.h),

            // SIGNATURE AREA
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.appTheme.inputBackground,
                  borderRadius: BorderRadius.circular(11.r),
                  border: Border.all(
                    color: context.primaryColor.withValues(alpha: 0.18),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11.r),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Signature(
                          controller: widget.controller,
                          backgroundColor: context.appTheme.inputBackground,
                        ),
                      ),

                      if (widget.controller.isEmpty)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.gesture_rounded,
                                    size: 22.sp,
                                    color: context.primaryColor.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    'Draw signature here',
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      color: context.secondaryTextColor
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
