import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:solufine/core/utility/widgets/custom_dropdown.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/secure_storage/secure_storage.dart';
import '../../../../core/utility/widgets/custom_appbar.dart';

import '../../domain/entities/growth_dealer_search.dart';
import '../../domain/entities/growth_report.dart';

import '../bloc/growth_report_bloc.dart';
import '../bloc/growth_report_event.dart';
import '../bloc/growth_report_state.dart';

class GrowthReportPage extends StatefulWidget {
  const GrowthReportPage({super.key});

  @override
  State<GrowthReportPage> createState() => _GrowthReportPageState();
}

class _GrowthReportPageState extends State<GrowthReportPage> {
  // ============================================================
  // COLORS
  // ============================================================

  Color get _primary => context.primaryColor;

  Color get _primaryDark => context.primaryColor;

  Color get _blue => context.appColors.secondary;

  Color get _orange => context.appColors.tertiary;

  Color get _teal => context.primaryColor;

  Color get _red => context.appColors.error;

  Color get _background => context.backgroundColor;

  Color get _card => context.cardBackgroundColor;

  Color get _border => context.borderColor;

  Color get _text => context.cardTextColor;

  Color get _secondary => context.secondaryTextColor;

  Color get _softGreen => context.primaryColor.withValues(alpha: 0.06);

  // ============================================================
  // TABLE WIDTHS
  // ============================================================

  static const double _srWidth = 42;

  static const double _dealerWidth = 220;

  static const double _amountWidth = 100;

  static const double _percentWidth = 118;

  static const double _growthWidth = 105;

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _dealerSearchController = TextEditingController();

  Timer? _dealerDebounce;

  // ============================================================
  // FILTER
  // ============================================================

  String _userId = '';

  String _selectedYears = 'Last 2 Year';

  GrowthDealerSearch? _selectedDealer;

  bool _filterExpanded = false;

  bool _initialized = false;

  final List<String> _yearOptions = const [
    'Last 2 Year',
    'Last 3 Year',
    'Last 4 Year',
    'Last 5 Year',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onGrowthScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _dealerDebounce?.cancel();

    _dealerSearchController.dispose();

    _scrollController.removeListener(_onGrowthScroll);

    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    final Map<String, dynamic>? data = await SecureStorage.instance
        .getUserData();

    if (!mounted) {
      return;
    }

    setState(() {
      _userId = data?['user_id']?.toString().trim() ?? '';
    });

    if (_userId.isNotEmpty) {
      _fetchGrowthReport();
    }
  }

  // ============================================================
  // REPORT PAGINATION
  // ============================================================

