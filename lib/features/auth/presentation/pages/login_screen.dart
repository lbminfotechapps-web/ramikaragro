import 'dart:ui';

import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_button.dart';
import 'package:demo/core/utility/widgets/custom_text.dart';
import 'package:demo/core/utility/widgets/custom_textformfield.dart';
import 'package:demo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:demo/features/auth/presentation/bloc/auth_event.dart';

import 'package:demo/features/auth/presentation/bloc/auth_state.dart';
import 'package:demo/features/auth/presentation/widgets/app_logo.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.backgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.loginStatus == LoginStatus.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Login successful')));

            context.go('/home');
          } else if (state.loginStatus == LoginStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Login failed')),
            );
          }
        },
        builder: (context, state) {
          if (state.loginStatus == LoginStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(gradient: AppColors.appGradient),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 20.h,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo
                              logo(),

                              SizedBox(height: 18.h),

                              // Welcome title
                              CustomText(
                                text: 'Welcome Back',
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 6.h),

                              // Subtitle
                              CustomText(
                                text: 'Login to your account',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.8),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: 24.h),

                              // Login Card
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(18.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24.r),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 12.h),

                                        email(),

                                        SizedBox(height: 12.h),

                                        password(),

                                        SizedBox(height: 20.h),

                                        submitButton(),

                                        SizedBox(height: 8.h),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 20.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget email() {
    return CustomTextFormField(
      controller: _emailController,
      // labelText: AppLocalizations.of(context)!.email,
      hintText: 'Enter your username',
      prefixIcon: Icons.email,
      keyboardType: TextInputType.text,

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        return null;
      },
    );
  }

  Widget password() {
    return CustomTextFormField(
      controller: _passwordController,
      // labelText: AppLocalizations.of(context)!.password,
      hintText: 'Enter your password',
      prefixIcon: Icons.lock,
      suffixIcon: _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
      onSuffixIconTap: () {
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      },
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget submitButton() {
    return CustomButton(
      width: double.infinity,
      textSize: 15.sp,
      text: 'Login',
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
        }
      },
    );
  }
}
