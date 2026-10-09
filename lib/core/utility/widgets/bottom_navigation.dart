import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/core/utility/tab_refresh.dart';
import 'package:solufine/core/di/auth_di.dart';
import 'package:solufine/features/auth/provider/auth_provider.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:solufine/features/home/presentation/home_bloc/home_event.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  GoRouterDelegate? _routerDelegate;
  late final AuthProvider _authProvider;

  List<int> get _visibleTabIndices => _userId > 0 ? [0, 1, 2, 3] : [0, 3];

  int _userId = 0;
  String _username = 'user';

  bool _isUserLoaded = false;

  String? _lastLocation;

  /// Prevents scheduling multiple Home refreshes
  /// during the same frame.
  bool _homeRefreshScheduled = false;

  static const _tabs = [
    // INDEX 0
    (path: AppRouter.home, icon: Icons.home_rounded, label: 'Home'),

    // INDEX 1
    (
      path: AppRouter.followup,
      icon: Icons.assignment_rounded,
      label: 'Follow up',
    ),

    (
      path: AppRouter.reportPage,
      icon: Icons.bar_chart_rounded,
      label: 'Report',
    ),

    (
      path: AppRouter.products,
      icon: Icons.inventory_2_rounded,
      label: 'Products',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _authProvider = sl<AuthProvider>();
    _authProvider.addListener(_onAuthChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await _refreshHome();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delegate = GoRouter.of(context).routerDelegate;
    if (identical(_routerDelegate, delegate)) return;

    _routerDelegate?.removeListener(_checkHomeNavigation);
    _routerDelegate = delegate;
    _lastLocation = delegate.state.uri.path;
    delegate.addListener(_checkHomeNavigation);
  }

  void _onAuthChanged() {
    if (!mounted || _authProvider.isChecking) return;
    _refreshHome();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    _routerDelegate?.removeListener(_checkHomeNavigation);
    super.dispose();
  }

  Future<void> refreshHome() async {
    if (!mounted) return;

    await _refreshHome();
  }

  void _checkHomeNavigation() {
    final delegate = _routerDelegate;
    if (!mounted || delegate == null || delegate.currentConfiguration.isEmpty) {
      return;
    }

    // The top route includes pushed screens above the bottom navigation.
    final location = delegate.state.uri.path;

    if (_lastLocation == location) {
      return;
    }

    final previousLocation = _lastLocation;

    _lastLocation = location;

    debugPrint('======================================');
    debugPrint('ROUTE CHANGED');
    debugPrint('FROM : $previousLocation');
    debugPrint('TO   : $location');
    debugPrint('TAB  : ${widget.navigationShell.currentIndex}');
    debugPrint('======================================');

    final bool isHomeRoute =
        location == AppRouter.home || location == '${AppRouter.home}/';

    if (!isHomeRoute) {
      return;
    }

    if (previousLocation == null) {
      debugPrint('HOME INITIAL ROUTE -> initState handles refresh');

      return;
    }

    _scheduleHomeRefresh(reason: 'RETURNED TO HOME FROM $previousLocation');
  }

  void _scheduleHomeRefresh({required String reason}) {
    if (_homeRefreshScheduled) {
      debugPrint('HOME REFRESH ALREADY SCHEDULED -> SKIPPING');

      return;
    }

    _homeRefreshScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _homeRefreshScheduled = false;

      if (!mounted ||
          (_lastLocation != AppRouter.home &&
              _lastLocation != '${AppRouter.home}/')) {
        return;
      }
      await _refreshHome();
    });
  }

  Future<void> _refreshHome() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      final userId = int.tryParse(userData?['user_id']?.toString() ?? '') ?? 0;

      final storedUserName = userData?['user_name']?.toString() ?? '';

      final userName = storedUserName.trim().isEmpty ? 'user' : storedUserName;

      if (!mounted) return;

      setState(() {
        _userId = userId;
        _username = userName;
        _isUserLoaded = true;
      });

      // Refresh the retained Home widget's user data and employee status too.
      TabRefresh.home.refresh();

      final String loginStatus = userId == 0 ? '0' : '1';

      if (!mounted) return;

      debugPrint('CALLING MENU API');

      context.read<HomeBloc>().add(GetMenuEvent(userId, loginStatus));

      if (userId == 0) {
        return;
      }

      final now = DateTime.now();

      final startDate = DateTime(now.year, now.month - 1, now.day);

      final searchFromDate = DateFormat('yyyy-MM-dd').format(startDate);

      final searchToDate = DateFormat('yyyy-MM-dd').format(now);

      if (!mounted) return;

      debugPrint('CALLING HOME VISIT API');

      context.read<HomeBloc>().add(GetHomeVisitEvent(userId.toString()));

      context.read<QuickAcessBloc>().add(PunchStatEvent(userId));

      context.read<HomeBloc>().add(
        VisitGraphCountEvent(userId, searchFromDate, searchToDate),
      );

      context.read<HomeBloc>().add(
        GetInpunchPendingEvent(userId: userId.toString()),
      );
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _userId = 0;
          _username = 'user';
          _isUserLoaded = true;
        });
      }
    }
  }

  void _onTabTapped(int index) {
    final visibleTabIndices = _visibleTabIndices;
    if (index < 0 || index >= visibleTabIndices.length) {
      return;
    }

    final branchIndex = visibleTabIndices[index];
    final currentIndex = widget.navigationShell.currentIndex;
    // Refresh on every tap, including the active tab. Record the destination
    // first to avoid a duplicate Home refresh from the route listener.
    _lastLocation = _tabs[branchIndex].path;
    switch (branchIndex) {
      case 0:
        _refreshHome();
        break;
      case 1:
        TabRefresh.followup.refresh();
        break;
      case 2:
        TabRefresh.products.refresh();
        break;
    }

    debugPrint('======================================');
    debugPrint('BOTTOM NAVIGATION');
    debugPrint('CURRENT INDEX : $currentIndex');
    debugPrint('NEW INDEX     : $index');
    debugPrint('======================================');

    // ----------------------------------------------------------
    // CHANGE TAB
    // ----------------------------------------------------------

    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == currentIndex,
    );
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================

  Future<void> _handleBack() async {
    final currentIndex = widget.navigationShell.currentIndex;

    debugPrint('======================================');
    debugPrint('SYSTEM BACK');
    debugPrint('CURRENT TAB: $currentIndex');
    debugPrint('======================================');

    // ----------------------------------------------------------
    // NOT ON HOME TAB
    //
    // Go to Home and refresh.
    // ----------------------------------------------------------

    if (currentIndex != 0) {
      widget.navigationShell.goBranch(0, initialLocation: true);

      return;
    }

    // ----------------------------------------------------------
    // ALREADY ON HOME
    //
    // Show exit dialog.
    // ----------------------------------------------------------

    final shouldExit = await _showExitDialog();

    if (shouldExit) {
      SystemNavigator.pop();
    }
  }

  // ============================================================
  // EXIT DIALOG
  // ============================================================

  Future<bool> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exit'),
          content: const Text('Do you want to exit the app?'),
          actions: [
            // --------------------------------------------------
            // CANCEL
            // --------------------------------------------------
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('CANCEL'),
            ),

            // --------------------------------------------------
            // EXIT
            // --------------------------------------------------
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final backgroundColor = context.appBackground;
    final navBackground = context.appCard;
    final selectedColor = context.appPrimary;
    final unselectedColor = context.appSubText;
    final textColor = context.appText;

    if (!_isUserLoaded) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final visibleTabIndices = _visibleTabIndices;

    final selectedIndex = visibleTabIndices.indexOf(
      widget.navigationShell.currentIndex,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: widget.navigationShell,

        bottomNavigationBar: ColoredBox(
          color: backgroundColor,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final showAi = _userId > 0;
                  final aiGap = showAi ? 64.0 : 0.0;
                  final active = selectedIndex < 0 ? 0 : selectedIndex;

                  final tabWidth =
                      (constraints.maxWidth - aiGap) / visibleTabIndices.length;

                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: active.toDouble(),
                      end: active.toDouble(),
                    ),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedIndex, child) {
                      final middle = visibleTabIndices.length ~/ 2;

                      final center = selectedIndex < 0
                          ? constraints.maxWidth / 2
                          : tabWidth * (animatedIndex + 0.5) +
                                (animatedIndex >= middle ? aiGap : 0);

                      return SizedBox(
                        height: 82,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                         Positioned.fill(
  child: CustomPaint(
    painter: _CurvedNavigationPainter(
      center,
      backgroundColor: context.appCard,
      borderColor: context.appBorder,
      shadowColor: Theme.of(context)
          .colorScheme
          .shadow
          .withValues(alpha: 0.15),
    ),
  ),
),

                            // =====================================
                            // NAVIGATION TABS
                            // =====================================
                            Positioned(
                              top: 28,
                              left: 0,
                              right: 0,
                              height: 48,
                              child: Row(
                                children: List.generate(
                                  visibleTabIndices.length + (showAi ? 1 : 0),
                                  (slot) {
                                    if (showAi && slot == middle) {
                                      return const SizedBox(width: 64);
                                    }

                                    final position = showAi && slot > middle
                                        ? slot - 1
                                        : slot;

                                    final tab =
                                        _tabs[visibleTabIndices[position]];

                                    final selected = position == selectedIndex;

                                    final itemColor = selected
                                        ? selectedColor
                                        : unselectedColor;

                                    return Expanded(
                                      child: Semantics(
                                        label: tab.label,
                                        button: true,
                                        selected: selected,
                                        child: Tooltip(
                                          message: tab.label,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkResponse(
                                              onTap: () =>
                                                  _onTabTapped(position),
                                              radius: 24,
                                              child: SizedBox.expand(
                                                child: Center(
                                                  child: ExcludeSemantics(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          tab.icon,
                                                          size: 25,
                                                          color: itemColor,
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          tab.label,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: itemColor,
                                                            fontSize: 11,
                                                            height: 1.1,
                                                            fontWeight: selected
                                                                ? FontWeight
                                                                      .w700
                                                                : FontWeight
                                                                      .w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // =====================================
                            // AI ASSISTANT BUTTON
                            // =====================================
                            if (showAi)
                              Positioned(
                                top: 0,
                                left: (constraints.maxWidth - 56) / 2,
                                width: 56,
                                height: 56,
                                child: Semantics(
                                  label: 'AI assistant',
                                  button: true,
                                  selected: selectedIndex < 0,
                                  child: Tooltip(
                                    message: 'AI assistant',
                                    child: GestureDetector(
                                      onTap: () => context.push(AppRouter.ai),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,

                                          color: colors.surface,

                                          border: Border.all(
                                            color: selectedColor,
                                            width: 2,
                                          ),

                                          boxShadow: [
                                            BoxShadow(
                                              color: selectedColor.withValues(
                                                alpha: 0.20,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),

                                        child: Icon(
                                          Icons.auto_awesome_rounded,
                                          color: selectedColor,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // WAIT FOR USER DATA
    // ==========================================================

    if (!_isUserLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ==========================================================
    // HOME SHELL
    // ==========================================================

    final visibleTabIndices = _visibleTabIndices;
    final selectedIndex = visibleTabIndices.indexOf(
      widget.navigationShell.currentIndex,
    );

    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        await _handleBack();
      },

      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,

        // ======================================================
        // ROUTER CONTENT
        // ======================================================
        body: widget.navigationShell,

        // ======================================================
        // BOTTOM NAVIGATION
        // ======================================================
        bottomNavigationBar: ColoredBox(
          color: AppColors.backgroundColor,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final showAi = _userId > 0;
                  final aiGap = showAi ? 64.0 : 0.0;
                  final active = selectedIndex < 0 ? 0 : selectedIndex;
                  final tabWidth =
                      (constraints.maxWidth - aiGap) / visibleTabIndices.length;
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: active.toDouble(),
                      end: active.toDouble(),
                    ),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedIndex, child) {
                      final middle = visibleTabIndices.length ~/ 2;
                      final center = selectedIndex < 0
                          ? constraints.maxWidth / 2
                          : tabWidth * (animatedIndex + 0.5) +
                                (animatedIndex >= middle ? aiGap : 0);
                      return SizedBox(
                        height: 82,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _CurvedNavigationPainter(center),
                              ),
                            ),
                            Positioned(
                              top: 28,
                              left: 0,
                              right: 0,
                              height: 48,
                              child: Row(
                                children: List.generate(
                                  visibleTabIndices.length + (showAi ? 1 : 0),
                                  (slot) {
                                    if (showAi && slot == middle) {
                                      return const SizedBox(width: 64);
                                    }
                                    final position = showAi && slot > middle
                                        ? slot - 1
                                        : slot;
                                    final tab =
                                        _tabs[visibleTabIndices[position]];
                                    final selected = position == selectedIndex;
                                    return Expanded(
                                      child: Semantics(
                                        label: tab.label,
                                        button: true,
                                        selected: selected,
                                        child: Tooltip(
                                          message: tab.label,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkResponse(
                                              onTap: () =>
                                                  _onTabTapped(position),
                                              radius: 24,
                                              child: SizedBox.expand(
                                                child: Center(
                                                  child: ExcludeSemantics(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Opacity(
                                                          opacity: 1,
                                                          child: Icon(
                                                            tab.icon,
                                                            size: 25,
                                                            color: AppColors
                                                                .textGrey,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          tab.label,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: selected
                                                                ? AppColors
                                                                      .primaryGreen
                                                                : AppColors
                                                                      .textGrey,
                                                            fontSize: 11,
                                                            height: 1.1,
                                                            fontWeight: selected
                                                                ? FontWeight
                                                                      .w700
                                                                : FontWeight
                                                                      .w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (showAi)
                              Positioned(
                                top: 0,
                                left: (constraints.maxWidth - 56) / 2,
                                width: 56,
                                height: 56,
                                child: Semantics(
                                  label: 'AI assistant',
                                  button: true,
                                  selected: selectedIndex < 0,
                                  child: Tooltip(
                                    message: 'AI assistant',
                                    child: GestureDetector(
                                      onTap: () => context.push(AppRouter.ai),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFFE8F5EC),
                                          border: Border.all(
                                            color: AppColors.primaryGreen,
                                            width: 2,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x33178A45),
                                              blurRadius: 8,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome_rounded,
                                          color: AppColors.primaryGreen,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // if (selectedIndex >= 0)
                            //   Positioned(
                            //     top: 4,
                            //     left: center - 24,
                            //     width: 48,
                            //     height: 48,
                            //     child: ExcludeSemantics(
                            //       child: Tooltip(
                            //         message:
                            //             _tabs[visibleTabIndices[active]].label,
                            //         child: Material(
                            //           color: const Color(0xFFE8F5EC),
                            //           elevation: 3,
                            //           shadowColor: const Color(0x33178A45),
                            //           shape: const CircleBorder(
                            //             side: BorderSide(
                            //               color: AppColors.primaryGreen,
                            //               width: 1.5,
                            //             ),
                            //           ),
                            //           clipBehavior: Clip.antiAlias,
                            //           child: InkWell(
                            //             customBorder: const CircleBorder(),
                            //             onTap: () => _onTabTapped(active),
                            //             child: Icon(
                            //               _tabs[visibleTabIndices[active]].icon,
                            //               color: AppColors.primaryGreen,
                            //               size: 25,
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }



  */
}


class _CurvedNavigationPainter extends CustomPainter {
  final double selectedCenter;

  // Dynamic theme colors
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;

  const _CurvedNavigationPainter(
    this.selectedCenter, {
    required this.backgroundColor,
    required this.borderColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // =========================================================
    // ORIGINAL NAVIGATION SHAPE
    // =========================================================

    final surface = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(0, 28, size.width, size.height),
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
          bottomLeft: const Radius.circular(22),
          bottomRight: const Radius.circular(22),
        ),
      );

    // =========================================================
    // CENTER NOTCH
    // =========================================================

    final notch = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(selectedCenter, 28),
          radius: 30,
        ),
      );

    final bar = Path.combine(
      PathOperation.difference,
      surface,
      notch,
    );

    // =========================================================
    // DYNAMIC SHADOW
    // =========================================================

    canvas.drawShadow(
      bar,
      shadowColor,
      3,
      false,
    );

    // =========================================================
    // DYNAMIC BACKGROUND
    // =========================================================

    canvas.drawPath(
      bar,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );

    // =========================================================
    // DYNAMIC BORDER
    // =========================================================

    canvas.drawPath(
      bar,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(
    covariant _CurvedNavigationPainter oldDelegate,
  ) {
    return oldDelegate.selectedCenter != selectedCenter ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}
