import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/features/home/doman/home_entity/homevisit_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class NotVisitedCard extends StatelessWidget {
  final HomeVisitEntity? homeData;
  const NotVisitedCard(this.homeData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w,),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: context.appBorder),
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
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: context.appPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.location_off_outlined,
                  size: 20.sp,
                  color: context.appPrimary,
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
                      color: context.appOnCard,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'In Last 30 Days',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.appSubText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Statistics
          Row(
            children: [
              Expanded(
                child: _statItem(context,
                  icon: Icons.storefront_outlined,
                  title: 'Dealers',
                  value: homeData!.lastThirNotVisitDealer,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: _statItem(context,
                  icon: Icons.agriculture_outlined,
                  title: 'Farmers',
                  value: homeData!.lastThirNotVisitFarmer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.appInputBackground,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: context.appPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: context.appPrimary),
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
                    color: context.appSubText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: context.appPrimary,
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
