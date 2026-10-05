import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_button.dart';
import 'package:solufine/core/utility/widgets/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ChangePassword extends StatefulWidget {
  
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitPasswordChange() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),

      appBar: CustomAppBar(
        title: 'Change Password',
        showBackButton: true,
        onBackTap: () {
          Navigator.pop(context);
        },
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   surfaceTintColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     onPressed: () => Navigator.of(context).pop(),
      //     icon: const Icon(
      //       Icons.arrow_back_ios_new_rounded,
      //       color: Colors.black,
      //     ),
      //   ),
      //   title: const Text(
      //     'Change Password',
      //     style: TextStyle(
      //       color: Colors.black,
      //       fontWeight: FontWeight.w700,
      //       fontSize: 20,
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 14.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 24.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 70.w,
                        height: 70.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.primaryGreen,
                          size: 34.sp,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'Secure your account',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Use a strong password with at least 8 characters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textGrey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Old Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: _oldPasswordController,
                  hintText: 'Enter old password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureOldPassword,
                  suffixIcon: _obscureOldPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixIconTap: () => setState(() {
                    _obscureOldPassword = !_obscureOldPassword;
                  }),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Please enter your old password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18.h),
                Text(
                  'New Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: _newPasswordController,
                  hintText: 'Enter new password',
                  prefixIcon: Icons.key_rounded,
                  obscureText: _obscureNewPassword,
                  suffixIcon: _obscureNewPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixIconTap: () => setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  }),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Please enter your new password';
                    }
                    if ((value ?? '').trim().length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                // SizedBox(height: 18.h),
                // Text(
                //   'Confirm Password',
                //   style: TextStyle(
                //     fontSize: 14.sp,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.textDark,
                //   ),
                // ),
                // SizedBox(height: 8.h),
                // CustomTextFormField(
                //   controller: _confirmPasswordController,
                //   hintText: 'Re-enter new password',
                //   prefixIcon: Icons.lock_reset_rounded,
                //   obscureText: _obscureConfirmPassword,
                //   suffixIcon: _obscureConfirmPassword
                //       ? Icons.visibility_off_outlined
                //       : Icons.visibility_outlined,
                //   onSuffixIconTap: () => setState(() {
                //     _obscureConfirmPassword = !_obscureConfirmPassword;
                //   }),
                //   validator: (value) {
                //     if ((value ?? '').trim().isEmpty) {
                //       return 'Please confirm your new password';
                //     }
                //     if (value != _newPasswordController.text) {
                //       return 'Passwords do not match';
                //     }
                //     return null;
                //   },
                // ),
                SizedBox(height: 26.h),
                CustomButton(
                  text: 'Update Password',
                  icon: Icon(Icons.check_rounded, size: 20.sp),
                  onPressed: _submitPasswordChange,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
