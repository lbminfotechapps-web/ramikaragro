import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/features/home/doman/home_entity/homevisit_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class VisitStatisticsTable extends StatelessWidget {
  final HomeVisitEntity homeData;

  const VisitStatisticsTable(this.homeData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              color: context.appPrimary,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Visited',
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            color: context.appOnPrimary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        if (homeData.currentMonth.trim().isNotEmpty)
                          Text(
                            homeData.currentMonth,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              color: context.appOnPrimary.withValues(alpha: 0.7),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(child: _headerText(context, 'Today')),
                  Expanded(child: _headerText(context, 'Month All')),
                  Expanded(child: _headerText(context, 'Month Unique')),
                ],
              ),
            ),

            // Dealer
            _visitRow(context,
              title: 'Dealer Visits',
              today: homeData.todayDealerCnt,
              monthAll: homeData.monthlyDealerCnt,
              monthUnique: homeData.monthlyUniqueDealerCnt,
              showDivider: true,
            ),

            // Farmer
            _visitRow(context,
              title: 'Farmer Visits',
              today: homeData.todayFarmerCnt,
              monthAll: homeData.monthlyFarmerCnt,
              monthUnique: homeData.monthlyUniqueFarmerCnt,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerText(BuildContext context, String text) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.appOnPrimary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _visitRow(BuildContext context, {
    required String title,
    required String today,
    required String monthAll,
    required String monthUnique,
    required bool showDivider,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: context.appCard,
        border: showDivider
            ? Border(bottom: BorderSide(color: context.appBorder))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: context.appOnCard,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: _numberText(context, today)),
          Expanded(child: _numberText(context, monthAll)),
          Expanded(child: _numberText(context, monthUnique)),
        ],
      ),
    );
  }

  Widget _numberText(BuildContext context, String value) {
    return Center(
      child: Text(
        value.isEmpty ? '0' : value,
        style: TextStyle(
          color: context.appPrimary,
          fontSize: 15.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
