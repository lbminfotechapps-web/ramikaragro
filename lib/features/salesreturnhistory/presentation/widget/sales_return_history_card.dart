import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../domain/entities/sales_return_history_entity.dart';

class SalesReturnHistoryCard extends StatelessWidget {
  final SalesReturnHistoryEntity item;
  final int index;
  final VoidCallback onViewDetails;

  const SalesReturnHistoryCard({
    super.key,
    required this.item,
    required this.index,
    required this.onViewDetails,
  });

  Color _statusColor() {
    switch (item.fldStatus) {
      case '0':
        return Colors.orange;

      case '1':
        return Colors.green;

      case '3':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String _statusText() {
    switch (item.fldStatus) {
      case '0':
        return 'Pending';

      case '1':
        return 'Approved';

      case '3':
        return 'Cancelled';

      default:
        return item.fldStatus;
    }
  }

  Widget _infoRow({required String title, required String value}) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 5.h, bottom: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135.w,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            ':',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(fontSize: 13.sp, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Card(
      margin: EdgeInsets.only(left: 10.w, right: 10.w, top: 7.h, bottom: 5.h),
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
        child: Column(
          children: [
            // TOP HEADER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.fldSalesReturnDate,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  Icon(Icons.circle, size: 9.sp, color: statusColor),

                  SizedBox(width: 5.w),

                  Text(
                    _statusText(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),

                  SizedBox(width: 8.w),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B4332),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'SR: ${(index + 1).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            Divider(height: 1, thickness: 0.8, color: Colors.grey.shade300),

            SizedBox(height: 6.h),

            // RETURNED BY
            _infoRow(title: 'Returned By', value: item.fldOutletName ?? ''),

            // SALES RETURN NO
            _infoRow(title: 'Sales Return No', value: item.fldSalesReturnNo),

            // GODOWN
            _infoRow(title: 'Godown', value: item.fldGodownName),

            // TOTAL RETURN QTY
            _infoRow(title: 'Total Return Quantity', value: item.fldTotalQty),

            // CANCEL REASON
            if (item.fldStatus == '3' && item.fldCancelReason.isNotEmpty)
              _infoRow(title: 'Cancel Reason', value: item.fldCancelReason),

            // BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 10.w, top: 5.h),
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4332),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 9.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
