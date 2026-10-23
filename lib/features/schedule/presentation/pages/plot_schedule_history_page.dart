import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';

import '../../../../core/secure_storage/secure_storage.dart';
import '../../domain/repositories/schedule_list_repository.dart';
import '../../domain/entities/plot_schedule_entity.dart';
import '../../domain/repositories/plot_schedule_repository.dart';
import '../bloc/plot_schedule_bloc.dart';

class PlotScheduleHistoryPage extends StatelessWidget {
  final String farmerId;
  final String plotId;
  final String plotName;
  final String farmerName;
  final String? cropId;

  const PlotScheduleHistoryPage({
    super.key,
    required this.farmerId,
    required this.plotId,
    this.plotName = '',
    this.farmerName = '',
    this.cropId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<PlotScheduleBloc>()
        ..add(
          LoadPlotScheduleHistory(
            PlotScheduleQuery(
              farmerId: farmerId,
              plotId: plotId,
              cropId: cropId,
            ),
          ),
        ),
      child: _HistoryBody(
        farmerId: farmerId,
        plotId: plotId,
        plotName: plotName,
        farmerName: farmerName,
        cropId: cropId,
      ),
    );
  }
}

class _HistoryBody extends StatefulWidget {
  final String farmerId;
  final String plotId;
  final String plotName;
  final String farmerName;
  final String? cropId;

  const _HistoryBody({
    required this.farmerId,
    required this.plotId,
    required this.plotName,
    required this.farmerName,
    this.cropId,
  });

  @override
  State<_HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends State<_HistoryBody> {
  Color get green => context.primaryColor;
  Color get ink => context.primaryTextColor;
  Color get muted => context.secondaryTextColor;
  Color get line => context.borderColor;
  Color get bg => context.backgroundColor;
  Color get _tintedSurface => Color.alphaBlend(
    context.primaryColor.withValues(alpha: 0.08),
    context.cardBackgroundColor,
  );
  DateTime? _from;
  DateTime? _to;
  String? _statusFilter;
  bool _showFilters = false;
  final Map<String, bool> _scheduleAnswers = {};
  final Set<String> _updatingScheduleIds = {};

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<PlotScheduleBloc>().state.schedules.any(
        (schedule) => schedule.status == null,
      )) {
        _load();
      }
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateScheduleStatus(PlotScheduleEntity schedule) async {
    final scheduleId = schedule.id.trim();
    if (schedule.status == '1' ||
        (_scheduleAnswers[scheduleId] ?? false) ||
        _updatingScheduleIds.contains(scheduleId))
      return;
    if (scheduleId.isEmpty) {
      _showMessage('Schedule ID is missing.');
      return;
    }
    setState(() => _updatingScheduleIds.add(scheduleId));
    try {
      final userData = await SecureStorage.instance.getUserData();
      if (!mounted) return;
      final empId = (userData?['user_id'] ?? userData?['userId'] ?? '')
          .toString()
          .trim();
      if (empId.isEmpty || empId == '0') {
        _showMessage('Please login again.');
        return;
      }
      final message = await GetIt.I<ScheduleListRepository>()
          .updateScheduleStatus(scheduleId: scheduleId, empId: empId);
      if (!mounted) return;
      setState(() => _scheduleAnswers[scheduleId] = true);
      _showMessage(message);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Unable to update schedule: $error');
    } finally {
      if (mounted) setState(() => _updatingScheduleIds.remove(scheduleId));
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreIfNeeded);
  }

  void _loadMoreIfNeeded() {
    if (!mounted || !_scrollController.hasClients) return;
    final state = context.read<PlotScheduleBloc>().state;
    if (state.status == PlotScheduleStatus.success &&
        state.hasMore &&
        !state.isLoadingMore &&
        state.loadMoreError.isEmpty &&
        (_scrollController.position.extentAfter < 300 ||
            _scrollController.position.extentBefore < 300)) {
      _loadMore();
    }
  }

  void _loadMore() {
    context.read<PlotScheduleBloc>().add(LoadMorePlotScheduleHistory());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _load() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    context.read<PlotScheduleBloc>().add(
      LoadPlotScheduleHistory(
        PlotScheduleQuery(
          farmerId: widget.farmerId,
          plotId: widget.plotId,
          cropId: widget.cropId,
          fromDate: _from,
          toDate: _to,
          status: _statusFilter,
        ),
      ),
    );
  }

