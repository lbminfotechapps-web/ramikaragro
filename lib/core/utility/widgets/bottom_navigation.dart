import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:demo/features/home/presentation/home_bloc/home_event.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_access_event.dart';
import 'package:demo/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// class HomeShell extends StatefulWidget {
//   const HomeShell({super.key, required this.navigationShell});

//   final StatefulNavigationShell navigationShell;

//   @override
//   State<HomeShell> createState() => _HomeShellState();
// }

// class _HomeShellState extends State<HomeShell> {
//   int _lastActiveIndex = -1;

//   static const _tabs = [
//     (path: AppRouter.home, icon: Icons.home, label: 'Home'),
//     (path: AppRouter.reports, icon: Icons.report, label: 'Reports'),
//     (path: AppRouter.visits, icon: Icons.location_city, label: 'Visits'),
//     (path: AppRouter.products, icon: Icons.storage, label: 'Products'),
//   ];

//   Future<void> _refreshHome() async {
//     final userData = await SecureStorage.instance.getUserData();
//     final userId = int.tryParse(userData?['user_id']?.toString() ?? '');

//     if (!mounted || userId == null) {
//       return;
//     }

//     final now = DateTime.now();

//     // 1 month previous
//     final startDate = DateTime(now.year, now.month - 1, now.day);

//     final searchFromDate = DateFormat('yyyy-MM-dd').format(startDate);

//     // Today's date
//     final searchToDate = DateFormat('yyyy-MM-dd').format(now);

//     debugPrint('GRAPH USER ID: $userId');
//     debugPrint('GRAPH FROM DATE: $searchFromDate');
//     debugPrint('GRAPH TO DATE: $searchToDate');

//     context.read<HomeBloc>().add(GetMenuEvent(userId, '2'));
//     context.read<QuickAcessBloc>().add(PunchStatEvent(userId));
//     context.read<HomeBloc>().add(
//       VisitGraphCountEvent(userId, '2026-08-07', '2026-09-07'),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final activeIndex = widget.navigationShell.currentIndex;
//     if (activeIndex != _lastActiveIndex) {
//       _lastActiveIndex = activeIndex;
//       if (activeIndex == 0) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             _refreshHome();
//           }
//         });
//       }
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: widget.navigationShell,
//       bottomNavigationBar: Stack(
//         alignment: Alignment.bottomCenter,
//         children: [
//           Material(
//             color: Colors.white,
//             elevation: 4,
//             shadowColor: Colors.black.withOpacity(0.06),
//             borderRadius: BorderRadius.circular(18),
//             child: Container(
//               height: 72,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(18),
//                 border: Border.all(color: Colors.grey.shade200, width: 1),
//               ),
//               child: NavigationBarTheme(
//                 data: NavigationBarThemeData(
//                   backgroundColor: Colors.transparent,
//                   surfaceTintColor: Colors.transparent,
//                   indicatorColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
//                     states,
//                   ) {
//                     final textTheme = Theme.of(context).textTheme;
//                     final selected = states.contains(WidgetState.selected);

