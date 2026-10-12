import 'package:solufine/core/di/auth_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/appname.dart';
import 'package:solufine/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final authProvider = sl<AuthProvider>();

    await authProvider.checkLoginStatus();

    if (!mounted) return;

    // Always open home.
    context.go(AppRouter.home);
  }
  // Future<void> _checkLogin() async {
  //   final authProvider = sl<AuthProvider>();

  //   await authProvider.checkLoginStatus();

  //   if (!mounted) return;
  //   context.go(authProvider.isLoggedIn ? '/home' : '/home');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: context.primaryColor),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.shadow.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/icons/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                appName,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: context.onPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Loading your workspace...',
                style: TextStyle(
                  fontSize: 16,
                  color: context.onPrimaryColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  backgroundColor: context.onPrimaryColor.withValues(
                    alpha: 0.24,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.onPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
