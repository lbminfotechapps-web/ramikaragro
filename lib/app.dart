
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:solufine/core/di/auth_di.dart';
// import 'package:solufine/core/router/app_router.dart';
// import 'package:solufine/core/theme/app_theme.dart';
// import 'package:solufine/features/addexpense/presentation/bloc/expense_bloc.dart';
// import 'package:solufine/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:solufine/features/collection/presentation/bloc/dealer_target_bloc.dart';
// import 'package:solufine/features/dealer/presentation/bloc/dealerlist_bloc.dart';
// import 'package:solufine/features/dealer_visit/presentation/bloc/add_dealer_visit_bloc.dart';
// import 'package:solufine/features/distpatchistory/presentation/bloc/dispatch_bloc.dart';
// import 'package:solufine/features/enquiry/presentation/bloc/enquiry_bloc.dart';
// import 'package:solufine/features/farmer/famerfollowup/presentation/bloc/famerfollowup_bloc.dart';
// import 'package:solufine/features/farmer/farmerlist/presentation/bloc/farmerlist_bloc.dart';
// import 'package:solufine/features/farmer/farmerregistration/presentation/bloc/state_bloc.dart';
// import 'package:solufine/features/followup/presentation/bloc/followup_bloc.dart';
// import 'package:solufine/features/gallery/presentation/boc/gallery_bloc.dart';
// import 'package:solufine/features/home/presentation/home_bloc/home_bloc.dart';
// import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';
// import 'package:solufine/features/leave/presentation/bloc/top_ten_dealer_bloc.dart';
// import 'package:solufine/features/orderhistory/presentation/bloc/order_history_bloc.dart';
// import 'package:solufine/features/products/presentation/bloc/product_bloc.dart';
// import 'package:solufine/features/reports/presentation/bloc/employee_activity_bloc.dart';
// import 'package:solufine/features/reports/presentation/bloc/not_visited_dealer_bloc.dart';
// import 'package:solufine/features/salesreturnhistory/presentation/bloc/sales_return_history_bloc.dart';
// import 'package:solufine/features/scheme/presentation/bloc/scheme_bloc.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<QuickAcessBloc>(create: (_) => sl<QuickAcessBloc>()),
//         BlocProvider<EmployeeActivityBloc>(
//           create: (_) => sl<EmployeeActivityBloc>(),
//         ),
//         BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
//         BlocProvider<NotVisitedDealerBloc>(
//           create: (_) => sl<NotVisitedDealerBloc>(),
//         ),

//         BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
//         BlocProvider<FarmerListBloc>(create: (_) => sl<FarmerListBloc>()),
//         BlocProvider<DealerListBloc>(create: (_) => sl<DealerListBloc>()),

//         BlocProvider<EnquiryBloc>(create: (_) => sl<EnquiryBloc>()),
//         BlocProvider<FollowupBloc>(create: (_) => sl<FollowupBloc>()),

//         BlocProvider<NotVisitedDealerBloc>(
//           create: (_) => sl<NotVisitedDealerBloc>(),
//         ),
//         BlocProvider<DealerTargetBloc>(create: (_) => sl<DealerTargetBloc>()),
//         BlocProvider<TopTenDealerBloc>(create: (_) => sl<TopTenDealerBloc>()),

//         BlocProvider<FarmerListBloc>(create: (_) => sl<FarmerListBloc>()),
//         BlocProvider<FamerfollowupBloc>(create: (_) => sl<FamerfollowupBloc>()),
//         BlocProvider<StateBloc>(create: (_) => sl<StateBloc>()),
//         BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),

//         BlocProvider<GalleryBloc>(create: (_) => sl<GalleryBloc>()),
//         BlocProvider<SchemeBloc>(create: (_) => sl<SchemeBloc>()),
//         BlocProvider<ProductBloc>(create: (_) => sl<ProductBloc>()),
//         BlocProvider<OrderHistoryBloc>(create: (_) => sl<OrderHistoryBloc>()),
//         BlocProvider<AddDealerVisitBlock>(
//           create: (_) => sl<AddDealerVisitBlock>(),
//         ),
//         BlocProvider<DispatchBloc>(create: (_) => sl<DispatchBloc>()),
//         BlocProvider<SalesReturnHistoryBloc>(
//           create: (_) => sl<SalesReturnHistoryBloc>(),
//         ),
//         BlocProvider<ExpenseBloc>(create: (_) => sl<ExpenseBloc>()),
//       ],

//       child: MaterialApp.router(
//         title: 'Flutter Demo',
//         theme: AppColor.getLightTheme(),
//         themeMode: ThemeMode.light,
//         debugShowCheckedModeBanner: false,
//         builder: (context, child) {
//           return Container(
//             decoration: AppColor.appGradientDecoration,
//             child: child,
//           );
//         },
//         routerConfig: AppRouter.router,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solufine/core/di/auth_di.dart';
import 'package:solufine/core/notifications/notification_navigation_service.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_theme.dart';

// ============================================================
// 🔔 ADDED FOR NOTIFICATION NAVIGATION
// ============================================================

