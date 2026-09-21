
import 'dart:io';

import 'package:solufine/core/theme/app_colors.dart';
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

    return SizedBox(
      height: 150.h,
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: hasImage
            ? Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.r),
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Camera + Delete
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: Row(
                      children: [
                        _ActionButton(
                          icon: Icons.camera_alt_rounded,
                          onTap: _pickImage,
                        ),
                        SizedBox(width: 5.w),
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

                  // Selected label
                  Positioned(
                    left: 6.w,
                    bottom: 6.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 13.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Photo selected',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5.sp,
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
                borderRadius: BorderRadius.circular(11.r),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(11.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 21.sp,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      Text(
                        'Add Order Photo',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        'Tap to open camera',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
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
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: 30.w,
          height: 30.w,
          child: Icon(
            icon,
            color: Colors.white,
            size: 16.sp,
          ),
        ),
      ),
    );
  }
}

