import 'dart:async';

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

  ScheduleFarmerFilter? _selectedFarmer;

  late DateTime _fromDate;
  late DateTime _toDate;

  static const Color _bg = Color(0xFFF5F7F6);
  static const Color _dark = Color(0xFF172B3A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _green = Color(0xFF16803D);
  static const Color _lightGreen = Color(0xFFE8F6EC);
  static const Color _border = Color(0xFFE3EAE6);

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _fromDate = DateTime(now.year, now.month, now.day);
    _toDate = DateTime(now.year, now.month, now.day);

    _loadEmployeeId();
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

    context.read<ScheduleListBloc>().add(const ResetScheduleList());

    final search = value.trim();

    if (search.length < 3) return;

    _farmerTimer = Timer(const Duration(seconds: 2), () {
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

    context.read<ScheduleListBloc>().add(const ClearScheduleFarmerResults());

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

    context.read<ScheduleListBloc>().add(const ResetScheduleList());
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

    context.read<ScheduleListBloc>().add(const ResetScheduleList());
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
          color: Colors.white,
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
              child: const Icon(Icons.tune_rounded, color: _green, size: 18),
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
        color: Colors.white,
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
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _farmerController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
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
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: _green,
                  ),
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
                    minimumSize: const Size(0, 44),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Clear'),
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
                    minimumSize: const Size(0, 44),
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.onPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                  ),
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Search'),
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
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: farmers.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
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
                    child: const Icon(
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
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _muted,
                    size: 18,
                  ),
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
          color: const Color(0xFFF8FAF9),
          borderRadius: BorderRadius.circular(9.r),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: _green, size: 15),
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
      fillColor: const Color(0xFFF8FAF9),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9.r),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9.r),
        borderSide: const BorderSide(color: _green, width: 1.2),
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
          child: const Icon(Icons.event_note_outlined, size: 19, color: _green),
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

  Widget _buildScheduleCard(ScheduleListEntity schedule) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: ExpansionTile(
          key: ValueKey(schedule.scheduleId),
          tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: _green,
          collapsedIconColor: _muted,

          title: Row(
            children: [
              Expanded(
                child: Text(
                  schedule.farmerName.isEmpty ? 'Farmer' : schedule.farmerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
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
                    const Icon(
                      Icons.landscape_outlined,
                      size: 14,
                      color: _muted,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        schedule.plotName.isEmpty
                            ? 'Plot #${schedule.plotRegistrationId}'
                            : schedule.plotName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp, color: _muted),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 7.h),

                Wrap(
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
              ],
            ),
          ),

          children: [
            const Divider(height: 16),

            _detailRow('Employee', schedule.employeeName),
            _detailRow('Main Crop', schedule.cropName),
            _detailRow('Schedule ID', schedule.scheduleId),

            SizedBox(height: 10.h),

            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: _green, size: 17),
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
                padding: EdgeInsets.all(10.w),
                child: const Text('No product details.'),
              )
            else
              ...schedule.details.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: 7.h),
                  child: _buildProductCard(entry.key + 1, entry.value),
                ),
              ),
          ],
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

  // ================= PRODUCT CARD =================

  Widget _buildProductCard(int index, ScheduleProductEntity product) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRODUCT NAME + TYPE
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(7.r),
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

              SizedBox(width: 8.w),

              Expanded(
                child: Text(
                  product.productName.isEmpty
                      ? 'Unnamed Product'
                      : product.productName,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
              ),

              if (product.productType.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _lightGreen,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Text(
                    product.productType,
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      color: _green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          if (product.cropName.isNotEmpty) ...[
            SizedBox(height: 7.h),
            Row(
              children: [
                const Icon(Icons.grass_outlined, size: 13, color: _muted),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    product.cropName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.sp, color: _muted),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 9.h),

          // QUANTITY + WATER IN ONE ROW
          Row(
            children: [
              Expanded(
                child: _valueCard(
                  label: 'QUANTITY',
                  value: _quantityText(product.productQty, product.unit),
                  icon: Icons.scale_outlined,
                  iconColor: const Color(0xFFCA8A04),
                ),
              ),

              SizedBox(width: 7.w),

              Expanded(
                child: _valueCard(
                  label: 'WATER',
                  value: _quantityText(product.waterQty, product.waterUnit),
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _valueCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          SizedBox(width: 7.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 8.5.sp, color: _muted),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: _dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _quantityText(String amount, String unit) {
    if (amount.trim().isEmpty) return '-';

    return unit.trim().isEmpty ? amount : '$amount $unit';
  }

  Widget _detailRow(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
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
      child: const Center(child: CircularProgressIndicator()),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
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
