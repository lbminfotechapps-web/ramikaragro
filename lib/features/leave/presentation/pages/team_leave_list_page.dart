import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
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

  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  final TextEditingController searchController = TextEditingController();

  String userId = '';
  bool showFilter = false;

  // ============================================================
  // COLORS
  // ============================================================

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
      final userData = await SecureStorage.instance.getUserData();

      debugPrint('');
      debugPrint('==========================================');
      debugPrint('TEAM LEAVE - SECURE STORAGE');
      debugPrint('USER DATA = $userData');
      debugPrint('==========================================');

      final storedUserId = userData?['user_id']?.toString() ?? '';

      debugPrint('STORED USER ID = $storedUserId');

      if (storedUserId.isEmpty) {
        debugPrint('ERROR: USER ID IS EMPTY');

        if (mounted) {
          _showMessage('User ID not found. Please login again.', isError: true);
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
        _showMessage('Unable to load user information', isError: true);
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
    await Future.delayed(const Duration(milliseconds: 500));
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
          debugPrint('LEAVES COUNT = ${state.leaves.length}');
          debugPrint('ERROR = ${state.errorMessage}');
          debugPrint('UPDATE STATUS = ${state.updateStatus}');
          debugPrint('==========================================');

          if (state.leaves.isNotEmpty) {
            debugPrint('FIRST LEAVE = ${state.leaves.first.leaveId}');
          }

          if (state.updateStatus == UpdateLeaveStatus.success) {
            _showMessage(
              state.updateMessage ?? 'Leave status updated successfully',
              isError: false,
            );
          }

          if (state.updateStatus == UpdateLeaveStatus.failure) {
            _showMessage(
              state.updateMessage ?? 'Unable to update leave status',
              isError: true,
            );
          }

          if (state.status == TeamLeaveStatus.failure && state.leaves.isEmpty) {
            _showMessage(
              state.errorMessage ?? 'Unable to load team leave list',
              isError: true,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.backgroundColor,
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
                  showFilter ? Icons.close_rounded : Icons.tune_rounded,

                  size: 23,
                ),
              ),
            ),
            body: RefreshIndicator(
              color: context.primaryColor,
              backgroundColor: context.cardBackgroundColor,
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
    if (state.status == TeamLeaveStatus.loading && state.leaves.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 220),
          Center(child: CustomLoader(color: context.primaryColor)),
        ],
      );
    }

    if (state.status == TeamLeaveStatus.failure && state.leaves.isEmpty) {
      return _buildError(state.errorMessage);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 80),
      children: [
        _buildTopHeader(state),

        SizedBox(height: 9),

        if (showFilter) ...[_buildFilter(), SizedBox(height: 9)],

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.16),
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
              color: context.onPrimaryColor.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: context.onPrimaryColor,
              size: 23,
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Leave Requests',
                  style: AppTextStyles.button.copyWith(
                    color: context.onPrimaryColor,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  '${fromDateController.text}  →  ${toDateController.text}',
                  style: AppTextStyles.caption.copyWith(
                    color: context.onPrimaryColor.withValues(alpha: 0.80),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 7),

          Container(
            constraints: const BoxConstraints(minWidth: 48),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${state.leaves.length}',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: context.primaryColor,
                  ),
                ),
                Text(
                  'Leaves',
                  style: AppTextStyles.badge.copyWith(
                    color: context.secondaryTextColor,
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
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.025),
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
                height: 31,
                width: 31,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: context.primaryColor,
                  size: 17,
                ),
              ),

              SizedBox(width: 8),

              Text(
                'Search & Filter',
                style: AppTextStyles.labelLarge.copyWith(
                  color: context.primaryTextColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _dateField(
                  controller: fromDateController,
                  label: 'From',
                ),
              ),
              SizedBox(width: 7),
              Expanded(
                child: _dateField(controller: toDateController, label: 'To'),
              ),
            ],
          ),

          SizedBox(height: 8),

          TextField(
            controller: searchController,
            style: AppTextStyles.input.copyWith(
              color: context.primaryTextColor,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              setState(() {
                showFilter = false;
              });

              _fetchLeaveList();
            },
            decoration: InputDecoration(
              hintText: 'Search employee...',
              hintStyle: AppTextStyles.inputHint.copyWith(
                color: context.secondaryTextColor,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 19,
                color: context.secondaryTextColor,
              ),
              filled: true,
              fillColor: context.appTheme.inputBackground,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          SizedBox(height: 8),

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
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.onPrimaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text('Search', style: AppTextStyles.labelSmall),
                ),
              ),

              SizedBox(width: 7),

              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilter,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.primaryColor,
                    side: BorderSide(
                      color: context.primaryColor.withValues(alpha: 0.30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text('Reset', style: AppTextStyles.labelSmall),
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
      style: AppTextStyles.input.copyWith(color: context.primaryTextColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.inputLabel.copyWith(
          color: context.secondaryTextColor,
        ),
        suffixIcon: Icon(
          Icons.calendar_month_rounded,
          size: 17,
          color: context.primaryColor,
        ),
        filled: true,
        fillColor: context.appTheme.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

  Future<void> _selectDate(TextEditingController controller) async {
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
          data: Theme.of(context).copyWith(colorScheme: context.appColors),
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

    final statusUpdateBy = leave.statusUpdateBy?.toString().trim() ?? '';

    final leaveApplicationDate =
        leave.leaveApplicationDate?.toString().trim() ?? '';

    final remark = leave.remark?.toString().trim() ?? '';

    final teamRemark = leave.teamRemark?.toString().trim() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: context.primaryColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: context.primaryColor,
                    size: 22,
                  ),
                ),

                SizedBox(width: 9),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.employeeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.listTitle.copyWith(
                          color: context.primaryTextColor,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        'Leave ID: ${leave.leaveId}',
                        style: AppTextStyles.caption.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 6),

                _statusBadge(managerStatus),
              ],
            ),

            SizedBox(height: 10),

            // ==================================================
            // DATE INFORMATION
            // ==================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
              decoration: BoxDecoration(
                color: context.appTheme.inputBackground,
                borderRadius: BorderRadius.circular(11),
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

                  Container(height: 29, width: 1, color: context.borderColor),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: _infoItem(Icons.event_rounded, 'TO', leave.toDate),
                    ),
                  ),

                  Container(height: 29, width: 1, color: context.borderColor),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 9),
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

            SizedBox(height: 8),

            // ==================================================
            // REPORTING / ADMIN
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: _compactDetail(
                    title: 'Reporting',
                    value: leave.reportingStatus.toString(),
                    icon: Icons.person_search_rounded,
                  ),
                ),

                SizedBox(width: 7),

                Expanded(
                  child: _compactDetail(
                    title: 'Admin',
                    value: leave.adminStatus.toString(),
                    icon: Icons.admin_panel_settings_rounded,
                  ),
                ),
              ],
            ),

            // ==================================================
            // OPTIONAL INFORMATION
            // ==================================================
            if (statusUpdateBy.isNotEmpty) ...[
              SizedBox(height: 6),
              _smallInfoRow(
                'Updated By',
                statusUpdateBy,
                Icons.person_outline_rounded,
              ),
            ],

            if (leaveApplicationDate.isNotEmpty) ...[
              SizedBox(height: 6),
              _smallInfoRow(
                'Applied On',
                leaveApplicationDate,
                Icons.access_time_rounded,
              ),
            ],

            if (remark.isNotEmpty) ...[
              SizedBox(height: 6),
              _smallInfoRow('Remark', remark, Icons.notes_rounded),
            ],

            if (teamRemark.isNotEmpty) ...[
              SizedBox(height: 6),
              _smallInfoRow('Team Remark', teamRemark, Icons.comment_rounded),
            ],

            // ==================================================
            // ACTION BUTTONS
            // ==================================================
            if (managerStatus == '0') ...[
              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      title: 'Approve',
                      icon: Icons.check_circle_outline_rounded,
                      color: context.primaryColor,
                      onTap: () {
                        _approveLeave(leave);
                      },
                    ),
                  ),

                  SizedBox(width: 7),

                  Expanded(
                    child: _actionButton(
                      title: 'Reject',
                      icon: Icons.cancel_outlined,
                      color: context.appColors.error,
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
        color = context.primaryColor;
        icon = Icons.check_circle_rounded;
        break;

      case '2':
        text = 'Rejected';
        color = context.appColors.error;
        icon = Icons.cancel_rounded;
        break;

      default:
        text = 'Pending';
        color = context.appColors.tertiary;
        icon = Icons.pending_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 3),
          Text(text, style: AppTextStyles.badge.copyWith(color: color)),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: context.primaryColor),
            SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.badge.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ],
        ),

        SizedBox(height: 3),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.badge.copyWith(color: context.primaryTextColor),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.primaryColor),

          SizedBox(width: 6),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.helperText.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),

                SizedBox(height: 1),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: context.primaryTextColor,
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

  Widget _smallInfoRow(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: context.appTheme.inputBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: context.secondaryTextColor),

          SizedBox(width: 6),

          Text(
            '$title: ',
            style: AppTextStyles.labelSmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                color: context.primaryTextColor,
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
      icon: Icon(icon, size: 16),
      label: Text(title, style: AppTextStyles.labelSmall),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: color == context.appColors.error
            ? context.appColors.onError
            : context.onPrimaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    );
  }

  // ============================================================
  // APPROVE
  // ============================================================

  void _approveLeave(TeamLeave leave) {
    debugPrint('==========================================');
    debugPrint('APPROVE LEAVE = ${leave.leaveId}');
    debugPrint('USER ID = $userId');
    debugPrint('==========================================');

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
          backgroundColor: context.cardBackgroundColor,
          surfaceTintColor: context.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
          contentPadding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),

          // =========================
          // TITLE
          // =========================
          title: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: context.appColors.error.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  color: context.appColors.error,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reject Leave',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: context.primaryTextColor,
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
                Text(
                  'Enter a reason for rejecting this leave request.',
                  style: AppTextStyles.caption.copyWith(
                    color: context.secondaryTextColor,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: remarkController,
                  style: AppTextStyles.input.copyWith(
                    color: context.primaryTextColor,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Enter rejection remark...',
                    hintStyle: AppTextStyles.inputHint.copyWith(
                      color: context.secondaryTextColor,
                    ),
                    filled: true,
                    fillColor: context.appTheme.inputBackground,
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
                Future.delayed(const Duration(milliseconds: 300), () {
                  remarkController.dispose();
                });
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(
                  color: context.secondaryTextColor,
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
                      SnackBar(
                        content: Text(
                          'Please enter remark',
                          style: AppTextStyles.body,
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                  return;
                }

                // Save the value BEFORE closing/dispose
                final finalRemark = remark;

                debugPrint('==========================================');
                debugPrint('REJECT LEAVE = ${leave.leaveId}');
                debugPrint('USER ID = $userId');
                debugPrint('REMARK = $finalRemark');
                debugPrint('STATUS = 2');
                debugPrint('==========================================');

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
                Future.delayed(const Duration(milliseconds: 300), () {
                  remarkController.dispose();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.error,
                foregroundColor: context.appColors.onError,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Reject', style: AppTextStyles.buttonSmall),
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
              color: context.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 34,
              color: context.primaryColor,
            ),
          ),

          SizedBox(height: 14),

          Text(
            'No Leave Found',
            style: AppTextStyles.cardTitle.copyWith(
              color: context.primaryTextColor,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'No leave applications found for\n'
            '${fromDateController.text} to '
            '${toDateController.text}.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: context.secondaryTextColor,
              height: 1.5,
            ),
          ),

          SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: _fetchLeaveList,
            icon: Icon(Icons.refresh_rounded, size: 16),
            label: Text('Reload', style: AppTextStyles.labelSmall),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: context.onPrimaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
        SizedBox(height: 110),

        Center(
          child: Container(
            height: 76,
            width: 76,
            decoration: BoxDecoration(
              color: context.appColors.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 35,
              color: context.appColors.error,
            ),
          ),
        ),

        SizedBox(height: 15),

        Center(
          child: Text(
            'Unable to load leave list',
            style: AppTextStyles.cardTitle.copyWith(
              color: context.primaryTextColor,
            ),
          ),
        ),

        SizedBox(height: 6),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Text(
            error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: context.secondaryTextColor,
              height: 1.4,
            ),
          ),
        ),

        SizedBox(height: 16),

        Center(
          child: ElevatedButton.icon(
            onPressed: _fetchLeaveList,
            icon: Icon(Icons.refresh_rounded, size: 17),
            label: Text('Try Again', style: AppTextStyles.labelSmall),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: context.onPrimaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? context.appColors.error
              : context.primaryColor,
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
                color: isError
                    ? context.appColors.onError
                    : context.onPrimaryColor,
                size: 19,
              ),

              SizedBox(width: 9),

              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isError
                        ? context.appColors.onError
                        : context.onPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
