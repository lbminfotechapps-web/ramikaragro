import 'dart:async';
import 'plot_schedule_history_page.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/secure_storage/secure_storage.dart';
import '../../../../core/theme/app_theme_context.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/schedule_list_entity.dart';
import '../../domain/repositories/schedule_list_repository.dart';
import '../../domain/repositories/farmer_plot_repository.dart';

import '../bloc/schedule_list_bloc.dart';
import '../bloc/schedule_list_event.dart';
import '../bloc/schedule_list_state.dart';

class ScheduleListPage extends StatefulWidget {
  const ScheduleListPage({super.key});

  @override
  State<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  final TextEditingController _farmerController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  Timer? _farmerTimer;

  String _employeeId = '';
  bool _loadingEmployee = true;
  bool _showFilters = false;
  bool _deletingSchedule = false;

  ScheduleFarmerFilter? _selectedFarmer;

  // Keep successful local updates selected until refreshed API data arrives.
  final Map<String, bool> _scheduleAnswers = {};

  // Track pending API requests and successfully updated schedules.
  final Set<String> _updatingScheduleIds = {};
  final Set<String> _completedScheduleIds = {};

  late DateTime _fromDate;
  late DateTime _toDate;

  Color get _bg => context.backgroundColor;
  Color get _dark => context.primaryTextColor;
  Color get _muted => context.secondaryTextColor;
  Color get _green => context.primaryColor;
  Color get _lightGreen => Color.alphaBlend(
    context.primaryColor.withValues(alpha: 0.08),
    context.cardBackgroundColor,
  );
  Color get _border => context.borderColor;
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _fromDate = DateTime(now.year, now.month, now.day);
    _toDate = DateTime(now.year, now.month, now.day);

