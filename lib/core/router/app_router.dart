import 'package:demo/core/utility/widgets/bottom_navigation.dart';
import 'package:demo/core/di/auth_di.dart';
import 'package:demo/features/auth/presentation/pages/login_screen.dart';
import 'package:demo/features/dealer/presentation/pages/DealerListScreen.dart';
import 'package:demo/features/farmer/famerfollowup/presentation/pages/famerfollowuppage.dart';
import 'package:demo/features/farmer/farmerlist/presentation/pages/farmerlist_screen.dart';
import 'package:demo/features/gallery/presentation/pages/galleryscreen.dart';

import 'package:demo/features/home/presentation/home.dart';
import 'package:demo/features/home/presentation/punch_screen.dart';
import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:demo/features/home/presentation/punch_out_screen.dart';
import 'package:demo/features/products/presentation/pages/products_screen.dart';
import 'package:demo/features/reports/presentation/pages/about_us_page.dart';
import 'package:demo/features/reports/presentation/pages/contact_us_page.dart';
import 'package:demo/features/reports/presentation/pages/employee_activity_report_page.dart';
import 'package:demo/features/reports/presentation/pages/employee_output_report_page.dart';
import 'package:demo/features/reports/presentation/pages/not_visited_dealer_page.dart';
import 'package:demo/features/reports/presentation/pages/notification_page.dart';

import 'package:demo/features/reports/presentation/pages/reports_scree.dart';
import 'package:demo/features/reports/presentation/pages/user_guidelines_page.dart';
import 'package:demo/features/reports/presentation/pages/visit_summary_page.dart';
import 'package:demo/features/reports/presentation/bloc/employee_output_bloc.dart';
import 'package:demo/features/reports/presentation/bloc/visit_report_bloc.dart';
import 'package:demo/features/scheme/presentation/pages/schemescreen.dart';
import 'package:demo/features/splash/splash_screen.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String punch = '/punchIn';
  static const String punchOut = '/punchOut';
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

  static const String aboutUs = '/aboutUs';
  static const String contactUs = '/contactUs';
  static const String userGuide = '/userGuide';
  static const String notification = '/notification';
  static const String gallery = '/gallery';
  static const String scheme = '/scheme';

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
        path: gallery,
        name: 'gallery',
        builder: (context, state) {
          return const GalleryScreen();
        },
      ),

      GoRoute(
        path: scheme,
        name: 'scheme',
        builder: (context, state) {
          return const SchemeScreen();
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
          final farmerId = state.extra is String ? state.extra as String : '';
          return FamerFollowupPage(farmerId: farmerId);
        },
      ),
      GoRoute(
        path: punch,
        name: 'punchIn',
        builder: (context, state) {
          final punchStat = state.extra is PunchStatEntity
              ? state.extra as PunchStatEntity
              : null;
          return PunchScreen(punchStat: punchStat);
        },
      ),

      GoRoute(
        path: punchOut,
        name: 'punchOut',
        builder: (context, state) {
          final punchStat = state.extra is PunchStatEntity
              ? state.extra as PunchStatEntity
              : null;
          return PunchOutScreen(punchStat);
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

      GoRoute(
        path: aboutUs,
        name: 'aboutUs',
        builder: (context, state) {
          return const AboutUsPage();
        },
      ),

      GoRoute(
        path: contactUs,
        name: 'contactUs',
        builder: (context, state) {
          return const ContactUsPage();
        },
      ),

      GoRoute(
        path: userGuide,
        name: 'userGuide',
        builder: (context, state) {
          return const UserGuidelinesPage();
        },
      ),

      GoRoute(
        path: notification,
        name: 'notification',
        builder: (context, state) {
          debugPrint('========================================');
          debugPrint('NOTIFICATION ROUTER');
          debugPrint('state.extra       : ${state.extra}');
          debugPrint('state.extra type  : ${state.extra.runtimeType}');

          final userId = state.extra is String
              ? int.tryParse(state.extra as String) ?? 0
              : state.extra is int
              ? state.extra as int
              : 0;

          debugPrint('FINAL USER ID     : $userId');
          debugPrint('========================================');

          return NotificationPage(userId: userId, isLogin: true, userType: '');
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
