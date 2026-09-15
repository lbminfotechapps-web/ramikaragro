import 'package:demo/features/distpatchistory/domain/entities/dispatch_order_detail_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class DispatchDetailCard extends StatelessWidget {
  final DispatchOrderDetailEntity detail;

  const DispatchDetailCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  detail.productName.isEmpty ? '-' : detail.productName,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(height: 5.h),

                // Quantity
                _detailRow(title: 'Quantity', value: detail.productQty),

                // Dispatch Quantity
                _detailRow(
                  title: 'Dispatch Quantity',
                  value: detail.actualDispatchQty,
                ),

                // Remaining Quantity
                _detailRow(
                  title: 'Remaining Quantity',
                  value: detail.remainingDispatchQty,
                ),

                // Remark
                _detailRow(title: 'Remark', value: detail.remark),
              ],
            ),
          ),

          // Divider
          Container(
            width: double.infinity,
            height: 1.h,
            margin: EdgeInsets.only(top: 5.h),
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _detailRow({required String title, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Expanded(
            flex: 50,
            child: Text(
              title,
              style: TextStyle(fontSize: 13.sp, color: Colors.black),
            ),
          ),

          // :
          SizedBox(
            width: 15.w,
            child: Text(
              ':',
              style: TextStyle(fontSize: 15.sp, color: Colors.black),
            ),
          ),

          // Value
          Expanded(
            flex: 50,
            child: Padding(
              padding: EdgeInsets.only(left: 5.w, right: 5.w),
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
