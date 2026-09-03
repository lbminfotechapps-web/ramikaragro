import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (path: AppRouter.home, icon: Icons.home, label: 'Home'),
    (path: AppRouter.reports, icon: Icons.report, label: 'Reports'),
    (path: AppRouter.visits, icon: Icons.location_city, label: 'Visits'),
    (path: AppRouter.products, icon: Icons.storage, label: 'Products'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: navigationShell,
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
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) {
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
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
          // Positioned(
          //   bottom: 30,
          //   child: GestureDetector(
          //     onTap: () {
          //       navigationShell.goBranch(2, initialLocation: false);
          //     },
          //     child: Container(
          //       width: 68,
          //       height: 68,
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         gradient: AppColors.appGradient,
          //         border: Border.all(color: Colors.white, width: 4),
          //         boxShadow: [
          //           BoxShadow(
          //             color: AppColors.gradientStartColor.withOpacity(0.35),
          //             blurRadius: 18,
          //             offset: const Offset(0, 10),
          //           ),
          //         ],
          //       ),
          //       child: const Icon(
          //         Icons.add,
          //         color: Colors.white,
          //         size: 30,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
