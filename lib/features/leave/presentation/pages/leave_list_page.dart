import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/utility/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:demo/core/di/leave_list_di.dart';

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
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
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
          content: const Text("Please select From Date first"),
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
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
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
    if (fromDate != null && toDate != null && toDate!.isBefore(fromDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("To Date cannot be before From Date"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      return;
    }

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

  Future<void> _openAddLeave() async {
    final result = await context.push("/add-leave");

    if (!mounted) {
      return;
    }

    if (result == true) {
      _getLeaveList();
    }
  }

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
        backgroundColor: AppColors.backgroundColor,

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

        //         appBar: CustomAppBar(
        //   title: 'My Leave',
        //   subtitle: "Manage your leave applications",
        //   actionIcon: Icons.filter_list_rounded,
        //    onBackTap: () => Navigator.pop(context),
        //   onActionIconTap: () {
        //     setState(() {
        //       showFilter = !showFilter;
        //     });
        //   },

        // ),

        /*
        appBar:
         AppBar(
          elevation: 0,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,

          titleSpacing: 18,

          title: const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "My Leave",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Manage your leave applications",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

            leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
            color: AppColors.backgroundColor,
          ),
          onPressed: () {
            context.go(AppRouter.home);
          },
        ),
        
          actions: [
            IconButton(
              tooltip: "Filter",
              onPressed: () {
                setState(() {
                  showFilter = !showFilter;
                });
              },
              icon: Icon(
                showFilter
                    ? Icons.filter_alt_rounded
                    : Icons.filter_alt_outlined,
              ),
            ),

            const SizedBox(width: 5),
          ],
        ),
        */

        // ======================================================
        // FAB
        // ======================================================
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddLeave,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 5,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            "Apply Leave",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
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
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
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
              padding: const EdgeInsets.only(left: 16, right: 16),
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
              color: Colors.green.withOpacity(0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Colors.green,
              size: 22,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leave Applications",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  "Your leave history",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          // RECORD COUNT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${state.leaves.length} Records",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.bold,
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
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.green.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.filter_alt_rounded,
              size: 15,
              color: Colors.green,
            ),
          ),

          const SizedBox(width: 8),

          const Text(
            "Filter",
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              _filterText(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _clearFilter,
            child: const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.close_rounded, size: 17, color: Colors.red),
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
      color: Colors.green,
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
              color: Colors.green.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const CustomLoader(
              strokeWidth: 3,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "Loading leave history...",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            "Please wait",
            style: TextStyle(fontSize: 12, color: Colors.grey),
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
      color: Colors.green,
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
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 43,
                color: Colors.red,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Unable to Load Leaves",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton.icon(
              onPressed: _getLeaveList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
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
              label: const Text("Try Again"),
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
      color: Colors.green,
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
                color: Colors.green.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
              child: Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.event_busy_rounded,
                  size: 48,
                  color: Colors.green,
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          Center(
            child: Text(
              isFiltered ? "No Leaves Found" : "No Leave Applications",
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
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
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
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
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.filter_alt_off, size: 18),
                label: const Text("Clear Filter"),
              ),
            )
          else
            Center(
              child: ElevatedButton.icon(
                onPressed: _openAddLeave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
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
                label: const Text("Apply Your First Leave"),
              ),
            ),
        ],
      ),
    );
  }
}
