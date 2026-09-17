import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:demo/core/di/leave_list_di.dart';
import 'package:demo/features/dealer_visit/domain/entities/dealer_followup_list_entity.dart';
import '../bloc/add_dealer_visit_bloc.dart';
import '../bloc/add_dealer_visit_event.dart';
import '../bloc/add_dealer_visit_state.dart';

class DealerFollowupListPage extends StatefulWidget {
  final String dealerId;
  final String dealerName;

  const DealerFollowupListPage({
    super.key,
    required this.dealerId,
    required this.dealerName,
  });

  @override
  State<DealerFollowupListPage> createState() => _DealerFollowupListPageState();
}

class _DealerFollowupListPageState extends State<DealerFollowupListPage> {
  late AddDealerVisitBlock dealerVisitBloc;

  @override
  void initState() {
    super.initState();

    dealerVisitBloc = sl<AddDealerVisitBlock>();

    dealerVisitBloc.add(GetFollowupEvent(widget.dealerId));
  }

  @override
  void dispose() {
    dealerVisitBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: dealerVisitBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F8F6),

        // =========================================================
        // APP BAR
        // =========================================================
        appBar: CustomAppBar(
          title: 'Visit Summary',
          subtitle: widget.dealerName,
          showBackButton: true,
          actionIcon: Icons.refresh_rounded,
          onBackTap: () => context.go(AppRouter.home),
          onActionIconTap: () {
            dealerVisitBloc.add(GetFollowupEvent(widget.dealerId));
          },
        ),
        // appBar: AppBar(
        //   backgroundColor: const Color(0xFF087C3A),
        //   elevation: 3,

        //   leading: IconButton(
        //     onPressed: () => context.pop(),
        //     icon: const Icon(
        //       Icons.arrow_back,
        //       color: Colors.white,
        //     ),
        //   ),

        //   title: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       const Text(
        //         'Follow-ups',
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontSize: 19,
        //           fontWeight: FontWeight.w700,
        //         ),
        //       ),

        //       Text(
        //         widget.dealerName,
        //         maxLines: 1,
        //         overflow: TextOverflow.ellipsis,
        //         style: const TextStyle(
        //           color: Colors.white70,
        //           fontSize: 12,
        //         ),
        //       ),
        //     ],
        //   ),

        //   actions: [
        //     IconButton(
        //       onPressed: () {
        // dealerVisitBloc.add(
        //   GetFollowupEvent(widget.dealerId),
        // );
        //       },
        //       icon: const Icon(
        //         Icons.refresh,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ],
        // ),

