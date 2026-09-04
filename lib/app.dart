import 'package:demo/core/di/auth_di.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_theme.dart';
import 'package:demo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:demo/features/reports/presentation/bloc/not_visited_dealer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
      BlocProvider<NotVisitedDealerBloc>(create: (_) => sl<NotVisitedDealerBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: AppColor.getLightTheme(),
        themeMode: ThemeMode.light,
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
