import 'package:demo/core/di/collection_target_di.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/features/collection/domain/entities/target_date_entity.dart';
import 'package:demo/features/collection/presentation/bloc/dealer_target_bloc.dart';
import 'package:demo/features/collection/presentation/bloc/dealer_target_event.dart';
import 'package:demo/features/collection/presentation/bloc/dealer_target_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DealerWiseTargetPage extends StatefulWidget {
  const DealerWiseTargetPage({
    super.key,
  });

  @override
  State<DealerWiseTargetPage> createState() =>
      _DealerWiseTargetPageState();
}

class _DealerWiseTargetPageState
    extends State<DealerWiseTargetPage> {
  late final DealerTargetBloc bloc;

  String userId = '';

  static const Color primaryGreen = Color(0xff0F8A4B);
  static const Color darkGreen = Color(0xff08713D);
  static const Color background = Color(0xffF5F7F9);
  static const Color pendingColor = Color(0xffF2B93B);
  static const Color achievedColor = Color(0xff75B943);

  @override
  void initState() {
    super.initState();

    bloc = sl<DealerTargetBloc>();

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final userData =
          await SecureStorage.instance.getUserData();

      userId =
          userData?['user_id']?.toString() ?? '';

      debugPrint(
        'TARGET SCREEN USER ID: $userId',
      );

      if (userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'User ID not found',
              ),
            ),
          );
        }

        return;
      }

      bloc.add(
        LoadTargetDatesEvent(
          userId: userId,
        ),
      );
    } catch (e) {
      debugPrint(
        'USER ID ERROR: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to load user information',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: background,
         
           appBar: CustomAppBar(
            backgroundColor: AppColors.backgroundColor,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 19,
                color: AppColors.darkBackgroundColor,
              ),
              onPressed: () {
                context.go(AppRouter.home);
              },
            ),
            title: 'Collection Wise Target And Achievement',
           
          ),


        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),

              Expanded(
                child: BlocBuilder<
                    DealerTargetBloc,
                    DealerTargetState>(
                  builder: (context, state) {
                    if (state.datesStatus ==
                        TargetDatesStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: primaryGreen,
                        ),
                      );
                    }

                    if (state.datesStatus ==
                        TargetDatesStatus.failure) {
                      return _buildMessage(
                        state.message ??
                            'Unable to load target dates',
                      );
                    }

                    if (state.targetDates.isEmpty) {
                      return _buildMessage(
                        'No target dates found',
                      );
                    }

                    return RefreshIndicator(
                      color: primaryGreen,
                      onRefresh: () async {
                        if (userId.isEmpty) {
                          return;
                        }

                        bloc.add(
                          LoadTargetDatesEvent(
                            userId: userId,
                          ),
                        );

                        await bloc.stream.firstWhere(
                          (state) =>
                              state.datesStatus !=
                              TargetDatesStatus.loading,
                        );
                      },
                      child: ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          14,
                          12,
                          14,
                          24,
                        ),
                        children: [
                          _buildMonthDropdown(state),

                          const SizedBox(height: 12),

                          _buildTargetContent(state),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        18,
      ),
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Achievement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Collection performance overview',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MONTH DROPDOWN
  // =========================================================

  Widget _buildMonthDropdown(
    DealerTargetState state,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: primaryGreen,
              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TargetDateEntity>(
                value: state.selectedDate,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black54,
                ),
                hint: const Text(
                  'Select Month',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                items: state.targetDates
                    .map(
                      (date) =>
                          DropdownMenuItem<
                              TargetDateEntity>(
                        value: date,
                        child: Text(
                          date.monthName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  bloc.add(
                    SelectTargetDateEvent(
                      selectedDate: value,
                      userId: userId,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TARGET CONTENT
  // =========================================================

  Widget _buildTargetContent(
    DealerTargetState state,
  ) {
    if (state.targetStatus ==
        CollectionTargetStatus.loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(
            color: primaryGreen,
          ),
        ),
      );
    }

    if (state.targetStatus ==
        CollectionTargetStatus.failure) {
      return _buildMessage(
        state.message ?? 'No record found',
      );
    }

    final target = state.target;

    if (target == null) {
      return _buildMessage(
        'No record found',
      );
    }

    return Column(
      children: [
        _buildSummaryCards(target),

        const SizedBox(height: 12),

        _buildChartCard(target),
      ],
    );
  }

  // =========================================================
  // SUMMARY CARDS
  // =========================================================

  Widget _buildSummaryCards(
    dynamic target,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Target',
                value: target.totalTarget,
                icon: Icons.flag_outlined,
                color: const Color(0xff4776E6),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildStatCard(
                title: 'Achieved',
                value: target.totalAchieved,
                icon: Icons.check_circle_outline,
                color: achievedColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Pending',
                value: target.totalPending,
                icon: Icons.pending_actions_outlined,
                color: pendingColor,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _buildStatCard(
                title: 'Achievement',
                value: '${target.percentage}%',
                icon: Icons.percent_rounded,
                color: primaryGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // STAT CARD
  // =========================================================

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.11),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xff202124),
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CHART CARD
  // =========================================================

  Widget _buildChartCard(
    dynamic target,
  ) {
    final double total =
        double.tryParse(
              target.totalTarget.toString(),
            ) ??
            0;

    final double achieved =
        double.tryParse(
              target.totalAchieved.toString(),
            ) ??
            0;

    double achievedPercent = 0;

    if (total > 0) {
      achievedPercent =
          (achieved / total) * 100;
    }

    achievedPercent =
        achievedPercent.clamp(0, 100);

    final double pendingPercent =
        100 - achievedPercent;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // TITLE
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color:
                      primaryGreen.withOpacity(0.10),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.donut_large_outlined,
                  color: primaryGreen,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievement Overview',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff202124),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Target vs collection',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // CHART
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 56,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sections: [
                      if (pendingPercent > 0)
                        PieChartSectionData(
                          value: pendingPercent,
                          title: '',
                          radius: 72,
                          color: pendingColor,
                          showTitle: false,
                        ),

                      if (achievedPercent > 0)
                        PieChartSectionData(
                          value: achievedPercent,
                          title: '',
                          radius: 72,
                          color: achievedColor,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),

                // CENTER VALUE
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                     // '${achievedPercent.toStringAsFixed(0)}%',
                    
                      '${achievedPercent.toStringAsFixed(2)}%',

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff202124),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Achieved',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // LEGEND
          Row(
            children: [
              Expanded(
                child: _buildLegendItem(
                  color: achievedColor,
                  title: 'Collection',
                  value:
                      '${achievedPercent.toStringAsFixed(0)}%',
                ),
              ),

              Expanded(
                child: _buildLegendItem(
                  color: pendingColor,
                  title: 'Pending Target',
                  value:
                      '${pendingPercent.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // LEGEND ITEM
  // =========================================================

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 9,
          width: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Flexible(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff333333),
                ),
              ),

              Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  Widget _buildMessage(
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color:
                    primaryGreen.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 34,
                color: primaryGreen,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
