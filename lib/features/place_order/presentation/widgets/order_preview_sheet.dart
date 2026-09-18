import 'dart:io';
import 'dart:typed_data';

import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/features/place_order/domain/entities/category_entity.dart';
import 'package:demo/features/place_order/domain/entities/dealer_entity.dart';
import 'package:demo/features/place_order/domain/entities/godown_entity.dart';
import 'package:demo/features/place_order/domain/entities/product_entity.dart';
import 'package:demo/features/place_order/domain/entities/product_rate_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class OrderPreviewSheet extends StatelessWidget {
  final DealerEntity dealer;
  final GodownEntity godown;
  final CategoryEntity category;
  final List<ProductEntity> products;

  final Map<String, Map<String, int>> packingQuantities;

  final Map<String, List<ProductRateEntity>> selectedRates;

  final String? imagePath;
  final Uint8List? signatureBytes;
  final String remark;
  final VoidCallback onConfirm;

  const OrderPreviewSheet({
    super.key,
    required this.dealer,
    required this.godown,
    required this.category,
    required this.products,
    required this.packingQuantities,
    required this.selectedRates,
    required this.imagePath,
    required this.signatureBytes,
    required this.remark,
    required this.onConfirm,
  });

  // ============================================================
  // TOTAL QUANTITY
  // ============================================================

  int get totalQuantity {
    int total = 0;

    for (final product in products) {
      final productId = product.id.toString();

      final quantities =
          packingQuantities[productId] ?? <String, int>{};

      for (final quantity in quantities.values) {
        total += quantity;
      }
    }

    return total;
  }

  // ============================================================
  // TOTAL AMOUNT
  // ============================================================

  double get totalAmount {
    double total = 0;

    for (final product in products) {
      final productId = product.id.toString();

      final rates =
          selectedRates[productId] ?? <ProductRateEntity>[];

      final quantities =
          packingQuantities[productId] ?? <String, int>{};

      for (final rate in rates) {
        final detailsId =
            rate.productDetailsId.toString();

        final quantity =
            quantities[detailsId] ?? 1;

        total += rate.price.toDouble() * quantity;
      }
    }

    return total;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto =
        imagePath != null &&
        imagePath!.trim().isNotEmpty;

    final bool hasSignature =
        signatureBytes != null &&
        signatureBytes!.isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height * 0.94,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                12.w,
                10.h,
                12.w,
                12.h,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // DEALER + ORDER INFORMATION
                  // ==================================================

                  _buildOrderOverview(),

                  SizedBox(height: 12.h),

                  // ==================================================
                  // PRODUCTS
                  // ==================================================

                  _buildSectionHeader(
                    Icons.shopping_bag_outlined,
                    'Products',
                    '${products.length}',
                  ),

                  SizedBox(height: 7.h),

                  if (products.isEmpty)
                    _buildEmptyProducts()
                  else
                    ...products.map(
                      (product) => Padding(
                        padding: EdgeInsets.only(
                          bottom: 7.h,
                        ),
                        child:
                            _buildProductCard(product),
                      ),
                    ),

                  SizedBox(height: 3.h),

                  // ==================================================
                  // TOTAL SUMMARY
                  // ==================================================

                  _buildTotalSummary(),

                  // ==================================================
                  // DEALER PHOTO + SIGNATURE
                  // ==================================================

                  if (hasPhoto || hasSignature) ...[
                    SizedBox(height: 12.h),

                    _buildSectionHeader(
                      Icons.verified_user_outlined,
                      'Dealer Verification',
                      null,
                    ),

                    SizedBox(height: 6.h),

                    _buildDealerVerification(
                      hasPhoto: hasPhoto,
                      hasSignature: hasSignature,
                    ),
                  ],

                  // ==================================================
                  // REMARK
                  // ==================================================

                  if (remark.trim().isNotEmpty) ...[
                    SizedBox(height: 12.h),

                    _buildSectionHeader(
                      Icons.notes_outlined,
                      'Remark',
                      null,
                    ),

                    SizedBox(height: 6.h),

                    _buildRemark(),
                  ],

                  SizedBox(height: 5.h),
                ],
              ),
            ),
          ),

          // ========================================================
          // BOTTOM BUTTONS
          // ========================================================

          _buildBottomButtons(context),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        15.w,
        11.h,
        8.w,
        11.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40.w,
            width: 40.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius:
                  BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
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
                  'Order Preview',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Review before submitting',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius:
                  BorderRadius.circular(8.r),
            ),
            child: Text(
              '${products.length} Items',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),

          SizedBox(width: 2.w),

          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () =>
                Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 21.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
    IconData icon,
    String title,
    String? trailing,
  ) {
    return Row(
      children: [
        Container(
          height: 28.w,
          width: 28.w,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius:
                BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 15.sp,
            color: AppColors.primary,
          ),
        ),

        SizedBox(width: 7.w),

        Text(
          title,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        if (trailing != null) ...[
          SizedBox(width: 6.w),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 6.w,
              vertical: 2.h,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(6.r),
            ),
            child: Text(
              trailing,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // ORDER OVERVIEW
  // ============================================================

  Widget _buildOrderOverview() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // ------------------------------------------------------
          // DEALER
          // ------------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                height: 42.w,
                width: 42.w,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_rounded,
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
                      'Dealer',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        color:
                            AppColors.textSecondary,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      dealer.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    if (dealer.mobile
                        .trim()
                        .isNotEmpty) ...[
                      SizedBox(height: 3.h),

                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 12.sp,
                            color:
                                AppColors.textSecondary,
                          ),

                          SizedBox(width: 4.w),

                          Text(
                            dealer.mobile,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color:
                                  AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (dealer.address
                        .trim()
                        .isNotEmpty) ...[
                      SizedBox(height: 3.h),

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons
                                .location_on_outlined,
                            size: 12.sp,
                            color:
                                AppColors.textSecondary,
                          ),

                          SizedBox(width: 4.w),

                          Expanded(
                            child: Text(
                              dealer.address,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          Divider(
            height: 1,
            color: AppColors.border,
          ),

          SizedBox(height: 10.h),

          // ------------------------------------------------------
          // GODOWN + CATEGORY
          // ------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _compactInfo(
                  icon:
                      Icons.warehouse_outlined,
                  label: 'Godown',
                  value: godown.name,
                ),
              ),

             
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMPACT INFO
  // ============================================================

  Widget _compactInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17.sp,
          color: AppColors.primary,
        ),

        SizedBox(width: 7.w),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  color:
                      AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 1.h),

              Text(
                value,
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
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(
    ProductEntity product,
  ) {
    final productId = product.id.toString();

    final rates =
        selectedRates[productId] ??
            <ProductRateEntity>[];

    final quantities =
        packingQuantities[productId] ??
            <String, int>{};

    int productQuantity = 0;
    double productTotal = 0;

    for (final rate in rates) {
      final detailsId =
          rate.productDetailsId.toString();

      final quantity =
          quantities[detailsId] ?? 1;

      productQuantity += quantity;

      productTotal +=
          rate.price.toDouble() * quantity;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // ======================================================
          // PRODUCT TOP
          // ======================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // IMAGE
              // --------------------------------------------------

              Container(
                height: 52.w,
                width: 52.w,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius:
                      BorderRadius.circular(10.r),
                ),
                child: product.image
                        .trim()
                        .isNotEmpty
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          10.r,
                        ),
                        child: Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) {
                            return _productIcon();
                          },
                        ),
                      )
                    : _productIcon(),
              ),

              SizedBox(width: 9.w),

              // --------------------------------------------------
              // PRODUCT NAME
              // --------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 5.h),

                    Container(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
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
                        category.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 7.w),

              // --------------------------------------------------
              // PRODUCT TOTAL
              // --------------------------------------------------

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${productTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                          FontWeight.w900,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  Text(
                    '$productQuantity Qty',
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ======================================================
          // RATES
          // ======================================================

          if (rates.isNotEmpty) ...[
            SizedBox(height: 8.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.circular(9.r),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'PACKING / RATE',
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight:
                              FontWeight.w800,
                          color: AppColors
                              .textSecondary,
                          letterSpacing: .3,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        'AMOUNT',
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight:
                              FontWeight.w800,
                          color: AppColors
                              .textSecondary,
                          letterSpacing: .3,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  ...rates.map(
                    (rate) {
                      final detailsId =
                          rate.productDetailsId
                              .toString();

                      final quantity =
                          quantities[detailsId] ??
                              1;

                      return _buildRateRow(
                        rate: rate,
                        quantity: quantity,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT ICON
  // ============================================================

  Widget _productIcon() {
    return Icon(
      Icons.inventory_2_outlined,
      color: AppColors.primary,
      size: 23.sp,
    );
  }

  // ============================================================
  // RATE ROW
  // ============================================================

  // Widget _buildRateRow({
  //   required ProductRateEntity rate,
  //   required int quantity,
  // }) {
  //   final price = rate.price.toDouble();

  //   final total = price * quantity;

  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //       vertical: 3.h,
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(
  //           Icons.inventory_2_outlined,
  //           size: 12.sp,
  //           color: AppColors.primary,
  //         ),

  //         SizedBox(width: 5.w),

  //         Expanded(
  //           child: Text(
  //             rate.displayPacking,
  //             maxLines: 1,
  //             overflow:
  //                 TextOverflow.ellipsis,
  //             style: TextStyle(
  //               fontSize: 9.5.sp,
  //               fontWeight: FontWeight.w700,
  //               color: AppColors.textPrimary,
  //             ),
  //           ),
  //         ),

  //         SizedBox(width: 5.w),

  //         Text(
  //           '₹${price.toStringAsFixed(2)}',
  //           style: TextStyle(
  //             fontSize: 9.sp,
  //             color: AppColors.primary,
  //             fontWeight: FontWeight.w700,
  //           ),
  //         ),

  //         SizedBox(width: 5.w),

  //         Container(
  //           padding:
  //               EdgeInsets.symmetric(
  //             horizontal: 5.w,
  //             vertical: 2.h,
  //           ),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius:
  //                 BorderRadius.circular(5.r),
  //           ),
  //           child: Text(
  //             '× $quantity',
  //             style: TextStyle(
  //               fontSize: 8.sp,
  //               fontWeight:
  //                   FontWeight.w700,
  //               color:
  //                   AppColors.textSecondary,
  //             ),
  //           ),
  //         ),

  //         SizedBox(width: 6.w),

  //         SizedBox(
  //           width: 58.w,
  //           child: Text(
  //             '₹${total.toStringAsFixed(2)}',
  //             textAlign: TextAlign.end,
  //             style: TextStyle(
  //               fontSize: 9.5.sp,
  //               fontWeight:
  //                   FontWeight.w800,
  //               color:
  //                   AppColors.textPrimary,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }



  Widget _buildRateRow({
  required ProductRateEntity rate,
  required int quantity,
}) {
  final price = rate.price.toDouble();
  final total = price * quantity;

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 3.h),
    child: Row(
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 12.sp,
          color: AppColors.primary,
        ),

        SizedBox(width: 5.w),

        // Packing + Unit Per Case
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rate.displayPacking,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 1.h),

              Text(
                'Unit/Case: ${rate.unitsPerCase}',
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 5.w),

        Text(
          '₹${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 9.sp,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(width: 5.w),

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 5.w,
            vertical: 2.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: Text(
            '× $quantity',
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        SizedBox(width: 6.w),

        SizedBox(
          width: 58.w,
          child: Text(
            '₹${total.toStringAsFixed(2)}',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}


  // ============================================================
  // EMPTY PRODUCTS
  // ============================================================

  Widget _buildEmptyProducts() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 34.sp,
            color:
                AppColors.textSecondary,
          ),

          SizedBox(height: 6.h),

          Text(
            'No products selected',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color:
                  AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOTAL SUMMARY
  // ============================================================

  Widget _buildTotalSummary() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary
                .withOpacity(.88),
          ],
        ),
        borderRadius:
            BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withOpacity(.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _totalItem(
              Icons.inventory_2_outlined,
              'Products',
              '${products.length}',
            ),
          ),

          _verticalDivider(),

          Expanded(
            child: _totalItem(
              Icons.format_list_numbered,
              'Quantity',
              '$totalQuantity',
            ),
          ),

          _verticalDivider(),

          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  'GRAND TOTAL',
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight:
                        FontWeight.w700,
                    color: Colors.white
                        .withOpacity(.75),
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight:
                        FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOTAL ITEM
  // ============================================================

  Widget _totalItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: Colors.white,
        ),

        SizedBox(width: 6.w),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8.sp,
                color:
                    Colors.white.withOpacity(.75),
              ),
            ),

            SizedBox(height: 1.h),

            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight:
                    FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 32.h,
      margin:
          EdgeInsets.symmetric(horizontal: 7.w),
      color: Colors.white.withOpacity(.22),
    );
  }

  // ============================================================
  // DEALER VERIFICATION
  // PHOTO + SIGNATURE IN ONE CARD
  // ============================================================

  Widget _buildDealerVerification({
    required bool hasPhoto,
    required bool hasSignature,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ======================================================
          // PHOTO
          // ======================================================

          if (hasPhoto)
            Expanded(
              child: _verificationItem(
                icon: Icons.camera_alt_outlined,
                title: 'Dealer Photo',
                child: Container(
                  height: 105.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        AppColors.background,
                    borderRadius:
                        BorderRadius.circular(
                      10.r,
                    ),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      10.r,
                    ),
                    child: Image.file(
                      File(imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) {
                        return Center(
                          child: Icon(
                            Icons
                                .broken_image_outlined,
                            size: 28.sp,
                            color: AppColors
                                .textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

          // ======================================================
          // GAP
          // ======================================================

          if (hasPhoto && hasSignature)
            SizedBox(width: 9.w),

          // ======================================================
          // SIGNATURE
          // ======================================================

          if (hasSignature)
            Expanded(
              child: _verificationItem(
                icon: Icons.draw_outlined,
                title: 'Signature',
                child: Container(
                  height: 105.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color:
                        AppColors.background,
                    borderRadius:
                        BorderRadius.circular(
                      10.r,
                    ),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      8.r,
                    ),
                    child: Image.memory(
                      signatureBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // VERIFICATION ITEM
  // ============================================================

  Widget _verificationItem({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 13.sp,
              color: AppColors.primary,
            ),

            SizedBox(width: 5.w),

            Text(
              title,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight:
                    FontWeight.w800,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ],
        ),

        SizedBox(height: 5.h),

        child,
      ],
    );
  }

  // ============================================================
  // REMARK
  // ============================================================

  Widget _buildRemark() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 11.w,
        vertical: 9.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 28.w,
            width: 28.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius:
                  BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.notes_outlined,
              size: 15.sp,
              color: AppColors.primary,
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Text(
              remark,
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.4,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTONS
  // ============================================================

  Widget _buildBottomButtons(
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12.w,
        9.h,
        12.w,
        10.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ==================================================
            // EDIT
            // ==================================================

            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.pop(context),
                style:
                    OutlinedButton.styleFrom(
                  minimumSize: Size(
                    double.infinity,
                    46.h,
                  ),
                  side: BorderSide(
                    color: AppColors.primary,
                    width: 1.1,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12.r,
                    ),
                  ),
                ),
                child: Text(
                  'Edit Order',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors.primary,
                  ),
                ),
              ),
            ),

            SizedBox(width: 9.w),

            // ==================================================
            // CONFIRM
            // ==================================================

            Expanded(
              child: ElevatedButton(
                onPressed: onConfirm,
                style:
                    ElevatedButton.styleFrom(
                  minimumSize: Size(
                    double.infinity,
                    46.h,
                  ),
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12.r,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .check_circle_outline,
                      size: 17.sp,
                    ),

                    SizedBox(width: 5.w),

                    Text(
                      'Confirm Order',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}