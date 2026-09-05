import 'package:demo/core/utility/widgets/bottom_navigation.dart';
import 'package:demo/core/di/auth_di.dart';
import 'package:demo/features/auth/presentation/pages/login_screen.dart';
import 'package:demo/features/farmer/famerfollowup/presentation/pages/FamerFollowupPage.dart';
import 'package:demo/features/dealer/presentation/pages/DealerListScreen.dart';
import 'package:demo/features/farmer/farmerlist/presentation/pages/farmerlist_screen.dart';

import 'package:demo/features/home/presentation/home.dart';
import 'package:demo/features/home/presentation/punch_screen.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/products/presentation/pages/products_screen.dart';
import 'package:demo/features/reports/presentation/pages/employee_activity_report_page.dart';
import 'package:demo/features/reports/presentation/pages/employee_output_report_page.dart';
import 'package:demo/features/reports/presentation/pages/not_visited_dealer_page.dart';

import 'package:demo/features/reports/presentation/pages/reports_scree.dart';
import 'package:demo/features/reports/presentation/pages/visit_summary_page.dart';
import 'package:demo/features/reports/presentation/bloc/employee_output_bloc.dart';
import 'package:demo/features/reports/presentation/bloc/visit_report_bloc.dart';
import 'package:demo/features/splash/splash_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String punch = '/punch';
  static const String noVisitDealer = '/notVisitDealer';

  static const String home = '/home';
  static const String reports = '/reports';
  static const String visits = '/visits';
  static const String products = '/products';
  static const String farmers = '/farmers';
  static const String farmerpin = '/farmerpin';

  static const String empActivityReport = '/empActivityReport';
  static const String empOutputReport = '/empOutputReport';
  static const String visitSummaryReport = '/visitSummaryReport';

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
        path: noVisitDealer,
        name: 'notVisitDealer',
        builder: (context, state) {
          return const NotVisitedDealerPage();
        },
      ),

      GoRoute(
        path: farmers,
        name: 'farmers',
        builder: (context, state) => const FarmerlistScreen(),
      ),
      GoRoute(
        path: farmerpin,
        name: 'farmerpin',
        builder: (context, state) {
          return const FamerFollowupPage();
        },
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

      GoRoute(
        path: empActivityReport,
        name: 'empActivityReport',
        builder: (context, state) {
          final userId = state.extra is String ? state.extra as String : '';

          return EmployeeActivityReportPage(userId: userId);
        },
      ),

      GoRoute(
        path: empOutputReport,
        name: 'empOutputReport',
        builder: (context, state) {
          final userId = state.extra is String ? state.extra as String : '';

          return BlocProvider<EmployeeOutputBloc>(
            create: (_) => sl<EmployeeOutputBloc>(),
            child: EmployeeOutputReportPage(userId: userId),
          );
        },
      ),

      GoRoute(
        path: visitSummaryReport,
        name: 'visitSummaryReport',
        builder: (context, state) {
          final userId = state.extra is String ? state.extra as String : '';

          return BlocProvider<VisitReportBloc>(
            create: (_) => sl<VisitReportBloc>(),
            child: VisitSummaryPage(userId: userId),
          );
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
                  return const Dealerlistscreen();
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