  Future<void> _chooseDate(bool isFrom) async {
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (isFrom) {
        _from = result;
      } else {
        _to = result;
      }
    });
  }

  DateTime _scheduleDate(String value) {
    final parts = value.trim().split('-');
    if (parts.length == 3 && parts.first.length == 2) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.tryParse(value) ?? DateTime(1970);
  }

  String _date(DateTime? date) {
    if (date == null) return 'Any date';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      // appBar: AppBar(
      //   backgroundColor: context.cardBackgroundColor,
      //   surfaceTintColor: context.cardBackgroundColor,
      //   title: Text(
      //     'Plot Schedule History',
      //     style: TextStyle(
      //       fontSize: 16,
      //       fontWeight: FontWeight.w800,
      //       color: ink,
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       tooltip: 'Filters',
      //       icon: Icon(
      //         Icons.tune_rounded,
      //         color: green,
      //       ),
      //       onPressed: () {
      //         setState(() {
      //           _showFilters = !_showFilters;
      //         });
      //       },
      //     ),
      //   ],
      // ),

      appBar: CustomAppBar(
        title: 'Plot Schedule History',
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

      body: BlocConsumer<PlotScheduleBloc, PlotScheduleState>(
        listener: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _loadMoreIfNeeded(),
          );
        },
        builder: (context, state) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _tintedSurface,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  "Note: Show Today's Schedules by default | Scroll Down ↓ → Load Future Schedules | Scroll Up ↑ → Load Past Schedules.",
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.5,
                    color: context.primaryTextColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: _plotHeader(),
              ),
              if (_showFilters)
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 8, 10, 0),
                  child: _filters(),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final bloc = context.read<PlotScheduleBloc>();
                    final completion = bloc.stream.firstWhere(
                      (s) =>
                          s.status == PlotScheduleStatus.success ||
                          s.status == PlotScheduleStatus.failure,
                    );
                    _load();
                    await completion;
                  },
                  child: _timeline(state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =====================================
  // PLOT HEADER
  // =====================================

  Widget _timeline(PlotScheduleState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final past =
        state.schedules
            .where((s) => _scheduleDate(s.date).isBefore(today))
            .toList()
          ..sort(
            (a, b) => _scheduleDate(b.date).compareTo(_scheduleDate(a.date)),
          );
    final upcoming =
        state.schedules
            .where((s) => !_scheduleDate(s.date).isBefore(today))
            .toList()
          ..sort(
            (a, b) => _scheduleDate(a.date).compareTo(_scheduleDate(b.date)),
          );
    final centerKey = ValueKey('today-timeline');
    Widget card(PlotScheduleEntity schedule) => Padding(
      key: ValueKey(schedule.id),
      padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
      child: _schedule(schedule),
    );
    Widget pagination() {
      if (state.isLoadingMore) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator(color: green)),
        );
      }
      return SizedBox.shrink();
    }

    // With no current or future records, open directly on the latest past one.
    if (upcoming.isEmpty && past.isNotEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: ListView.builder(
          shrinkWrap: true,
          key: ValueKey('past-only-timeline'),
          controller: _scrollController,
          reverse: true,
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: past.length + 1,
          itemBuilder: (context, index) {
            if (index == past.length) return pagination();
            return card(past[index]);
          },
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      center: centerKey,
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: pagination()),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => card(past[index]),
            childCount: past.length,
          ),
        ),
        SliverToBoxAdapter(
          key: centerKey,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: _chip('Today · ${_date(today)}', green)),
          ),
        ),
        if (state.status == PlotScheduleStatus.loading)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(42),
              child: Center(child: CircularProgressIndicator(color: green)),
            ),
          )
        else if (state.status == PlotScheduleStatus.failure)
          SliverToBoxAdapter(
            child: _message(
              Icons.error_outline_rounded,
              'Unable to load history',
              state.error,
              retry: _load,
            ),
          )
        else if (state.schedules.isEmpty)
          SliverToBoxAdapter(
            child: _message(
              Icons.event_busy_outlined,
              'No schedule history',
              'No schedules found for the selected plot.',
              retry: _load,
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => card(upcoming[index]),
            childCount: upcoming.length,
          ),
        ),
        SliverToBoxAdapter(child: pagination()),
      ],
    );
  }

  Widget _plotHeader() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: _decoration(),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _tintedSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.landscape_outlined, color: green),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plot Name : ${widget.plotName.isNotEmpty ? widget.plotName : '#${widget.plotId}'}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Farmer Name : ${widget.farmerName.isNotEmpty ? widget.farmerName : '#${widget.farmerId}'}',
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),

          _chip('History', green),
        ],
      ),
    );
  }

  // =====================================
  // DATE FILTERS
  // =====================================

  Widget _filters() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: _decoration(),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _statusFilter ?? '',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: ink,
            ),
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Status',
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: muted,
              ),
              floatingLabelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: green,
              ),
              isDense: true,
              filled: true,
              fillColor: context.appColors.surfaceContainerLow,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide(color: line),
              ),
            ),
            items: [
              DropdownMenuItem(value: '', child: Text('Select status')),
              DropdownMenuItem(value: '1', child: Text('Yes')),
              DropdownMenuItem(value: '0', child: Text('No')),
            ],
            onChanged: (value) => setState(() {
              _statusFilter = value == '' ? null : value;
            }),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _dateTile('From Date', _from, () => _chooseDate(true)),
              ),

              SizedBox(width: 8),

              Expanded(
                child: _dateTile('To Date', _to, () => _chooseDate(false)),
              ),
            ],
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _from = null;
                      _to = null;
                      _statusFilter = null;
                    });

                    _load();
                  },
                  child: Text('Clear'),
                ),
              ),

              SizedBox(width: 8),

              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: green),
                  icon: Icon(Icons.search, size: 17),
                  label: Text('Apply Filters'),
                  onPressed: () {
                    if (_from != null && _to != null && _from!.isAfter(_to!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('From Date cannot be after To Date'),
                        ),
                      );
                      return;
                    }

                    _load();

                    setState(() {
                      _showFilters = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateTile(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.appColors.surfaceContainerLow,
          border: Border.all(color: line),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: muted)),

            SizedBox(height: 3),

            Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: green, size: 13),

                SizedBox(width: 6),

                Expanded(
                  child: Text(
                    _date(date),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ink,
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

  // =====================================
  // SCHEDULE CARD
  // =====================================

  Widget _schedule(PlotScheduleEntity schedule) {
    final remark = schedule.remark?.trim() ?? '';
    final isCompleted =
        schedule.status == '1' ||
        (_scheduleAnswers[schedule.id.trim()] ?? false);
    return Container(
      padding: EdgeInsets.all(12),
      decoration: _decoration().copyWith(
        color:
            schedule.status == '1' ||
                (_scheduleAnswers[schedule.id.trim()] ?? false)
            ? _tintedSurface
            : context.cardBackgroundColor,
        border: Border.all(
          color: isCompleted ? context.primaryColor : line,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  schedule.date,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ),
              _chip(
                '${schedule.products.length} ${schedule.products.length == 1 ? 'Product' : 'Products'}',
                green,
              ),
            ],
          ),
          // if (schedule.crop.trim().isNotEmpty) ...[
          //   SizedBox(height: 6),
          //   Text(
          //     'Crop : ${schedule.crop.trim()}',
          //     style: TextStyle(
          //       fontSize: 11,
          //       fontWeight: FontWeight.w600,
          //       color: green,
          //     ),
          //   ),
          // ],
          Divider(height: 16, color: line),
          if (schedule.products.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No products',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            )
          else
            for (int i = 0; i < schedule.products.length; i++)
              _product(i + 1, schedule.products[i]),
          Divider(height: 16, color: line),
          if (remark.isNotEmpty)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Remark : ',
                    style: TextStyle(fontWeight: FontWeight.w700, color: green),
                  ),
                  TextSpan(text: remark),
                ],
              ),
              style: TextStyle(color: ink, fontSize: 12, height: 1.35),
            ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: _tintedSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Products Applied',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
                _answerOption(schedule, 'Yes', true),
                SizedBox(width: 8),
                _answerOption(schedule, 'No', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerOption(PlotScheduleEntity schedule, String label, bool value) {
    final scheduleId = schedule.id.trim();
    final isCompleted =
        schedule.status == '1' || (_scheduleAnswers[scheduleId] ?? false);
    final isUpdating = _updatingScheduleIds.contains(scheduleId);
    final disabled = isCompleted || isUpdating;
    final selected = isCompleted || (_scheduleAnswers[scheduleId] ?? false);
    final isSelected = selected == value;
    return Semantics(
      enabled: !disabled,
      checked: isSelected,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: disabled
            ? null
            : () {
                if (value) {
                  _updateScheduleStatus(schedule);
                } else {
                  setState(() => _scheduleAnswers[scheduleId] = false);
                }
              },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value && isUpdating)
                SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: green,
                  ),
                )
              else
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? green
                      : (isCompleted ? muted.withOpacity(0.42) : muted),
                  size: 19,
                ),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? green
                      : (isCompleted ? muted.withOpacity(0.42) : ink),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _product(int number, PlotScheduleProductEntity product) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$number. Product Name : ${product.name.isEmpty ? 'Unnamed product' : product.name}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
              ),

              if (product.type.isNotEmpty) _chip(product.type, green),
            ],
          ),

          SizedBox(height: 5),

          Padding(
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                Expanded(
                  child: _amount(
                    Icons.scale_outlined,
                    'Qty',
                    product.quantity,
                    product.unit,
                    context.appColors.tertiary,
                  ),
                ),

                SizedBox(width: 6),

                Expanded(
                  child: _amount(
                    Icons.water_drop_outlined,
                    'Water',
                    product.waterQuantity,
                    product.waterUnit,
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

  Widget _amount(
    IconData icon,
    String label,
    String quantity,
    String unit,
    Color color,
  ) {
    final text = quantity.trim().isEmpty
        ? '-'
        : '${quantity.trim()}'
              '${unit.trim().isEmpty ? '' : ' ${unit.trim()}'}';

    return Row(
      children: [
        Icon(icon, size: 14, color: color),

        SizedBox(width: 4),

        Text('$label: ', style: TextStyle(color: muted, fontSize: 10)),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: ink,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // =====================================
  // COMMON UI HELPERS
  // =====================================

  Widget _chip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _message(
    IconData icon,
    String title,
    String description, {
    VoidCallback? retry,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: _decoration(),
      child: Column(
        children: [
          Icon(icon, size: 32, color: green),

          SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w800, color: ink),
          ),

          SizedBox(height: 5),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: muted),
          ),

          if (retry != null) ...[
            SizedBox(height: 12),

            OutlinedButton(onPressed: retry, child: Text('Retry')),
          ],
        ],
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: context.cardBackgroundColor,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: line),
    );
  }
}
