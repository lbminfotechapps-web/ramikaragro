import 'package:flutter/material.dart';
import '../../core/theme/app_dynamic_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/secure_storage/secure_storage.dart';
import '../../core/utility/widgets/custom_appbar.dart';

import '../home/doman/home_entity/menu_entity.dart';
import '../home/presentation/home_bloc/home_bloc.dart';
import '../home/presentation/home_bloc/home_event.dart';
import '../home/presentation/home_bloc/home_state.dart';

class ReportsHomePage extends StatelessWidget {
  const ReportsHomePage({
    super.key,
  });

  // ============================================================
  // REPORT MENU IDS
  // ============================================================

  static const List<String> _menuIds = [
    '32',
    '63',
    '65',
    '57',
    '64',
    '86',
    '87',

    // Dealer Growth / De-Growth
    '89',
   
  ];

  // ============================================================
  // COLORS
  // ============================================================

  static const Color _primary =
      Color(0xFF168A45);

  static const Color _blue =
      Color(0xFF3B78E7);

  static const Color _purple =
      Color(0xFF7658D8);

  static const Color _orange =
      Color(0xFFF59E0B);

  static const Color _red =
      Color(0xFFE55757);

  static const Color _teal =
      Color(0xFF18A99A);

  static const Color _indigo =
      Color(0xFF536DFE);

  // ============================================================
  // ROUTES
  // ============================================================

  static const Map<String, String> _routes = {
    '32': AppRouter.empActivityReport,
    '63': AppRouter.empOutputReport,
    '65': AppRouter.noVisitDealer,
    '57': AppRouter.visitSummaryReport,
    '64': AppRouter.topTenDealer,

    // Growth / De-Growth
    '89': AppRouter.growthReport,
  
    //Visit Analysis Report
    '87': AppRouter.monthlyVisitPerformanceReport,
  };

  // ============================================================
  // RELOAD MENUS
  // ============================================================

  Future<void> _reloadMenus(
    BuildContext context,
  ) async {
    final data =
        await SecureStorage.instance
            .getUserData();

    if (!context.mounted) {
      return;
    }

    final int userId =
        int.tryParse(
          data?['user_id']
                  ?.toString() ??
              '',
        ) ??
        0;

    context.read<HomeBloc>().add(
          GetMenuEvent(
            userId,
            userId == 0 ? '0' : '1',
          ),
        );
  }

  // ============================================================
  // ROUTE RESOLVER
  // ============================================================

  String? _routeForMenu(
    MenuEntity menu,
  ) {
    final String menuId =
        menu.menuId.trim();

    final String name =
        menu.menuName
            .toLowerCase()
            .replaceAll(
              RegExp(
                r'[^a-z0-9]',
              ),
              '',
            );

    debugPrint(
      '============================================',
    );

    debugPrint(
      'REPORT MENU CLICK',
    );

    debugPrint(
      'ID         => $menuId',
    );

    debugPrint(
      'NAME       => ${menu.menuName}',
    );

    debugPrint(
      'NORMALIZED => $name',
    );

    debugPrint(
      '============================================',
    );

    // ==========================================================
    // GROWTH / DE-GROWTH
    // MENU ID = 89
    // ==========================================================

    if (menuId == '89') {
      return AppRouter.growthReport;
    }

    if (name.contains(
          'growth',
        ) ||
        name.contains(
          'degrowth',
        ) ||
        name.contains(
          'dealergrowth',
        ) ||
        name.contains(
          'growthreport',
        )) {
      return AppRouter.growthReport;
    }

    // ==========================================================
    // MONTHLY PERFORMANCE
    // ==========================================================

    if (name.contains(
          'salespersonstat',
        ) ||
        name.contains(
          'salesmanstat',
        ) ||
        name.contains(
          'monthlyperformance',
        ) ||
        name.contains(
          'performanceanalysis',
        )) {
      return AppRouter
          .monthlyPerformanceReport;
    }

    // ==========================================================
    // EMPLOYEE ACTIVITY
    // ==========================================================

    if (name.contains(
          'employeeactivity',
        ) ||
        name.contains(
          'empactivity',
        )) {
      return AppRouter
          .empActivityReport;
    }

    // ==========================================================
    // EMPLOYEE OUTPUT
    // ==========================================================

    if (name.contains(
          'employeeoutput',
        ) ||
        name.contains(
          'empoutput',
        )) {
      return AppRouter
          .empOutputReport;
    }

    // ==========================================================
    // VISIT SUMMARY
    // ==========================================================

    if (name.contains(
      'visitsummary',
    )) {
      return AppRouter
          .visitSummaryReport;
    }

    // ==========================================================
    // NOT VISITED DEALER
    // ==========================================================

    if (name.contains(
          'notvisitdealer',
        ) ||
        name.contains(
          'nonvisiteddealer',
        ) ||
        name.contains(
          'notvisiteddealer',
        )) {
      return AppRouter
          .noVisitDealer;
    }

    // ==========================================================
    // TOP TEN DEALER
    // ==========================================================

    if (name.contains(
          'toptendealer',
        ) ||
        name.contains(
          'top10dealer',
        )) {
      return AppRouter
          .topTenDealer;
    }

    // ==========================================================
    // FALLBACK
    // ==========================================================

    return _routes[
      menuId
    ];
  }

