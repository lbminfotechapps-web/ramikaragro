import 'package:demo/core/di/global_di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/not_visited_dealer_bloc.dart';
import '../bloc/not_visited_dealer_event.dart';
import '../bloc/not_visited_dealer_state.dart';
import '../widgets/dealer_card.dart';

class NotVisitedDealerPage extends StatelessWidget {
  const NotVisitedDealerPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotVisitedDealerBloc>(
      create: (_) {
        final bloc = sl<NotVisitedDealerBloc>();

        // =======================================================
        // FIRST API CALL
        // =======================================================

        bloc.add(
          const GetNotVisitedDealersEvent(
            days: 30,
            startLimit: 0,
          ),
        );

        return bloc;
      },
      child: const NotVisitedDealerView(),
    );
  }
}

// =================================================================
// VIEW
// =================================================================

class NotVisitedDealerView extends StatefulWidget {
  const NotVisitedDealerView({
    super.key,
  });

  @override
  State<NotVisitedDealerView> createState() =>
      _NotVisitedDealerViewState();
}

class _NotVisitedDealerViewState
    extends State<NotVisitedDealerView> {
  late final ScrollController _scrollController;

  // Prevent multiple scroll events from firing together.
  bool _isScrollLoading = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(
      _onScroll,
    );
  }

  // =============================================================
  // SCROLL LISTENER
  // =============================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    // -----------------------------------------------------------
    // Load more when 300 pixels are remaining.
    // -----------------------------------------------------------

    if (position.pixels >=
        position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  // =============================================================
  // LOAD MORE
  // =============================================================

  void _loadMore() {
    if (_isScrollLoading) {
      return;
    }

    final bloc =
        context.read<NotVisitedDealerBloc>();

    // Already loading
    if (bloc.state.status ==
        DealerStatus.loadingMore) {
      return;
    }

    // All data loaded
    if (bloc.state.hasReachedMax) {
      return;
    }

    _isScrollLoading = true;

    print('');
    print('========================================');
    print('SCROLL → LOAD MORE');
    print('========================================');
    print(
      'Current startLimit: ${bloc.state.startLimit}',
    );
    print(
      'Current dealers: ${bloc.state.dealers.length}',
    );
    print('========================================');

    bloc.add(
      const GetMoreNotVisitedDealersEvent(
        days: 30,
      ),
    );

    // Allow another request after state update.
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        if (mounted) {
          _isScrollLoading = false;
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(
      _onScroll,
    );

    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FB),

      body: BlocBuilder<
          NotVisitedDealerBloc,
          DealerState>(
        builder: (context, state) {
          // ===================================================
          // FIRST PAGE LOADING
          // ===================================================

          if (state.status ==
                  DealerStatus.loading &&
              state.dealers.isEmpty) {
            return const _LoadingView();
          }

          // ===================================================
          // FIRST PAGE ERROR
          // ===================================================

          if (state.status ==
                  DealerStatus.failure &&
              state.dealers.isEmpty) {
            return _ErrorView(
              message: state.errorMessage ??
                  'An unexpected error occurred. Please try again later.',
            );
          }

          // ===================================================
          // EMPTY
          // ===================================================

          if (state.status ==
                  DealerStatus.success &&
              state.dealers.isEmpty) {
            return const _EmptyView();
          }

          // ===================================================
          // DEALER LIST
          // ===================================================

          return RefreshIndicator(
            color:
                const Color(0xFF168A4A),
            backgroundColor: Colors.white,

            // -------------------------------------------------
            // PULL TO REFRESH
            // -------------------------------------------------

            onRefresh: () async {
              context
                  .read<NotVisitedDealerBloc>()
                  .add(
                    const GetNotVisitedDealersEvent(
                      days: 30,
                      startLimit: 0,
                    ),
                  );

              // Wait until refresh finishes.
              await context
                  .read<NotVisitedDealerBloc>()
                  .stream
                  .firstWhere(
                    (state) =>
                        state.status ==
                            DealerStatus.success ||
                        state.status ==
                            DealerStatus.failure,
                  );
            },

            child: CustomScrollView(
              controller: _scrollController,

              physics:
                  const AlwaysScrollableScrollPhysics(),

              slivers: [
                // =================================================
                // HEADER
                // =================================================

                SliverToBoxAdapter(
                  child: _Header(
                    dealerCount:
                        state.dealers.length,
                  ),
                ),

                // =================================================
                // DEALER LIST
                // =================================================

                SliverList(
                  delegate:
                      SliverChildBuilderDelegate(
                    (context, index) {
                      final dealer =
                          state.dealers[index];

                      return DealerCard(
                        dealer: dealer,
                      );
                    },
                    childCount:
                        state.dealers.length,
                  ),
                ),

                // =================================================
                // LOAD MORE INDICATOR
                // =================================================

                if (state.status ==
                    DealerStatus.loadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      child: Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              Color(0xFF168A4A),
                        ),
                      ),
                    ),
                  ),

                // =================================================
                // NO MORE DATA
                // =================================================

                if (state.hasReachedMax &&
                    state.dealers.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      child: Center(
                        child: Text(
                          'No more dealers',
                          style: TextStyle(
                            color:
                                Color(0xFF89939D),
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 25,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =================================================================
// HEADER
// =================================================================

class _Header extends StatelessWidget {
  final int dealerCount;

  const _Header({
    required this.dealerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top:
            MediaQuery.of(context)
                    .padding
                    .top +
                16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF167D46),
            Color(0xFF20A35E),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:
              Radius.circular(30),
          bottomRight:
              Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =====================================================
          // APP BAR
          // =====================================================

          Row(
            children: [
              InkWell(
                borderRadius:
                    BorderRadius.circular(14),
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 44,
                  width: 44,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.16),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Text(
                  'Not Visited Dealers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              InkWell(
                borderRadius:
                    BorderRadius.circular(14),
                onTap: () {
                  context
                      .read<
                          NotVisitedDealerBloc>()
                      .add(
                        const GetNotVisitedDealersEvent(
                          days: 30,
                          startLimit: 0,
                        ),
                      );
                },
                child: Container(
                  height: 44,
                  width: 44,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.16),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // =====================================================
          // SUMMARY
          // =====================================================

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.14),
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .storefront_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Pending Visits',
                        style: TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        '$dealerCount Dealers',
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Text(
                    '30 Days',
                    style: TextStyle(
                      color:
                          Color(0xFF168A4A),
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// LOADING VIEW
// =================================================================

class _LoadingView
    extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FB),
      body: Column(
        children: [
          Container(
            height: 155,
            width: double.infinity,
            decoration:
                const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF167D46),
                  Color(0xFF20A35E),
                ],
              ),
              borderRadius:
                  BorderRadius.only(
                bottomLeft:
                    Radius.circular(30),
                bottomRight:
                    Radius.circular(30),
              ),
            ),
          ),

          const SizedBox(height: 35),

          const CircularProgressIndicator(
            color: Color(0xFF168A4A),
          ),

          const SizedBox(height: 18),

          const Text(
            'Loading dealers...',
            style: TextStyle(
              fontSize: 15,
              color:
                  Color(0xFF6D7680),
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// ERROR VIEW
// =================================================================

class _ErrorView
    extends StatelessWidget {
  final String message;

  const _ErrorView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FB),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.05),
                  blurRadius: 20,
                  offset:
                      const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration:
                      const BoxDecoration(
                    color:
                        Color(0xFFFFEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .cloud_off_rounded,
                    color:
                        Colors.redAccent,
                    size: 34,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF20262D),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  message,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color:
                        Color(0xFF7A8491),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child:
                      ElevatedButton(
                    onPressed: () {
                      context
                          .read<
                              NotVisitedDealerBloc>()
                          .add(
                            const GetNotVisitedDealersEvent(
                              days: 30,
                              startLimit: 0,
                            ),
                          );
                    },
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF168A4A,
                      ),
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),
                    ),
                    child:
                        const Text(
                      'Try Again',
                      style:
                          TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =================================================================
// EMPTY VIEW
// =================================================================

class _EmptyView
    extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8FB),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.04),
                  blurRadius: 20,
                  offset:
                      const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration:
                      const BoxDecoration(
                    color:
                        Color(0xFFEAF7EF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    size: 40,
                    color:
                        Color(0xFF168A4A),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                const Text(
                  'All Dealers Visited',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xFF20262D),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Great job! There are no dealers who have not been visited in the last 30 days.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color:
                        Color(0xFF7A8491),
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                TextButton.icon(
                  onPressed: () {
                    context
                        .read<
                            NotVisitedDealerBloc>()
                        .add(
                          const GetNotVisitedDealersEvent(
                            days: 30,
                            startLimit: 0,
                          ),
                        );
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label:
                      const Text('Refresh'),
                  style:
                      TextButton.styleFrom(
                    foregroundColor:
                        const Color(
                      0xFF168A4A,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}