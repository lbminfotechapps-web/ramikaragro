import 'dart:io';

import 'package:demo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerSection extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String?> onChanged;

  const ImagePickerSection({
    super.key,
    required this.imagePath,
    required this.onChanged,
  });

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      onChanged(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        imagePath != null && imagePath!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: hasImage
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.file(
                    File(imagePath!),
                    width: double.infinity,
                    height: 190.h,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Row(
                    children: [
                      _ActionButton(
                        icon: Icons.camera_alt_rounded,
                        onTap: _pickImage,
                      ),

                      SizedBox(width: 8.w),

                      _ActionButton(
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.error,
                        onTap: () {
                          onChanged(null);
                        },
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 10.w,
                  bottom: 10.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 15.sp,
                        ),

                        SizedBox(width: 5.w),

                        Text(
                          '1 photo selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(14.r),
              child: Container(
                width: double.infinity,
                height: 170.h,
                decoration: BoxDecoration(
                  color:
                      AppColors.lightGreen.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color:
                        AppColors.primary.withOpacity(0.25),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 58.w,
                      height: 58.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(18.r),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Text(
                      'Add Order Photo',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      'Tap to open camera',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.black.withOpacity(0.55),
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: SizedBox(
          width: 38.w,
          height: 38.w,
          child: Icon(
            icon,
            color: Colors.white,
            size: 19.sp,
          ),
        ),
      ),
    );
  }
}