  // ============================================================
  // OPEN MENU
  // ============================================================

  Future<void> _openMenu(
    BuildContext context,
    MenuEntity menu,
  ) async {
    final String? route =
        _routeForMenu(
      menu,
    );

    if (route == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          content: Text(
            '${menu.menuName} is not available yet',
          ),
        ),
      );

      return;
    }

    debugPrint(
      'OPENING REPORT ROUTE => $route',
    );

    // ==========================================================
    // ROUTES THAT REQUIRE USER ID
    // ==========================================================

    if ([
      AppRouter.empActivityReport,
      AppRouter.empOutputReport,
      AppRouter.visitSummaryReport,
    ].contains(route)) {
      final data =
          await SecureStorage.instance
              .getUserData();

      if (!context.mounted) {
        return;
      }

      context.push(
        route,
        extra:
            data?['user_id']
                    ?.toString() ??
                '',
      );
    } else {
      // Growth report comes here.
      //
      // GrowthReportPage itself reads logged-in user ID
      // from SecureStorage.

      context.push(
        route,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
   
      backgroundColor:
          context.appBackground,

      appBar:
          CustomAppBar(
        title:
            'Reports',

        showBackButton:
            true,

        onBackTap:
            () {
          context.go(
            AppRouter.home,
          );
        },
      ),

      body:
          SafeArea(
        child:
            BlocBuilder<
                HomeBloc,
                HomeState>(
          builder:
              (
            context,
            state,
          ) {
            // ==================================================
            // FILTER ONLY REQUIRED REPORT MENUS
            // ==================================================

            final Map<String, MenuEntity>
                menusById = {
              for (final menu
                  in state.menus)
                if (_menuIds.contains(
                  menu.menuId.trim(),
                ))
                  menu.menuId.trim():
                      menu,
            };

            // Keep same order as _menuIds
            final List<MenuEntity>
                menus = [
              for (final String id
                  in _menuIds)
                if (menusById
                    .containsKey(
                  id,
                ))
                  menusById[id]!,
            ];

            // ==================================================
            // LOADING
            // ==================================================

            if (state.status ==
                    HomeStatus.loading &&
                state.menus.isEmpty) {
              return Center(
                child:
                    CircularProgressIndicator(
                  color:
                      context.appPrimary,
                  strokeWidth:
                      2.3,
                ),
              );
            }

            // ==================================================
            // ERROR
            // ==================================================

            if (state.status ==
                    HomeStatus.failure &&
                state.menus.isEmpty) {
              return _errorState(
                context,
              );
            }

            // ==================================================
            // CONTENT
            // ==================================================

            return RefreshIndicator(
              color:
                  context.appPrimary,

              onRefresh:
                  () =>
                      _reloadMenus(
                context,
              ),

              child:
                  CustomScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                slivers: [
                  const SliverToBoxAdapter(
                    child:
                        SizedBox(
                      height:
                          8,
                    ),
                  ),

                  // ============================================
                  // HERO
                  // ============================================

                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal:
                          10,
                    ),

                    sliver:
                        SliverToBoxAdapter(
                      child:
                          _heroCard(
                        context, reportCount:
                            menus.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child:
                        SizedBox(
                      height:
                          11,
                    ),
                  ),

                  // ============================================
                  // REPORT HEADER
                  // ============================================

                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal:
                          11,
                    ),

                    sliver:
                        SliverToBoxAdapter(
                      child:
                          _reportsHeader(
                        context, menus.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child:
                        SizedBox(
                      height:
                          7,
                    ),
                  ),

                  // ============================================
                  // EMPTY
                  // ============================================

                  if (menus.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody:
                          false,
                      child:
                          _EmptyReports(),
                    )

                  // ============================================
                  // REPORT GRID
                  // ============================================

                  else
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        10,
                        0,
                        10,
                        18,
                      ),

                      sliver:
                          SliverLayoutBuilder(
                        builder:
                            (
                          context,
                          constraints,
                        ) {
                          final double width =
                              constraints
                                  .crossAxisExtent;

                          int columns = 2;

                          double ratio =
                              1.48;

                          if (width >=
                              1100) {
                            columns =
                                5;

                            ratio =
                                1.70;
                          } else if (width >=
                              850) {
                            columns =
                                4;

                            ratio =
                                1.62;
                          } else if (width >=
                              600) {
                            columns =
                                3;

                            ratio =
                                1.52;
                          }

                          return SliverGrid(
                            delegate:
                                SliverChildBuilderDelegate(
                              (
                                context,
                                index,
                              ) {
                                return _reportTile(
                                  context,
                                  menus[
                                      index],
                                  index,
                                );
                              },
                              childCount:
                                  menus.length,
                            ),

                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  columns,

                              crossAxisSpacing:
                                  8,

                              mainAxisSpacing:
                                  8,

                              childAspectRatio:
                                  ratio,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _heroCard(BuildContext context, {
    required int reportCount,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        12,
      ),

      decoration:
          BoxDecoration(
        color: context.appPrimary,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        boxShadow: [
          BoxShadow(
            color:
                context.appPrimary
                    .withValues(alpha: .13),

            blurRadius:
                14,

            offset:
                const Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child:
          Stack(
        children: [
          Positioned(
            right:
                -20,

            top:
                -25,

            child:
                Container(
              width:
                  100,

              height:
                  100,

              decoration:
                  BoxDecoration(
                color:
                    context.appOnPrimary
                        .withValues(alpha: .05),

                shape:
                    BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right:
                25,

            bottom:
                -45,

            child:
                Container(
              width:
                  85,

              height:
                  85,

              decoration:
                  BoxDecoration(
                color:
                    context.appOnPrimary
                        .withValues(alpha: .04),

                shape:
                    BoxShape.circle,
              ),
            ),
          ),

          Row(
            children: [
              Container(
                width:
                    42,

                height:
                    42,

                decoration:
                    BoxDecoration(
                  color:
                      context.appOnPrimary
                          .withValues(alpha: .14),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child:
                    Icon(
                  Icons
                      .dashboard_customize_outlined,

                  color:
                      context.appOnPrimary,

                  size:
                      22,
                ),
              ),

              const SizedBox(
                width:
                    10,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'All Reports',

                      style:
                          TextStyle(
                        color:
                            context.appOnPrimary,

                        fontSize:
                            15,

                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    SizedBox(
                      height:
                          2,
                    ),

                    Text(
                      'Track performance, productivity and field activity',

                      maxLines:
                          2,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          TextStyle(
                        color:
                            context.appOnPrimary.withValues(alpha: 0.8),

                        fontSize:
                            7.7,

                        height:
                            1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width:
                    8,
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      9,

                  vertical:
                      6,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      context.appOnPrimary
                          .withValues(alpha: .13),

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child:
                    Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Text(
                      '$reportCount',

                      style:
                          TextStyle(
                        color:
                            context.appOnPrimary,

                        fontSize:
                            14,

                        fontWeight:
                            FontWeight.w900,

                        height:
                            1,
                      ),
                    ),

                    const SizedBox(
                      height:
                          2,
                    ),

                    Text(
                      'Reports',

                      style:
                          TextStyle(
                        color:
                            context.appOnPrimary.withValues(alpha: 0.7),

                        fontSize:
                            6.5,

                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT HEADER
  // ============================================================

  Widget _reportsHeader(
    BuildContext context, int count,
  ) {
    return Row(
      children: [
        Expanded(
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'Explore all available report modules',

                style:
                    TextStyle(
                  color:
                      context.appSubText,

                  fontSize:
                      7,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal:
                7,

            vertical:
                3,
          ),

          decoration:
              BoxDecoration(
            color:
                Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard),

            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),

          child:
              Text(
            '$count available',

            style:
                TextStyle(
              color:
                  context.appPrimary,

              fontSize:
                  6.7,

              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REPORT TILE
  // ============================================================

  Widget _reportTile(
    BuildContext context,
    MenuEntity menu,
    int index,
  ) {
    final style =
        _styleForMenu(
      menu,
      index,
    );

    return Material(
      color:
          Colors.transparent,

      child:
          InkWell(
        onTap:
            () {
          _openMenu(
            context,
            menu,
          );
        },

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        child:
            Ink(
          decoration:
              BoxDecoration(
            color:
                context.appCard,

            borderRadius:
                BorderRadius.circular(
              14,
            ),

            border:
                Border.all(
              color:
                  context.appBorder,

              width:
                  .8,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    Theme.of(context).colorScheme.shadow
                        .withValues(alpha: .018),

                blurRadius:
                    6,

                offset:
                    const Offset(
                  0,
                  2,
                ),
              ),
            ],
          ),

          child:
              Column(
            children: [
              // ================================================
              // TOP ACCENT
              // ================================================

              Container(
                height:
                    3.5,

                decoration:
                    BoxDecoration(
                  color:
                      context.appPrimary,

                  borderRadius:
                      const BorderRadius.vertical(
                    top:
                        Radius.circular(
                      14,
                    ),
                  ),
                ),
              ),

              Expanded(
                child:
                    Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    9,
                    8,
                    9,
                    7,
                  ),

                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Container(
                            width:
                                34,

                            height:
                                34,

                            decoration:
                                BoxDecoration(
                              color:
                                  context.appPrimary
                                      .withValues(alpha: .08),

                              borderRadius:
                                  BorderRadius.circular(
                                9,
                              ),
                            ),

                            child:
                                menu.iconImage
                                        .trim()
                                        .isEmpty
                                    ? Icon(
                                        style.icon,

                                        color:
                                            context.appPrimary,

                                        size:
                                            18,
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.all(
                                          7,
                                        ),

                                        child:
                                            Image.network(
                                          menu.iconImage,

                                          fit:
                                              BoxFit.contain,

                                          errorBuilder:
                                              (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Icon(
                                              style.icon,

                                              color:
                                                  context.appPrimary,

                                              size:
                                                  18,
                                            );
                                          },
                                        ),
                                      ),
                          ),

                          const Spacer(),

                          Container(
                            width:
                                26,

                            height:
                                26,

                            decoration:
                                BoxDecoration(
                              color:
                                  context.appPrimary
                                      .withValues(alpha: .055),

                              shape:
                                  BoxShape.circle,
                            ),

                            child:
                                Icon(
                              Icons
                                  .north_east_rounded,

                              size:
                                  12,

                              color:
                                  context.appPrimary,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Text(
                        menu.menuName,

                        maxLines:
                            2,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            TextStyle(
                          color:
                              context.appOnCard,

                          fontSize:
                              10,

                          height:
                              1.15,

                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      const SizedBox(
                        height:
                            3,
                      ),

                      Text(
                        _descriptionForMenu(
                          menu,
                        ),

                        maxLines:
                            1,

                        overflow:
                            TextOverflow.ellipsis,

                        style:
                            TextStyle(
                          color:
                              context.appSubText,

                          fontSize:
                              6.5,

                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(
                        height:
                            6,
                      ),

                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal:
                                  6,

                              vertical:
                                  2,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  context.appPrimary
                                      .withValues(alpha: .07),

                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),

                            child:
                                Text(
                              _tagForMenu(
                                menu,
                              ),

                              style:
                                  TextStyle(
                                color:
                                    context.appPrimary,

                                fontSize:
                                    6,

                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),

                          const Spacer(),

                          Icon(
                            Icons
                                .chevron_right_rounded,

                            color:
                                context.appPrimary,

                            size:
                                15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAG
  // ============================================================

  String _tagForMenu(
    MenuEntity menu,
  ) {
    final String menuId =
        menu.menuId.trim();

    final String name =
        menu.menuName
            .toLowerCase();

    // Growth / De-Growth
    if (menuId == '89' ||
        name.contains(
          'growth',
        ) ||
        name.contains(
          'de-growth',
        ) ||
        name.contains(
          'degrowth',
        )) {
      return 'GROWTH';
    }

    if (name.contains(
          'performance',
        ) ||
        name.contains(
          'salesman',
        )) {
      return 'ANALYTICS';
    }

    if (name.contains(
      'activity',
    )) {
      return 'ACTIVITY';
    }

    if (name.contains(
      'output',
    )) {
      return 'OUTPUT';
    }

    if (name.contains(
      'visit',
    )) {
      return 'VISITS';
    }

    if (name.contains(
      'top',
    )) {
      return 'RANKING';
    }

    return 'REPORT';
  }

  // ============================================================
  // STYLE
  // ============================================================

  _ReportStyle _styleForMenu(
    MenuEntity menu,
    int index,
  ) {
    final String menuId =
        menu.menuId.trim();

    final String name =
        menu.menuName
            .toLowerCase();

    // ==========================================================
    // GROWTH / DE-GROWTH
    // ==========================================================

    if (menuId == '89' ||
        name.contains(
          'growth',
        ) ||
        name.contains(
          'de-growth',
        ) ||
        name.contains(
          'degrowth',
        )) {
      return const _ReportStyle(
        color:
            Color(
          0xFF14804A,
        ),

        icon:
            Icons.trending_up_rounded,
      );
    }

    // ==========================================================
    // PERFORMANCE
    // ==========================================================

    if (name.contains(
          'performance',
        ) ||
        name.contains(
          'salesman stat',
        ) ||
        name.contains(
          'sales person stat',
        )) {
      return const _ReportStyle(
        color:
            _blue,

        icon:
            Icons.insights_rounded,
      );
    }

    // ==========================================================
    // EMPLOYEE ACTIVITY
    // ==========================================================

    if (name.contains(
      'employee activity',
    )) {
      return const _ReportStyle(
        color:
            _purple,

        icon:
            Icons.badge_outlined,
      );
    }

    // ==========================================================
    // EMPLOYEE OUTPUT
    // ==========================================================

    if (name.contains(
      'employee output',
    )) {
      return const _ReportStyle(
        color:
            _orange,

        icon:
            Icons.trending_up_rounded,
      );
    }

    // ==========================================================
    // VISIT SUMMARY
    // ==========================================================

    if (name.contains(
      'visit summary',
    )) {
      return const _ReportStyle(
        color:
            _primary,

        icon:
            Icons.route_outlined,
      );
    }

    // ==========================================================
    // NOT VISITED
    // ==========================================================

    if (name.contains(
          'not visit',
        ) ||
        name.contains(
          'not visited',
        )) {
      return const _ReportStyle(
        color:
            _red,

        icon:
            Icons.location_off_outlined,
      );
    }

    // ==========================================================
    // TOP TEN
    // ==========================================================

    if (name.contains(
          'top ten',
        ) ||
        name.contains(
          'top 10',
        )) {
      return const _ReportStyle(
        color:
            _teal,

        icon:
            Icons.emoji_events_outlined,
      );
    }

    // ==========================================================
    // FALLBACK
    // ==========================================================

    const List<Color> colors = [
      _primary,
      _blue,
      _purple,
      _orange,
      _teal,
      _indigo,
      _red,
    ];

    const List<IconData> icons = [
      Icons.assessment_outlined,
      Icons.analytics_outlined,
      Icons.bar_chart_rounded,
      Icons.insights_outlined,
      Icons.pie_chart_outline,
      Icons.query_stats_outlined,
      Icons.timeline_rounded,
    ];

    final int position =
        index %
            colors.length;

    return _ReportStyle(
      color:
          colors[position],

      icon:
          icons[position],
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  String _descriptionForMenu(
    MenuEntity menu,
  ) {
    final String menuId =
        menu.menuId.trim();

    final String name =
        menu.menuName
            .toLowerCase();

    // Growth
    if (menuId == '89' ||
        name.contains(
          'growth',
        ) ||
        name.contains(
          'de-growth',
        ) ||
        name.contains(
          'degrowth',
        )) {
      return 'Dealer year-wise growth / de-growth';
    }

    if (name.contains(
          'performance',
        ) ||
        name.contains(
          'salesman',
        )) {
      return 'Monthly • Daily • Hourly • Area';
    }

    if (name.contains(
      'employee activity',
    )) {
      return 'Field activity tracking';
    }

    if (name.contains(
      'employee output',
    )) {
      return 'Employee productivity';
    }

    if (name.contains(
      'visit summary',
    )) {
      return 'Dealer & farmer coverage';
    }

    if (name.contains(
          'not visit',
        ) ||
        name.contains(
          'not visited',
        )) {
      return 'Pending dealer coverage';
    }

    if (name.contains(
          'top ten',
        ) ||
        name.contains(
          'top 10',
        )) {
      return 'Top dealer ranking';
    }

    return 'Detailed business insights';
  }

  // ============================================================
  // ERROR
  // ============================================================

  static Widget _errorState(
    BuildContext context,
  ) {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width:
                  52,

              height:
                  52,

              decoration:
                  BoxDecoration(
                color:
                    context.appError
                        .withValues(alpha: .06),

                shape:
                    BoxShape.circle,
              ),

              child:
                  Icon(
                Icons
                    .error_outline_rounded,

                color:
                    context.appError,

                size:
                    25,
              ),
            ),

            const SizedBox(
              height:
                  10,
            ),

            Text(
              'Unable to load reports',

              style:
                  TextStyle(
                color:
                    context.appOnCard,

                fontSize:
                    12,

                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height:
                  3,
            ),

            Text(
              'Please check your connection and try again.',

              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                color:
                    context.appSubText,

                fontSize:
                    7.5,
              ),
            ),

            const SizedBox(
              height:
                  10,
            ),

            OutlinedButton.icon(
              onPressed:
                  () {
                const ReportsHomePage()
                    ._reloadMenus(
                  context,
                );
              },

              icon:
                  Icon(
                Icons.refresh_rounded,

                size:
                    14,
              ),

              label:
                  Text(
                'Retry',
              ),

              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    context.appPrimary,

                side:
                    BorderSide(
                  color:
                      context.appPrimary,
                ),

                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      14,

                  vertical:
                      8,
                ),

                textStyle:
                    TextStyle(
                  fontSize:
                      8.5,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyReports
    extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          26,
        ),

        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width:
                  58,

              height:
                  58,

              decoration:
                  BoxDecoration(
                color:
                    Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard),

                shape:
                    BoxShape.circle,
              ),

              child:
                  Icon(
                Icons
                    .dashboard_customize_outlined,

                color:
                    context.appPrimary,

                size:
                    28,
              ),
            ),

            const SizedBox(
              height:
                  10,
            ),

            Text(
              'No Reports Available',

              style:
                  TextStyle(
                color:
                    context.appText,

                fontSize:
                    12,

                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height:
                  3,
            ),

            Text(
              'No report menus are assigned to your account.',

              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                color:
                    context.appSubText,

                fontSize:
                    7.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STYLE MODEL
// ============================================================

class _ReportStyle {
  final Color color;

  final IconData icon;

  const _ReportStyle({
    required this.color,
    required this.icon,
  });
}