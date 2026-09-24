import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/core/utility/widgets/custom_loader.dart';
import 'package:solufine/features/leave/domain/entities/team_leave.dart';
import 'package:solufine/features/leave/presentation/bloc/team_leave_bloc.dart';
import 'package:solufine/features/leave/presentation/bloc/team_leave_event.dart';
import 'package:solufine/features/leave/presentation/bloc/team_leave_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class TeamLeaveListPage extends StatefulWidget {
  const TeamLeaveListPage({super.key});

  @override
  State<TeamLeaveListPage> createState() => _TeamLeaveListPageState();
}

class _TeamLeaveListPageState extends State<TeamLeaveListPage> {
  final GetIt sl = GetIt.instance;

  late final TeamLeaveBloc bloc;

  final TextEditingController fromDateController =
      TextEditingController();

  final TextEditingController toDateController =
      TextEditingController();

  final TextEditingController searchController =
      TextEditingController();

  String userId = '';
  bool showFilter = false;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xff0F8A4B);
  static const Color lightGreen = Color(0xff19B866);
  static const Color background = Color(0xffF5F7F9);
  static const Color textDark = Color(0xff17212B);
  static const Color textGrey = Color(0xff78838F);
  static const Color borderColor = Color(0xffE8ECF0);

  static const Color red = Color(0xffD64545);
  static const Color orange = Color(0xffE08A00);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    bloc = sl<TeamLeaveBloc>();

    _setInitialDates();
    _loadUserAndLeaveList();
  }



