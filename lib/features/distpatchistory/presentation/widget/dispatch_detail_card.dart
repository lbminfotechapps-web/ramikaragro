import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:solufine/features/distpatchistory/domain/entities/dispatch_order_detail_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class DispatchDetailCard extends StatelessWidget {
  final DispatchOrderDetailEntity detail;

  const DispatchDetailCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.cardBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================================================
                // PRODUCT NAME
                // =========================================================
                Text(
                  detail.productName.isEmpty
                      ? '-'
                      : detail.packing.isEmpty
                      ? detail.productName
                      : '${detail.productName} (${detail.packing})',
                  textAlign: TextAlign.start,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(height: 5.h),

                // =========================================================
                // QUANTITY
                // =========================================================
                _detailRow(
                  context,
                  title: 'Case Quantity',
                  value: detail.productQty,
                ),

                // =========================================================
                // DISPATCH QUANTITY
                // =========================================================
                _detailRow(
                  context,
                  title: 'Dispatch Case Quantity',
                  value: detail.actualDispatchQty,
                ),

                // =========================================================
                // REMAINING QUANTITY
                // =========================================================
                _detailRow(
                  context,
                  title: 'Remaining Case Quantity',
                  value: detail.remainingDispatchQty,
                ),

                // =========================================================
                // REMARK
                // =========================================================
                _detailRow(context, title: 'Remark', value: detail.remark),
              ],
            ),
          ),

          // =============================================================
          // DIVIDER BETWEEN PRODUCTS
          // =============================================================
          Container(
            width: double.infinity,
            height: 1.h,
            margin: EdgeInsets.only(top: 5.h),
            color: context.borderColor,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =============================================================
          // LABEL
          // =============================================================
          Expanded(
            flex: 50,
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(color: context.cardTextColor),
            ),
          ),

          // =============================================================
          // COLON
          // =============================================================
          SizedBox(
            width: 15.w,
            child: Text(
              ':',
              style: AppTextStyles.body.copyWith(color: context.cardTextColor),
            ),
          ),

          // =============================================================
          // VALUE
          // =============================================================
          Expanded(
            flex: 50,
            child: Padding(
              padding: EdgeInsets.only(left: 5.w, right: 5.w),
              child: Text(
                value.trim().isEmpty ? '-' : value,
                style: AppTextStyles.body.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
