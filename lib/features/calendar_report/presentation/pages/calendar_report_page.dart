import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/secure_storage/secure_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/calendar_day_entity.dart';

import '../bloc/calendar_report_bloc.dart';
import '../bloc/calendar_report_event.dart';
import '../bloc/calendar_report_state.dart';

class CalendarReportPage extends StatefulWidget {
  const CalendarReportPage({
    super.key,
  });

  @override
  State<CalendarReportPage> createState() =>
      _CalendarReportPageState();
}

class _CalendarReportPageState extends State<CalendarReportPage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color _background = Color(0xFFF4F7F6);

  static const Color _card = Colors.white;

  static const Color _text = Color(0xFF1E2D28);

  static const Color _muted = Color(0xFF7B8881);

  static const Color _border = Color(0xFFE3E9E5);

  static const Color _primary = Color(0xFF13875E);

  static const Color _primarySoft = Color(0xFFEAF6F1);

  static const Color _dealer = Color(0xFFF16A21);

  static const Color _dealerSoft = Color(0xFFFFF2E9);

  static const Color _farmer = Color(0xFF0BAA73);

  static const Color _farmerSoft = Color(0xFFE9F8F2);

  static const Color _today = Color(0xFFFFA000);

  static const Color _weekend = Color(0xFFFFF9F5);

  static const Color _outsideMonth = Color(0xFFF6F8F7);

  // ============================================================
  // WEEK DAYS
  // ============================================================

  static const List<String> _weekDays = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  // ============================================================
  // VARIABLES
  // ============================================================

  String _userId = '';

  bool _initialized = false;

  DateTime? _selectedDate;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initialize() async {
    final Map<String, dynamic>? userData =
        await SecureStorage.instance.getUserData();

    if (!mounted) {
      return;
    }

    final String id =
        userData?['user_id']?.toString().trim() ?? '';

    final DateTime now = DateTime.now();

    setState(() {
      _userId = id;

      _initialized = true;

      _selectedDate = DateTime(
        now.year,
        now.month,
        now.day,
      );
    });

    if (id.isEmpty) {
      return;
    }

    _loadMonth(
      DateTime(
        now.year,
        now.month,
        1,
      ),
    );
  }

  // ============================================================
  // LOAD MONTH
  // ============================================================

  void _loadMonth(
    DateTime month,
  ) {
    if (_userId.isEmpty) {
      return;
    }

    context.read<CalendarReportBloc>().add(
      LoadCalendarReportEvent(
        userId: _userId,
        month: month,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,

      appBar: const CustomAppBar(
        title: 'Followup Calendar',
        showBackButton: true,
      ),

      body: !_initialized
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
            )
          : BlocBuilder<
              CalendarReportBloc,
              CalendarReportState>(
              builder: (
                context,
                state,
              ) {
                return _buildBody(
                  state,
                );
              },
            ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
    CalendarReportState state,
  ) {
    if (_userId.isEmpty) {
  return const Center(
    child: Text(
      'User not found',
      style: TextStyle(
        color: _text,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

    if (state.status == CalendarReportStatus.loading) {
      return _buildLoading();
    }

    if (state.status == CalendarReportStatus.failure) {
      return _buildError(
        state.errorMessage ??
            'Unable to load followup calendar.',
      );
    }

    return SafeArea(
      top: false,
      child: Column(
        children: [
          // =====================================================
          // MONTH HEADER
          // =====================================================

          _buildMonthHeader(
            state,
          ),

          // =====================================================
          // CALENDAR
          // =====================================================

          _buildCalendarCard(
            state,
          ),

          const SizedBox(
            height: 8,
          ),

          // =====================================================
          // SELECTED DATE DETAILS
          // =====================================================

          Expanded(
            child: _buildSelectedDateSection(
              state,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONTH HEADER
  // ============================================================

  Widget _buildMonthHeader(
    CalendarReportState state,
  ) {
    final String monthTitle =
        DateFormat(
      'MMMM yyyy',
    ).format(
      state.visibleMonth,
    );

    final int farmerTotal =
        state.days.fold(
      0,
      (
        total,
        item,
      ) =>
          total + item.farmerCount,
    );

    final int dealerTotal =
        state.days.fold(
      0,
      (
        total,
        item,
      ) =>
          total + item.dealerCount,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(
        10,
        10,
        10,
        8,
      ),
      padding: const EdgeInsets.fromLTRB(
        10,
        9,
        10,
        9,
      ),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              .025,
            ),
            blurRadius: 8,
            offset: const Offset(
              0,
              2,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          // =====================================================
          // MONTH CONTROL
          // =====================================================

          Row(
            children: [
              _buildNavigationButton(
                icon:
                    Icons.chevron_left_rounded,
                onTap: _previousMonth,
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      monthTitle,
                      textAlign:
                          TextAlign.center,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    const Text(
                      'Followup activity overview',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 7,
              ),

              _buildNavigationButton(
                icon:
                    Icons.chevron_right_rounded,
                onTap: _nextMonth,
              ),
            ],
          ),

          const SizedBox(
            height: 9,
          ),

          // =====================================================
          // TOTAL SUMMARY
          // =====================================================

          Row(
            children: [
              Expanded(
                child: _buildMonthlySummary(
                  icon:
                      Icons.agriculture_rounded,
                  title:
                      'Farmers',
                  value:
                      farmerTotal,
                  color:
                      _farmer,
                  background:
                      _farmerSoft,
                ),
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child: _buildMonthlySummary(
                  icon:
                      Icons.storefront_rounded,
                  title:
                      'Dealers',
                  value:
                      dealerTotal,
                  color:
                      _dealer,
                  background:
                      _dealerSoft,
                ),
              ),

              const SizedBox(
                width: 7,
              ),

              _buildTodayButton(),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAVIGATION BUTTON
  // ============================================================

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _primarySoft,
      borderRadius: BorderRadius.circular(
        10,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          10,
        ),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 21,
            color: _primary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MONTH SUMMARY
  // ============================================================

  Widget _buildMonthlySummary({
    required IconData icon,
    required String title,
    required int value,
    required Color color,
    required Color background,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                .75,
              ),
              borderRadius: BorderRadius.circular(
                7,
              ),
            ),
            child: Icon(
              icon,
              size: 13,
              color: color,
            ),
          ),

          const SizedBox(
            width: 6,
          ),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 7,
                    fontWeight:
                        FontWeight.w600,
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
  // TODAY
  // ============================================================

  Widget _buildTodayButton() {
    return Material(
      color: _primary,
      borderRadius: BorderRadius.circular(
        10,
      ),
      child: InkWell(
        onTap: _goToday,
        borderRadius: BorderRadius.circular(
          10,
        ),
        child: const SizedBox(
          width: 55,
          height: 38,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.today_rounded,
                size: 13,
                color: Colors.white,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                'Today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CALENDAR CARD
  // ============================================================

  Widget _buildCalendarCard(
    CalendarReportState state,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              .02,
            ),
            blurRadius: 7,
            offset: const Offset(
              0,
              2,
            ),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildWeekHeader(),

          _buildCalendarGrid(
            state,
          ),

          _buildLegend(),
        ],
      ),
    );
  }

  // ============================================================
  // WEEK HEADER
  // ============================================================

  Widget _buildWeekHeader() {
    return Container(
      height: 32,
      color: const Color(
        0xFF253B34,
      ),
      child: Row(
        children: List.generate(
          7,
          (
            index,
          ) {
            return Expanded(
              child: Center(
                child: Text(
                  _weekDays[index],
                  style: TextStyle(
                    color:
                        index == 0
                            ? const Color(
                                0xFFFFB288,
                              )
                            : Colors.white,
                    fontSize: 7.5,
                    fontWeight:
                        FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CALENDAR GRID
  // ============================================================

  Widget _buildCalendarGrid(
    CalendarReportState state,
  ) {
    final List<DateTime> dates =
        _calendarDates(
      state.visibleMonth,
    );

    final int rows =
        (dates.length / 7).ceil();

    /*
     * Compact mobile heights:
     *
     * 5 week month = 58 each
     * 6 week month = 52 each
     */
    final double cellHeight =
        rows == 6 ? 52 : 58;

    return SizedBox(
      height:
          rows * cellHeight,
      child: GridView.builder(
        physics:
            const NeverScrollableScrollPhysics(),
        padding:
            EdgeInsets.zero,
        itemCount:
            dates.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              7,
          mainAxisExtent:
              cellHeight,
        ),
        itemBuilder: (
          context,
          index,
        ) {
          final DateTime date =
              dates[index];

          final CalendarDayEntity?
              day =
              _findDay(
            state.days,
            date,
          );

          return _buildDayCell(
            date:
                date,
            visibleMonth:
                state.visibleMonth,
            day:
                day,
            columnIndex:
                index % 7,
          );
        },
      ),
    );
  }

  // ============================================================
  // DAY CELL
  // ============================================================

  Widget _buildDayCell({
    required DateTime date,
    required DateTime visibleMonth,
    required CalendarDayEntity? day,
    required int columnIndex,
  }) {
    final bool currentMonth =
        date.year ==
                visibleMonth.year &&
            date.month ==
                visibleMonth.month;

    final bool today =
        _sameDate(
      date,
      DateTime.now(),
    );

    final bool selected =
        _selectedDate != null &&
            _sameDate(
              date,
              _selectedDate!,
            );

    final int farmerCount =
        day?.farmerCount ?? 0;

    final int dealerCount =
        day?.dealerCount ?? 0;

    final bool hasData =
        farmerCount > 0 ||
            dealerCount > 0;

    Color cellColor;

    if (!currentMonth) {
      cellColor =
          _outsideMonth;
    } else if (selected) {
      cellColor =
          _primarySoft;
    } else if (columnIndex == 0) {
      cellColor =
          _weekend;
    } else {
      cellColor =
          Colors.white;
    }

    return Material(
      color:
          cellColor,
      child: InkWell(
        onTap:
            currentMonth
                ? () {
                    setState(() {
                      _selectedDate =
                          date;
                    });
                  }
                : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            4,
            4,
            4,
            3,
          ),
          decoration: BoxDecoration(
            border: Border(
              right: const BorderSide(
                color: _border,
                width: .5,
              ),
              bottom: const BorderSide(
                color: _border,
                width: .5,
              ),
              left:
                  selected
                      ? const BorderSide(
                          color:
                              _primary,
                          width:
                              1.5,
                        )
                      : BorderSide.none,
            ),
          ),
          child: Column(
            children: [
              // =================================================
              // DATE
              // =================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  Container(
                    width:
                        22,
                    height:
                        22,
                    alignment:
                        Alignment.center,
                    decoration:
                        today
                            ? const BoxDecoration(
                                color:
                                    _today,
                                shape:
                                    BoxShape.circle,
                              )
                            : selected
                            ? const BoxDecoration(
                                color:
                                    _primary,
                                shape:
                                    BoxShape.circle,
                              )
                            : null,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color:
                            today ||
                                    selected
                                ? Colors.white
                                : currentMonth
                                ? _text
                                : const Color(
                                    0xFFBCC4C0,
                                  ),
                        fontSize:
                            9.5,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // =================================================
              // COUNT INDICATORS
              // =================================================

              if (currentMonth &&
                  hasData)
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    if (farmerCount >
                        0)
                      _buildDayCount(
                        count:
                            farmerCount,
                        color:
                            _farmer,
                      ),

                    if (farmerCount >
                            0 &&
                        dealerCount >
                            0)
                      const SizedBox(
                        width:
                            3,
                      ),

                    if (dealerCount >
                        0)
                      _buildDayCount(
                        count:
                            dealerCount,
                        color:
                            _dealer,
                      ),
                  ],
                ),

              if (!hasData)
                const SizedBox(
                  height: 15,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SMALL COUNT
  // ============================================================

  Widget _buildDayCount({
    required int count,
    required Color color,
  }) {
    return Container(
      constraints:
          const BoxConstraints(
        minWidth:
            16,
        minHeight:
            15,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(
          .10,
        ),
        borderRadius: BorderRadius.circular(
          5,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color:
                  color,
              shape:
                  BoxShape.circle,
            ),
          ),

          const SizedBox(
            width: 2,
          ),

          Text(
            '$count',
            style: TextStyle(
              color:
                  color,
              fontSize:
                  6.5,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LEGEND
  // ============================================================

  Widget _buildLegend() {
    return Container(
      height: 30,
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            10,
      ),
      decoration:
          const BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                _border,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildLegendItem(
            color:
                _farmer,
            title:
                'Farmer',
          ),

          const SizedBox(
            width: 12,
          ),

          _buildLegendItem(
            color:
                _dealer,
            title:
                'Dealer',
          ),

          const Spacer(),

          const Icon(
            Icons.touch_app_outlined,
            size: 10,
            color: _muted,
          ),

          const SizedBox(
            width: 3,
          ),

          const Text(
            'Tap date for details',
            style: TextStyle(
              color: _muted,
              fontSize: 6.5,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
  }) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color:
                color,
            shape:
                BoxShape.circle,
          ),
        ),

        const SizedBox(
          width: 4,
        ),

        Text(
          title,
          style: const TextStyle(
            color:
                _muted,
            fontSize:
                7,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SELECTED DATE SECTION
  // ============================================================

  Widget _buildSelectedDateSection(
    CalendarReportState state,
  ) {
    if (_selectedDate == null) {
      return _buildNoDateSelected();
    }

    final DateTime selectedDate =
        _selectedDate!;

    final CalendarDayEntity?
        selectedDay =
        _findDay(
      state.days,
      selectedDate,
    );

    final int farmerCount =
        selectedDay?.farmerCount ??
            0;

    final int dealerCount =
        selectedDay?.dealerCount ??
            0;

    final int totalCount =
        selectedDay?.totalCount ??
            0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        10,
        0,
        10,
        18,
      ),
      child: Column(
        children: [
          // =====================================================
          // SELECTED DATE HEADER
          // =====================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color:
                  _card,
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
              border: Border.all(
                color:
                    _border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width:
                      34,
                  height:
                      34,
                  decoration:
                      BoxDecoration(
                    color:
                        _primarySoft,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .calendar_today_rounded,
                    size:
                        16,
                    color:
                        _primary,
                  ),
                ),

                const SizedBox(
                  width:
                      9,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selected Date',
                        style: TextStyle(
                          color:
                              _muted,
                          fontSize:
                              7,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height:
                            2,
                      ),

                      Text(
                        DateFormat(
                          'EEEE, dd MMM yyyy',
                        ).format(
                          selectedDate,
                        ),
                        style:
                            const TextStyle(
                          color:
                              _text,
                          fontSize:
                              11,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                if (totalCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal:
                          8,
                      vertical:
                          5,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          _primarySoft,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child:
                        Text(
                      '$totalCount Followups',
                      style:
                          const TextStyle(
                        color:
                            _primary,
                        fontSize:
                            7,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(
            height:
                7,
          ),

          // =====================================================
          // NO DATA
          // =====================================================

          if (selectedDay ==
                  null ||
              !selectedDay
                  .hasAnyVisit)
            _buildNoActivityCard(
              selectedDate,
            )
          else ...[
            // ===================================================
            // FARMER SUMMARY
            // ===================================================

            if (farmerCount >
                0)
              _buildSelectedSummaryCard(
                title:
                    'Farmers',
                subtitle:
                    'View farmer followup details',
                count:
                    farmerCount,
                icon:
                    Icons.agriculture_rounded,
                color:
                    _farmer,
                background:
                    _farmerSoft,
                onTap:
                    () {
                  _showVisitDetailsBottomSheet(
                    date:
                        selectedDay.date,
                    title:
                        'Farmers',
                    count:
                        selectedDay.farmerCount,
                    persons:
                        selectedDay.farmers,
                    color:
                        _farmer,
                    background:
                        _farmerSoft,
                    icon:
                        Icons.agriculture_rounded,
                  );
                },
              ),

            if (farmerCount >
                    0 &&
                dealerCount >
                    0)
              const SizedBox(
                height:
                    7,
              ),

            // ===================================================
            // DEALER SUMMARY
            // ===================================================

            if (dealerCount >
                0)
              _buildSelectedSummaryCard(
                title:
                    'Dealers',
                subtitle:
                    'View dealer followup details',
                count:
                    dealerCount,
                icon:
                    Icons.storefront_rounded,
                color:
                    _dealer,
                background:
                    _dealerSoft,
                onTap:
                    () {
                  _showVisitDetailsBottomSheet(
                    date:
                        selectedDay.date,
                    title:
                        'Dealers',
                    count:
                        selectedDay.dealerCount,
                    persons:
                        selectedDay.dealers,
                    color:
                        _dealer,
                    background:
                        _dealerSoft,
                    icon:
                        Icons.storefront_rounded,
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // SELECTED SUMMARY CARD
  // ============================================================

  Widget _buildSelectedSummaryCard({
    required String title,
    required String subtitle,
    required int count,
    required IconData icon,
    required Color color,
    required Color background,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
          _card,
      borderRadius:
          BorderRadius.circular(
        13,
      ),
      child: InkWell(
        onTap:
            onTap,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal:
                11,
            vertical:
                9,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              13,
            ),
            border:
                Border.all(
              color:
                  _border,
            ),
          ),
          child:
              Row(
            children: [
              // =================================================
              // ICON
              // =================================================

              Container(
                width:
                    39,
                height:
                    39,
                decoration:
                    BoxDecoration(
                  color:
                      background,
                  borderRadius:
                      BorderRadius.circular(
                    11,
                  ),
                ),
                child:
                    Icon(
                  icon,
                  size:
                      18,
                  color:
                      color,
                ),
              ),

              const SizedBox(
                width:
                    10,
              ),

              // =================================================
              // TEXT
              // =================================================

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color:
                            _text,
                        fontSize:
                            11,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height:
                          2,
                    ),

                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color:
                            _muted,
                        fontSize:
                            7.5,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // COUNT
              // =================================================

              Container(
                constraints:
                    const BoxConstraints(
                  minWidth:
                      32,
                ),
                height:
                    30,
                alignment:
                    Alignment.center,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal:
                      8,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      background,
                  borderRadius:
                      BorderRadius.circular(
                    9,
                  ),
                ),
                child:
                    Text(
                  '$count',
                  style:
                      TextStyle(
                    color:
                        color,
                    fontSize:
                        11,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(
                width:
                    6,
              ),

              Icon(
                Icons.chevron_right_rounded,
                color:
                    color,
                size:
                    19,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NO ACTIVITY
  // ============================================================

  Widget _buildNoActivityCard(
    DateTime date,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical:
            16,
        horizontal:
            12,
      ),
      decoration:
          BoxDecoration(
        color:
            _card,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        border:
            Border.all(
          color:
              _border,
        ),
      ),
      child:
          Column(
        children: [
          Container(
            width:
                42,
            height:
                42,
            decoration:
                BoxDecoration(
              color:
                  _primarySoft,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child:
                const Icon(
              Icons.event_available_outlined,
              color:
                  _primary,
              size:
                  20,
            ),
          ),

          const SizedBox(
            height:
                7,
          ),

          const Text(
            'No followups on this date',
            style:
                TextStyle(
              color:
                  _text,
              fontSize:
                  10,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height:
                3,
          ),

          Text(
            DateFormat(
              'dd MMM yyyy',
            ).format(
              date,
            ),
            style:
                const TextStyle(
              color:
                  _muted,
              fontSize:
                  7.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO DATE SELECTED
  // ============================================================

  Widget _buildNoDateSelected() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.touch_app_outlined,
              color:
                  _primary,
              size:
                  30,
            ),

            const SizedBox(
              height:
                  7,
            ),

            const Text(
              'Select a date',
              style:
                  TextStyle(
                color:
                    _text,
                fontSize:
                    11,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height:
                  2,
            ),

            const Text(
              'Tap any calendar date to see followup details.',
              style:
                  TextStyle(
                color:
                    _muted,
                fontSize:
                    8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM SHEET
  // ============================================================

  void _showVisitDetailsBottomSheet({
    required DateTime date,
    required String title,
    required int count,
    required List<CalendarPersonEntity> persons,
    required Color color,
    required Color background,
    required IconData icon,
  }) {
    showModalBottomSheet(
      context:
          context,

      isScrollControlled:
          true,

      useSafeArea:
          true,

      backgroundColor:
          Colors.transparent,

      barrierColor:
          Colors.black.withOpacity(
        .35,
      ),

      builder: (
        sheetContext,
      ) {
        return DraggableScrollableSheet(
          initialChildSize:
              .58,

          minChildSize:
              .35,

          maxChildSize:
              .88,

          expand:
              false,

          builder: (
            context,
            scrollController,
          ) {
            return Container(
              decoration:
                  const BoxDecoration(
                color:
                    Color(
                  0xFFF7F9F8,
                ),
                borderRadius:
                    BorderRadius.vertical(
                  top:
                      Radius.circular(
                    24,
                  ),
                ),
              ),
              clipBehavior:
                  Clip.antiAlias,
              child:
                  Column(
                children: [
                  // ==============================================
                  // HANDLE
                  // ==============================================

                  const SizedBox(
                    height:
                        8,
                  ),

                  Container(
                    width:
                        38,
                    height:
                        4,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFD5DCD8,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        7,
                  ),

                  // ==============================================
                  // HEADER
                  // ==============================================

                  Container(
                    color:
                        Colors.white,
                    padding:
                        const EdgeInsets.fromLTRB(
                      14,
                      8,
                      8,
                      11,
                    ),
                    child:
                        Row(
                      children: [
                        Container(
                          width:
                              40,
                          height:
                              40,
                          decoration:
                              BoxDecoration(
                            color:
                                background,
                            borderRadius:
                                BorderRadius.circular(
                              11,
                            ),
                          ),
                          child:
                              Icon(
                            icon,
                            size:
                                19,
                            color:
                                color,
                          ),
                        ),

                        const SizedBox(
                          width:
                              10,
                        ),

                        Expanded(
                          child:
                              Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child:
                                        Text(
                                      title,
                                      maxLines:
                                          1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(
                                        color:
                                            _text,
                                        fontSize:
                                            14,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width:
                                        6,
                                  ),

                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal:
                                          7,
                                      vertical:
                                          3,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          background,
                                      borderRadius:
                                          BorderRadius.circular(
                                        20,
                                      ),
                                    ),
                                    child:
                                        Text(
                                      '$count',
                                      style:
                                          TextStyle(
                                        color:
                                            color,
                                        fontSize:
                                            8,
                                        fontWeight:
                                            FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height:
                                    3,
                              ),

                              Text(
                                DateFormat(
                                  'EEEE, dd MMMM yyyy',
                                ).format(
                                  date,
                                ),
                                style:
                                    const TextStyle(
                                  color:
                                      _muted,
                                  fontSize:
                                      8,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          visualDensity:
                              VisualDensity.compact,
                          onPressed:
                              () {
                            Navigator.pop(
                              sheetContext,
                            );
                          },
                          icon:
                              const Icon(
                            Icons.close_rounded,
                            size:
                                20,
                            color:
                                _muted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==============================================
                  // LIST
                  // ==============================================

                  Expanded(
                    child:
                        persons.isEmpty
                            ? _buildEmptyPersonList(
                                title:
                                    title,
                                icon:
                                    icon,
                                color:
                                    color,
                                background:
                                    background,
                              )
                            : ListView.separated(
                                controller:
                                    scrollController,
                                physics:
                                    const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  22,
                                ),
                                itemCount:
                                    persons.length,
                                separatorBuilder:
                                    (
                                  context,
                                  index,
                                ) =>
                                        const SizedBox(
                                  height:
                                      6,
                                ),
                                itemBuilder:
                                    (
                                  context,
                                  index,
                                ) {
                                  return _buildPersonCard(
                                    person:
                                        persons[index],
                                    index:
                                        index,
                                    icon:
                                        icon,
                                    color:
                                        color,
                                    background:
                                        background,
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // PERSON CARD
  // ============================================================

  Widget _buildPersonCard({
    required CalendarPersonEntity person,
    required int index,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    final String rawName =
        person.name.trim();

    final bool hasName =
        rawName.isNotEmpty;

    final String name =
        hasName
            ? rawName
            : 'Name not available';

    final String initial =
        hasName
            ? rawName
                .characters
                .first
                .toUpperCase()
            : '?';

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            9,
        vertical:
            8,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border:
            Border.all(
          color:
              _border,
        ),
      ),
      child:
          Row(
        children: [
          // =====================================================
          // NUMBER
          // =====================================================

          // Container(
          //   width:
          //       24,
          //   height:
          //       24,
          //   alignment:
          //       Alignment.center,
          //   decoration:
          //       BoxDecoration(
          //     color:
          //         background,
          //     borderRadius:
          //         BorderRadius.circular(
          //       7,
          //     ),
          //   ),
          //   child:
          //       Text(
          //     '${index + 1}',
          //     style:
          //         TextStyle(
          //       color:
          //           color,
          //       fontSize:
          //           7,
          //       fontWeight:
          //           FontWeight.w900,
          //     ),
          //   ),
          // ),

          const SizedBox(
            width:
                8,
          ),

          // =====================================================
          // AVATAR
          // =====================================================

          Container(
            width:
                36,
            height:
                36,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  background,
              shape:
                  BoxShape.circle,
            ),
            child:
                Text(
              initial,
              style:
                  TextStyle(
                color:
                    color,
                fontSize:
                    12,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(
            width:
                9,
          ),

          // =====================================================
          // NAME
          // =====================================================

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines:
                      2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    color:
                        hasName
                            ? _text
                            : _muted,
                    fontSize:
                        10.5,
                    fontWeight:
                        FontWeight.w700,
                    fontStyle:
                        hasName
                            ? FontStyle.normal
                            : FontStyle.italic,
                  ),
                ),

                const SizedBox(
                  height:
                      3,
                ),

                // Row(
                //   children: [
                //     Icon(
                //       Icons.badge_outlined,
                //       color:
                //           color.withOpacity(
                //         .75,
                //       ),
                //       size:
                //           10,
                //     ),

                //     const SizedBox(
                //       width:
                //           3,
                //     ),

                //     Text(
                //       'ID: ${person.id.isEmpty ? '--' : person.id}',
                //       style:
                //           const TextStyle(
                //         color:
                //             _muted,
                //         fontSize:
                //             7.5,
                //         fontWeight:
                //             FontWeight.w500,
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),

          Container(
            width:
                29,
            height:
                29,
            decoration:
                BoxDecoration(
              color:
                  background,
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
            ),
            child:
                Icon(
              icon,
              color:
                  color,
              size:
                  14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY PERSON LIST
  // ============================================================

  Widget _buildEmptyPersonList({
    required String title,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Center(
      child:
          Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width:
                52,
            height:
                52,
            decoration:
                BoxDecoration(
              color:
                  background,
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child:
                Icon(
              icon,
              size:
                  23,
              color:
                  color,
            ),
          ),

          const SizedBox(
            height:
                9,
          ),

          Text(
            'No $title found',
            style:
                const TextStyle(
              color:
                  _text,
              fontSize:
                  11,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height:
                3,
          ),

          Text(
            'No ${title.toLowerCase()} details are available.',
            style:
                const TextStyle(
              color:
                  _muted,
              fontSize:
                  8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIOUS MONTH
  // ============================================================

  void _previousMonth() {
    if (_userId.isEmpty) {
      return;
    }

    final DateTime current =
        context
            .read<CalendarReportBloc>()
            .state
            .visibleMonth;

    final DateTime previous =
        DateTime(
      current.year,
      current.month - 1,
      1,
    );

    setState(() {
      _selectedDate =
          null;
    });

    context.read<CalendarReportBloc>().add(
      PreviousCalendarMonthEvent(
        userId: _userId,
      ),
    );
  }

  // ============================================================
  // NEXT MONTH
  // ============================================================

  void _nextMonth() {
    if (_userId.isEmpty) {
      return;
    }

    setState(() {
      _selectedDate =
          null;
    });

    context.read<CalendarReportBloc>().add(
      NextCalendarMonthEvent(
        userId: _userId,
      ),
    );
  }

  // ============================================================
  // TODAY
  // ============================================================

  void _goToday() {
    if (_userId.isEmpty) {
      return;
    }

    final DateTime now =
        DateTime.now();

    setState(() {
      _selectedDate =
          DateTime(
        now.year,
        now.month,
        now.day,
      );
    });

    context.read<CalendarReportBloc>().add(
      TodayCalendarEvent(
        userId: _userId,
      ),
    );
  }

  // ============================================================
  // GENERATE CALENDAR DATES
  // ============================================================

  List<DateTime> _calendarDates(
    DateTime month,
  ) {
    final DateTime firstDay =
        DateTime(
      month.year,
      month.month,
      1,
    );

    final DateTime lastDay =
        DateTime(
      month.year,
      month.month + 1,
      0,
    );

    final int previousDays =
        firstDay.weekday % 7;

    final DateTime startDate =
        firstDay.subtract(
      Duration(
        days:
            previousDays,
      ),
    );

    final int nextDays =
        6 -
            (lastDay.weekday %
                7);

    final DateTime endDate =
        lastDay.add(
      Duration(
        days:
            nextDays,
      ),
    );

    final List<DateTime> dates =
        [];

    DateTime current =
        startDate;

    while (!current.isAfter(
      endDate,
    )) {
      dates.add(
        current,
      );

      current =
          current.add(
        const Duration(
          days:
              1,
        ),
      );
    }

    return dates;
  }

  // ============================================================
  // FIND DATE
  // ============================================================

  CalendarDayEntity? _findDay(
    List<CalendarDayEntity> days,
    DateTime date,
  ) {
    for (final CalendarDayEntity item
        in days) {
      if (_sameDate(
        item.date,
        date,
      )) {
        return item;
      }
    }

    return null;
  }

  // ============================================================
  // SAME DATE
  // ============================================================

  bool _sameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year ==
            second.year &&
        first.month ==
            second.month &&
        first.day ==
            second.day;
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child:
          Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          SizedBox(
            width:
                27,
            height:
                27,
            child:
                CircularProgressIndicator(
              strokeWidth:
                  2.4,
              color:
                  AppColors.primaryGreen,
            ),
          ),

          SizedBox(
            height:
                8,
          ),

          Text(
            'Loading calendar...',
            style:
                TextStyle(
              color:
                  _muted,
              fontSize:
                  9,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
    String message,
  ) {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width:
                  55,
              height:
                  55,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFFFEEEE,
                ),
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child:
                  const Icon(
                Icons
                    .calendar_month_outlined,
                color:
                    Colors.redAccent,
                size:
                    26,
              ),
            ),

            const SizedBox(
              height:
                  10,
            ),

            const Text(
              'Unable to load calendar',
              style:
                  TextStyle(
                color:
                    _text,
                fontSize:
                    12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height:
                  4,
            ),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    _muted,
                fontSize:
                    8,
              ),
            ),

            const SizedBox(
              height:
                  12,
            ),

            SizedBox(
              height:
                  35,
              child:
                  ElevatedButton.icon(
                onPressed:
                    _retry,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _primary,
                  foregroundColor:
                      Colors.white,
                  elevation:
                      0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      9,
                    ),
                  ),
                ),
                icon:
                    const Icon(
                  Icons.refresh_rounded,
                  size:
                      15,
                ),
                label:
                    const Text(
                  'Try Again',
                  style:
                      TextStyle(
                    fontSize:
                        8.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RETRY
  // ============================================================

  void _retry() {
    if (_userId.isEmpty) {
      return;
    }

    final DateTime visibleMonth =
        context
            .read<CalendarReportBloc>()
            .state
            .visibleMonth;

    _loadMonth(
      visibleMonth,
    );
  }
}