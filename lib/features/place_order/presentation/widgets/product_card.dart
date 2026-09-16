import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/features/place_order/domain/entities/product_entity.dart';
import 'package:demo/features/place_order/domain/entities/product_rate_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  /// Quantity for each selected packing.
  ///
  /// Key   = productDetailsId
  /// Value = quantity
  ///
  /// Example:
  /// {
  ///   "101": 2,
  ///   "102": 5,
  ///   "103": 1,
  /// }
  final Map<String, int> packingQuantities;

  /// All selected rates / packings for this product.
  final List<ProductRateEntity> selectedRates;

  /// Opens packing/rate selector.
  final VoidCallback onAdd;

  /// Opens selector again.
  final VoidCallback onAddMore;

  /// Delete complete product.
  final VoidCallback onDelete;

  /// Increase quantity of one packing.
  final void Function(ProductRateEntity rate) onIncrease;

  /// Decrease quantity of one packing.
  final void Function(ProductRateEntity rate) onDecrease;

  const ProductCard({
    super.key,
    required this.product,
    required this.packingQuantities,
    required this.selectedRates,
    required this.onAdd,
    required this.onAddMore,
    required this.onDelete,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasRates = selectedRates.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: hasRates
              ? AppColors.primary.withOpacity(0.25)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // PRODUCT HEADER
          // ============================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  size: 21.sp,
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      hasRates
                          ? '${selectedRates.length} packing${selectedRates.length == 1 ? '' : 's'} selected'
                          : 'Select packing / rate',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: hasRates
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 5.w),

              // DELETE
              IconButton(
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20.sp,
                ),
              ),
            ],
          ),

          // ============================================================
          // SELECTED PACKINGS
          // ============================================================

          if (hasRates) ...[
            SizedBox(height: 10.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 9.w,
                vertical: 5.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color:
                      AppColors.border.withOpacity(0.50),
                ),
              ),
              child: Column(
                children: [
                  for (int index = 0;
                      index < selectedRates.length;
                      index++) ...[
                    _buildPackingRow(
                      selectedRates[index],
                    ),

                    if (index <
                        selectedRates.length - 1)
                      Divider(
                        height: 1,
                        color: AppColors.border
                            .withOpacity(0.35),
                      ),
                  ],
                ],
              ),
            ),
          ],

          SizedBox(height: 10.h),

          // ============================================================
          // ADD MORE
          // ============================================================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.end,
            children: [
              if (hasRates)
                _buildAddMoreButton()
              else
                _buildAddButton(),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PACKING ROW
  // ==========================================================================

  Widget _buildPackingRow(
    ProductRateEntity rate,
  ) {
    // IMPORTANT:
    // Quantity is identified by productDetailsId.
    final String productDetailsId =
        rate.productDetailsId.toString();

    // If Bloc has not stored a quantity yet,
    // default is 1.
    final int quantity =
        packingQuantities[productDetailsId] ?? 1;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 7.h,
      ),
      child: Row(
        children: [
          // ==============================================================
          // CHECK ICON
          // ==============================================================

          Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 15.sp,
          ),

          SizedBox(width: 6.w),

          // ==============================================================
          // PACKING + RATE
          // ==============================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${rate.packing} ${rate.unit}',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  '₹${rate.rateWithGst}',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // ==============================================================
          // QUANTITY CONTROL
          // ==============================================================

          _buildQuantityControl(
            rate: rate,
            quantity: quantity,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // QUANTITY CONTROL
  // ==========================================================================

  Widget _buildQuantityControl({
    required ProductRateEntity rate,
    required int quantity,
  }) {
    return Container(
      height: 32.h,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              AppColors.primary.withOpacity(0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ==============================================================
          // MINUS
          // ==============================================================

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: quantity > 1
                  ? () => onDecrease(rate)
                  : null,
              borderRadius:
                  BorderRadius.circular(8.r),
              child: SizedBox(
                width: 30.w,
                height: 32.h,
                child: Icon(
                  Icons.remove_rounded,
                  size: 16.sp,
                  color: quantity > 1
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
            ),
          ),

          // ==============================================================
          // QUANTITY
          // ==============================================================

          Container(
            constraints: BoxConstraints(
              minWidth: 28.w,
            ),
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ),

          // ==============================================================
          // PLUS
          // ==============================================================

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onIncrease(rate),
              borderRadius:
                  BorderRadius.circular(8.r),
              child: SizedBox(
                width: 30.w,
                height: 32.h,
                child: Icon(
                  Icons.add_rounded,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ADD BUTTON
  // ==========================================================================

  Widget _buildAddButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 18.w,
            vertical: 8.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 17.sp,
              ),

              SizedBox(width: 4.w),

              Text(
                'Add',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ADD MORE BUTTON
  // ==========================================================================

  Widget _buildAddMoreButton() {
    return Material(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onAddMore,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 11.w,
            vertical: 8.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 16.sp,
                color: AppColors.primary,
              ),

              SizedBox(width: 4.w),

              Text(
                'Add More',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}