import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/di/global_di.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/not_visited_dealer_bloc.dart';
import '../bloc/not_visited_dealer_event.dart';
import '../bloc/not_visited_dealer_state.dart';
import '../widgets/dealer_card.dart';

class NotVisitedDealerPage extends StatelessWidget {
  const NotVisitedDealerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotVisitedDealerBloc>(
      create: (_) {
        final bloc = sl<NotVisitedDealerBloc>();

        bloc.add(const GetNotVisitedDealersEvent(days: 30, startLimit: 0));

        return bloc;
      },
      child: const NotVisitedDealerView(),
    );
  }
}

// ============================================================================
// VIEW
// ============================================================================

class NotVisitedDealerView extends StatefulWidget {
  const NotVisitedDealerView({super.key});

  @override
  State<NotVisitedDealerView> createState() => _NotVisitedDealerViewState();
}

class _NotVisitedDealerViewState extends State<NotVisitedDealerView> {
  late final ScrollController _scrollController;

  bool _isRefreshing = false;
  bool _isScrollLoading = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  // ==========================================================================
  // LOAD MORE
  // ==========================================================================

  void _loadMore() {
    if (_isScrollLoading) {
      return;
    }

    final bloc = context.read<NotVisitedDealerBloc>();

    final state = bloc.state;

    if (state.status == DealerStatus.loadingMore) {
      return;
    }

    if (state.hasReachedMax) {
      return;
    }

    _isScrollLoading = true;

    debugPrint('========================================');
    debugPrint('NOT VISITED DEALER: LOAD MORE');
    debugPrint('Current count: ${state.dealers.length}');
    debugPrint('========================================');

    bloc.add(const GetMoreNotVisitedDealersEvent(days: 30));

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        _isScrollLoading = false;
      }
    });
  }

  // ==========================================================================
  // REFRESH
  // ==========================================================================

  Future<void> _refreshDealers() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    final bloc = context.read<NotVisitedDealerBloc>();

    bloc.add(const GetNotVisitedDealersEvent(days: 30, startLimit: 0));

    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    try {
      await bloc.stream.firstWhere(
        (state) =>
            state.status == DealerStatus.success ||
            state.status == DealerStatus.failure,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _isScrollLoading = false;
        });
      }
    }
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Android system back will automatically pop this route.
      canPop: true,

      child: Scaffold(
        backgroundColor: context.backgroundColor,

        appBar: CustomAppBar(
          title: 'Not Visited Dealers',
          backgroundColor: context.primaryColor,
          titleStyle: AppTextStyles.appBarTitle.copyWith(
            color: context.onPrimaryColor,
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: context.onPrimaryColor,
            ),
            onPressed: () => context.go(AppRouter.home),
          ),
          showBackButton: true,
          onBackTap: () => context.go(AppRouter.home),

          // Normal refresh icon
          actionIcon: Icons.refresh_rounded,

          // Disable click while refreshing
          onActionIconTap: _isRefreshing ? null : _refreshDealers,

          // Show loader when refreshing
          action: _isRefreshing
              ? SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.onPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),

        // appBar: AppBar(
        //   backgroundColor: const Color(0xFF287A4B),

        //   foregroundColor: context.onPrimaryColor,

        //   elevation: 0,

        //   automaticallyImplyLeading: false,

        //   leading: IconButton(
        //     onPressed: () {
        //       context.go(AppRouter.home);
        //     },
        //     icon: Icon(Icons.arrow_back_rounded, size: 25),
        //   ),

        //   title: Text(
        //     'Not Visited Dealers',
        //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        //   ),

        //   actions: [
        //     IconButton(
        //       tooltip: 'Refresh',

        //       onPressed: _isRefreshing ? null : _refreshDealers,

        //       icon: _isRefreshing
        //           ? SizedBox(
        //               width: 20,
        //               height: 20,
        //               child: CircularProgressIndicator(
        //                 strokeWidth: 2,
        //                 valueColor: AlwaysStoppedAnimation<Color>(context.cardBackgroundColor),
        //               ),
        //             )
        //           : Icon(Icons.refresh_rounded, size: 25),
        //     ),

        //     SizedBox(width: 6),
        //   ],
        // ),

        // ====================================================================
        // BODY
        // ====================================================================
        body: BlocBuilder<NotVisitedDealerBloc, DealerState>(
          builder: (context, state) {
            // ================================================================
            // LOADING
            // ================================================================

            if (state.status == DealerStatus.loading && state.dealers.isEmpty) {
              return const _LoadingView();
            }

            // ================================================================
            // ERROR
            // ================================================================

            if (state.status == DealerStatus.failure && state.dealers.isEmpty) {
              return _ErrorView(
                message: state.errorMessage ?? 'Unable to load dealers.',
              );
            }

            // ================================================================
            // EMPTY
            // ================================================================

            if (state.status == DealerStatus.success && state.dealers.isEmpty) {
              return const _EmptyView();
            }

            // ================================================================
            // LIST
            // ================================================================

            return RefreshIndicator(
              color: context.primaryColor,

              backgroundColor: context.cardBackgroundColor,

              onRefresh: _refreshDealers,

              child: CustomScrollView(
                controller: _scrollController,

                physics: const AlwaysScrollableScrollPhysics(),

                slivers: [
                  // ==========================================================
                  // SUMMARY
                  // ==========================================================
                  SliverToBoxAdapter(
                    child: _SummaryHeader(dealerCount: state.dealers.length),
                  ),

                  // ==========================================================
                  // DEALERS
                  // ==========================================================
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final dealer = state.dealers[index];

                      return DealerCard(dealer: dealer);
                    }, childCount: state.dealers.length),
                  ),

                  // ==========================================================
                  // PAGINATION LOADING
                  // ==========================================================
                  if (state.status == DealerStatus.loadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: context.primaryColor,
                          ),
                        ),
                      ),
                    ),

                  // ==========================================================
                  // NO MORE DATA
                  // ==========================================================
                  if (state.hasReachedMax && state.dealers.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No more dealers',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(child: SizedBox(height: 30)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// SUMMARY HEADER
// ============================================================================

class _SummaryHeader extends StatelessWidget {
  final int dealerCount;

  const _SummaryHeader({required this.dealerCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 8),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: context.borderColor),

        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,

            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.08),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              Icons.storefront_rounded,
              color: context.primaryColor,
              size: 25,
            ),
          ),

          SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Visits',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  '$dealerCount Dealers',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: context.cardTextColor,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),

            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.08),

              borderRadius: BorderRadius.circular(10),
            ),

            child: Text(
              '30 Days',
              style: AppTextStyles.labelSmall.copyWith(
                color: context.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOADING VIEW
// ============================================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.primaryColor),
    );
  }
}

