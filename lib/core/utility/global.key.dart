import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/utility/widgets/bottom_navigation.dart';

final GlobalKey<HomeShellState> homeShellKey = GlobalKey<HomeShellState>();

void goToHomeAndRefresh(BuildContext context) {
  context.go(AppRouter.home);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    homeShellKey.currentState?.refreshHome();
  });
}