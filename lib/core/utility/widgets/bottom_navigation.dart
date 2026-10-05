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

  List<int> get _visibleTabIndices => _userId > 0 ? [0, 1, 2] : [0, 2];

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

  static const _tabs = [
    (path: AppRouter.home, icon: Icons.home, label: 'Home'),
    (path: AppRouter.reports, icon: Icons.report, label: 'Follow up'),
    // (path: AppRouter.visits, icon: Icons.location_city, label: 'Visits'),
    (path: AppRouter.products, icon: Icons.storage, label: 'Products'),
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
        bottomNavigationBar: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: BottomNavigationBar(
                  currentIndex: selectedIndex < 0 ? 0 : selectedIndex,

                  type: BottomNavigationBarType.fixed,

                  onTap: _onTabTapped,

                  items: visibleTabIndices.map((index) {
                    final tab = _tabs[index];
                    return BottomNavigationBarItem(
                      icon: Icon(tab.icon),
                      label: tab.label,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _lastActiveIndex = -1;

  int _userId = 0;
  bool _isUserLoaded = false;
  String _username = 'user';

  static const _tabs = [
    (path: AppRouter.home, icon: Icons.home, label: 'Home'),
    (path: AppRouter.reports, icon: Icons.report, label: 'Follow up'),
    (path: AppRouter.visits, icon: Icons.location_city, label: 'Visits'),
    (path: AppRouter.products, icon: Icons.storage, label: 'Products'),
  ];
  void refreshHome() {
    _refreshHome();
  }

  Future<void> _refreshHome() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      // --------------------------------------------------------
      // USER ID
      //
      // No user / empty user_id / invalid user_id = 0
      // Logged-in user = actual user ID
      // --------------------------------------------------------

      final userId = int.tryParse(userData?['user_id']?.toString() ?? '') ?? 0;

      final userName = userData?['user_name']?.toString() ?? 'user';

      if (!mounted) return;

      // --------------------------------------------------------
      // UPDATE SHELL STATE FIRST
      // --------------------------------------------------------

      setState(() {
        _userId = userId;
        _username = userName.trim().isNotEmpty ? userName : 'user';

        _isUserLoaded = true;
      });

      // --------------------------------------------------------
      // LOGIN STATUS
      //
      // 0 = not logged in
      // 1 = logged in
      // --------------------------------------------------------

      final loginStatus = userId == 0 ? '0' : '1';

      debugPrint('====================================');
      debugPrint('HOME REFRESH');
      debugPrint('USER ID: $userId');
      debugPrint('USER NAME: $_username');
      debugPrint('LOGIN STATUS: $loginStatus');
      debugPrint('====================================');

      // ========================================================
      // MENU API
      //
      // This API runs for BOTH guest and logged-in users.
      // ========================================================

      context.read<HomeBloc>().add(GetMenuEvent(userId, loginStatus));

      // ========================================================
      // GUEST USER
      //
      // Don't call logged-in APIs.
      // ========================================================

      if (userId == 0) {
        debugPrint('Guest user -> skipping logged-in home APIs');

        return;
      }

      // ========================================================
      // LOGGED-IN USER APIs
      // ========================================================

      final now = DateTime.now();

      final startDate = DateTime(now.year, now.month - 1, now.day);

      final searchFromDate = DateFormat('yyyy-MM-dd').format(startDate);

      final searchToDate = DateFormat('yyyy-MM-dd').format(now);

      context.read<HomeBloc>().add(GetHomeVisitEvent(userId.toString()));

      context.read<QuickAcessBloc>().add(PunchStatEvent(userId));

      context.read<HomeBloc>().add(
        VisitGraphCountEvent(userId, searchFromDate, searchToDate),
      );

      context.read<HomeBloc>().add(
        GetInpunchPendingEvent(userId: userId.toString()),
      );
    } catch (e, stackTrace) {
      debugPrint('HOME REFRESH ERROR: $e');
      debugPrint('$stackTrace');

      // Even if SecureStorage fails, don't keep loader forever.
      if (mounted) {
        setState(() {
          _userId = 0;
          _username = 'user';
          _isUserLoaded = true;
        });
      }
    }
  }

  Future<void> _handleBack() async {
    final currentIndex = widget.navigationShell.currentIndex;

    debugPrint('Current bottom tab: $currentIndex');

    // ----------------------------------------------------------
    // NOT HOME -> GO HOME
    // ----------------------------------------------------------

    if (currentIndex != 0) {
      widget.navigationShell.goBranch(0, initialLocation: true);

      return;
    }

    // ----------------------------------------------------------
    // ALREADY HOME -> EXIT DIALOG
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('CANCEL'),
            ),
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

  @override
  Widget build(BuildContext context) {


        if (!_isUserLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }



    final activeIndex = widget.navigationShell.currentIndex;

    // if (activeIndex != _lastActiveIndex) {
    //   _lastActiveIndex = activeIndex;

    //   if (activeIndex == 0) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       if (mounted) {
    //         _refreshHome();
    //       }
    //     });
    //   }
    // }

    if (activeIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshHome();
        }
      });
    }

    _lastActiveIndex = activeIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        body: widget.navigationShell,

        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          child: Material(
            color: Colors.white,
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  shadowColor: Colors.transparent,

                  // Prevent icons/text from becoming too large
                  iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
                    states,
                  ) {
                    final selected = states.contains(WidgetState.selected);

                    return IconThemeData(
                      color: selected
                          ? AppColors.gradientStartColor
                          : AppColors.textSecondaryColor,
                      size: 23,
                    );
                  }),

                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                    states,
                  ) {
                    final selected = states.contains(WidgetState.selected);

                    return TextStyle(
                      fontSize: 11,
                      height: 1.1,
                      color: selected
                          ? AppColors.gradientStartColor
                          : AppColors.textSecondaryColor,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    );
                  }),
                ),

                child: NavigationBar(
                  height: 68,
                  selectedIndex: widget.navigationShell.currentIndex,

                  // Important for preventing extra vertical movement
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

                  onDestinationSelected: (index) {
                    widget.navigationShell.goBranch(
                      index,
                      initialLocation:
                          index == widget.navigationShell.currentIndex,
                    );
                  },

                  destinations: [
                    for (final tab in _tabs)
                      NavigationDestination(
                        icon: Icon(tab.icon),
                        selectedIcon: Icon(tab.icon),
                        label: tab.label,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

             ),
    );
  }
}
*/
