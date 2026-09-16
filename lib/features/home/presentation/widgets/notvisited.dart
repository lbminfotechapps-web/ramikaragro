import 'package:demo/features/home/doman/home_entity/homevisit_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class NotVisitedCard extends StatelessWidget {
  final HomeVisitEntity homeData;
  const NotVisitedCard(this.homeData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE8F0EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.location_off_outlined,
                  size: 20.sp,
                  color: const Color(0xFF40916C),
                ),
              ),

              SizedBox(width: 10.w),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Not Visited',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF263238),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'In Last 30 Days',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Statistics
          Row(
            children: [
              Expanded(
                child: _statItem(
                  icon: Icons.storefront_outlined,
                  title: 'Dealers',
                  value: homeData.todayDealerCnt,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: _statItem(
                  icon: Icons.agriculture_outlined,
                  title: 'Farmers',
                  value: homeData.todayFarmerCnt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF9),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: const Color(0xFF40916C)),
          ),

          SizedBox(width: 9.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2D6A4F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
