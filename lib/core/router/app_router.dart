import 'package:demo/core/utility/widgets/bottom_navigation.dart';
import 'package:demo/features/auth/presentation/pages/login_screen.dart';
import 'package:demo/features/farmer/farmerlist/presentation/pages/farmerlist_screen.dart';

import 'package:demo/features/home/presentation/home.dart';
import 'package:demo/features/home/presentation/punch_screen.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/products/presentation/pages/products_screen.dart';

import 'package:demo/features/reports/presentation/pages/reports_scree.dart';
import 'package:demo/features/splash/splash_screen.dart';
import 'package:demo/features/visits/presentation/pages/visits_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String punch = '/punch';
  static const String home = '/home';
  static const String reports = '/reports';
  static const String visits = '/visits';
  static const String products = '/products';
  static const String farmers = '/farmers';

  static final GoRouter router = GoRouter(
    initialLocation: splash,

    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) {
          return const SplashScreen();
        },
      ),

      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: farmers,
        name: 'farmers',
        builder: (context, state) => const FarmerlistScreen(),
      ),
      GoRoute(
        path: punch,
        name: 'punch',
        builder: (context, state) {
          final punchStat = state.extra is PunchStatEntity
              ? state.extra as PunchStatEntity
              : null;
          return PunchScreen(punchStat: punchStat);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },

        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                name: 'home',
                builder: (context, state) {
                  return const Home();
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: reports,
                name: 'reports',
                builder: (context, state) {
                  return const ReportsScree();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: visits,
                name: 'visits',
                builder: (context, state) {
                  return const VisitsScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: products,
                name: 'products',
                builder: (context, state) {
                  return const ProductsScreen();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
