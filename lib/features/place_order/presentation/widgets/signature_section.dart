import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:signature/signature.dart';

import '../../../../core/theme/app_colors.dart';

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
  State<SignatureSection> createState() =>
      _SignatureSectionState();
}

class _SignatureSectionState
    extends State<SignatureSection> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(
      _signatureChanged,
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(
      _signatureChanged,
    );

    super.dispose();
  }

  Future<void> _signatureChanged() async {
    if (widget.controller.isEmpty) {
      widget.onSignatureChanged(null);
      return;
    }

    final bytes =
        await widget.controller.toPngBytes();

    widget.onSignatureChanged(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ========================================================
          // HEADER
          // ========================================================

          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius:
                      BorderRadius.circular(11.r),
                ),
                child: Icon(
                  Icons.draw_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dealer Signature',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Sign inside the box',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: widget.onClear,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ========================================================
          // SIGNATURE BOX
          // ========================================================

          Container(
            height: 175.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCFA),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.18),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Stack(
                children: [
                  Signature(
                    controller: widget.controller,
                    backgroundColor:
                        const Color(0xFFFAFCFA),
                  ),

                  // Center hint
                  if (widget.controller.isEmpty)
                    IgnorePointer(
                      child: Center(
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.gesture_rounded,
                              size: 30.sp,
                              color: AppColors.primary
                                  .withOpacity(0.25),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              'Draw signature here',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors
                                    .textSecondary
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}