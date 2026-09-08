import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_button.dart';
import 'package:demo/core/utility/widgets/custom_textformfield.dart';
import 'package:demo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:demo/features/auth/presentation/bloc/auth_event.dart';

import 'package:demo/features/auth/presentation/bloc/auth_state.dart';

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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.loginStatus == LoginStatus.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Login successful')));

            context.go('/home');
          }

          if (state.loginStatus == LoginStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Login failed')),
            );
          }
        },

        builder: (context, state) {
          if (state.loginStatus == LoginStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF087C3A)),
            );
          }

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  // =========================
                  // HERO SECTION
                  // =========================
                  _heroSection(),

                  // =========================
                  // LOGIN SECTION
                  // =========================
                  _loginSection(),

                  _bottomLogo(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _heroSection() {
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.38).clamp(
      180.0,
      340.0,
    );

    return Stack(
      children: [
        // Farm background
        SizedBox(
          height: heroHeight,
          child: Image.asset(
            'assets/images/login_background.png',
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),

        // RAI Logo
        Positioned(
          top: heroHeight * 0.08,
          left: 18.w,
          child: _raiLogo(heroHeight),
        ),
      ],
    );
  }

  // ============================================================
  // RAI LOGO
  // ============================================================

  Widget _raiLogo(double heroHeight) {
    final logoSize = heroHeight * 0.9;

    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: 0.55,
          heightFactor: 0.60,
          child: Image.asset(
            'assets/images/rai_logo.jpg.png',
            width: logoSize * 2,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // Widget _bottomLogo() {
  //   return SizedBox(
  //     width: double.infinity,
  //     // height: 100.h,
  //     child: ClipRect(
  //       child: Align(
  //         alignment: Alignment.topLeft,
  //         widthFactor: 0.55,
  //         heightFactor: 0.60,
  //         child: Image.asset(
  //           'assets/images/login_bottom_logo.png',
  //           width: double.infinity,
  //           fit: BoxFit.contain,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ============================================================
  // LOGIN SECTION
  // ============================================================

  Widget _loginSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),

            // Title
            Text(
              'Login to your account',
              style: TextStyle(
                color: Color(0xFF087C3A),
                fontSize: 25.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 4.h),

            // Subtitle
            Text(
              'Welcome back! Please login to continue.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 10.h),

            // Mobile
            email(),

            SizedBox(height: 15.h),

            // Password
            password(),

            SizedBox(height: 10.h),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // Forgot password
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF087C3A),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            submitButton(),

            // const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMAIL / MOBILE
  // ============================================================

  Widget email() {
    return CustomTextFormField(
      controller: _emailController,
      hintText: 'Enter Usrname',
      prefixIcon: Icons.person_outline,
      keyboardType: TextInputType.text,

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }

        return null;
      },
    );
  }

  Widget _bottomLogo() {
    return SizedBox(
      width: double.infinity,
      height: 100.h,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topLeft,
          // widthFactor: 0.55,
          // heightFactor: 0.60,
          child: Image.asset(
            'assets/images/login_bottom_logo.png',
            width: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PASSWORD
  // ============================================================

  Widget password() {
    return CustomTextFormField(
      controller: _passwordController,
      hintText: 'Password',
      prefixIcon: Icons.lock_outline,

      suffixIcon: _isPasswordVisible
          ? Icons.visibility_off_outlined
          : Icons.visibility_outlined,

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

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget submitButton() {
    return CustomButton(
      width: double.infinity,
      textSize: 15.sp,
      text: 'LOGIN',
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
