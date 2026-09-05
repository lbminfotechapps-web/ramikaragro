import 'dart:io';

import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/app_image_picker.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/utility/widgets/custom_button.dart';
import 'package:demo/core/utility/widgets/custom_textformfield.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

class PunchScreen extends StatefulWidget {
  final PunchStatEntity? punchStat;

  const PunchScreen({super.key, this.punchStat});

  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  final _formKey = GlobalKey<FormState>();

  File? _uploadedImage;

  final TextEditingController openingKmController = TextEditingController();

  final TextEditingController closingKmController = TextEditingController();

  final TextEditingController routeController = TextEditingController();

  final TextEditingController remarkController = TextEditingController();

  String selectedVehicle = 'Bike';

  bool get isPunchIn => widget.punchStat?.inOutStatus != '0';

  @override
  void initState() {
    super.initState();

    print('punch status $isPunchIn');
    if (!isPunchIn) {
      openingKmController.text = widget.punchStat?.startingKm ?? '';
    }
  }

  Future<void> _captureImage() async {
    try {
      final File? image = await AppImagePicker.instance.pickFromCamera();

      if (image == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _uploadedImage = image;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to capture image')));
    }
  }

  @override
  void dispose() {
    openingKmController.dispose();
    closingKmController.dispose();
    routeController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      appBar: CustomAppBar(
        title: isPunchIn ? 'Punch Out' : 'Punch In',
        showBackButton: true,
        onBackTap: () => context.go(AppRouter.home),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: [
                  SizedBox(height: 14.h),
                  _vehicleDropdown(),

                  SizedBox(height: 14.h),

                  Row(
                    children: [
                      Expanded(
                        child: _kmField(
                          controller: openingKmController,
                          hintText: 'Opening KM',
                          enabled: !isPunchIn,
                          validator: (value) =>
                              _validateKm(value, 'Opening KM'),
                        ),
                      ),

                      SizedBox(width: 14.w),

                      Expanded(
                        child: _kmField(
                          controller: closingKmController,
                          hintText: 'Closing KM',
                          enabled: isPunchIn,
                          validator: (value) =>
                              _validateKm(value, 'Closing KM'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  // Route
                  _textField(
                    controller: routeController,
                    hintText: 'Enter Route*',
                    icon: Icons.route_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter route';
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 14.h),

                  // Remark
                  _textField(
                    controller: remarkController,
                    hintText: 'Enter Remark',
                    icon: Icons.note_add_outlined,
                    maxLines: 1,
                  ),

                  SizedBox(height: 14.h),

                  // Upload photo
                  FormField<bool>(
                    initialValue: _uploadedImage != null,
                    validator: (_) {
                      if (_uploadedImage == null) {
                        return 'Please upload an image';
                      }

                      return null;
                    },
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _uploadPhotoCard(),
                          if (field.hasError)
                            Padding(
                              padding: EdgeInsets.only(left: 16.w, top: 4.h),
                              child: Text(
                                field.errorText!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 14.h),

                  // Submit
                  _submitButton(),
                  SizedBox(height: 14.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // VEHICLE DROPDOWN
  // ------------------------------------------------------------

  Widget _vehicleDropdown() {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedVehicle,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade500,
          ),
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            DropdownMenuItem(value: 'Bike', child: Text('Bike')),
            DropdownMenuItem(value: 'Car', child: Text('Car')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedVehicle = value;
            });
          },
        ),
      ),
    );
  }

  Widget _kmField({
    required TextEditingController controller,
    required String hintText,
    required bool enabled,
    required String? Function(String?) validator,
  }) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      prefixIcon: Icons.speed_outlined,
      keyboardType: TextInputType.number,
      enabled: enabled,
      validator: enabled ? validator : null,
    );
  }

  String? _validateKm(String? value, String fieldName) {
    final text = value?.trim() ?? '';
    final km = double.tryParse(text);

    if (text.isEmpty) {
      return '$fieldName is required';
    }

    if (km == null || km < 0) {
      return 'Enter a valid $fieldName';
    }

    return null;
  }

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return CustomTextFormField(
      controller: controller,
      hintText: hintText,
      prefixIcon: icon,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _uploadPhotoCard() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Upload header
          InkWell(
            onTap: _captureImage,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F8EB),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF00A83B),
                      size: 22.sp,
                    ),
                  ),

                  SizedBox(width: 14.w),

                  Expanded(
                    child: Text(
                      'Upload Photo',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade500,
                    size: 28.sp,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Image capture area
          InkWell(
            onTap: _captureImage,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              height: 260.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _uploadedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 52.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Tap to capture image',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.file(
                        _uploadedImage!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return CustomButton(
      width: double.infinity,
      textSize: 15.sp,
      text: 'SUBMIT',
      onPressed: () {
        if (_formKey.currentState!.validate()) {}
      },
    );
  }
}