// ============================================================
// INITIAL DATE
// ============================================================
void _setInitialDates() {
  final today = DateTime.now();

  fromDateController.text = _formatDate(today);
  toDateController.text = _formatDate(today);
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year}';
}

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> _loadUserAndLeaveList() async {
    try {
      final userData =
          await SecureStorage.instance.getUserData();

      debugPrint('');
      debugPrint('==========================================');
      debugPrint('TEAM LEAVE - SECURE STORAGE');
      debugPrint('USER DATA = $userData');
      debugPrint('==========================================');

      final storedUserId =
          userData?['user_id']?.toString() ?? '';

      debugPrint('STORED USER ID = $storedUserId');

      if (storedUserId.isEmpty) {
        debugPrint('ERROR: USER ID IS EMPTY');

        if (mounted) {
          _showMessage(
            'User ID not found. Please login again.',
            isError: true,
          );
        }

        return;
      }

      if (!mounted) return;

      setState(() {
        userId = storedUserId;
      });

      debugPrint('TEAM LEAVE USER ID = $userId');

      _fetchLeaveList();
    } catch (e, stackTrace) {
      debugPrint('LOAD USER ERROR = $e');
      debugPrint('$stackTrace');

      if (mounted) {
        _showMessage(
          'Unable to load user information',
          isError: true,
        );
      }
    }
  }

  // ============================================================
  // FETCH
  // ============================================================

  void _fetchLeaveList() {
    if (userId.isEmpty) {
      debugPrint('FETCH CANCELLED: USER ID EMPTY');
      return;
    }

    final fromDate = fromDateController.text.trim();
    final toDate = toDateController.text.trim();
    final search = searchController.text.trim();

    debugPrint('');
    debugPrint('==========================================');
    debugPrint('FETCH TEAM LEAVE LIST');
    debugPrint('==========================================');
    debugPrint('USER ID     = $userId');
    debugPrint('FROM DATE   = $fromDate');
    debugPrint('TO DATE     = $toDate');
    debugPrint('START LIMIT = 0');
    debugPrint('SEARCH      = "$search"');
    debugPrint('==========================================');

    bloc.add(
      GetTeamLeaveListEvent(
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
        startLimit: 0,
        searchText: search,
      ),
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    if (userId.isEmpty) return;

    debugPrint('REFRESHING TEAM LEAVE LIST');

    bloc.add(
      RefreshTeamLeaveListEvent(
        userId: userId,
        fromDate: fromDateController.text.trim(),
        toDate: toDateController.text.trim(),
        searchText: searchController.text.trim(),
      ),
    );

    // Gives RefreshIndicator enough time to show animation.
    await Future.delayed(
      const Duration(milliseconds: 500),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    bloc.close();

    fromDateController.dispose();
    toDateController.dispose();
    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<TeamLeaveBloc, TeamLeaveState>(
        listener: (context, state) {
          debugPrint('');
          debugPrint('==========================================');
          debugPrint('TEAM LEAVE STATE CHANGED');
          debugPrint('STATUS = ${state.status}');
          debugPrint(
            'LEAVES COUNT = ${state.leaves.length}',
          );
          debugPrint('ERROR = ${state.errorMessage}');
          debugPrint(
            'UPDATE STATUS = ${state.updateStatus}',
          );
          debugPrint('==========================================');

          if (state.leaves.isNotEmpty) {
            debugPrint(
              'FIRST LEAVE = ${state.leaves.first.leaveId}',
            );
          }

          if (state.updateStatus ==
              UpdateLeaveStatus.success) {
            _showMessage(
              state.updateMessage ??
                  'Leave status updated successfully',
              isError: false,
            );
          }

          if (state.updateStatus ==
              UpdateLeaveStatus.failure) {
            _showMessage(
              state.updateMessage ??
                  'Unable to update leave status',
              isError: true,
            );
          }

          if (state.status == TeamLeaveStatus.failure &&
              state.leaves.isEmpty) {
            _showMessage(
              state.errorMessage ??
                  'Unable to load team leave list',
              isError: true,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: background,
            appBar: CustomAppBar(
              title: 'Team Leave',
              showBackButton: true,
              onBackTap: () {
                context.go(AppRouter.home);
              },
              action: IconButton(
                onPressed: () {
                  setState(() {
                    showFilter = !showFilter;
                  });
                },
                icon: Icon(
                  showFilter
                      ? Icons.close_rounded
                      : Icons.tune_rounded,
                  color: Colors.black,
                  size: 23,
                ),
              ),
            ),
            body: RefreshIndicator(
              color: primaryGreen,
              backgroundColor: Colors.white,
              onRefresh: _refresh,
              child: _buildBody(state),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(TeamLeaveState state) {
    if (state.status == TeamLeaveStatus.loading &&
        state.leaves.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 220),
          Center(
            child: CustomLoader(
              color: primaryGreen,
            ),
          ),
        ],
      );
    }

    if (state.status == TeamLeaveStatus.failure &&
        state.leaves.isEmpty) {
      return _buildError(state.errorMessage);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        80,
      ),
      children: [
        _buildTopHeader(state),

        const SizedBox(height: 9),

        if (showFilter) ...[
          _buildFilter(),
          const SizedBox(height: 9),
        ],

        if (state.leaves.isEmpty)
          _buildEmpty()
        else
          ...state.leaves.map(
            (leave) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _buildLeaveCard(leave),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // TOP HEADER
  // ============================================================

  Widget _buildTopHeader(TeamLeaveState state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primaryGreen,
            lightGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.16),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.17),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Team Leave Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${fromDateController.text}  →  ${toDateController.text}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.80),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 7),

          Container(
            constraints: const BoxConstraints(
              minWidth: 48,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${state.leaves.length}',
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'Leaves',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _buildFilter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 31,
                width: 31,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: primaryGreen,
                  size: 17,
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'Search & Filter',
                style: TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _dateField(
                  controller: fromDateController,
                  label: 'From',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _dateField(
                  controller: toDateController,
                  label: 'To',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              setState(() {
                showFilter = false;
              });

              _fetchLeaveList();
            },
            decoration: InputDecoration(
              hintText: 'Search employee...',
              hintStyle: const TextStyle(
                color: Color(0xff9AA3AC),
                fontSize: 11.5,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 19,
                color: textGrey,
              ),
              filled: true,
              fillColor: const Color(0xffF6F8FA),
              contentPadding:
                  const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showFilter = false;
                    });

                    _fetchLeaveList();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilter,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: BorderSide(
                      color: primaryGreen.withOpacity(0.30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(controller),
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: textGrey,
          fontSize: 10,
        ),
        suffixIcon: const Icon(
          Icons.calendar_month_rounded,
          size: 17,
          color: primaryGreen,
        ),
        filled: true,
        fillColor: const Color(0xffF6F8FA),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate(
    TextEditingController controller,
  ) async {
    DateTime initialDate = DateTime.now();

    try {
      final parts = controller.text.split('-');

      if (parts.length == 3) {
        initialDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = _formatDate(picked);

      setState(() {});
    }
  }

  // ============================================================
  // RESET
  // ============================================================

  void _resetFilter() {
    _setInitialDates();
    searchController.clear();

    setState(() {
      showFilter = false;
    });

    _fetchLeaveList();
  }

  // ============================================================
  // LEAVE CARD
  // ============================================================

  Widget _buildLeaveCard(TeamLeave leave) {
    final managerStatus = leave.managerStatus;

    final statusUpdateBy =
        leave.statusUpdateBy?.toString().trim() ?? '';

    final leaveApplicationDate =
        leave.leaveApplicationDate?.toString().trim() ?? '';

    final remark =
        leave.remark?.toString().trim() ?? '';

    final teamRemark =
        leave.teamRemark?.toString().trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // EMPLOYEE HEADER
            // ==================================================

            Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.09),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: primaryGreen,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.employeeName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Leave ID: ${leave.leaveId}',
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                _statusBadge(managerStatus),
              ],
            ),

            const SizedBox(height: 10),

            // ==================================================
            // DATE INFORMATION
            // ==================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffF7F9FA),
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _infoItem(
                      Icons.calendar_today_rounded,
                      'FROM',
                      leave.fromDate,
                    ),
                  ),

                  Container(
                    height: 29,
                    width: 1,
                    color: borderColor,
                  ),

                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 9),
                      child: _infoItem(
                        Icons.event_rounded,
                        'TO',
                        leave.toDate,
                      ),
                    ),
                  ),

                  Container(
                    height: 29,
                    width: 1,
                    color: borderColor,
                  ),

                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 9),
                      child: _infoItem(
                        Icons.timelapse_rounded,
                        'DAYS',
                        leave.leaveDays.toString(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ==================================================
            // REPORTING / ADMIN
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: _compactDetail(
                    title: 'Reporting',
                    value:
                        leave.reportingStatus.toString(),
                    icon:
                        Icons.person_search_rounded,
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _compactDetail(
                    title: 'Admin',
                    value:
                        leave.adminStatus.toString(),
                    icon:
                        Icons.admin_panel_settings_rounded,
                  ),
                ),
              ],
            ),

            // ==================================================
            // OPTIONAL INFORMATION
            // ==================================================

            if (statusUpdateBy.isNotEmpty) ...[
              const SizedBox(height: 6),
              _smallInfoRow(
                'Updated By',
                statusUpdateBy,
                Icons.person_outline_rounded,
              ),
            ],

            if (leaveApplicationDate.isNotEmpty) ...[
              const SizedBox(height: 6),
              _smallInfoRow(
                'Applied On',
                leaveApplicationDate,
                Icons.access_time_rounded,
              ),
            ],

            if (remark.isNotEmpty) ...[
              const SizedBox(height: 6),
              _smallInfoRow(
                'Remark',
                remark,
                Icons.notes_rounded,
              ),
            ],

            if (teamRemark.isNotEmpty) ...[
              const SizedBox(height: 6),
              _smallInfoRow(
                'Team Remark',
                teamRemark,
                Icons.comment_rounded,
              ),
            ],

            // ==================================================
            // ACTION BUTTONS
            // ==================================================

            if (managerStatus == '0') ...[
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      title: 'Approve',
                      icon:
                          Icons.check_circle_outline_rounded,
                      color: primaryGreen,
                      onTap: () {
                        _approveLeave(leave);
                      },
                    ),
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: _actionButton(
                      title: 'Reject',
                      icon:
                          Icons.cancel_outlined,
                      color: red,
                      onTap: () {
                        _showRejectDialog(leave);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    String text;
    Color color;
    IconData icon;

    switch (status) {
      case '1':
        text = 'Approved';
        color = primaryGreen;
        icon = Icons.check_circle_rounded;
        break;

      case '2':
        text = 'Rejected';
        color = red;
        icon = Icons.cancel_rounded;
        break;

      default:
        text = 'Pending';
        color = orange;
        icon = Icons.pending_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 12,
              color: primaryGreen,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: textGrey,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 3),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: textDark,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // COMPACT DETAIL
  // ============================================================

  Widget _compactDetail({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF8F9FA),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: primaryGreen,
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 8,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL INFO ROW
  // ============================================================

  Widget _smallInfoRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 13,
            color: textGrey,
          ),

          const SizedBox(width: 6),

          Text(
            '$title: ',
            style: const TextStyle(
              color: textGrey,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textDark,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 16,
      ),
      label: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }

  // ============================================================
  // APPROVE
  // ============================================================

  void _approveLeave(TeamLeave leave) {
    debugPrint(
      '==========================================',
    );
    debugPrint(
      'APPROVE LEAVE = ${leave.leaveId}',
    );
    debugPrint('USER ID = $userId');
    debugPrint(
      '==========================================',
    );

    bloc.add(
      UpdateTeamLeaveStatusEvent(
        leaveId: leave.leaveId,
        userId: userId,
        remark: '',
        status: '1',
      ),
    );
  }

  // ============================================================
  // REJECT DIALOG
  // ============================================================

void _showRejectDialog(TeamLeave leave) {
  final remarkController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        titlePadding: const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          6,
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          20,
          6,
          20,
          8,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          14,
        ),

        // =========================
        // TITLE
        // =========================
        title: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: red.withOpacity(0.09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: red,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Reject Leave',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ),
          ],
        ),

        // =========================
        // CONTENT
        // =========================
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter a reason for rejecting this leave request.',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: remarkController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Enter rejection remark...',
                  hintStyle: const TextStyle(
                    color: Color(0xffA0A7AE),
                    fontSize: 11.5,
                  ),
                  filled: true,
                  fillColor: const Color(0xffF6F8FA),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),

        // =========================
        // ACTIONS
        // =========================
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog first
              Navigator.of(dialogContext).pop();

              // Dispose after dialog has been removed
              Future.delayed(
                const Duration(milliseconds: 300),
                () {
                  remarkController.dispose();
                },
              );
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: textGrey,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              final remark = remarkController.text.trim();

              if (remark.isEmpty) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Please enter remark'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                return;
              }

              // Save the value BEFORE closing/dispose
              final finalRemark = remark;

              debugPrint(
                '==========================================',
              );
              debugPrint(
                'REJECT LEAVE = ${leave.leaveId}',
              );
              debugPrint(
                'USER ID = $userId',
              );
              debugPrint(
                'REMARK = $finalRemark',
              );
              debugPrint(
                'STATUS = 2',
              );
              debugPrint(
                '==========================================',
              );

              // Close dialog
              Navigator.of(dialogContext).pop();

              // Send API request
              bloc.add(
                UpdateTeamLeaveStatusEvent(
                  leaveId: leave.leaveId,
                  userId: userId,
                  remark: finalRemark,
                  status: '2',
                ),
              );

              // Dispose after dialog animation is completed
              Future.delayed(
                const Duration(milliseconds: 300),
                () {
                  remarkController.dispose();
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Reject',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );
    },
  );
}

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 65),
      child: Column(
        children: [
          Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 34,
              color: primaryGreen,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No Leave Found',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'No leave applications found for\n'
            '${fromDateController.text} to '
            '${toDateController.text}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textGrey,
              fontSize: 11,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: _fetchLeaveList,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 16,
            ),
            label: const Text(
              'Reload',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(String? error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 110),

        Center(
          child: Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              size: 35,
              color: red,
            ),
          ),
        ),

        const SizedBox(height: 15),

        const Center(
          child: Text(
            'Unable to load leave list',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 6),

        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 35,
          ),
          child: Text(
            error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textGrey,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Center(
          child: ElevatedButton.icon(
            onPressed: _fetchLeaveList,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 17,
            ),
            label: const Text(
              'Try Again',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? Colors.red : primaryGreen,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 19,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}