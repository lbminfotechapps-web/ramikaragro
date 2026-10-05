import 'package:flutter/material.dart';
import 'package:solufine/core/di/auth_di.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/features/auth/provider/auth_provider.dart';

import 'connection_status_row.dart';

class AppStatusFrame extends StatefulWidget {
  const AppStatusFrame({super.key, required this.child});

  final Widget child;

  @override
  State<AppStatusFrame> createState() => _AppStatusFrameState();
}

class _AppStatusFrameState extends State<AppStatusFrame> {
  late final AuthProvider _auth;
  int _userId = 0;
  int _loadVersion = 0;

  @override
  void initState() {
    super.initState();
    _auth = sl<AuthProvider>();
    _auth.addListener(_loadUser);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final version = ++_loadVersion;
    try {
      final data = await SecureStorage.instance.getUserData();
      if (!mounted || version != _loadVersion) return;
      setState(() {
        _userId = int.tryParse(data?['user_id']?.toString() ?? '') ?? 0;
      });
    } catch (_) {
      if (!mounted || version != _loadVersion) return;
      setState(() => _userId = 0);
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_loadUser);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.primary,
    child: SafeArea(
      top: false,
      left: false,
      right: false,
      child: Column(
        children: [
          Expanded(child: widget.child),
          ConnectionStatusRow(userId: _userId),
        ],
      ),
    ),
  );
}
