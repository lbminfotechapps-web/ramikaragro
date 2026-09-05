import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/features/reports/domain/entities/employee_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';

import 'package:demo/core/api_constant/api_client.dart';
import '../bloc/employee_activity_bloc.dart';
import '../bloc/employee_activity_event.dart';
import '../bloc/employee_activity_state.dart';
import '../widgets/activity_summary_card.dart';
import '../widgets/activity_timeline_item.dart';

class EmployeeActivityReportPage extends StatefulWidget {
  final String userId;

  const EmployeeActivityReportPage({
    super.key,
    required this.userId,
  });

  @override
  State<EmployeeActivityReportPage> createState() =>
      _EmployeeActivityReportPageState();
}

class _EmployeeActivityReportPageState
    extends State<EmployeeActivityReportPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActivities();
    });
  }

  // ============================================================
  // FETCH ACTIVITY
  // ============================================================

  void _fetchActivities() {
    final searchDate = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedDate);

    context.read<EmployeeActivityBloc>().add(
          GetEmployeeActivityEvent(
            userId: widget.userId,
            searchDate: searchDate,
            logUserId: widget.userId,
          ),
        );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Select Activity Date',
      cancelText: 'Cancel',
      confirmText: 'Select',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF168A45),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });

    _fetchActivities();
  }

  // ============================================================
  // DATE FORMATTING
  // ============================================================

  String get _displayDate {
    return DateFormat(
      'dd-MM-yyyy',
    ).format(_selectedDate);
  }

  String get _dayName {
    return DateFormat(
      'EEEE',
    ).format(_selectedDate);
  }

  // ============================================================
  // ACTIVITY COUNTS
  // ============================================================

  int _countActivity(
    List<EmployeeActivity> activities,
    String activity,
  ) {
    return activities.where(
      (item) {
        return item.activityName.toUpperCase().contains(
              activity.toUpperCase(),
            );
      },
    ).length;
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _onRefresh() async {
    _fetchActivities();

    await context.read<EmployeeActivityBloc>().stream.firstWhere(
          (state) =>
              state.status == EmployeeActivityStatus.success ||
              state.status == EmployeeActivityStatus.failure,
        );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFF168A45),
        foregroundColor: Colors.white,

        title: const Text(
          'Employee Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

            
          leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: AppColors.backgroundColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),


        actions: [
          IconButton(
            tooltip: 'Change Date',
            onPressed: _selectDate,
            icon: const Icon(
              Icons.calendar_month_rounded,
              size: 25,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: BlocBuilder<EmployeeActivityBloc,
          EmployeeActivityState>(
        builder: (context, state) {
          if (state.status == EmployeeActivityStatus.loading) {
            return const _LoadingView();
          }

          if (state.status == EmployeeActivityStatus.failure) {
            return _ErrorView(
              message: state.errorMessage ??
                  'Something went wrong',
              onRetry: _fetchActivities,
              onChangeDate: _selectDate,
            );
          }

          final activities = state.activities;

          return RefreshIndicator(
            color: const Color(0xFF168A45),
            onRefresh: _onRefresh,

            child: activities.isEmpty
                ? _EmptyView(
                    onChangeDate: _selectDate,
                  )
                : _ActivityContent(
                    selectedDate: _selectedDate,
                    displayDate: _displayDate,
                    dayName: _dayName,
                    activities: activities,
                    countIn: _countActivity(
                      activities,
                      'IN PUNCH',
                    ),
                    countOut: _countActivity(
                      activities,
                      'OUT PUNCH',
                    ),
                    countFarmer: _countActivity(
                      activities,
                      'FARMER',
                    ),

                      countDealer: _countActivity(
                      activities,
                      'Dealer',
                    ),
                    countLocation: _countActivity(
                      activities,
                      'SHARE LOCATION',
                    ),
                    onChangeDate: _selectDate,
                  ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// ACTIVITY CONTENT
// ============================================================================

class _ActivityContent extends StatelessWidget {
  final DateTime selectedDate;
  final String displayDate;
  final String dayName;

  final List<EmployeeActivity> activities;

  final int countIn;
  final int countOut;
  final int countFarmer;
  final int countDealer;
  final int countLocation;

  final VoidCallback onChangeDate;

  const _ActivityContent({
    required this.selectedDate,
    required this.displayDate,
    required this.dayName,
    required this.activities,
    required this.countIn,
    required this.countOut,
    required this.countFarmer,
    required this.countDealer,
    required this.countLocation,
    required this.onChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        30,
      ),
      children: [
        // ======================================================
        // DATE CARD
        // ======================================================

        _DateCard(
          displayDate: displayDate,
          dayName: dayName,
          onChangeDate: onChangeDate,
        ),

        const SizedBox(height: 18),

        // ======================================================
        // SUMMARY TITLE
        // ======================================================

        const Text(
          'Activity Summary',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202522),
          ),
        ),

        const SizedBox(height: 12),

        // ======================================================
        // SUMMARY CARDS
        // ======================================================

        SizedBox(
          height: 55.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              ActivitySummaryCard(
                title: 'IN Punch',
                count: countIn,
                icon: Icons.login_rounded,
                color: const Color(0xFF168A45),
              ),

              const SizedBox(width: 12),

              ActivitySummaryCard(
                title: 'OUT Punch',
                count: countOut,
                icon: Icons.logout_rounded,
                color: const Color(0xFFE53935),
              ),

              const SizedBox(width: 12),

              ActivitySummaryCard(
                title: 'Farmer Visit',
                count: countFarmer,
                icon: Icons.agriculture_rounded,
                color: const Color(0xFFF28C28),
              ),

              const SizedBox(width: 12),


              ActivitySummaryCard(
                title: 'Dealer Visit',
                count: countDealer,
                icon: Icons.agriculture_rounded,
                color: const Color(0xFFF28C28),
              ),

              const SizedBox(width: 12),



              ActivitySummaryCard(
                title: 'Location',
                count: countLocation,
                icon: Icons.location_on_rounded,
                color: const Color(0xFF1976D2),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ======================================================
        // TIMELINE TITLE
        // ======================================================

        Row(
          children: [
            const Expanded(
              child: Text(
                'Activity Timeline',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202522),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${activities.length} Activities',
                style: const TextStyle(
                  color: Color(0xFF168A45),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ======================================================
        // TIMELINE
        // ======================================================

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];

            return ActivityTimelineItem(
              activity: activity,
              isFirst: index == 0,
              isLast: index == activities.length - 1,
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// DATE CARD
// ============================================================================

class _DateCard extends StatelessWidget {
  final String displayDate;
  final String dayName;
  final VoidCallback onChangeDate;

  const _DateCard({
    required this.displayDate,
    required this.dayName,
    required this.onChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ====================================================
          // CALENDAR ICON
          // ====================================================

          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF168A45),
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          // ====================================================
          // DATE
          // ====================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A827D),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  displayDate,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202522),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  dayName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF168A45),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // CHANGE BUTTON
          // ====================================================

          OutlinedButton(
            onPressed: onChangeDate,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF168A45),
              side: const BorderSide(
                color: Color(0xFF168A45),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 9,
              ),
            ),
            child: const Text(
              'Change',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
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
      child: CircularProgressIndicator(
        color: Color(0xFF168A45),
        strokeWidth: 3,
      ),
    );
  }
}

// ============================================================================
// EMPTY VIEW
// ============================================================================

class _EmptyView extends StatelessWidget {
  final VoidCallback onChangeDate;

  const _EmptyView({
    required this.onChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),

        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5EC),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.event_busy_rounded,
            color: Color(0xFF168A45),
            size: 52,
          ),
        ),

        const SizedBox(height: 24),

        const Center(
          child: Text(
            'No Activity Found',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF202522),
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Center(
          child: Text(
            'There is no employee activity available\n'
            'for the selected date.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF7A827D),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Center(
          child: ElevatedButton.icon(
            onPressed: onChangeDate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF168A45),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.calendar_month_rounded,
            ),
            label: const Text(
              'Change Date',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ERROR VIEW
// ============================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onChangeDate;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onChangeDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 100),

        Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE53935),
            size: 52,
          ),
        ),

        const SizedBox(height: 24),

        const Center(
          child: Text(
            'Something Went Wrong',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF168A45),
                side: const BorderSide(
                  color: Color(0xFF168A45),
                ),
              ),
            ),

            const SizedBox(width: 10),

            ElevatedButton.icon(
              onPressed: onChangeDate,
              icon: const Icon(
                Icons.calendar_month_rounded,
              ),
              label: const Text('Change Date'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF168A45),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}