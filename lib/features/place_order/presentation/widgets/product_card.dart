import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/features/place_order/domain/entities/product_entity.dart';
import 'package:solufine/features/place_order/domain/entities/product_rate_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  final Map<String, int> packingQuantities;

  final List<ProductRateEntity> selectedRates;

  final VoidCallback onAdd;

  final VoidCallback onAddMore;

  final VoidCallback onDelete;

  final void Function(ProductRateEntity rate) onIncrease;
  final void Function(ProductRateEntity rate) onDecrease;
  final void Function(ProductRateEntity rate) onDeletePacking;

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
      // NEW
    required this.onDeletePacking,
    
  });

  @override
  Widget build(BuildContext context) {
    final bool hasRates =
        selectedRates.isNotEmpty;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: 6.h,
      ),

      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 8.h,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(12.r),

        border: Border.all(
          color: hasRates
              ? AppColors.primary.withOpacity(
                  0.22,
                )
              : AppColors.border,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.025,
            ),
            blurRadius: 5,
            offset: const Offset(
              0,
              2,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =========================================================
          // COMPACT PRODUCT HEADER
          // =========================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              // PRODUCT ICON
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius:
                      BorderRadius.circular(
                    9.r,
                  ),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  size: 17.sp,
                ),
              ),

              SizedBox(
                width: 8.w,
              ),

              // PRODUCT NAME + STATUS
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(
                      height: 2.h,
                    ),

                    Row(
                      children: [
                        Icon(
                          hasRates
                              ? Icons
                                  .check_circle_rounded
                              : Icons
                                  .radio_button_unchecked_rounded,
                          size: 11.sp,
                          color: hasRates
                              ? AppColors.primary
                              : AppColors
                                  .textSecondary,
                        ),

                        SizedBox(
                          width: 3.w,
                        ),

                        Flexible(
                          child: Text(
                            hasRates
                                ? '${selectedRates.length} packing${selectedRates.length == 1 ? '' : 's'} selected'
                                : 'Select packing / rate',
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight:
                                  FontWeight.w600,
                              color: hasRates
                                  ? AppColors.primary
                                  : AppColors
                                      .textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 5.w,
              ),

              // ADD / ADD MORE
              _buildCompactActionButton(
                hasRates: hasRates,
              ),

              SizedBox(
                width: 3.w,
              ),

              // DELETE
              InkWell(
                borderRadius:
                    BorderRadius.circular(
                  8.r,
                ),
                onTap: onDelete,
                child: Container(
                  width: 30.w,
                  height: 30.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red
                        .withOpacity(0.06),
                    borderRadius:
                        BorderRadius.circular(
                      8.r,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 17.sp,
                  ),
                ),
              ),
            ],
          ),

          // =========================================================
          // PACKINGS
          // =========================================================

          if (hasRates) ...[
            SizedBox(
              height: 7.h,
            ),

            Container(
              width: double.infinity,

              padding: EdgeInsets.symmetric(
                horizontal: 7.w,
                vertical: 2.h,
              ),

              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.circular(9.r),
                border: Border.all(
                  color: AppColors.border
                      .withOpacity(0.45),
                ),
              ),

              child: Column(
                children: [
                  for (int index = 0;
                      index <
                          selectedRates.length;
                      index++) ...[
                    _buildPackingRow(
                      selectedRates[index],
                    ),

                    if (index <
                        selectedRates.length - 1)
                      Divider(
                        height: 1,
                        color: AppColors.border
                            .withOpacity(
                          0.35,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

 

  Widget _buildPackingRow(
  ProductRateEntity rate,
) {
  final String productDetailsId =
      rate.productDetailsId.toString();

  final int quantity =
      packingQuantities[productDetailsId] ?? 1;

  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: 5.h,
    ),
    child: Row(
      children: [
        // =========================================================
        // CHECK ICON
        // =========================================================

        Icon(
          Icons.check_circle_rounded,
          color: AppColors.primary,
          size: 13.sp,
        ),

        SizedBox(width: 5.w),

        // =========================================================
        // PACKING INFORMATION
        // =========================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${rate.packing} ${rate.unit}',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ),

                  SizedBox(width: 5.w),

                  Text(
                    '₹${rate.rateWithGst}',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight:
                          FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AppColors.lightGreen,
                      borderRadius:
                          BorderRadius.circular(
                        5.r,
                      ),
                    ),
                    child: Text(
                      rate.displayCase,
                      style: TextStyle(
                        fontSize: 7.5.sp,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(width: 6.w),

        // =========================================================
        // QUANTITY
        // =========================================================

        _buildQuantityControl(
          rate: rate,
          quantity: quantity,
        ),

        SizedBox(width: 5.w),

        // =========================================================
        // NEW DELETE PACKING BUTTON
        // =========================================================

        Material(
          color: Colors.red.withOpacity(0.07),
          borderRadius:
              BorderRadius.circular(7.r),
          child: InkWell(
            borderRadius:
                BorderRadius.circular(7.r),

            onTap: () {
              onDeletePacking(rate);
            },

            child: SizedBox(
              width: 28.w,
              height: 28.h,
              child: Icon(
                Icons.close,
                color: Colors.redAccent,
                size: 15.sp,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  // ===============================================================
  // QUANTITY CONTROL
  // ===============================================================

  Widget _buildQuantityControl({
    required ProductRateEntity rate,
    required int quantity,
  }) {
    return Container(
      height: 28.h,

      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius:
            BorderRadius.circular(7.r),
        border: Border.all(
          color: AppColors.primary
              .withOpacity(0.18),
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          InkWell(
            onTap: quantity > 1
                ? () {
                    onDecrease(rate);
                  }
                : null,
            borderRadius:
                BorderRadius.circular(
              7.r,
            ),
            child: SizedBox(
              width: 26.w,
              height: 28.h,
              child: Icon(
                Icons.remove_rounded,
                size: 14.sp,
                color: quantity > 1
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
          ),

          Container(
            constraints:
                BoxConstraints(
              minWidth: 24.w,
            ),
            alignment:
                Alignment.center,
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight:
                    FontWeight.w900,
                color:
                    AppColors.primary,
              ),
            ),
          ),

          InkWell(
            onTap: () {
              onIncrease(rate);
            },
            borderRadius:
                BorderRadius.circular(
              7.r,
            ),
            child: SizedBox(
              width: 26.w,
              height: 28.h,
              child: Icon(
                Icons.add_rounded,
                size: 14.sp,
                color:
                    AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // COMPACT ADD / ADD MORE BUTTON
  // ===============================================================

  Widget _buildCompactActionButton({
    required bool hasRates,
  }) {
    return Material(
      color: hasRates
          ? AppColors.primary.withOpacity(
              0.08,
            )
          : AppColors.primary,

      borderRadius:
          BorderRadius.circular(8.r),

      child: InkWell(
        onTap:
            hasRates ? onAddMore : onAdd,

        borderRadius:
            BorderRadius.circular(8.r),

        child: Container(
          height: 30.h,

          padding:
              EdgeInsets.symmetric(
            horizontal: 8.w,
          ),

          alignment:
              Alignment.center,

          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                hasRates
                    ? Icons
                        .add_circle_outline_rounded
                    : Icons.add_rounded,
                size: 14.sp,
                color: hasRates
                    ? AppColors.primary
                    : Colors.white,
              ),

              SizedBox(
                width: 3.w,
              ),

              Text(
                hasRates
                    ? 'More'
                    : 'Add',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight:
                      FontWeight.w800,
                  color: hasRates
                      ? AppColors.primary
                      : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}