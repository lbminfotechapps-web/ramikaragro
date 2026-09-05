import 'dart:math' as math;

import 'package:demo/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class VisitOverviewCard extends StatelessWidget {
  final VoidCallback? onViewReport;

  const VisitOverviewCard({super.key, this.onViewReport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.visitGraphColor,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header
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
                child: const Row(
                  children: [
                    Text(
                      'View Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Legend
          const Row(
            children: [
              _LegendItem(color: Color(0xFF22E66B), label: 'Dealer Visit'),
              SizedBox(width: 32),
              _LegendItem(color: Color(0xFF4285F4), label: 'Farmer Visit'),
            ],
          ),

          SizedBox(height: 10.h),

        
          LayoutBuilder(
            builder: (context, constraints) {
              final contentHeight = 136.h;
              final statsWidth = math.min(
                math.max(constraints.maxWidth * 0.25, 105.w),
                130.w,
              );

              return SizedBox(
                height: contentHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _VisitLineChart()),
                    SizedBox(width: 25.w),
                    SizedBox(
                      width: statsWidth,
                      child: Column(
                        children: [
                          Expanded(
                            child: _VisitStatCard(
                              title: 'Dealer Visit',
                              value: '32',
                              color: const Color(0xFF087C43),
                            ),
                          ),

                          SizedBox(height: 6.h),

                          Expanded(
                            child: _VisitStatCard(
                              title: 'Farmer Visit',
                              value: '28',
                              color: const Color(0xFF075E8A),
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7.w,
          height: 7.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

class _VisitLineChart extends StatelessWidget {
  const _VisitLineChart();

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 1.5,

        minX: 0,
        maxX: 5,

        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.white.withOpacity(0.45)),
            bottom: BorderSide(color: Colors.white.withOpacity(0.45)),
          ),
        ),

        gridData: FlGridData(
          show: true,
          horizontalInterval: 0.5,
          verticalInterval: 1,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.white.withOpacity(0.2), strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.16),
              strokeWidth: 1,
            );
          },
        ),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 0.5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(value == 0 ? 0 : 1),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 11,
                  ),
                );
              },
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                const dates = [
                  '15 Aug',
                  '16 Aug',
                  '17 Aug',
                  '18 Aug',
                  '19 Aug',
                  '20 Aug',
                ];

                if (value < 0 || value >= dates.length) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    dates[value.toInt()],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  spot.y.toString(),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),

        lineBarsData: [
          // Dealer
          LineChartBarData(
            spots: const [
              FlSpot(0, 0.95),
              FlSpot(1, 1.02),
              FlSpot(2, 0.90),
              FlSpot(3, 1.20),
              FlSpot(4, 0.72),
              FlSpot(5, 1.00),
            ],
            isCurved: true,
            curveSmoothness: 0.25,
            color: const Color(0xFF22E66B),
            barWidth: 3,
            isStrokeCapRound: true,

            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: const Color(0xFF003D29),
                  strokeWidth: 3,
                  strokeColor: const Color(0xFF22E66B),
                );
              },
            ),

            belowBarData: BarAreaData(show: false),
          ),

          // Farmer
          LineChartBarData(
            spots: const [
              FlSpot(0, 0.58),
              FlSpot(1, 0.53),
              FlSpot(2, 0.58),
              FlSpot(3, 0.82),
              FlSpot(4, 0.40),
              FlSpot(5, 0.72),
            ],
            isCurved: true,
            curveSmoothness: 0.25,
            color: const Color(0xFF4285F4),
            barWidth: 3,
            isStrokeCapRound: true,

            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: const Color(0xFF003D29),
                  strokeWidth: 3,
                  strokeColor: const Color(0xFF4285F4),
                );
              },
            ),

            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
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
            height: 28.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
