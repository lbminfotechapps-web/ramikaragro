import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:intl/intl.dart';
import 'package:solufine/core/theme/app_colors.dart';

// ============================================================================
// VISIT OVERVIEW CARD
// ============================================================================

class VisitOverviewCard extends StatelessWidget {
  final VoidCallback? onViewReport;
  final String dealerCount;
  final String farmerCount;

  const VisitOverviewCard({
    super.key,
    this.onViewReport,
    required this.dealerCount,
    required this.farmerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        14.h,
        16.w,
        14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.visitGraphColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ==================================================================
          // HEADER
          // ==================================================================

          Row(
            children: [
              Expanded(
                child: Text(
                  'Visit Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              GestureDetector(
                onTap: onViewReport,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(width: 8.w),

                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ==================================================================
          // LEGEND
          // ==================================================================

          Row(
            children: [
              const _LegendItem(
                color: Color(0xFF22E66B),
                label: 'Dealer Visit',
              ),

              SizedBox(width: 32.w),

              const _LegendItem(
                color: Color(0xFF4285F4),
                label: 'Farmer Visit',
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ==================================================================
          // GRAPH + STAT CARDS
          // ==================================================================

          LayoutBuilder(
            builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              final double contentHeight = 136.h;

              final double statsWidth = math.min(
                math.max(
                  constraints.maxWidth * 0.25,
                  105.w,
                ),
                130.w,
              );

              return SizedBox(
                height: contentHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==========================================================
                    // GRAPH
                    // ==========================================================

                    Expanded(
                      child: _VisitLineChart(
                        dealerCount:
                            int.tryParse(dealerCount) ?? 0,
                        farmerCount:
                            int.tryParse(farmerCount) ?? 0,
                      ),
                    ),

                    SizedBox(width: 25.w),

                    // ==========================================================
                    // COUNT CARDS
                    // ==========================================================

                    SizedBox(
                      width: statsWidth,
                      child: Column(
                        children: [
                          Expanded(
                            child: _VisitStatCard(
                              title: 'Dealer Visit',
                              value: dealerCount,
                              color: const Color(
                                0xFF087C43,
                              ),
                            ),
                          ),

                          SizedBox(height: 6.h),

                          Expanded(
                            child: _VisitStatCard(
                              title: 'Farmer Visit',
                              value: farmerCount,
                              color: const Color(
                                0xFF075E8A,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LEGEND
// ============================================================================

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7.w,
          height: 7.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        SizedBox(width: 5.w),

        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// VISIT LINE CHART
// ============================================================================

class _VisitLineChart extends StatelessWidget {
  final int dealerCount;
  final int farmerCount;

  const _VisitLineChart({
    required this.dealerCount,
    required this.farmerCount,
  });

  @override
  Widget build(BuildContext context) {
    // ========================================================================
    // DYNAMIC X AXIS
    //
    // Automatically create last 6 days including today.
    //
    // Example if today = 22 Sep:
    //
    // 17 Sep
    // 18 Sep
    // 19 Sep
    // 20 Sep
    // 21 Sep
    // 22 Sep
    // ========================================================================

    final DateTime today = DateTime.now();

    final List<DateTime> dates = List.generate(
      6,
      (int index) {
        return today.subtract(
          Duration(
            days: 5 - index,
          ),
        );
      },
    );

    // ========================================================================
    // FIND MAXIMUM API COUNT
    // ========================================================================

    final int maxCount = math.max(
      dealerCount,
      farmerCount,
    );

    // ========================================================================
    // DYNAMIC Y AXIS INTERVAL
    // ========================================================================

    final double yInterval = _calculateYInterval(
      maxCount,
    );

    // ========================================================================
    // DYNAMIC MAX Y
    // ========================================================================

    final double maxY = _calculateMaxY(
      maxCount,
      yInterval,
    );

    return LineChart(
      LineChartData(
        // ====================================================================
        // AXIS LIMITS
        // ====================================================================

        minX: 0,
        maxX: 5,

        minY: 0,
        maxY: maxY,

        // ====================================================================
        // BORDER
        // ====================================================================

        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(
              color: Colors.white.withOpacity(0.45),
              width: 1,
            ),
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.45),
              width: 1,
            ),
          ),
        ),

        // ====================================================================
        // GRID
        // ====================================================================

        gridData: FlGridData(
          show: true,

          drawHorizontalLine: true,
          drawVerticalLine: true,

          // Dynamic Y interval
          horizontalInterval: yInterval,

          // One grid for every date
          verticalInterval: 1,

          getDrawingHorizontalLine: (
            double value,
          ) {
            return FlLine(
              color: Colors.white.withOpacity(0.20),
              strokeWidth: 1,
            );
          },

          getDrawingVerticalLine: (
            double value,
          ) {
            return FlLine(
              color: Colors.white.withOpacity(0.16),
              strokeWidth: 1,
            );
          },
        ),

        // ====================================================================
        // AXIS TITLES
        // ====================================================================

        titlesData: FlTitlesData(
          // ==================================================================
          // TOP AXIS
          // ==================================================================

          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),

          // ==================================================================
          // RIGHT AXIS
          // ==================================================================

          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),

          // ==================================================================
          // Y AXIS
          // DYNAMIC
          // ==================================================================

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,

              reservedSize: 35.w,

              // IMPORTANT:
              // No static interval.
              // Calculated according to API counts.
              interval: yInterval,

              getTitlesWidget: (
                double value,
                TitleMeta meta,
              ) {
                if (value < 0 || value > maxY) {
                  return const SizedBox.shrink();
                }

                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _formatYAxisValue(value),
                    style: TextStyle(
                      color:
                          Colors.white.withOpacity(0.65),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),

          // ==================================================================
          // X AXIS
          // DYNAMIC DATE
          // ==================================================================

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,

              interval: 1,

              reservedSize: 35.h,

              getTitlesWidget: (
                double value,
                TitleMeta meta,
              ) {
                final int index = value.round();

                // Check valid index
                if (index < 0 ||
                    index >= dates.length) {
                  return const SizedBox.shrink();
                }

                // Prevent decimal positions such as:
                // 0.5, 1.5, 2.5...
                if ((value - index).abs() > 0.01) {
                  return const SizedBox.shrink();
                }

                final DateTime date = dates[index];

                return SideTitleWidget(
                  meta: meta,
                  space: 8.h,
                  child: Text(
                    DateFormat(
                      'dd MMM',
                    ).format(date),
                    style: TextStyle(
                      color:
                          Colors.white.withOpacity(0.65),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // ====================================================================
        // TOUCH / TOOLTIP
        // ====================================================================

        lineTouchData: LineTouchData(
          enabled: true,

          handleBuiltInTouches: true,

          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (
              List<LineBarSpot> touchedSpots,
            ) {
              return touchedSpots.map(
                (LineBarSpot spot) {
                  final bool isDealer =
                      spot.barIndex == 0;

                  return LineTooltipItem(
                    '${isDealer ? 'Dealer' : 'Farmer'}\n'
                    '${spot.y.toInt()}',
                    TextStyle(
                      color: isDealer
                          ? const Color(0xFF22E66B)
                          : const Color(0xFF4285F4),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ).toList();
            },
          ),
        ),

        // ====================================================================
        // LINE DATA
        // ====================================================================

        lineBarsData: [
          // ==================================================================
          // DEALER LINE
          // ==================================================================

          LineChartBarData(
            spots: [
              const FlSpot(
                0,
                0,
              ),

              FlSpot(
                5,
                dealerCount.toDouble(),
              ),
            ],

            isCurved: true,

            curveSmoothness: 0.25,

            color: const Color(
              0xFF22E66B,
            ),

            barWidth: 3,

            isStrokeCapRound: true,

            preventCurveOverShooting: true,

            // ================================================================
            // DEALER DOTS
            // ================================================================

            dotData: FlDotData(
              show: true,

              getDotPainter: (
                FlSpot spot,
                double percent,
                LineChartBarData barData,
                int index,
              ) {
                return FlDotCirclePainter(
                  radius: 5,

                  color: const Color(
                    0xFF003D29,
                  ),

                  strokeWidth: 3,

                  strokeColor: const Color(
                    0xFF22E66B,
                  ),
                );
              },
            ),

            belowBarData: BarAreaData(
              show: false,
            ),
          ),

          // ==================================================================
          // FARMER LINE
          // ==================================================================

          LineChartBarData(
            spots: [
              const FlSpot(
                0,
                0,
              ),

              FlSpot(
                5,
                farmerCount.toDouble(),
              ),
            ],

            isCurved: true,

            curveSmoothness: 0.25,

            color: const Color(
              0xFF4285F4,
            ),

            barWidth: 3,

            isStrokeCapRound: true,

            preventCurveOverShooting: true,

            // ================================================================
            // FARMER DOTS
            // ================================================================

            dotData: FlDotData(
              show: true,

              getDotPainter: (
                FlSpot spot,
                double percent,
                LineChartBarData barData,
                int index,
              ) {
                return FlDotCirclePainter(
                  radius: 5,

                  color: const Color(
                    0xFF003D29,
                  ),

                  strokeWidth: 3,

                  strokeColor: const Color(
                    0xFF4285F4,
                  ),
                );
              },
            ),

            belowBarData: BarAreaData(
              show: false,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // DYNAMIC Y AXIS INTERVAL
  // ==========================================================================

  double _calculateYInterval(int maxCount) {
    // No data
    if (maxCount <= 0) {
      return 2;
    }

    // 0 - 5
    if (maxCount <= 5) {
      return 1;
    }

    // 0 - 10
    if (maxCount <= 10) {
      return 2;
    }

    // 0 - 25
    if (maxCount <= 25) {
      return 5;
    }

    // 0 - 50
    if (maxCount <= 50) {
      return 10;
    }

    // 0 - 100
    if (maxCount <= 100) {
      return 20;
    }

    // 0 - 250
    if (maxCount <= 250) {
      return 50;
    }

    // 0 - 500
    if (maxCount <= 500) {
      return 100;
    }

    // 0 - 1000
    if (maxCount <= 1000) {
      return 200;
    }

    // 0 - 2500
    if (maxCount <= 2500) {
      return 500;
    }

    // 0 - 5000
    if (maxCount <= 5000) {
      return 1000;
    }

    // For very large values
    return _niceNumber(
      maxCount / 5,
    );
  }

  // ==========================================================================
  // CALCULATE MAX Y
  // ==========================================================================

  double _calculateMaxY(
    int maxCount,
    double interval,
  ) {
    if (maxCount <= 0) {
      return 10;
    }

    // Round highest count to next interval
    final double roundedMax =
        (maxCount / interval).ceil() * interval;

    // Add some space above highest point
    return roundedMax + interval;
  }

  // ==========================================================================
  // NICE NUMBER FOR LARGE VALUES
  // ==========================================================================

  double _niceNumber(double value) {
    if (value <= 0) {
      return 1;
    }

    final double exponent = math.pow(
      10,
      (math.log(value) / math.ln10).floor(),
    ).toDouble();

    final double fraction = value / exponent;

    double niceFraction;

    if (fraction <= 1) {
      niceFraction = 1;
    } else if (fraction <= 2) {
      niceFraction = 2;
    } else if (fraction <= 5) {
      niceFraction = 5;
    } else {
      niceFraction = 10;
    }

    return niceFraction * exponent;
  }

  // ==========================================================================
  // FORMAT Y AXIS VALUE
  // ==========================================================================

  String _formatYAxisValue(double value) {
    // 1,000,000 -> 1M
    if (value >= 1000000) {
      final double result = value / 1000000;

      if (result == result.roundToDouble()) {
        return '${result.toInt()}M';
      }

      return '${result.toStringAsFixed(1)}M';
    }

    // 1000 -> 1K
    if (value >= 1000) {
      final double result = value / 1000;

      if (result == result.roundToDouble()) {
        return '${result.toInt()}K';
      }

      return '${result.toStringAsFixed(1)}K';
    }

    return value.toInt().toString();
  }
}

// ============================================================================
// VISIT STAT CARD
// ============================================================================

class _VisitStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _VisitStatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          12.r,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                0.08,
              ),
              borderRadius: BorderRadius.circular(
                8.r,
              ),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}