    _loadEmployeeId();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload retains schedules created before fld_status was mapped.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loadingEmployee || _employeeId.isEmpty) return;
      final schedules = context.read<ScheduleListBloc>().state.schedules;
      if (schedules.any((schedule) => schedule.status == null)) {
        _searchSchedules();
      }
    });
  }

  Future<void> _loadEmployeeId() async {
    try {
      final userData = await SecureStorage.instance.getUserData();

      if (!mounted) return;

      setState(() {
        _employeeId = (userData?['user_id'] ?? userData?['userId'] ?? '')
            .toString()
            .trim();

        _loadingEmployee = false;
      });
      _searchSchedules();
    } catch (e) {
      if (!mounted) return;

      setState(() => _loadingEmployee = false);

      _showMessage('Unable to read employee ID: $e');
    }
  }

  @override
  void dispose() {
    _farmerTimer?.cancel();
    _farmerController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // ================= FARMER SEARCH =================

  void _onFarmerSearch(String value) {
    _farmerTimer?.cancel();

    setState(() {
      _selectedFarmer = null;
    });

    context.read<ScheduleListBloc>().add(ResetScheduleList());

    final search = value.trim();

    if (search.length < 3) return;

    _farmerTimer = Timer(Duration(seconds: 2), () {
      if (!mounted) return;

      context.read<ScheduleListBloc>().add(SearchScheduleFarmers(search));
    });
  }

  void _onFarmerSelected(ScheduleFarmerFilter farmer) {
    _farmerTimer?.cancel();

    _farmerController.text = farmer.farmerName;

    setState(() {
      _selectedFarmer = farmer;
    });

    context.read<ScheduleListBloc>().add(ClearScheduleFarmerResults());

    FocusScope.of(context).unfocus();
  }

  // ================= DATE PICKER =================

  Future<void> _pickDate(bool isFromDate) async {
    final current = isFromDate ? _fromDate : _toDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isFromDate) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });

    context.read<ScheduleListBloc>().add(ResetScheduleList());
  }

  // ================= API SEARCH =================

  void _searchSchedules() {
    if (_loadingEmployee || _employeeId.isEmpty || _employeeId == '0') {
      _showMessage('Please login again.');
      return;
    }

    if (_fromDate.isAfter(_toDate)) {
      _showMessage('From Date cannot be after To Date.');
      return;
    }

    FocusScope.of(context).unfocus();

    context.read<ScheduleListBloc>().add(
      LoadScheduleList(
        ScheduleListFilter(
          empId: _employeeId,
          farmerId: _selectedFarmer?.farmerId ?? '',
          fromDate: _fromDate,
          toDate: _toDate,
        ),
      ),
    );

    setState(() {
      _showFilters = false;
    });
  }

  void _clearFilters() {
    _farmerTimer?.cancel();
    _farmerController.clear();

    final now = DateTime.now();

    setState(() {
      _selectedFarmer = null;
      _fromDate = DateTime(now.year, now.month, now.day);
      _toDate = DateTime(now.year, now.month, now.day);
    });

    context.read<ScheduleListBloc>().add(ResetScheduleList());
  }

  // ================= SCREEN =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: CustomAppBar(
        title: 'Schedule List',
        showBackButton: true,
        backgroundColor: context.primaryColor,
        titleStyle: AppTextStyles.appBarTitle.copyWith(
          color: context.onPrimaryColor,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: context.onPrimaryColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.home);
            }
          },
        ),
        action: IconButton(
          tooltip: 'Show / Hide Filters',
          icon: Icon(
            _showFilters ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
            color: context.onPrimaryColor,
          ),
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
        ),
      ),

      body: BlocConsumer<ScheduleListBloc, ScheduleListState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage.isNotEmpty,
        listener: (context, state) {
          _showMessage(state.errorMessage);
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              if (_loadingEmployee ||
                  _employeeId.isEmpty ||
                  _fromDate.isAfter(_toDate)) {
                return;
              }

              final bloc = context.read<ScheduleListBloc>();

              final completion = bloc.stream.firstWhere(
                (s) =>
                    s.status == ScheduleListStatus.success ||
                    s.status == ScheduleListStatus.failure,
              );

              _searchSchedules();
              await completion;
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 24.h),
              children: [
                // COMPACT FILTER SUMMARY
                _buildFilterSummary(),

                if (_showFilters) ...[
                  SizedBox(height: 10.h),
                  _buildFilterCard(state),
                ],

                SizedBox(height: 14.h),

                if (state.status == ScheduleListStatus.loading)
                  _loadingWidget(),

                if (state.status == ScheduleListStatus.failure)
                  _statusWidget(
                    icon: Icons.error_outline_rounded,
                    title: 'Unable to load schedules',
                    subtitle: state.errorMessage,
                    buttonText: 'Retry',
                    onPressed: _searchSchedules,
                  ),

                if (state.status == ScheduleListStatus.success &&
                    state.schedules.isEmpty)
                  _statusWidget(
                    icon: Icons.event_busy_outlined,
                    title: 'No schedules found',
                    subtitle:
                        'No records found for the selected farmer '
                        'and date range.',
                  ),

                if (state.status == ScheduleListStatus.success &&
                    state.schedules.isNotEmpty) ...[
                  _buildListHeader(state.schedules),
                  SizedBox(height: 10.h),

                  ...state.schedules.map(
                    (schedule) => Padding(
                      padding: EdgeInsets.only(bottom: 9.h),
                      child: _buildScheduleCard(schedule),
                    ),
                  ),
                ],

                if (state.status == ScheduleListStatus.initial)
                  _statusWidget(
                    icon: Icons.manage_search_rounded,
                    title: 'Find Farmer Schedules',
                    subtitle:
                        'Choose a date range and optionally a farmer to '
                        'view registered schedules.',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= FILTER SUMMARY =================

  Widget _buildFilterSummary() {
    return InkWell(
      onTap: () {
        setState(() => _showFilters = !_showFilters);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.tune_rounded, color: _green, size: 18),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFarmer?.farmerName ?? 'Select Farmer & Date',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '${_dateFormat.format(_fromDate)}  →  '
                    '${_dateFormat.format(_toDate)}',
                    style: TextStyle(fontSize: 10.sp, color: _muted),
                  ),
                ],
              ),
            ),

            Icon(
              _showFilters
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: _green,
            ),
          ],
        ),
      ),
    );
  }

  // ================= FILTER CARD =================

  Widget _buildFilterCard(ScheduleListState state) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FARMER
          TextField(
            controller: _farmerController,
            onChanged: _onFarmerSearch,
            style: TextStyle(fontSize: 12.sp),
            decoration:
                _inputDecoration(
                  'Search Farmer Name (optional)',
                  Icons.person_search_outlined,
                ).copyWith(
                  suffixIcon: state.farmerLoading
                      ? Padding(
                          padding: EdgeInsets.all(13),
                          child: SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _farmerController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _farmerController.clear();
                            _onFarmerSearch('');
                          },
                        )
                      : null,
                ),
          ),

          if (state.farmers.isNotEmpty) _buildFarmerSuggestions(state.farmers),

          if (_selectedFarmer != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: _green),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Text(
                      _selectedFarmer!.farmerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: _dark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 10.h),

          // DATES IN SAME ROW
          Row(
            children: [
              Expanded(
                child: _dateField(
                  'From Date',
                  _fromDate,
                  () => _pickDate(true),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _dateField('To Date', _toDate, () => _pickDate(false)),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // FILTER ACTIONS
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(0, 44),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('Clear'),
                ),
              ),

              SizedBox(width: 8.w),

              Expanded(
                flex: 5,
                child: FilledButton.icon(
                  onPressed:
                      _loadingEmployee ||
                          state.status == ScheduleListStatus.loading
                      ? null
                      : _searchSchedules,
                  style: FilledButton.styleFrom(
                    minimumSize: Size(0, 44),
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.onPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                  ),
                  icon: Icon(Icons.search_rounded, size: 18),
                  label: Text('Search'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= FARMER SUGGESTIONS =================

  Widget _buildFarmerSuggestions(List<ScheduleFarmerFilter> farmers) {
    return Container(
      margin: EdgeInsets.only(top: 5.h),
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: farmers.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, index) {
          final farmer = farmers[index];

          return InkWell(
            onTap: () => _onFarmerSelected(farmer),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: _lightGreen,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: _green,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer.farmerName,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (farmer.talukaName.isNotEmpty)
                          Text(
                            farmer.talukaName,
                            style: TextStyle(fontSize: 9.sp, color: _muted),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: _muted, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= DATE FIELD =================

  Widget _dateField(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: context.appColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: _green, size: 15),
            SizedBox(width: 7.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 9.sp, color: _muted),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    _dateFormat.format(date),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 11.sp, color: _muted),
      prefixIcon: Icon(icon, color: _green, size: 19),
      isDense: true,
      filled: true,
      fillColor: context.appColors.surfaceContainerLow,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9.r),
        borderSide: BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9.r),
        borderSide: BorderSide(color: _green, width: 1.2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9.r)),
    );
  }

  // ================= LIST HEADER =================

  Widget _buildListHeader(List<ScheduleListEntity> schedules) {
    final totalProducts = schedules.fold<int>(
      0,
      (total, schedule) => total + schedule.details.length,
    );

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: _lightGreen,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(Icons.event_note_outlined, size: 19, color: _green),
        ),

        SizedBox(width: 9.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Schedules',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: _dark,
                ),
              ),
              Text(
                '$totalProducts total products',
                style: TextStyle(fontSize: 10.sp, color: _muted),
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: _lightGreen,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '${schedules.length} Found',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: _green,
            ),
          ),
        ),
      ],
    );
  }

  // ================= SCHEDULE CARD =================

  Future<void> _confirmDeleteSchedule(ScheduleListEntity schedule) async {
    if (_deletingSchedule) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Text('Delete Schedule?'),
        content: Text(
          'Are you sure you want to delete this schedule?\n\n'
          'Farmer: ${schedule.farmerName}\n'
          'Plot: ${schedule.plotName}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.appColors.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true || _deletingSchedule) return;
    if (_loadingEmployee || _employeeId.isEmpty || _employeeId == '0') {
      _showMessage('Please log in again.');
      return;
    }
    if (schedule.scheduleId.trim().isEmpty) {
      _showMessage('Schedule ID is missing. Refresh the list and try again.');
      return;
    }
    setState(() => _deletingSchedule = true);
    _showMessage('Deleting schedule...');
    try {
      final message = await GetIt.instance<ScheduleListRepository>()
          .deleteSchedule(scheduleId: schedule.scheduleId, empId: _employeeId);
      if (!mounted) return;
      setState(() {
        final id = schedule.scheduleId.trim();
        _scheduleAnswers.remove(id);
        _completedScheduleIds.remove(id);
        _updatingScheduleIds.remove(id);
      });
      _showMessage(message);
      _searchSchedules();
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to delete schedule: $error');
    } finally {
      if (mounted) setState(() => _deletingSchedule = false);
    }
  }
  // ================= UPDATE SCHEDULE (YES) =================

  Future<void> _updateScheduleStatus(ScheduleListEntity schedule) async {
    final scheduleId = schedule.scheduleId.trim();

    if (scheduleId.isEmpty) {
      _showMessage('Schedule ID is missing.');
      return;
    }

    // _employeeId is the logged-in user_id from SecureStorage.
    if (_loadingEmployee || _employeeId.isEmpty || _employeeId == '0') {
      _showMessage('Please login again.');
      return;
    }

    if (schedule.status == '1' ||
        _updatingScheduleIds.contains(scheduleId) ||
        _completedScheduleIds.contains(scheduleId)) {
      return;
    }

    setState(() => _updatingScheduleIds.add(scheduleId));

    try {
      debugPrint('========== UPDATE SCHEDULE ==========');
      debugPrint('scheduleId: $scheduleId');
      debugPrint('empId (SecureStorage user_id): $_employeeId');

      final message = await GetIt.I<ScheduleListRepository>()
          .updateScheduleStatus(scheduleId: scheduleId, empId: _employeeId);

      if (!mounted) return;
      setState(() {
        _scheduleAnswers[scheduleId] = true;
        _completedScheduleIds.add(scheduleId);
      });
      _showMessage(message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _scheduleAnswers[scheduleId] = false);
      _showMessage('Unable to update schedule: $error');
    } finally {
      if (mounted) {
        setState(() => _updatingScheduleIds.remove(scheduleId));
      }
    }
  }

  bool _openingPlotHistory = false;

  Future<void> _openPlotHistory(ScheduleListEntity schedule) async {
    if (_openingPlotHistory) return;
    final plotId = schedule.plotRegistrationId.trim();
    if (plotId.isEmpty) {
      _showMessage('The selected schedule has no plot ID.');
      return;
    }
    setState(() => _openingPlotHistory = true);
    try {
      var farmerId = schedule.farmerId?.trim() ?? '';
      if (farmerId.isEmpty) {
        if (_loadingEmployee || _employeeId.isEmpty || _employeeId == '0') {
          _showMessage(
            'Please wait for your login details to load, then try again.',
          );
          return;
        }
        final name = schedule.farmerName.trim();
        if (name.isEmpty) {
          _showMessage(
            'The schedule response is missing the farmer ID and name.',
          );
          return;
        }
        final farmers = await GetIt.I<ScheduleListRepository>().searchFarmers(
          name,
        );
        if (!mounted) return;
        final owners = <String>{};
        for (final farmer in farmers) {
          final plots = await GetIt.I<FarmerPlotRepository>().getFarmerPlots(
            empId: _employeeId,
            farmerId: farmer.farmerId,
          );
          if (!mounted) return;
          if (plots.any(
            (plot) =>
                plot.plotId.trim() == plotId &&
                plot.farmerId.trim() == farmer.farmerId.trim(),
          )) {
            owners.add(farmer.farmerId.trim());
          }
        }
        if (owners.length != 1) {
          _showMessage(
            'Unable to identify the owner of this plot. The schedule API must include fld_farmer_id.',
          );
          return;
        }
        farmerId = owners.single;
      }
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PlotScheduleHistoryPage(
            farmerId: farmerId,
            plotId: plotId,
            plotName: schedule.plotName,
            farmerName: schedule.farmerName,
            cropId: schedule.cropId.trim().isEmpty ? null : schedule.cropId,
          ),
        ),
      );
    } catch (error) {
      if (mounted) _showMessage('Unable to open plot history: $error');
    } finally {
      if (mounted) setState(() => _openingPlotHistory = false);
    }
  }

  Widget _buildScheduleCard(ScheduleListEntity schedule) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: ListTileTheme.merge(
          horizontalTitleGap: 0,
          child: ExpansionTile(
            enabled: false,
            key: ValueKey(schedule.scheduleId),
            tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            shape: Border(),
            collapsedShape: Border(),
            iconColor: _green,
            collapsedIconColor: _muted,
            showTrailingIcon: false,
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'Plot Name: ${schedule.plotName.trim().isEmpty ? '#${schedule.plotRegistrationId}' : schedule.plotName}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      color: _dark,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Semantics(
                  button: true,
                  label: 'View history',
                  child: InkWell(
                    onTap: _openingPlotHistory
                        ? null
                        : () => _openPlotHistory(schedule),
                    borderRadius: BorderRadius.circular(6.r),
                    child: _miniChip(Icons.history_rounded, 'View History'),
                  ),
                ),
              ],
            ),

            subtitle: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: _muted,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'Farmer Name: ${schedule.farmerName.trim().isEmpty ? '-' : schedule.farmerName}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.sp, color: _muted),
                        ),
                      ),
                    ],
                  ),

                

                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6.w,
                          runSpacing: 5.h,
                          children: [
                            _miniChip(
                              Icons.calendar_today_outlined,
                              schedule.scheduleDate,
                            ),
                            _miniChip(
                              Icons.inventory_2_outlined,
                              '${schedule.details.length} Products',
                            ),
                          ],
                        ),
                      ),
                      Builder(
                        builder: (tileContext) {
                          final controller = ExpansibleController.of(
                            tileContext,
                          );
                          return ListenableBuilder(
                            listenable: controller,
                            builder: (context, child) => AnimatedRotation(
                              turns: controller.isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: IconButton(
                                tooltip: controller.isExpanded
                                    ? 'Hide details'
                                    : 'Show details',
                                onPressed: () {
                                  if (controller.isExpanded) {
                                    controller.collapse();
                                  } else {
                                    controller.expand();
                                  }
                                },
                                icon: Icon(
                                  Icons.expand_more,
                                  size: 24,
                                  color: _green,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            children: [
              Divider(height: 16),

              _detailRow('Employee', schedule.employeeName),
              _detailRow('Crop', schedule.cropName),
              //  _detailRow('Schedule ID', schedule.scheduleId),

              SizedBox(height: 10.h),

              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: _green, size: 17),
                  SizedBox(width: 6.w),
                  Text(
                    'PRODUCT DETAILS',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w800,
                      color: _dark,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              if (schedule.details.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Text('No product details.'),
                )
              else
                _buildProductGroup(schedule),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _green),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 9.5.sp,
              color: _green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ONE GROUP FOR ALL PRODUCTS =================

  Widget _buildProductGroup(ScheduleListEntity schedule) {
    final products = schedule.details;
    final remark = schedule.remark?.trim() ?? '';
    final scheduleId = schedule.scheduleId.trim();
    final selected =
        schedule.status == '1' || (_scheduleAnswers[scheduleId] ?? false);
    final isUpdating = _updatingScheduleIds.contains(scheduleId);
    final isCompleted =
        schedule.status == '1' || _completedScheduleIds.contains(scheduleId);

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 3.h),
            child: Column(
              children: [
                for (int i = 0; i < products.length; i++) ...[
                  if (i > 0) Divider(height: 1, thickness: 1, color: _border),
                  _buildProductRow(i + 1, products[i]),
                ],
              ],
            ),
          ),
          if (remark.isNotEmpty)
            Container(
              margin: EdgeInsets.fromLTRB(10.w, 2.h, 10.w, 10.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: context.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Icon(
                      Icons.notes_rounded,
                      color: _green,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remark',
                          style: TextStyle(
                            color: _green,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          remark,
                          style: TextStyle(
                            color: _dark,
                            fontSize: 11.5.sp,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: _lightGreen.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _answerOption(
                      text: 'Yes',
                      value: true,
                      selected: selected,
                      schedule: schedule,
                      isUpdating: isUpdating,
                      isCompleted: isCompleted,
                    ),
                    SizedBox(width: 12.w),
                    _answerOption(
                      text: 'No',
                      value: false,
                      selected: selected,
                      schedule: schedule,
                      isUpdating: isUpdating,
                      isCompleted: isCompleted,
                    ),
                    Spacer(),
                    Semantics(
                      button: true,
                      enabled: !_deletingSchedule && !isUpdating,
                      child: InkWell(
                        onTap: _deletingSchedule || isUpdating
                            ? null
                            : () => _confirmDeleteSchedule(schedule),
                        borderRadius: BorderRadius.circular(6.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _deletingSchedule || isUpdating
                                ? context.appColors.error.withValues(alpha: 0.4)
                                : context.appColors.error,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 11,
                                color: context.appColors.onError,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Delete Schedule',
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color: context.appColors.onError,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isUpdating) ...[
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 7.w),
                      Text(
                        'Updating schedule...',
                        style: TextStyle(fontSize: 10.sp, color: _muted),
                      ),
                    ],
                  ),
                ],

                // if (isCompleted) ...[
                //   SizedBox(height: 8.h),
                //   Row(
                //     children: [
                //       Icon(Icons.check_circle, size: 16, color: _green),
                //       SizedBox(width: 6.w),
                //       Expanded(
                //         child: Text(
                //           'Schedule Updated Successfully',
                //           style: TextStyle(
                //             fontSize: 10.sp,
                //             fontWeight: FontWeight.w700,
                //             color: _green,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerOption({
    required String text,
    required bool value,
    required bool selected,
    required ScheduleListEntity schedule,
    required bool isUpdating,
    required bool isCompleted,
  }) {
    final isSelected = selected == value;
    final disabled = isUpdating || isCompleted || _deletingSchedule;

    return Semantics(
      button: true,
      enabled: !disabled,
      selected: isSelected,
      child: InkWell(
        onTap: disabled
            ? null
            : () {
                if (value) {
                  // YES makes exactly one update request.
                  _updateScheduleStatus(schedule);
                } else {
                  // NO is the default; no API call is needed.
                  setState(() {
                    _scheduleAnswers[schedule.scheduleId.trim()] = false;
                  });
                }
              },
        borderRadius: BorderRadius.circular(18.r),
        child: Opacity(
          opacity: disabled && !isSelected ? 0.42 : 1.0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? _green : _muted,
                  size: 19,
                ),
                SizedBox(width: 4.w),
                Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? _green : _dark,
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (value && isCompleted) ...[
                  SizedBox(width: 5.w),
                  Icon(Icons.verified_rounded, size: 15, color: _green),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(int index, ScheduleProductEntity product) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: _green,
                  ),
                ),
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'Product Name: ${product.productName.trim().isEmpty ? 'Unnamed Product' : product.productName}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
              ),
              if (product.productType.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(left: 6.w),
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    product.productType,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: _green,
                    ),
                  ),
                ),
            ],
          ),
          if (product.cropName.isNotEmpty) ...[
            SizedBox(height: 5.h),
            // Padding(
            //   padding: EdgeInsets.only(left: 29.w),
            //   child: Text.rich(
            //     TextSpan(
            //       children: [
            //         TextSpan(
            //           text: 'Crop: ',
            //           style: TextStyle(color: _muted),
            //         ),
            //         TextSpan(
            //           text: product.cropName,
            //           style: TextStyle(
            //             color: _dark,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ],
            //     ),
            //     maxLines: 2,
            //     overflow: TextOverflow.ellipsis,
            //     style: TextStyle(fontSize: 10.sp),
            //   ),
            // ),
          ],
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 29.w),
            child: Row(
              children: [
                Expanded(
                  child: _inlineValue(
                    'Qty',
                    _quantityText(product.productQty, product.unit),
                    Icons.scale_outlined,
                    context.appColors.tertiary,
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: _inlineValue(
                    'Water',
                    _quantityText(product.waterQty, product.waterUnit),
                    Icons.water_drop_outlined,
                    context.appColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inlineValue(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        SizedBox(width: 3.w),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 9.sp, color: _muted),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
        ),
      ],
    );
  }

  String _quantityText(String amount, String unit) {
    if (amount.trim().isEmpty) return '-';

    return unit.trim().isEmpty ? amount : '$amount $unit';
  }

  Widget _detailRow(String label, String value) {
    if (value.trim().isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 85.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: _muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= LOADING =================

  Widget _loadingWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36.h),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  // ================= EMPTY / ERROR =================

  Widget _statusWidget({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: _green),
          ),

          SizedBox(height: 12.h),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: _dark,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: _muted, height: 1.4),
          ),

          if (buttonText != null && onPressed != null) ...[
            SizedBox(height: 12.h),
            OutlinedButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        ],
      ),
    );
  }
}
