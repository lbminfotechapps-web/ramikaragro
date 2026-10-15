import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_loader.dart';
import 'package:solufine/features/leave/presentation/pages/add_leave_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:solufine/core/di/leave_list_di.dart';

import '../bloc/leave_bloc.dart';
import '../bloc/leave_event.dart';
import '../bloc/leave_state.dart';
import '../widgets/leave_card.dart';
import '../widgets/leave_filter_card.dart';

class LeaveListPage extends StatefulWidget {
  const LeaveListPage({super.key});

  @override
  State<LeaveListPage> createState() => _LeaveListPageState();
}

class _LeaveListPageState extends State<LeaveListPage>
    with SingleTickerProviderStateMixin {
  DateTime? fromDate;
  DateTime? toDate;

  bool showFilter = false;

  late LeaveBloc leaveBloc;

  @override
  void initState() {
    super.initState();

    leaveBloc = sl<LeaveBloc>();

    // Initial API call
    leaveBloc.add(const GetLeaveListEvent());
  }

  @override
  void dispose() {
    leaveBloc.close();
    super.dispose();
  }

  // ============================================================
  // FORMAT API DATE
  // ============================================================

  String _apiDate(DateTime? date) {
    if (date == null) {
      return "";
    }

    return DateFormat("yyyy-MM-dd").format(date);
  }

  // ============================================================
  // FORMAT DISPLAY DATE
  // ============================================================

  String _displayDate(DateTime? date) {
    if (date == null) {
      return "";
    }

    return DateFormat("dd-MM-yyyy").format(date);
  }

  // ============================================================
  // SELECT FROM DATE
  // ============================================================

  Future<void> _selectFromDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: context.appColors),
          child: child!,
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      fromDate = selected;

      if (toDate != null && toDate!.isBefore(selected)) {
        toDate = null;
      }
    });
  }

  // ============================================================
  // SELECT TO DATE
  // ============================================================

  Future<void> _selectToDate() async {
    if (fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select From Date first",
            style: AppTextStyles.body,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      return;
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: toDate ?? fromDate!,
      firstDate: fromDate!,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: context.appColors),
          child: child!,
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      toDate = selected;
    });
  }

  // ============================================================
  // GET LEAVE LIST
  // ============================================================

  void _getLeaveList() {
    leaveBloc.add(
      GetLeaveListEvent(fromDate: _apiDate(fromDate), toDate: _apiDate(toDate)),
    );
  }

  // ============================================================
  // APPLY FILTER
  // ============================================================

  void _applyFilter() {
    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select both From Date and To Date",
            style: AppTextStyles.body,
          ),
          backgroundColor: context.appColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      return;
    }

    if (toDate!.isBefore(fromDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "To Date cannot be before From Date",
            style: AppTextStyles.body,
          ),
          backgroundColor: context.appColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      return;
    }

    // Both dates are valid → call API
    _getLeaveList();

    setState(() {
      showFilter = false;
    });
  }

  // ============================================================
  // CLEAR FILTER
  // ============================================================

  void _clearFilter() {
    setState(() {
      fromDate = null;
      toDate = null;
      showFilter = false;
    });

    leaveBloc.add(const GetLeaveListEvent());
  }

  // ============================================================
  // OPEN ADD LEAVE
  // ============================================================

  // Future<void> _openAddLeave() async {
  //   print("jgfjhfgk");
  //   // final result = await context.push("/addLeave");

  //   if (!mounted) {
  //     return;
  //   }

  //   if (result == true) {
  //     _getLeaveList();
  //   }
  // }

  // ============================================================
  // FILTER TEXT
  // ============================================================

  String _filterText() {
    final from = _displayDate(fromDate);
    final to = _displayDate(toDate);

    if (from.isNotEmpty && to.isNotEmpty) {
      return "$from  →  $to";
    }

    if (from.isNotEmpty) {
      return "From $from";
    }

    return "Until $to";
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: leaveBloc,
      child: Scaffold(
        backgroundColor: context.backgroundColor,

        // ======================================================
        // APP BAR
        // ======================================================
        appBar: CustomAppBar(
          title: 'My Leave',
          subtitle: 'Manage your leave applications',
          showBackButton: true,
          onBackTap: () => context.go(AppRouter.home),

          actionIcon: Icons.filter_list_rounded,

          onActionIconTap: () {
            setState(() {
              showFilter = !showFilter;
            });
          },
        ),

        // ======================================================
        // FAB
        // ======================================================
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            //  context.push('/add-Leave');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddLeavePage()),
            );
          },
          backgroundColor: context.primaryColor,
          foregroundColor: context.onPrimaryColor,
          elevation: 5,
          icon: const Icon(Icons.add_rounded),
          label: Text("Apply Leave", style: AppTextStyles.button),
        ),

        // ======================================================
        // BODY
        // ======================================================
        body: BlocConsumer<LeaveBloc, LeaveState>(
          listener: (context, state) {
            if (state.leaveStatus == LeaveStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!, style: AppTextStyles.body),
                  backgroundColor: context.appColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },

          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Column(
                children: [
                  SizedBox(height: 14.h),
                  // ==================================================
                  // FILTER
                  // ==================================================
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,

                    child: showFilter
                        ? LeaveFilterCard(
                            fromDate: fromDate,
                            toDate: toDate,
                            onFromDateTap: _selectFromDate,
                            onToDateTap: _selectToDate,
                            onApply: _applyFilter,
                            onClear: _clearFilter,
                          )
                        : const SizedBox.shrink(),
                  ),

                  // ==================================================
                  // ACTIVE FILTER
                  // ==================================================
                  if (!showFilter && (fromDate != null || toDate != null))
                    _buildActiveFilter(),

                  // ==================================================
                  // HEADER / COUNT
                  // ==================================================
                  _buildListHeader(state),

                  // ==================================================
                  // LIST
                  // ==================================================
                  Expanded(child: _buildBody(state)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // LIST HEADER
  // ============================================================

  Widget _buildListHeader(LeaveState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.event_note_rounded,
              color: context.primaryColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Leave Applications", style: AppTextStyles.cardTitle),
                SizedBox(height: 2),
                Text(
                  "Your leave history",
                  style: AppTextStyles.caption.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // RECORD COUNT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${state.leaves.length} Records",
              style: AppTextStyles.labelSmall.copyWith(
                color: context.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIVE FILTER
  // ============================================================

  Widget _buildActiveFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: context.primaryColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.filter_alt_rounded,
              size: 15,
              color: context.primaryColor,
            ),
          ),

          const SizedBox(width: 8),

          Text(
            "Filter",
            style: AppTextStyles.labelSmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              _filterText(),
              style: AppTextStyles.buttonSmall.copyWith(
                color: context.primaryColor,
              ),
            ),
          ),

          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _clearFilter,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.close_rounded,
                size: 17,
                color: context.appColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(LeaveState state) {
    // ==========================================================
    // LOADING
    // ==========================================================

    if (state.leaveStatus == LeaveStatus.loading) {
      return _buildLoading();
    }

    // ==========================================================
    // ERROR
    // ==========================================================

    if (state.leaveStatus == LeaveStatus.failure) {
      return _buildError(state.errorMessage ?? "Something went wrong");
    }

    // ==========================================================
    // NO DATA
    // ==========================================================

    if (state.leaves.isEmpty) {
      return _buildEmpty();
    }

    // ==========================================================
    // DATA
    // ==========================================================

    return RefreshIndicator(
      color: context.primaryColor,
      onRefresh: () async {
        _getLeaveList();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        itemCount: state.leaves.length,
        itemBuilder: (context, index) {
          return LeaveCard(leave: state.leaves[index]);
        },
      ),
    );
  }

  // ============================================================
  // LOADING UI
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: CustomLoader(strokeWidth: 3, color: context.primaryColor),
          ),

          const SizedBox(height: 18),

          Text(
            "Loading leave history...",
            style: AppTextStyles.labelLarge.copyWith(
              color: context.cardTextColor,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "Please wait",
            style: AppTextStyles.bodySmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR UI
  // ============================================================

  Widget _buildError(String message) {
    return RefreshIndicator(
      color: context.primaryColor,
      onRefresh: () async {
        _getLeaveList();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.22),

          Center(
            child: Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: context.appColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 43,
                color: context.appColors.error,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(child: Text(message, style: AppTextStyles.button)),

          // const SizedBox(height: 8),

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 35),
          //   child: Text(
          //     message,
          //     textAlign: TextAlign.center,
          //     style: const TextStyle(fontSize: 13, color: Colors.grey),
          //   ),
          // ),
          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              onPressed: _getLeaveList,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text("Try Again", style: AppTextStyles.body),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY UI
  // ============================================================

  Widget _buildEmpty() {
    final bool isFiltered = fromDate != null || toDate != null;

    return RefreshIndicator(
      color: context.primaryColor,
      onRefresh: () async {
        _getLeaveList();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.16),

          Center(
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.event_busy_rounded,
                  size: 48,
                  color: context.primaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          Center(
            child: Text(
              isFiltered ? "No Leaves Found" : "No Leave Applications",
              style: AppTextStyles.button,
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Text(
              isFiltered
                  ? "No leave applications were found for the selected date range."
                  : "You don't have any leave applications yet.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: context.secondaryTextColor,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (isFiltered)
            Center(
              child: OutlinedButton.icon(
                onPressed: _clearFilter,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.primaryColor,
                  side: BorderSide(color: context.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.filter_alt_off, size: 18),
                label: Text("Clear Filter", style: AppTextStyles.body),
              ),
            )
          else
            Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.onPrimaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 19),
                label: Text(
                  "Apply Your First Leave",
                  style: AppTextStyles.body,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
