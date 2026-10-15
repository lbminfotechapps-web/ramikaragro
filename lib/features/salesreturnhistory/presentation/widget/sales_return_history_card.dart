import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/core/theme/app_dynamic_colors.dart';
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

  Color _statusColor(BuildContext context) {
    switch (item.fldStatus) {
      case '0':
        return context.appWarning;

      case '1':
        return context.appSuccess;

      case '3':
        return context.appColors.error;

      default:
        return context.secondaryTextColor;
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

  Widget _infoRow(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 5.h, bottom: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135.w,
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.primaryTextColor,
              ),
            ),
          ),
          Text(':', style: AppTextStyles.bodyMedium),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: AppTextStyles.body.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);

    return Card(
      color: context.cardBackgroundColor,
      margin: EdgeInsets.only(left: 10.w, right: 10.w, top: 7.h, bottom: 5.h),
      elevation: 4,
      shadowColor: context.appColors.shadow.withValues(alpha: 0.26),
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
                      style: AppTextStyles.labelLarge.copyWith(
                        color: context.primaryTextColor,
                      ),
                    ),
                  ),

                  Icon(Icons.circle, size: 9.sp, color: statusColor),

                  SizedBox(width: 5.w),

                  Text(
                    _statusText(),
                    style: AppTextStyles.labelLarge.copyWith(
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
                      color: context.primaryColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'SR: ${(index + 1).toString().padLeft(2, '0')}',
                      style: AppTextStyles.badge.copyWith(
                        color: context.onPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.h),

            Divider(height: 1, thickness: 0.8, color: context.borderColor),

            SizedBox(height: 6.h),

            _infoRow(
              context,
              title: 'Dealer Name',
              value: item.fldOutletName ?? '',
            ),

            _infoRow(context, title: 'Employee Name', value: item.employeeName),

            _infoRow(
              context,
              title: 'Sales Return No',
              value: item.fldSalesReturnNo,
            ),

            _infoRow(context, title: 'Godown', value: item.fldGodownName),

            _infoRow(
              context,
              title: 'Total Return Quantity',
              value: item.fldTotalQty,
            ),

            if (item.fldStatus == '3' && item.fldCancelReason.isNotEmpty)
              _infoRow(
                context,
                title: 'Cancel Reason',
                value: item.fldCancelReason,
              ),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 10.w, top: 5.h),
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: context.onPrimaryColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 9.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text('View Details', style: AppTextStyles.buttonSmall),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
