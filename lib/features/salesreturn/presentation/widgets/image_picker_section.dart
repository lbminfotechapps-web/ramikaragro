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

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // ------------------------------------------------------
    // SELECT CAMERA OR GALLERY
    // ------------------------------------------------------

    final ImageSource? source =
        await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Select Photo',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  'Choose where you want to get the photo from',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 18.h),

                // Camera + Gallery
                Row(
                  children: [
                    Expanded(
                      child: _ImageSourceButton(
                        icon: Icons.camera_alt_rounded,
                        title: 'Camera',
                        onTap: () {
                          Navigator.pop(
                            context,
                            ImageSource.camera,
                          );
                        },
                      ),
                    ),

                    SizedBox(width: 12.w),

                    Expanded(
                      child: _ImageSourceButton(
                        icon: Icons.photo_library_rounded,
                        title: 'Gallery',
                        onTap: () {
                          Navigator.pop(
                            context,
                            ImageSource.gallery,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),
              ],
            ),
          ),
        );
      },
    );

    // User closed the bottom sheet
    if (source == null) {
      return;
    }

    // ------------------------------------------------------
    // PICK IMAGE
    // ------------------------------------------------------

    final XFile? image = await picker.pickImage(
      source: source,
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
                  // --------------------------------------------------
                  // SELECTED IMAGE
                  // --------------------------------------------------

                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.r),
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // --------------------------------------------------
                  // CAMERA + DELETE BUTTONS
                  // --------------------------------------------------

                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: Row(
                      children: [
                        _ActionButton(
                          icon: Icons.camera_alt_rounded,
                          onTap: () => _pickImage(context),
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

                  // --------------------------------------------------
                  // SELECTED LABEL
                  // --------------------------------------------------

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

            // --------------------------------------------------------
            // NO IMAGE
            // --------------------------------------------------------

            : InkWell(
                onTap: () => _pickImage(context),
                borderRadius: BorderRadius.circular(11.r),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        AppColors.lightGreen.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(11.r),
                    border: Border.all(
                      color:
                          AppColors.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius:
                              BorderRadius.circular(13.r),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 21.sp,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      Text(
                        'Add Order Photo *',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        'Tap to open camera or gallery',
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

// ============================================================
// IMAGE SOURCE BUTTON
// ============================================================

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightGreen.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.25),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 28.sp,
            ),

            SizedBox(height: 7.h),

            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ACTION BUTTON
// ============================================================

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