import 'package:demo/features/leave/domain/entities/team_leave.dart';
import 'package:demo/features/leave/presentation/bloc/team_leave_bloc.dart';
import 'package:demo/features/leave/presentation/bloc/team_leave_event.dart';
import 'package:demo/features/leave/presentation/bloc/team_leave_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/team_leave_di.dart';
import '../../../../core/secure_storage/secure_storage.dart';


class TeamLeaveListPage extends StatefulWidget {
  const TeamLeaveListPage({super.key});

  @override
  State<TeamLeaveListPage> createState() =>
      _TeamLeaveListPageState();
}

class _TeamLeaveListPageState
    extends State<TeamLeaveListPage> {
  late final TeamLeaveBloc bloc;

  final TextEditingController fromDateController =
      TextEditingController();

  final TextEditingController toDateController =
      TextEditingController();

  final TextEditingController searchController =
      TextEditingController();

  String userId = '';

  bool showFilter = false;

  int startLimit = 0;

  @override
  void initState() {
    super.initState();

    bloc = sl<TeamLeaveBloc>();

    _setInitialDates();
    _loadUserAndLeaveList();
  }

  void _setInitialDates() {
    final now = DateTime.now();

    final sevenDaysAgo =
        now.subtract(const Duration(days: 7));

    fromDateController.text =
        _formatDate(sevenDaysAgo);

    toDateController.text =
        _formatDate(now);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  Future<void> _loadUserAndLeaveList() async {
    final userData =
        await SecureStorage.instance.getUserData();

    userId =
        userData?['user_id']?.toString() ?? '';

    debugPrint(
      'TEAM LEAVE USER ID = $userId',
    );

    if (!mounted) return;

    _fetchLeaveList();
  }

  void _fetchLeaveList() {
    startLimit = 0;

    bloc.add(
      GetTeamLeaveListEvent(
        userId: userId,
        fromDate: fromDateController.text.trim(),
        toDate: toDateController.text.trim(),
        startLimit: startLimit,
        searchText: searchController.text.trim(),
      ),
    );
  }

  Future<void> _refresh() async {
    bloc.add(
      RefreshTeamLeaveListEvent(
        userId: userId,
        fromDate: fromDateController.text.trim(),
        toDate: toDateController.text.trim(),
        searchText: searchController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    bloc.close();

    fromDateController.dispose();
    toDateController.dispose();
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<TeamLeaveBloc, TeamLeaveState>(
        listener: (context, state) {
          if (state.updateStatus ==
              UpdateLeaveStatus.success) {
            _showMessage(
              state.updateMessage ??
                  'Leave status updated successfully',
              isError: false,
            );

            _fetchLeaveList();
          }

          if (state.updateStatus ==
              UpdateLeaveStatus.failure) {
            _showMessage(
              state.updateMessage ??
                  'Unable to update leave status',
              isError: true,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor:
                const Color(0xffF5F7FA),

            appBar: _buildAppBar(),

            floatingActionButton:
                _buildAddLeaveButton(),

            body: RefreshIndicator(
              color: const Color(0xff0F8A4B),
              onRefresh: _refresh,
              child: _buildBody(state),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor:
          const Color(0xff0F8A4B),
      foregroundColor: Colors.white,

      title: const Text(
        'Team Leave List',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              showFilter = !showFilter;
            });
          },
          icon: Icon(
            showFilter
                ? Icons.close_rounded
                : Icons.filter_alt_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(TeamLeaveState state) {
    if (state.status ==
        TeamLeaveStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xff0F8A4B),
        ),
      );
    }

    if (state.status ==
        TeamLeaveStatus.failure) {
      return _buildError(
        state.errorMessage,
      );
    }

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        100,
      ),

      children: [
        if (showFilter) ...[
          _buildFilter(),

          const SizedBox(height: 20),
        ],

        _buildSummary(state),

        const SizedBox(height: 14),

        if (state.leaves.isEmpty)
          _buildEmpty()
        else
          ...state.leaves.map(
            (leave) => Padding(
              padding:
                  const EdgeInsets.only(bottom: 14),
              child: _buildLeaveCard(leave),
            ),
          ),
      ],
    );
  }

  Widget _buildFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffE6E9ED),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                size: 20,
                color: Color(0xff0F8A4B),
              ),
              SizedBox(width: 8),
              Text(
                'Search & Filter',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _dateField(
                  controller:
                      fromDateController,
                  label: 'From Date',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateField(
                  controller:
                      toDateController,
                  label: 'To Date',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText:
                  'Search employee...',
              prefixIcon: const Icon(
                Icons.search_rounded,
              ),
              filled: true,
              fillColor:
                  const Color(0xffF6F8FA),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      showFilter = false;
                    });

                    _fetchLeaveList();
                  },
                  icon: const Icon(
                    Icons.search_rounded,
                  ),
                  label: const Text('Search'),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff0F8A4B),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetFilter,
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text('Reset'),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(0xff0F8A4B),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
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

  Widget _dateField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(
        controller,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(
          Icons.calendar_month_rounded,
          size: 20,
        ),
        filled: true,
        fillColor:
            const Color(0xffF6F8FA),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _selectDate(
    TextEditingController controller,
  ) async {
    DateTime initialDate =
        DateTime.now();

    try {
      final parts =
          controller.text.split('-');

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
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                const ColorScheme.light(
              primary:
                  Color(0xff0F8A4B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text =
          _formatDate(picked);
    }
  }

  void _resetFilter() {
    _setInitialDates();

    searchController.clear();

    setState(() {
      showFilter = false;
    });

    _fetchLeaveList();
  }

  Widget _buildSummary(
    TeamLeaveState state,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff0F8A4B),
            Color(0xff19B866),
          ],
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.15),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Team Leave Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage employee leave applications',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              '${state.leaves.length}',
              style: const TextStyle(
                color:
                    Color(0xff0F8A4B),
                fontWeight:
                    FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(
    TeamLeave leave,
  ) {
    final status =
        leave.status;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xffE7EAEE),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xff0F8A4B,
                    ).withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color:
                        Color(0xff0F8A4B),
                  ),
                ),

                const SizedBox(width: 12),

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
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Leave ID: ${leave.leaveId}',
                        style:
                            const TextStyle(
                          fontSize: 11,
                          color:
                              Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                _statusBadge(status),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    Icons.calendar_today_rounded,
                    'From',
                    leave.fromDate,
                  ),
                ),
                Expanded(
                  child: _infoItem(
                    Icons.event_rounded,
                    'To',
                    leave.toDate,
                  ),
                ),
                Expanded(
                  child: _infoItem(
                    Icons.timelapse_rounded,
                    'Days',
                    leave.leaveDays,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _detailRow(
              'Reporting',
              leave.reportingStatus,
              Icons.person_search_rounded,
            ),

            const SizedBox(height: 10),

            _detailRow(
              'Admin',
              leave.adminStatus,
              Icons.admin_panel_settings_rounded,
            ),

            if (leave.remark.isNotEmpty) ...[
              const SizedBox(height: 10),

              _detailRow(
                'Remark',
                leave.remark,
                Icons.notes_rounded,
              ),
            ],

            if (leave.teamRemark.isNotEmpty) ...[
              const SizedBox(height: 10),

              _detailRow(
                'Team Remark',
                leave.teamRemark,
                Icons.comment_rounded,
              ),
            ],

            const SizedBox(height: 16),

            if (status == '0')
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      title: 'Approve',
                      icon:
                          Icons.check_rounded,
                      color:
                          const Color(0xff0F8A4B),
                      onTap: () {
                        _approveLeave(
                          leave,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _actionButton(
                      title: 'Reject',
                      icon:
                          Icons.close_rounded,
                      color:
                          const Color(0xffD64545),
                      onTap: () {
                        _showRejectDialog(
                          leave,
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    String text;
    Color color;

    switch (status) {
      case '1':
        text = 'Approved';
        color =
            const Color(0xff0F8A4B);
        break;

      case '2':
        text = 'Rejected';
        color =
            const Color(0xffD64545);
        break;

      default:
        text = 'Pending';
        color =
            const Color(0xffE08A00);
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color:
              const Color(0xff0F8A4B),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color:
            const Color(0xffF7F8FA),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color:
                const Color(0xff69727D),
          ),

          const SizedBox(width: 9),

          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xff4D5560),
            ),
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color:
                    Color(0xff68717C),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        size: 18,
      ),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(13),
        ),
      ),
    );
  }

  void _approveLeave(
    TeamLeave leave,
  ) {
    bloc.add(
      UpdateTeamLeaveStatusEvent(
        leaveId: leave.leaveId,
        userId: userId,
        remark: '',
        status: '1',
      ),
    );
  }

  void _showRejectDialog(
    TeamLeave leave,
  ) {
    final remarkController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            'Reject Leave',
            style: TextStyle(
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          content: TextField(
            controller:
                remarkController,
            maxLines: 4,
            decoration:
                InputDecoration(
              hintText:
                  'Enter rejection remark',
              filled: true,
              fillColor:
                  const Color(0xffF5F6F8),
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                borderSide:
                    BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final remark =
                    remarkController
                        .text
                        .trim();

                if (remark.isEmpty) {
                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter remark',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(
                  dialogContext,
                );

                bloc.add(
                  UpdateTeamLeaveStatusEvent(
                    leaveId:
                        leave.leaveId,
                    userId: userId,
                    remark: remark,
                    status: '2',
                  ),
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xffD64545,
                ),
                foregroundColor:
                    Colors.white,
              ),
              child: const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    ).then((_) {
      remarkController.dispose();
    });
  }

  Widget _buildEmpty() {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 80,
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color:
                  const Color(0xff0F8A4B)
                      .withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 42,
              color:
                  Color(0xff0F8A4B),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No Leave Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'No leave applications are available\nfor the selected date range.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String? error) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 130),

        const Icon(
          Icons.cloud_off_rounded,
          size: 60,
          color: Colors.red,
        ),

        const SizedBox(height: 18),

        const Center(
          child: Text(
            'Unable to load leave list',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: Text(
            error ??
                'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: ElevatedButton.icon(
            onPressed: _fetchLeaveList,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label:
                const Text('Try Again'),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                0xff0F8A4B,
              ),
              foregroundColor:
                  Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddLeaveButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Replace with your GoRouter route
        // context.push('/add-leave');
      },
      backgroundColor:
          const Color(0xff0F8A4B),
      foregroundColor: Colors.white,
      elevation: 5,
      icon: const Icon(
        Icons.add_rounded,
      ),
      label: const Text(
        'Add Leave',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        backgroundColor: isError
            ? Colors.red
            : const Color(0xff0F8A4B),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
        content: Text(message),
      ),
    );
  }
}