import 'package:solufine/features/addexpense/presentation/bloc/expense_bloc.dart';
import 'package:solufine/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:solufine/features/collection/presentation/bloc/dealer_target_bloc.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_bloc.dart';
import 'package:solufine/features/dealer_visit/presentation/bloc/add_dealer_visit_bloc.dart';
import 'package:solufine/features/distpatchistory/presentation/bloc/dispatch_bloc.dart';
import 'package:solufine/features/enquiry/presentation/bloc/enquiry_bloc.dart';
import 'package:solufine/features/farmer/famerfollowup/presentation/bloc/famerfollowup_bloc.dart';
import 'package:solufine/features/farmer/farmerlist/presentation/bloc/farmerlist_bloc.dart';
import 'package:solufine/features/farmer/farmerregistration/presentation/bloc/state_bloc.dart';
import 'package:solufine/features/followup/presentation/bloc/followup_bloc.dart';
import 'package:solufine/features/gallery/presentation/boc/gallery_bloc.dart';
import 'package:solufine/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:solufine/features/home/presentation/quick_aceess_bloc/quick_acess_bloc.dart';
import 'package:solufine/features/leave/presentation/bloc/top_ten_dealer_bloc.dart';
import 'package:solufine/features/orderhistory/presentation/bloc/order_history_bloc.dart';
import 'package:solufine/features/products/presentation/bloc/product_bloc.dart';
import 'package:solufine/features/reports/presentation/bloc/employee_activity_bloc.dart';
import 'package:solufine/features/reports/presentation/bloc/not_visited_dealer_bloc.dart';
import 'package:solufine/features/salesreturnhistory/presentation/bloc/sales_return_history_bloc.dart';
import 'package:solufine/features/scheme/presentation/bloc/scheme_bloc.dart';

// ============================================================
// 🔔 CHANGED FROM StatelessWidget TO StatefulWidget
// ============================================================

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ============================================================
  // 🔔 ADDED FOR NOTIFICATION NAVIGATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    NotificationNavigationService.instance.setRouter(
      AppRouter.router,
    );

    debugPrint(
      '==========================================',
    );
    debugPrint(
      '🔔 NOTIFICATION ROUTER REGISTERED',
    );
    debugPrint(
      '==========================================',
    );
  }

  // ============================================================
  // YOUR EXISTING BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ======================================================
        // YOUR EXISTING PROVIDERS
        // NOTHING REMOVED
        // ======================================================

        BlocProvider<QuickAcessBloc>(
          create: (_) => sl<QuickAcessBloc>(),
        ),

        BlocProvider<EmployeeActivityBloc>(
          create: (_) => sl<EmployeeActivityBloc>(),
        ),

        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),

        BlocProvider<NotVisitedDealerBloc>(
          create: (_) => sl<NotVisitedDealerBloc>(),
        ),

        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),

        BlocProvider<FarmerListBloc>(
          create: (_) => sl<FarmerListBloc>(),
        ),

        BlocProvider<DealerListBloc>(
          create: (_) => sl<DealerListBloc>(),
        ),

        BlocProvider<EnquiryBloc>(
          create: (_) => sl<EnquiryBloc>(),
        ),

        BlocProvider<FollowupBloc>(
          create: (_) => sl<FollowupBloc>(),
        ),

        BlocProvider<NotVisitedDealerBloc>(
          create: (_) => sl<NotVisitedDealerBloc>(),
        ),

        BlocProvider<DealerTargetBloc>(
          create: (_) => sl<DealerTargetBloc>(),
        ),

        BlocProvider<TopTenDealerBloc>(
          create: (_) => sl<TopTenDealerBloc>(),
        ),

        BlocProvider<FarmerListBloc>(
          create: (_) => sl<FarmerListBloc>(),
        ),

        BlocProvider<FamerfollowupBloc>(
          create: (_) => sl<FamerfollowupBloc>(),
        ),

        BlocProvider<StateBloc>(
          create: (_) => sl<StateBloc>(),
        ),

        BlocProvider<HomeBloc>(
          create: (_) => sl<HomeBloc>(),
        ),

        BlocProvider<GalleryBloc>(
          create: (_) => sl<GalleryBloc>(),
        ),

        BlocProvider<SchemeBloc>(
          create: (_) => sl<SchemeBloc>(),
        ),

        BlocProvider<ProductBloc>(
          create: (_) => sl<ProductBloc>(),
        ),

        BlocProvider<OrderHistoryBloc>(
          create: (_) => sl<OrderHistoryBloc>(),
        ),

        BlocProvider<AddDealerVisitBlock>(
          create: (_) => sl<AddDealerVisitBlock>(),
        ),

        BlocProvider<DispatchBloc>(
          create: (_) => sl<DispatchBloc>(),
        ),

        BlocProvider<SalesReturnHistoryBloc>(
          create: (_) => sl<SalesReturnHistoryBloc>(),
        ),

        BlocProvider<ExpenseBloc>(
          create: (_) => sl<ExpenseBloc>(),
        ),
      ],

      // ========================================================
      // YOUR EXISTING MATERIAL APP
      // NOTHING CHANGED
      // ========================================================

      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: AppColor.getLightTheme(),
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,

        builder: (context, child) {
          return Container(
            decoration: AppColor.appGradientDecoration,
            child: child,
          );
        },

        routerConfig: AppRouter.router,
      ),
    );
  }
}
