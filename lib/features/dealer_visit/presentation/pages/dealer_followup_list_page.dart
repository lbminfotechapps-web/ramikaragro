import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:demo/core/di/leave_list_di.dart';

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
  State<DealerFollowupListPage> createState() =>
      _DealerFollowupListPageState();
}

class _DealerFollowupListPageState extends State<DealerFollowupListPage> {
  late AddDealerVisitBlock dealerVisitBloc;

  @override
  void initState() {
    super.initState();

    dealerVisitBloc = sl<AddDealerVisitBlock>();

    dealerVisitBloc.add(
      GetFollowupEvent(widget.dealerId),
    );
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
        appBar: AppBar(
          backgroundColor: const Color(0xFF087C3A),
          elevation: 3,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Follow-ups',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.dealerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                dealerVisitBloc.add(
                  GetFollowupEvent(widget.dealerId),
                );
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: BlocBuilder<AddDealerVisitBlock, AddDealerVisitState>(
          builder: (context, state) {
            if (state.addLeaveStatus ==
                AddDealerVisitStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF087C3A),
                ),
              );
            }

            final followups = state.followupList;

            print('Followup List Size: ${followups.length}');
print('Followup List: $followups');

            if (followups == null || followups.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: const Color(0xFF087C3A),
              onRefresh: () async {
                dealerVisitBloc.add(
                  GetFollowupEvent(widget.dealerId),
                );

                await Future.delayed(
                  const Duration(milliseconds: 500),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: followups.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildDealerHeader();
                  }

                  if (index == 1) {
                    return _buildSummaryCard(
                      followups.length,
                    );
                  }

                  return _buildFollowupCard(
                    followups[index - 2],
                    index - 1,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

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
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
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
    );
  }

  Widget _buildSummaryCard(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF087C3A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_note_rounded,
            color: Colors.white,
            size: 25,
          ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
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

  Widget _buildFollowupCard(
    dynamic item,
    int index,
  ) {
    final date = _readValue(item, 'followUpDate');
    final type = _readValue(item, 'followUpType');
    final purpose = _readValue(item, 'purpose');
    final remark = _readValue(item, 'remark');
    final amount = _readValue(item, 'amount');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF087C3A),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  date.isEmpty
                      ? 'Follow-up $index'
                      : date,
                  style: const TextStyle(
                    color: Color(0xFF1B4332),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          if (type.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildRow(
              Icons.category_outlined,
              'Type',
              type,
            ),
          ],

          if (purpose.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildRow(
              Icons.flag_outlined,
              'Purpose',
              purpose,
            ),
          ],

          if (amount.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildRow(
              Icons.currency_rupee,
              'Amount',
              amount,
            ),
          ],

          if (remark.isNotEmpty) ...[
            const SizedBox(height: 12),
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
                  const Text(
                    'Remark',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    remark,
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
        ],
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF087C3A),
        ),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _readValue(
    dynamic item,
    String key,
  ) {
    if (item is Map) {
      return item[key]?.toString() ?? '';
    }

    return '';
  }
}