  void _onGrowthScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      context.read<GrowthReportBloc>().add(const LoadMoreGrowthReportEvent());
    }
  }

  // ============================================================
  // FETCH REPORT
  // ============================================================

  void _fetchGrowthReport() {
    if (_userId.isEmpty) {
      return;
    }

    context.read<GrowthReportBloc>().add(
      GetGrowthReportEvent(
        userId: _userId,
        years: _selectedYears,
        dealerId: _selectedDealer?.dealerId ?? '',
      ),
    );
  }

  // ============================================================
  // RESET
  // ============================================================

  void _resetFilter() {
    setState(() {
      _selectedYears = 'Last 2 Year';

      _selectedDealer = null;

      _filterExpanded = false;
    });

    context.read<GrowthReportBloc>().add(const ClearGrowthDealerSearchEvent());

    _fetchGrowthReport();
  }

  // ============================================================
  // DEALER BOTTOM SHEET
  // ============================================================

  Future<void> _openDealerSheet() async {
    debugPrint('OPEN DEALER SHEET USER ID => $_userId');

    if (_userId.isEmpty) {
      return;
    }

    _dealerSearchController.clear();

    context.read<GrowthReportBloc>().add(
      SearchGrowthDealersEvent(userId: _userId, searchText: ''),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: context.read<GrowthReportBloc>(),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Container(
                height: MediaQuery.of(context).size.height * .74,
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 8),

                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.borderColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    SizedBox(height: 10),

                    // ==========================================
                    // TITLE
                    // ==========================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _softGreen,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              Icons.storefront_outlined,
                              color: _primary,
                              size: 18,
                            ),
                          ),

                          SizedBox(width: 8),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Dealer',
                                  style: TextStyle(
                                    color: _text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Search dealer name, code or mobile',
                                  style: TextStyle(
                                    color: _secondary,
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close_rounded, color: _secondary),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8),

                    // ==========================================
                    // SEARCH
                    // ==========================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _dealerSearchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search dealer...',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _primary,
                            size: 18,
                          ),
                          suffixIcon: _dealerSearchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _dealerSearchController.clear();

                                    setSheetState(() {});

                                    context.read<GrowthReportBloc>().add(
                                      SearchGrowthDealersEvent(
                                        userId: _userId,
                                        searchText: '',
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.close_rounded, size: 17),
                                ),
                          filled: true,
                          fillColor: context.appColors.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          setSheetState(() {});

                          _dealerDebounce?.cancel();

                          _dealerDebounce = Timer(
                            const Duration(milliseconds: 500),
                            () {
                              if (!mounted) {
                                return;
                              }

                              context.read<GrowthReportBloc>().add(
                                SearchGrowthDealersEvent(
                                  userId: _userId,
                                  searchText: value.trim(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 8),

                    // ==========================================
                    // ALL DEALERS
                    // ==========================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDealer = null;
                          });

                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedDealer == null
                                ? _softGreen
                                : context.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.store_mall_directory_outlined,
                                color: _primary,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'All Dealers',
                                  style: TextStyle(
                                    color: _text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 5),

                    Divider(height: 1),

                    // ==========================================
                    // DEALER LIST
                    // ==========================================
                    Expanded(
                      child: BlocBuilder<GrowthReportBloc, GrowthReportState>(
                        builder: (context, state) {
                          if (state.dealerSearchStatus ==
                              GrowthDealerSearchStatus.loading) {
                            return Center(
                              child: CircularProgressIndicator(color: _primary),
                            );
                          }

                          if (state.dealerSearchStatus ==
                              GrowthDealerSearchStatus.failure) {
                            return Center(
                              child: Text(
                                state.dealerError,
                                style: TextStyle(color: _red),
                              ),
                            );
                          }

                          if (state.dealerSuggestions.isEmpty) {
                            return Center(child: Text('No dealers found'));
                          }

                          return NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification.metrics.pixels >=
                                      notification.metrics.maxScrollExtent -
                                          120 &&
                                  !state.dealerLoadingMore &&
                                  state.dealerHasMore) {
                                context.read<GrowthReportBloc>().add(
                                  const LoadMoreGrowthDealersEvent(),
                                );
                              }

                              return false;
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.all(8),
                              itemCount:
                                  state.dealerSuggestions.length +
                                  (state.dealerLoadingMore ? 1 : 0),
                              separatorBuilder: (context, index) =>
                                  Divider(height: 1),
                              itemBuilder: (context, index) {
                                if (index >= state.dealerSuggestions.length) {
                                  return Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: _primary,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                return _dealerSearchItem(
                                  state.dealerSuggestions[index],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: CustomAppBar(
        title: 'Dealer Growth Report',
        backgroundColor: context.primaryColor,
        titleStyle: TextStyle(color: context.onPrimaryColor),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: context.onPrimaryColor,
          ),
          onPressed: () => context.go(AppRouter.home),
        ),
        showBackButton: true,
        onBackTap: () {
          context.go(AppRouter.home);
        },
        actionIcon: Icons.refresh_rounded,
        onActionIconTap: _fetchGrowthReport,
      ),
      body: BlocBuilder<GrowthReportBloc, GrowthReportState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: _primary,
            onRefresh: () async {
              _fetchGrowthReport();
            },
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(7, 7, 7, 18),
              children: [
                _filterCard(),

                SizedBox(height: 8),

                if (state.status == GrowthReportStatus.loading &&
                    state.dealers.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 70),
                    child: Center(
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  ),

                if (state.status == GrowthReportStatus.failure)
                  _errorCard(state.errorMessage),

                if (state.status == GrowthReportStatus.success &&
                    state.dealers.isEmpty)
                  _emptyCard(),

                if (state.status == GrowthReportStatus.success &&
                    state.dealers.isNotEmpty) ...[
                  _reportHeader(state),

                  SizedBox(height: 8),

                  _growthTable(state),

                  if (state.loadingMore)
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Widget _filterCard() {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _filterExpanded = !_filterExpanded;
                });
              },
              borderRadius: BorderRadius.circular(13),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _softGreen,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: _primary,
                        size: 18,
                      ),
                    ),

                    SizedBox(width: 8),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Growth Report Filter',
                            style: TextStyle(
                              color: _text,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '${_selectedDealer?.dealerName ?? 'All Dealers'} • $_selectedYears',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: _secondary, fontSize: 7.5),
                          ),
                        ],
                      ),
                    ),

                    AnimatedRotation(
                      turns: _filterExpanded ? .5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_filterExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 0, 9, 9),
              child: Column(
                children: [
                  Divider(),

                  Row(
                    children: [
                      Expanded(child: _dealerSelector()),
                      SizedBox(width: 6),
                      Expanded(child: _yearDropdown()),
                    ],
                  ),

                  SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _filterExpanded = false;
                            });

                            _fetchGrowthReport();
                          },
                          icon: Icon(Icons.analytics_outlined, size: 15),
                          label: Text('View Growth'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: context.onPrimaryColor,
                          ),
                        ),
                      ),

                      SizedBox(width: 6),

                      OutlinedButton.icon(
                        onPressed: _resetFilter,
                        icon: Icon(Icons.restart_alt_rounded, size: 14),
                        label: Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DEALER SELECTOR
  // ============================================================

  Widget _dealerSelector() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openDealerSheet,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 58,

          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: context.appColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Icon(Icons.storefront_outlined, color: _primary, size: 16),

              SizedBox(width: 7),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dealer',
                      style: TextStyle(color: _secondary, fontSize: 8),
                    ),
                    Text(
                      _selectedDealer == null
                          ? 'All Dealers'
                          : _selectedDealer!.dealerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _text,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // Icon(Icons.keyboard_arrow_down_rounded, size: 17),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // YEAR DROPDOWN
  // ============================================================

  Widget _yearDropdown() {
    return CustomDropdown<String>(
      hintText: 'Years',
      prefixIcon: Icons.calendar_today_rounded,

      compactItems: true,

      value: _selectedYears,

      items: _yearOptions.map((year) {
        return DropdownMenuItem<String>(
          value: year,
          child: Text(
            year,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        );
      }).toList(),

      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedYears = value;
        });
      },
    );
  }

  // ============================================================
  // REPORT HEADER
  // ============================================================

  Widget _reportHeader(GrowthReportState state) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(9),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.trending_up_rounded, color: _primary),
          ),

          SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dealer Growth / De-Growth Report',
                  style: TextStyle(
                    color: _text,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Financial Year For Last: ${state.yearsSelected} Years',
                  style: TextStyle(color: _secondary, fontSize: 7),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${state.totalRows} Dealers',
              style: TextStyle(
                color: _primaryDark,
                fontSize: 7,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GROWTH TABLE
  // ============================================================

  Widget _growthTable(GrowthReportState state) {
    // Each financial year contains:
    //
    // Collection Amount
    // Collection %
    // Order Amount
    // Order %
    //
    // Growth section contains:
    //
    // Collection Growth
    // Order Growth

    final double yearWidth = (_amountWidth * 2) + (_percentWidth * 2);

    final double growthGroupWidth = _growthWidth * 2;

    final double tableWidth =
        _srWidth +
        _dealerWidth +
        (state.totals.length * yearWidth) +
        growthGroupWidth;

    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: context.primaryColor,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Dealer Growth Comparison',
                    style: TextStyle(
                      color: context.onPrimaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  _selectedYears,
                  style: TextStyle(
                    color: context.onPrimaryColor.withValues(alpha: 0.7),
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _growthMainHeader(state),

                  ...List.generate(state.dealers.length, (index) {
                    return _growthRow(state.dealers[index], index, state);
                  }),

                  _growthTotalRow(state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _growthMainHeader(GrowthReportState state) {
    final double yearWidth = (_amountWidth * 2) + (_percentWidth * 2);

    return Column(
      children: [
        // ======================================================
        // MAIN YEAR HEADER
        // ======================================================
        Container(
          height: 32,
          color: context.appColors.surfaceContainerHighest,
          child: Row(
            children: [
              _headerCell('Sr.No.', _srWidth, center: true),

              _headerCell('Dealer Name', _dealerWidth),

              ...List.generate(state.totals.length, (index) {
                final year = state.totals[index];

                return Container(
                  width: yearWidth,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? context.appColors.secondary.withValues(alpha: 0.08)
                        : context.appColors.tertiary.withValues(alpha: 0.08),
                    border: Border(right: BorderSide(color: _border)),
                  ),
                  child: Text(
                    year.yearLabel,
                    style: TextStyle(
                      color: _text,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              }),

              Container(
                width: _growthWidth * 2,
                alignment: Alignment.center,
                color: context.primaryColor.withValues(alpha: 0.08),
                child: Text(
                  'Growth/D',
                  style: TextStyle(
                    color: _primaryDark,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // SUB HEADER
        // ======================================================
        Container(
          height: 34,
          color: context.cardBackgroundColor,
          child: Row(
            children: [
              SizedBox(width: _srWidth),

              SizedBox(width: _dealerWidth),

              ...List.generate(state.totals.length, (index) {
                return Row(
                  children: [
                    _headerCell('Total Collection', _amountWidth, center: true),

                    _headerCell(
                      'Collection Proportional %',
                      _percentWidth,
                      center: true,
                    ),

                    _headerCell('Order Amount', _amountWidth, center: true),

                    _headerCell(
                      'Order Proportional %',
                      _percentWidth,
                      center: true,
                    ),
                  ],
                );
              }),

              _headerCell(
                'Collection Growth',
                _growthWidth,
                center: true,
                green: true,
              ),

              _headerCell(
                'Order Growth',
                _growthWidth,
                center: true,
                green: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TABLE DATA ROW
  // ============================================================

  Widget _growthRow(GrowthDealer dealer, int index, GrowthReportState state) {
    final Map<String, GrowthYearData> yearMap = {
      for (final item in dealer.years) item.year: item,
    };

    final GrowthYearData? latest = dealer.years.isEmpty
        ? null
        : dealer.years.last;

    return Container(
      height: 52,
      color: index.isEven
          ? context.cardBackgroundColor
          : context.appColors.surfaceContainerHighest,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _bodyCell('${index + 1}', _srWidth, center: true),

          // ====================================================
          // DEALER
          // ====================================================
          Container(
            width: _dealerWidth,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: _border)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dealer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _text,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    if (dealer.mobile.isNotEmpty)
                      Text(
                        ' (${dealer.mobile})',
                        style: TextStyle(
                          color: _text,
                          fontSize: 7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 2),

                Text(
                  _dealerMeta(dealer),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _secondary, fontSize: 6.5),
                ),
              ],
            ),
          ),

          // ====================================================
          // YEAR DATA
          // ====================================================
          ...List.generate(state.totals.length, (yearIndex) {
            final String yearKey = state.totals[yearIndex].year;

            final GrowthYearData? data = yearMap[yearKey];

            return Row(
              children: [
                // COLLECTION AMOUNT
                _amountCell(data?.collectionAmount ?? 0, _amountWidth, _teal),

                // COLLECTION %
                _percentageCell(
                  data?.collectionProportionalPercent ?? 0,
                  _percentWidth,
                  color: _teal,
                ),

                // ORDER AMOUNT
                _amountCell(data?.orderAmount ?? 0, _amountWidth, _orange),

                // ORDER %
                _percentageCell(
                  data?.orderProportionalPercent ?? 0,
                  _percentWidth,
                  color: _blue,
                ),
              ],
            );
          }),

          // ====================================================
          // COLLECTION GROWTH
          // ====================================================
          _growthCell(latest?.collectionGrowthPercent ?? 'NA'),

          // ====================================================
          // ORDER GROWTH
          // ====================================================
          _growthCell(latest?.orderGrowthPercent ?? 'NA'),
        ],
      ),
    );
  }

  // ============================================================
  // TOTAL ROW
  // ============================================================

  Widget _growthTotalRow(GrowthReportState state) {
    final GrowthYearData? latest = state.totals.isEmpty
        ? null
        : state.totals.last;

    return Container(
      height: 42,
      color: context.appColors.secondary.withValues(alpha: 0.08),
      child: Row(
        children: [
          SizedBox(width: _srWidth),

          Container(
            width: _dealerWidth,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: _border)),
            ),
            child: Text(
              'Total',
              style: TextStyle(
                color: _text,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          ...List.generate(state.totals.length, (index) {
            final total = state.totals[index];

            return Row(
              children: [
                // TOTAL COLLECTION
                _amountCell(
                  total.collectionAmount,
                  _amountWidth,
                  _teal,
                  bold: true,
                ),

                // TOTAL COLLECTION %
                _percentageCell(
                  total.collectionProportionalPercent,
                  _percentWidth,
                  bold: true,
                  color: _teal,
                ),

                // TOTAL ORDER
                _amountCell(
                  total.orderAmount,
                  _amountWidth,
                  _orange,
                  bold: true,
                ),

                // TOTAL ORDER %
                _percentageCell(
                  total.orderProportionalPercent,
                  _percentWidth,
                  bold: true,
                  color: _blue,
                ),
              ],
            );
          }),

          _growthCell(latest?.collectionGrowthPercent ?? 'NA', bold: true),

          _growthCell(latest?.orderGrowthPercent ?? 'NA', bold: true),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER CELL
  // ============================================================

  Widget _headerCell(
    String value,
    double width, {
    bool center = false,
    bool green = false,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: center ? Alignment.center : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: green ? context.primaryColor.withValues(alpha: 0.08) : null,
        border: Border(right: BorderSide(color: _border)),
      ),
      child: Text(
        value,
        textAlign: center ? TextAlign.center : TextAlign.left,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _text,
          fontSize: 7,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // BODY CELL
  // ============================================================

  Widget _bodyCell(String value, double width, {bool center = false}) {
    return Container(
      width: width,
      alignment: center ? Alignment.center : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: _border)),
      ),
      child: Text(value, style: TextStyle(color: _text, fontSize: 7.5)),
    );
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  Widget _amountCell(
    double amount,
    double width,
    Color color, {
    bool bold = false,
  }) {
    return Container(
      width: width,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: _border)),
      ),
      child: Text(
        _money(amount),
        style: TextStyle(
          color: amount > 0 ? color : _secondary,
          fontSize: 7.5,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // PERCENTAGE
  // ============================================================

  Widget _percentageCell(
    double value,
    double width, {
    bool bold = false,
    Color? color,
  }) {
    return Container(
      width: width,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: _border)),
      ),
      child: Text(
        '${value.toStringAsFixed(2)}%',
        style: TextStyle(
          color: value > 0 ? (color ?? _blue) : _secondary,
          fontSize: 7.2,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // GROWTH CELL
  // ============================================================

  Widget _growthCell(String value, {bool bold = false}) {
    final String clean = value.trim();

    final bool isNA = clean.toUpperCase() == 'NA';

    final double? number = double.tryParse(clean);

    final bool positive = number != null && number > 0;

    final bool negative = number != null && number < 0;

    final Color color = isNA
        ? _secondary
        : positive
        ? _primary
        : negative
        ? _red
        : _primaryDark;

    return Container(
      width: _growthWidth,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      color: context.primaryColor.withValues(alpha: 0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            positive
                ? Icons.trending_up_rounded
                : negative
                ? Icons.trending_down_rounded
                : Icons.remove_rounded,
            size: 10,
            color: color,
          ),

          SizedBox(width: 2),

          Text(
            isNA ? 'NA' : '$clean%',
            style: TextStyle(
              color: color,
              fontSize: 7.5,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DEALER SEARCH ROW
  // ============================================================

  Widget _dealerSearchItem(GrowthDealerSearch dealer) {
    final bool selected = _selectedDealer?.dealerId == dealer.dealerId;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDealer = dealer;
        });

        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _softGreen,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(Icons.storefront_outlined, color: _primary, size: 17),
            ),

            SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dealer.dealerName,
                    style: TextStyle(
                      color: _text,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    [
                      if (dealer.personName.isNotEmpty) dealer.personName,
                      if (dealer.personMobile.isNotEmpty) dealer.personMobile,
                      if (dealer.districtName.isNotEmpty) dealer.districtName,
                    ].join(' • '),
                    style: TextStyle(color: _secondary, fontSize: 6.7),
                  ),
                ],
              ),
            ),

            if (selected) Icon(Icons.check_circle_rounded, color: _primary),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DEALER META
  // ============================================================

  String _dealerMeta(GrowthDealer dealer) {
    final List<String> values = [];

    if (dealer.taluka.isNotEmpty) {
      values.add(dealer.taluka);
    }

    if (dealer.district.isNotEmpty) {
      values.add(dealer.district);
    }

    if (dealer.state.isNotEmpty) {
      values.add(dealer.state);
    }

    return values.join(', ');
  }

  // ============================================================
  // MONEY
  // ============================================================

  String _money(double value) {
    return value.toStringAsFixed(2);
  }

  // ============================================================
  // DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: _border),
      boxShadow: [
        BoxShadow(
          color: context.appColors.shadow.withValues(alpha: .02),
          blurRadius: 7,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorCard(String value) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: _red),
          SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Column(
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            color: context.secondaryTextColor,
            size: 34,
          ),
          SizedBox(height: 7),
          Text(
            'No Growth Data Found',
            style: TextStyle(
              color: _text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
