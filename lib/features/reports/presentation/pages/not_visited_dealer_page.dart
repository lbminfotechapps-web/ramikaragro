import 'package:demo/core/di/global_di.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:flutter/material.dart';
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
        backgroundColor: const Color(0xFFF6F8FB),

        // ====================================================================
        // APP BAR
        // ====================================================================
        appBar: AppBar(
          backgroundColor: const Color(0xFF287A4B),

          foregroundColor: Colors.white,

          elevation: 0,

          automaticallyImplyLeading: false,

          leading: IconButton(
            onPressed: () {
              context.go(AppRouter.home);
            },
            icon: const Icon(Icons.arrow_back_rounded, size: 25),
          ),

          title: const Text(
            'Not Visited Dealers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          actions: [
            IconButton(
              tooltip: 'Refresh',

              onPressed: _isRefreshing ? null : _refreshDealers,

              icon: _isRefreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 25),
            ),

            const SizedBox(width: 6),
          ],
        ),

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
              color: const Color(0xFF168A4A),

              backgroundColor: Colors.white,

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
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF168A4A),
                          ),
                        ),
                      ),
                    ),

                  // ==========================================================
                  // NO MORE DATA
                  // ==========================================================
                  if (state.hasReachedMax && state.dealers.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No more dealers',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF89939D),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
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
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFE5E9EC)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              color: const Color(0xFFEAF7EF),

              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.storefront_rounded,
              color: Color(0xFF168A4A),
              size: 25,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Visits',
                  style: TextStyle(
                    color: Color(0xFF7B858E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '$dealerCount Dealers',
                  style: const TextStyle(
                    color: Color(0xFF20262D),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),

            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),

              borderRadius: BorderRadius.circular(10),
            ),

            child: const Text(
              '30 Days',
              style: TextStyle(
                color: Color(0xFF168A4A),
                fontSize: 11,
                fontWeight: FontWeight.w700,
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
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF168A4A)),
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
            const Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 16),

            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7A8491)),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                context.read<NotVisitedDealerBloc>().add(
                  const GetNotVisitedDealersEvent(days: 30, startLimit: 0),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF168A4A),
                foregroundColor: Colors.white,
              ),

              child: const Text('Try Again'),
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

              decoration: const BoxDecoration(
                color: Color(0xFFEAF7EF),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.store_rounded,
                size: 40,
                color: Color(0xFF168A4A),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'All Dealers Visited',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            const Text(
              'There are no dealers who have not been visited in the last 30 days.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF7A8491),
              ),
            ),

            const SizedBox(height: 20),

            TextButton.icon(
              onPressed: () {
                context.read<NotVisitedDealerBloc>().add(
                  const GetNotVisitedDealersEvent(days: 30, startLimit: 0),
                );
              },

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Refresh'),

              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF168A4A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
