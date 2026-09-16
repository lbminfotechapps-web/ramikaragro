import 'package:demo/features/home/doman/home_entity/homevisit_entity.dart';
import 'package:demo/features/home/presentation/home_bloc/home_visit_state.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              color: const Color(0xFF1B4332),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Visited',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(child: _headerText('Today')),
                  Expanded(child: _headerText('Month All')),
                  Expanded(child: _headerText('Month Unique')),
                ],
              ),
            ),

            // Dealer
            _visitRow(
              title: 'Dealer Visits',
              today: homeData.todayDealerCnt,
              monthAll: homeData.monthlyDealerCnt,
              monthUnique: homeData.monthlyUniqueDealerCnt,
              showDivider: true,
            ),

            // Farmer
            _visitRow(
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

  Widget _headerText(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _visitRow({
    required String title,
    required String today,
    required String monthAll,
    required String monthUnique,
    required bool showDivider,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFF1F2937),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: _numberText(today)),
          Expanded(child: _numberText(monthAll)),
          Expanded(child: _numberText(monthUnique)),
        ],
      ),
    );
  }

  Widget _numberText(String value) {
    return Center(
      child: Text(
        value.isEmpty ? '0' : value,
        style: TextStyle(
          color: const Color(0xFF1B4332),
          fontSize: 15.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