// ============================================================================
// ERROR VIEW
// ============================================================================

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: context.appColors.error,
            ),

            SizedBox(height: 16),

            // Text(
            //   'Something went wrong',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            // ),

            // SizedBox(height: 8),
            Text(
              "No Record Found",
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle,
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                context.read<NotVisitedDealerBloc>().add(
                  const GetNotVisitedDealersEvent(days: 30, startLimit: 0),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimaryColor,
              ),

              child: Text('Try Again', style: AppTextStyles.body),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EMPTY VIEW
// ============================================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              height: 80,
              width: 80,

              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.store_rounded,
                size: 40,
                color: context.primaryColor,
              ),
            ),

            SizedBox(height: 20),

            Text('All Dealers Visited', style: AppTextStyles.headingLarge),

            SizedBox(height: 8),

            Text(
              'There are no dealers who have not been visited in the last 30 days.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                height: 1.5,
                color: context.secondaryTextColor,
              ),
            ),

            SizedBox(height: 20),

            TextButton.icon(
              onPressed: () {
                context.read<NotVisitedDealerBloc>().add(
                  const GetNotVisitedDealersEvent(days: 30, startLimit: 0),
                );
              },

              icon: Icon(Icons.refresh_rounded),

              label: Text('Refresh', style: AppTextStyles.body),

              style: TextButton.styleFrom(
                foregroundColor: context.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
