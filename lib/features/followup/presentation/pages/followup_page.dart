import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/followup_entity.dart';
import '../bloc/followup_bloc.dart';
import '../bloc/followup_event.dart';
import '../bloc/followup_state.dart';

class FollowupPage extends StatefulWidget {
  const FollowupPage({
    super.key,
  });

  @override
  State<FollowupPage> createState() => _FollowupPageState();
}

class _FollowupPageState extends State<FollowupPage> {
  DateTime fromDate = DateTime(2026, 1, 1);
  DateTime toDate = DateTime(2026, 9, 17);

  String selectedType = 'Dealer';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    final userData = await SecureStorage.instance.getUserData();

    if (!mounted) return;

    userId = userData?['user_id']?.toString() ?? '';

    if (userId.isNotEmpty) {
      _loadFollowup();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  void _loadFollowup() {
    if (userId.isEmpty) return;

    context.read<FollowupBloc>().add(
          GetUpcomingFollowupEvent(
            fromDate: _formatDate(fromDate),
            toDate: _formatDate(toDate),
            type: selectedType,
            userId: userId,
          ),
        );
  }

  Future<void> _selectFromDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        fromDate = result;

        if (fromDate.isAfter(toDate)) {
          toDate = fromDate;
        }
      });
    }
  }

  Future<void> _selectToDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: fromDate,
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        toDate = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),

      appBar: CustomAppBar(
        title: 'Followups',
      ),

      body: Column(
        children: [
          _buildFilterCard(),

          Expanded(
            child: BlocBuilder<FollowupBloc, FollowupState>(
              builder: (context, state) {
                if (state is FollowupLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is FollowupError) {
                  return _buildEmptyState(
                    icon: Icons.error_outline,
                    title: 'Something went wrong',
                    subtitle: state.message,
                    iconColor: Colors.red,
                  );
                }

                if (state is FollowupEmpty) {
                  return _buildEmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'No followups found',
                    subtitle: 'Try changing the date or type',
                  );
                }

                if (state is FollowupSuccess) {
                  return _buildList(state.followups);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FILTER
  // ---------------------------------------------------------------------------

  Widget _buildFilterCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4E9E4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateField(
              label: 'From',
              date: fromDate,
              onTap: _selectFromDate,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: _buildDateField(
              label: 'To',
              date: toDate,
              onTap: _selectToDate,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: _buildTypeField(),
          ),

          const SizedBox(width: 7),

          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAF8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE1E7E1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 13,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _formatDate(date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeField() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE1E7E1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Colors.green.shade700,
          ),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          items: const [
            DropdownMenuItem(
              value: 'Dealer',
              child: Text('Dealer'),
            ),
            DropdownMenuItem(
              value: 'Farmer',
              child: Text('Farmer'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedType = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return Material(
      color: Colors.green.shade700,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: userId.isEmpty ? null : _loadFollowup,
        borderRadius: BorderRadius.circular(10),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.search_rounded,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIST
  // ---------------------------------------------------------------------------

  Widget _buildList(List<FollowupEntity> followups) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadFollowup();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          12,
          5,
          12,
          20,
        ),
        itemCount: followups.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCard(followups[index]),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FOLLOWUP CARD
  // ---------------------------------------------------------------------------

  Widget _buildCard(FollowupEntity item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE7EBE7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NAME + TYPE
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Colors.green.shade700,
                  size: 21,
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.isEmpty
                          ? 'Unknown'
                          : item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      item.type,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              _buildTypeChip(item.followupType),
            ],
          ),

          const SizedBox(height: 9),

          // DATE + TIME
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9F7),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.green.shade700,
                ),

                const SizedBox(width: 5),

                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Container(
                  width: 1,
                  height: 15,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  color: Colors.grey.shade300,
                ),

                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.green.shade700,
                ),

                const SizedBox(width: 5),

                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                if (item.followupDate.isNotEmpty &&
                    item.followupDate != item.date)
                  Text(
                    item.followupDate,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          // REMARK
          if (item.remark.isNotEmpty) ...[
            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 15,
                  color: Colors.grey.shade600,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    item.remark,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    if (type.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isPhone = type.toLowerCase() == 'phone';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isPhone
            ? Colors.blue.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPhone
                ? Icons.phone_outlined
                : Icons.location_on_outlined,
            size: 12,
            color: isPhone
                ? Colors.blue.shade700
                : Colors.orange.shade700,
          ),
          const SizedBox(width: 3),
          Text(
            type,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isPhone
                  ? Colors.blue.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY / ERROR
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: iconColor ?? Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}