//                     return (selected
//                             ? textTheme.labelLarge
//                             : textTheme.labelMedium) ??
//                         TextStyle(
//                           color: selected
//                               ? AppColors.gradientStartColor
//                               : AppColors.textSecondaryColor,
//                           fontWeight: selected
//                               ? FontWeight.w700
//                               : FontWeight.w500,
//                         );
//                   }),
//                   iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
//                     states,
//                   ) {
//                     final selected = states.contains(WidgetState.selected);
//                     return IconThemeData(
//                       color: selected
//                           ? AppColors.gradientStartColor
//                           : AppColors.textSecondaryColor,
//                       size: 24,
//                     );
//                   }),
//                 ),
//                 child: NavigationBar(
//                   height: 72,
//                   selectedIndex: widget.navigationShell.currentIndex,
//                   onDestinationSelected: (index) {
//                     widget.navigationShell.goBranch(
//                       index,
//                       initialLocation:
//                           index == widget.navigationShell.currentIndex,
//                     );
//                   },
//                   destinations: [
//                     for (final tab in _tabs)
//                       NavigationDestination(
//                         icon: Icon(tab.icon),
//                         label: tab.label,
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Positioned(
//           //   bottom: 30,
//           //   child: GestureDetector(
//           //     onTap: () {
//           //       navigationShell.goBranch(2, initialLocation: false);
//           //     },
//           //     child: Container(
//           //       width: 68,
//           //       height: 68,
//           //       decoration: BoxDecoration(
//           //         shape: BoxShape.circle,
//           //         gradient: AppColors.appGradient,
//           //         border: Border.all(color: Colors.white, width: 4),
//           //         boxShadow: [
//           //           BoxShadow(
//           //             color: AppColors.gradientStartColor.withOpacity(0.35),
//           //             blurRadius: 18,
//           //             offset: const Offset(0, 10),
//           //           ),
//           //         ],
//           //       ),
//           //       child: const Icon(
//           //         Icons.add,
//           //         color: Colors.white,
//           //         size: 30,
//           //       ),
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _lastActiveIndex = -1;

  static const _tabs = [
    (path: AppRouter.home, icon: Icons.home, label: 'Home'),
    (path: AppRouter.reports, icon: Icons.report, label: 'Reports'),
    (path: AppRouter.visits, icon: Icons.location_city, label: 'Visits'),
    (path: AppRouter.products, icon: Icons.storage, label: 'Products'),
  ];

  Future<void> _refreshHome() async {
    final userData = await SecureStorage.instance.getUserData();

    final userId = int.tryParse(userData?['user_id']?.toString() ?? '');

    if (!mounted || userId == null) {
      return;
    }

    final now = DateTime.now();

    final startDate = DateTime(now.year, now.month - 1, now.day);

    final searchFromDate = DateFormat('yyyy-MM-dd').format(startDate);

    final searchToDate = DateFormat('yyyy-MM-dd').format(now);

    debugPrint('GRAPH USER ID: $userId');
    debugPrint('GRAPH FROM DATE: $searchFromDate');
    debugPrint('GRAPH TO DATE: $searchToDate');

    context.read<HomeBloc>().add(GetMenuEvent(userId, '2'));

    context.read<HomeBloc>().add(GetHomeVisitEvent(userId.toString()));

    context.read<QuickAcessBloc>().add(PunchStatEvent(userId));

    context.read<HomeBloc>().add(
      VisitGraphCountEvent(userId, searchFromDate, searchToDate),
    );
  }

  Future<void> _handleBack() async {
    final currentIndex = widget.navigationShell.currentIndex;

    debugPrint('Current bottom tab: $currentIndex');

    // -----------------------------------------
    // 1. If NOT on Home -> Go to Home
    // -----------------------------------------
    if (currentIndex != 0) {
      widget.navigationShell.goBranch(0, initialLocation: true);

      return;
    }

    // -----------------------------------------
    // 2. Already on Home -> Show Exit Dialog
    // -----------------------------------------
    final shouldExit = await _showExitDialog();

    if (shouldExit) {
      SystemNavigator.pop();
    }
  }

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
    final activeIndex = widget.navigationShell.currentIndex;

    if (activeIndex != _lastActiveIndex) {
      _lastActiveIndex = activeIndex;

      if (activeIndex == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _refreshHome();
          }
        });
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        await _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        body: widget.navigationShell,

        bottomNavigationBar: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Material(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),

              child: Container(
                height: 72,

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

                    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                      states,
                    ) {
                      final textTheme = Theme.of(context).textTheme;

                      final selected = states.contains(WidgetState.selected);

                      return (selected
                              ? textTheme.labelLarge
                              : textTheme.labelMedium) ??
                          TextStyle(
                            color: selected
                                ? AppColors.gradientStartColor
                                : AppColors.textSecondaryColor,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          );
                    }),

                    iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
                      states,
                    ) {
                      final selected = states.contains(WidgetState.selected);

                      return IconThemeData(
                        color: selected
                            ? AppColors.gradientStartColor
                            : AppColors.textSecondaryColor,
                        size: 24,
                      );
                    }),
                  ),

                  child: NavigationBar(
                    height: 72,

                    selectedIndex: widget.navigationShell.currentIndex,

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
                          label: tab.label,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
