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
  // ============================================================
  // VARIABLES
  // ============================================================

  GoRouterDelegate? _routerDelegate;
  late final AuthProvider _authProvider;

  List<int> get _visibleTabIndices => _userId > 0 ? [0, 1, 2, 3] : [0, 3];

  int _userId = 0;
  String _username = 'user';

  /// false = SecureStorage is still being checked.
  /// true  = user state is ready.
  bool _isUserLoaded = false;

  // ============================================================
  // ROUTE REFRESH VARIABLES
  // ============================================================

  /// Stores previous route so that we can detect:
  ///
  /// Any Screen
  ///     ↓
  /// Home
  ///
  /// and refresh Home APIs.
  String? _lastLocation;

  /// Prevents scheduling multiple Home refreshes
  /// during the same frame.
  bool _homeRefreshScheduled = false;

  // ============================================================
  // TABS
  // ============================================================

  // static const _tabs = [
  //   (path: AppRouter.home, icon: Icons.home, label: 'Home'),
  //   (path: AppRouter.followup, icon: Icons.report, label: 'Follow up'),
  //   (path: AppRouter.products, icon: Icons.storage, label: 'Products'),
  //   (path: AppRouter.monthlyPerformanceReport, icon: Icons.location_city, label: 'Report'),
  // ];




static const _tabs = [
  // INDEX 0
  (
    path: AppRouter.home,
    icon: Icons.home_rounded,
    label: 'Home',
  ),

  // INDEX 1
  (
    path: AppRouter.followup,
    icon: Icons.assignment_rounded,
    label: 'Follow up',
  ),

  // INDEX 2
  (
    // path: AppRouter.monthlyPerformanceReport,
    // icon: Icons.bar_chart_rounded,
    // label: 'Report',
    path: AppRouter.reportPage,
    icon: Icons.bar_chart_rounded,
    label: 'Report',

  ),

  // INDEX 3
  (
    path: AppRouter.products,
    icon: Icons.inventory_2_rounded,
    label: 'Products',
  ),
];


  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _authProvider = sl<AuthProvider>();
    _authProvider.addListener(_onAuthChanged);

    // ----------------------------------------------------------
    // INITIAL HOME LOAD
    // ----------------------------------------------------------

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

  // ============================================================
  // PUBLIC REFRESH METHOD
  // ============================================================

  Future<void> refreshHome() async {
    if (!mounted) return;

    await _refreshHome();
  }

  // ============================================================
  // CHECK NAVIGATION
  // ============================================================

  void _checkHomeNavigation() {
    // ----------------------------------------------------------
    // GET CURRENT GO ROUTER LOCATION
    // ----------------------------------------------------------

    final delegate = _routerDelegate;
    if (!mounted || delegate == null || delegate.currentConfiguration.isEmpty) {
      return;
    }

    // The top route includes pushed screens above the bottom navigation.
    final location = delegate.state.uri.path;

    // ----------------------------------------------------------
    // SAME ROUTE
    //
    // Widget may rebuild because Bloc/setState changed.
    // That does NOT mean navigation happened.
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // CHECK IF HOME IS NOW ACTIVE
    // ----------------------------------------------------------

    final bool isHomeRoute =
        location == AppRouter.home || location == '${AppRouter.home}/';

    if (!isHomeRoute) {
      return;
    }

    // ----------------------------------------------------------
    // INITIAL LOAD
    //
    // initState() already handles initial Home API calls.
    // Don't call twice.
    // ----------------------------------------------------------

    if (previousLocation == null) {
      debugPrint('HOME INITIAL ROUTE -> initState handles refresh');

      return;
    }

    // ----------------------------------------------------------
    // HOME BECAME ACTIVE FROM ANOTHER ROUTE
    // ----------------------------------------------------------

    _scheduleHomeRefresh(reason: 'RETURNED TO HOME FROM $previousLocation');
  }

  // ============================================================
  // SCHEDULE HOME REFRESH
  // ============================================================

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

  // ============================================================
  // LOAD USER + ALL HOME DATA
  // ============================================================

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

      final String loginStatus = userId == 0 ? '0' : '1';

      if (!mounted) return;

      // ========================================================
      // 1. MENU API
      //
      // Works for guest + logged-in user.
      // ========================================================

      debugPrint('CALLING MENU API');

      context.read<HomeBloc>().add(GetMenuEvent(userId, loginStatus));

      // ========================================================
      // GUEST USER
      // ========================================================

      if (userId == 0) {
        return;
      }

      // ========================================================
      // LOGGED-IN USER
      // ========================================================

      final now = DateTime.now();

      final startDate = DateTime(now.year, now.month - 1, now.day);

      final searchFromDate = DateFormat('yyyy-MM-dd').format(startDate);

      final searchToDate = DateFormat('yyyy-MM-dd').format(now);

      if (!mounted) return;

      // ========================================================
      // 2. HOME VISIT API
      // ========================================================

      debugPrint('CALLING HOME VISIT API');

      context.read<HomeBloc>().add(GetHomeVisitEvent(userId.toString()));

      context.read<QuickAcessBloc>().add(PunchStatEvent(userId));

      context.read<HomeBloc>().add(
        VisitGraphCountEvent(userId, searchFromDate, searchToDate),
      );

      // ========================================================
      // 5. PENDING IN-PUNCH API
      // ========================================================

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

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

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
        TabRefresh.home.refresh();
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
                  final active = selectedIndex < 0 ? 0 : selectedIndex;
                  final tabWidth =
                      constraints.maxWidth / visibleTabIndices.length;
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: active.toDouble(),
                      end: active.toDouble(),
                    ),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedIndex, child) {
                      final center = tabWidth * (animatedIndex + 0.5);
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
                                  visibleTabIndices.length,
                                  (position) {
                                    final tab =
                                        _tabs[visibleTabIndices[position]];
                                    final selected = position == active;
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
                                                          opacity: selected
                                                              ? 0
                                                              : 1,
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
                            Positioned(
                              top: 4,
                              left: center - 24,
                              width: 48,
                              height: 48,
                              child: ExcludeSemantics(
                                child: Tooltip(
                                  message:
                                      _tabs[visibleTabIndices[active]].label,
                                  child: Material(
                                    color: const Color(0xFFE8F5EC),
                                    elevation: 3,
                                    shadowColor: const Color(0x33178A45),
                                    shape: const CircleBorder(
                                      side: BorderSide(
                                        color: AppColors.primaryGreen,
                                        width: 1.5,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () => _onTabTapped(active),
                                      child: Icon(
                                        _tabs[visibleTabIndices[active]]
                                            .selectedIcon,
                                        color: AppColors.primaryGreen,
                                        size: 25,
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
}

class _CurvedNavigationPainter extends CustomPainter {
  final double selectedCenter;
  const _CurvedNavigationPainter(this.selectedCenter);

  @override
  void paint(Canvas canvas, Size size) {
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
    final notch = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(selectedCenter, 28), radius: 30),
      );
    final bar = Path.combine(PathOperation.difference, surface, notch);
    canvas.drawShadow(bar, const Color(0x261B4332), 3, false);
    canvas.drawPath(bar, Paint()..color = Colors.white);
    canvas.drawPath(
      bar,
      Paint()
        ..color = const Color(0xFFDDEBE1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_CurvedNavigationPainter oldDelegate) =>
      oldDelegate.selectedCenter != selectedCenter;
}
