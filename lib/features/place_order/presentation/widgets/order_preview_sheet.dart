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
  final Map<String, int> quantities;

  // ============================================================
  // SELECTED PRODUCT RATES
  // productId -> selected ProductRateEntity
  // ============================================================
  final Map<String, ProductRateEntity> selectedRates;

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
    required this.quantities,
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
    return products.fold<int>(
      0,
      (total, product) {
        return total + (quantities[product.id] ?? 0);
      },
    );
  }

  // ============================================================
  // TOTAL AMOUNT
  // ============================================================

  double get totalAmount {
    return products.fold<double>(
      0,
      (total, product) {
        final quantity = quantities[product.id] ?? 0;

        final rate = selectedRates[product.id.toString()];

        final price = rate?.price ?? 0;

        return total + (price * quantity);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.93,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),

          // ----------------------------------------------------
          // SCROLL CONTENT
          // ----------------------------------------------------

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                8.h,
                16.w,
                20.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // DEALER
                  // ==================================================

                  _sectionTitle(
                    icon: Icons.person_outline,
                    title: 'Dealer Details',
                  ),

                  SizedBox(height: 10.h),

                  _buildDealerCard(),

                  SizedBox(height: 18.h),

                  // ==================================================
                  // ORDER DETAILS
                  // ==================================================

                  _sectionTitle(
                    icon: Icons.receipt_long_outlined,
                    title: 'Order Details',
                  ),

                  SizedBox(height: 10.h),

                  _buildOrderInfoCard(),

                  SizedBox(height: 18.h),

                  // ==================================================
                  // PRODUCTS
                  // ==================================================

                  _sectionTitle(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Products',
                  ),

                  SizedBox(height: 10.h),

                  if (products.isEmpty)
                    _buildEmptyProducts()
                  else
                    ...products.map(
                      (product) => Padding(
                        padding: EdgeInsets.only(
                          bottom: 10.h,
                        ),
                        child: _buildProductCard(product),
                      ),
                    ),

                  // ==================================================
                  // TOTAL SUMMARY
                  // ==================================================

                  SizedBox(height: 4.h),

                  _buildTotalSummary(),

                  // ==================================================
                  // PHOTO
                  // ==================================================

                  if (imagePath != null &&
                      imagePath!.trim().isNotEmpty) ...[
                    SizedBox(height: 18.h),

                    _sectionTitle(
                      icon: Icons.camera_alt_outlined,
                      title: 'Photo',
                    ),

                    SizedBox(height: 10.h),

                    _buildPhoto(),
                  ],

                  // ==================================================
                  // SIGNATURE
                  // ==================================================

                  if (signatureBytes != null &&
                      signatureBytes!.isNotEmpty) ...[
                    SizedBox(height: 18.h),

                    _sectionTitle(
                      icon: Icons.draw_outlined,
                      title: 'Dealer Signature',
                    ),

                    SizedBox(height: 10.h),

                    _buildSignature(),
                  ],

                  // ==================================================
                  // REMARK
                  // ==================================================

                  if (remark.trim().isNotEmpty) ...[
                    SizedBox(height: 18.h),

                    _sectionTitle(
                      icon: Icons.notes_outlined,
                      title: 'Remark',
                    ),

                    SizedBox(height: 10.h),

                    _buildRemark(),
                  ],

                  SizedBox(height: 15.h),
                ],
              ),
            ),
          ),

          // ----------------------------------------------------
          // BOTTOM BUTTONS
          // ----------------------------------------------------

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
        20.w,
        14.h,
        12.w,
        14.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44.w,
            width: 44.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 23.sp,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Preview',
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  'Review your order before submitting',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: AppColors.primary,
        ),

        SizedBox(width: 7.w),

        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DEALER CARD
  // ============================================================

  Widget _buildDealerCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48.w,
            width: 48.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dealer.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                if (dealer.mobile.trim().isNotEmpty) ...[
                  SizedBox(height: 5.h),

                  Row(
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14.sp,
                        color: AppColors.textSecondary,
                      ),

                      SizedBox(width: 5.w),

                      Expanded(
                        child: Text(
                          dealer.mobile,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (dealer.address.trim().isNotEmpty) ...[
                  SizedBox(height: 4.h),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: AppColors.textSecondary,
                      ),

                      SizedBox(width: 5.w),

                      Expanded(
                        child: Text(
                          dealer.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
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
    );
  }

  // ============================================================
  // ORDER INFO
  // ============================================================

  Widget _buildOrderInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _infoItem(
              icon: Icons.warehouse_outlined,
              label: 'Godown',
              value: godown.name,
            ),
          ),

          Container(
            width: 1,
            height: 60.h,
            color: AppColors.border,
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 14.w),
              child: _infoItem(
                icon: Icons.category_outlined,
                label: 'Category',
                value: category.name,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: AppColors.primary,
        ),

        SizedBox(height: 5.h),

        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondary,
          ),
        ),

        SizedBox(height: 2.h),

        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductCard(ProductEntity product) {
    final quantity = quantities[product.id] ?? 0;

    // ------------------------------------------------------------
    // GET SELECTED RATE FOR THIS PRODUCT
    // ------------------------------------------------------------

    final rate = selectedRates[product.id.toString()];

    // ------------------------------------------------------------
    // USE SELECTED API RATE
    // ------------------------------------------------------------

    final price = rate?.price ?? 0;

    final productTotal = price * quantity;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // PRODUCT IMAGE
          // ----------------------------------------------------

          Container(
            height: 62.w,
            width: 62.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: product.image.trim().isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12.r),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 25.sp,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 25.sp,
                  ),
          ),

          SizedBox(width: 12.w),

          // ----------------------------------------------------
          // PRODUCT INFORMATION
          // ----------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 6.h),

                // ==================================================
                // CATEGORY
                // ==================================================

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius:
                        BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 12.sp,
                        color: AppColors.primary,
                      ),

                      SizedBox(width: 4.w),

                      Flexible(
                        child: Text(
                          category.name,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 7.h),

                // ==================================================
                // SELECTED PACKING
                // ==================================================

                if (rate != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 6.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius:
                          BorderRadius.circular(7.r),
                      border: Border.all(
                        color: Colors.green.shade100,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 12.sp,
                          color: AppColors.primary,
                        ),

                        SizedBox(width: 4.w),

                        Text(
                          rate.displayPacking,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ==================================================
                // QUANTITY
                // ==================================================

                Row(
                  children: [
                    Text(
                      'Qty: $quantity',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),

                    if (rate != null &&
                        rate.unitsPerCase.trim().isNotEmpty) ...[
                      SizedBox(width: 8.w),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius:
                              BorderRadius.circular(5.r),
                        ),
                        child: Text(
                          rate.displayCase,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // ----------------------------------------------------
          // PRICE
          // ----------------------------------------------------

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                '× $quantity',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                '₹${productTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(height: 1.h),

              Text(
                'Total',
                style: TextStyle(
                  fontSize: 9.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 40.sp,
            color: AppColors.textSecondary,
          ),

          SizedBox(height: 8.h),

          Text(
            'No products selected',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Total Products',
                  value: '${products.length}',
                ),
              ),

              Container(
                width: 1,
                height: 42.h,
                color: Colors.white.withOpacity(0.25),
              ),

              Expanded(
                child: _summaryItem(
                  icon: Icons.format_list_numbered,
                  label: 'Total Quantity',
                  value: '$totalQuantity',
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withOpacity(0.20),
          ),

          SizedBox(height: 14.h),

          Row(
            children: [
              Container(
                height: 42.w,
                width: 42.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.currency_rupee_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grand Total Amount',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color:
                            Colors.white.withOpacity(0.85),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY ITEM
  // ============================================================

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20.sp,
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color:
                        Colors.white.withOpacity(0.80),
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
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
  // PHOTO
  // ============================================================

  Widget _buildPhoto() {
    return Container(
      width: double.infinity,
      height: 170.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 35.sp,
                color: AppColors.textSecondary,
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SIGNATURE
  // ============================================================

  Widget _buildSignature() {
    return Container(
      width: double.infinity,
      height: 150.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Image.memory(
          signatureBytes!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ============================================================
  // REMARK
  // ============================================================

  Widget _buildRemark() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Text(
        remark,
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.5,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTONS
  // ============================================================

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
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
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(
                    double.infinity,
                    50.h,
                  ),
                  side: BorderSide(
                    color: AppColors.primary,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Edit Order',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // ==================================================
            // CONFIRM
            // ==================================================

            Expanded(
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    double.infinity,
                    50.h,
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 19.sp,
                    ),

                    SizedBox(width: 7.w),

                    Text(
                      'Confirm Order',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
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