        // =========================================================
        // BODY
        // =========================================================
        body: BlocBuilder<AddDealerVisitBlock, AddDealerVisitState>(
          builder: (context, state) {
            // -----------------------------------------------------
            // LOADING
            // -----------------------------------------------------
            if (state.addLeaveStatus == AddDealerVisitStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF087C3A)),
              );
            }

            final followups = state.followupList;

            debugPrint('Followup List Size: ${followups.length}');

            debugPrint('Followup List: $followups');

            // -----------------------------------------------------
            // EMPTY
            // -----------------------------------------------------
            if (followups.isEmpty) {
              return _buildEmptyState();
            }

            // -----------------------------------------------------
            // LIST
            // -----------------------------------------------------
            return RefreshIndicator(
              color: const Color(0xFF087C3A),

              onRefresh: () async {
                dealerVisitBloc.add(GetFollowupEvent(widget.dealerId));

                await Future.delayed(const Duration(milliseconds: 500));
              },

              child: ListView.builder(
                padding: const EdgeInsets.all(16),

                // Dealer header + summary + followups
                itemCount: followups.length + 2,

                itemBuilder: (context, index) {
                  // ------------------------------------------------
                  // DEALER HEADER
                  // ------------------------------------------------
                  if (index == 0) {
                    return _buildDealerHeader();
                  }

                  // ------------------------------------------------
                  // SUMMARY
                  // ------------------------------------------------
                  if (index == 1) {
                    return _buildSummaryCard(followups.length);
                  }

                  // ------------------------------------------------
                  // FOLLOW-UP CARD
                  // ------------------------------------------------
                  final followupIndex = index - 2;

                  final followup = followups[followupIndex];

                  return _buildFollowupCard(followup, followupIndex + 1);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================================================
  // DEALER HEADER
  // ===============================================================

  Widget _buildDealerHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          // Dealer icon
          Container(
            height: 52,
            width: 52,

            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),

            child: const Icon(
              Icons.store_rounded,
              color: Color(0xFF087C3A),
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dealer',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.dealerName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: Color(0xFF1B4332),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'ID: ${widget.dealerId}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SUMMARY CARD
  // ===============================================================

  Widget _buildSummaryCard(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      decoration: BoxDecoration(
        color: const Color(0xFF087C3A),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          const Icon(Icons.event_note_rounded, color: Colors.white, size: 25),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Follow-up History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              '$count',
              style: const TextStyle(
                color: Color(0xFF087C3A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FOLLOW-UP CARD
  // ===============================================================

  Widget _buildFollowupCard(DealerFollowupListEntity item, int index) {
    debugPrint('========== FOLLOW UP $index ==========');

    debugPrint('Employee: ${item.admName}');

    debugPrint('Dealer: ${item.outletName}');

    debugPrint('Date: ${item.followupDate}');

    debugPrint('Time: ${item.followupTime}');

    debugPrint('Remark: ${item.followupRemark}');

    debugPrint('=====================================');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE0E8E3)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // CARD HEADER
          // ========================================================
          Row(
            children: [
              Container(
                height: 44,
                width: 44,

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.event_note_rounded,
                  color: Color(0xFF087C3A),
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Follow-up $index',

                      style: const TextStyle(
                        color: Color(0xFF1B4332),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    if (item.followupDate.isNotEmpty ||
                        item.followupTime.isNotEmpty)
                      Text(
                        [
                          if (item.followupDate.isNotEmpty) item.followupDate,
                          if (item.followupTime.isNotEmpty) item.followupTime,
                        ].join(' • '),

                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ========================================================
          // EMPLOYEE
          // ========================================================
          _buildFollowupInfoRow(
            icon: Icons.person_outline_rounded,
            title: 'Employee',
            value: item.admName.isEmpty ? '-' : item.admName,
          ),

          const SizedBox(height: 11),

          // ========================================================
          // DEALER
          // ========================================================
          _buildFollowupInfoRow(
            icon: Icons.store_outlined,
            title: 'Dealer',
            value: item.outletName.isEmpty ? '-' : item.outletName,
          ),

          const SizedBox(height: 11),

          // ========================================================
          // DATE
          // ========================================================
          _buildFollowupInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Date',
            value: item.followupDate.isEmpty ? '-' : item.followupDate,
          ),

          const SizedBox(height: 11),

          // ========================================================
          // TIME
          // ========================================================
          _buildFollowupInfoRow(
            icon: Icons.access_time_rounded,
            title: 'Time',
            value: item.followupTime.isEmpty ? '-' : item.followupTime,
          ),

          const SizedBox(height: 14),

          // ========================================================
          // REMARK
          // ========================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F6),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 17,
                      color: Color(0xFF087C3A),
                    ),

                    SizedBox(width: 7),

                    Text(
                      'Remark',
                      style: TextStyle(
                        color: Color(0xFF087C3A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  item.followupRemark.isEmpty ? '-' : item.followupRemark,

                  style: const TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FOLLOW-UP INFO ROW
  // ===============================================================

  Widget _buildFollowupInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          height: 32,
          width: 32,

          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),

          child: Icon(icon, size: 17, color: const Color(0xFF087C3A)),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,

                style: const TextStyle(
                  color: Color(0xFF263238),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // EMPTY STATE
  // ===============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              height: 90,
              width: 90,

              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.event_busy_rounded,
                size: 45,
                color: Color(0xFF087C3A),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Follow-ups Found',

              style: TextStyle(
                color: Color(0xFF1B4332),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'No follow-up records are available for this dealer.',

              textAlign: TextAlign.center,

              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
