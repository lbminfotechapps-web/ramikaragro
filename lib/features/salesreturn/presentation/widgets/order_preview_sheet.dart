import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:solufine/core/theme/app_theme_context.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import 'package:solufine/features/salesreturn/domain/entities/dealer_entity.dart';
import 'package:solufine/features/salesreturn/domain/entities/godown_entity.dart';
import 'package:solufine/features/salesreturn/domain/entities/product_entity.dart';
import 'package:solufine/features/salesreturn/domain/entities/product_rate_entity.dart';

class OrderPreviewSheet extends StatelessWidget {
  final DealerEntity dealer;
  final GodownEntity godown;

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

    required this.products,
    required this.packingQuantities,
    required this.selectedRates,
    required this.imagePath,
    required this.signatureBytes,
    required this.remark,
    required this.onConfirm,
  });

  int get totalQuantity {
    int total = 0;

    for (final product in products) {
      final productId = product.id.toString();

      final quantities = packingQuantities[productId] ?? <String, int>{};

      for (final quantity in quantities.values) {
        total += quantity;
      }
    }

    return total;
  }

  double get totalAmount {
    double total = 0;

    for (final product in products) {
      final productId = product.id.toString();

      final rates = selectedRates[productId] ?? <ProductRateEntity>[];

      final quantities = packingQuantities[productId] ?? <String, int>{};

      for (final rate in rates) {
        final detailsId = rate.productDetailsId.toString();

        final quantity = quantities[detailsId] ?? 1;

        total += rate.amountForCases(quantity);
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = imagePath != null && imagePath!.trim().isNotEmpty;

    final bool hasSignature =
        signatureBytes != null && signatureBytes!.isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.94,
      ),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderOverview(context),

                  SizedBox(height: 12.h),

                  _buildSectionHeader(
                    context,
                    Icons.shopping_bag_outlined,
                    'Products',
                    '${products.length}',
                  ),

                  SizedBox(height: 7.h),

                  if (products.isEmpty)
                    _buildEmptyProducts(context)
                  else
                    ...products.map(
                      (product) => Padding(
                        padding: EdgeInsets.only(bottom: 7.h),
                        child: _buildProductCard(context, product),
                      ),
                    ),

                  SizedBox(height: 3.h),

                  _buildTotalSummary(context),

                  if (hasPhoto || hasSignature) ...[
                    SizedBox(height: 12.h),

                    _buildSectionHeader(
                      context,
                      Icons.verified_user_outlined,
                      'Dealer Verification',
                      null,
                    ),

                    SizedBox(height: 6.h),

                    _buildDealerVerification(
                      context,
                      hasPhoto: hasPhoto,
                      hasSignature: hasSignature,
                    ),
                  ],

                  if (remark.trim().isNotEmpty) ...[
                    SizedBox(height: 12.h),

                    _buildSectionHeader(
                      context,
                      Icons.notes_outlined,
                      'Remark',
                      null,
                    ),

                    SizedBox(height: 6.h),

                    _buildRemark(context),
                  ],

                  SizedBox(height: 5.h),
                ],
              ),
            ),
          ),

          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 11.h, 8.w, 11.h),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.05),
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
              color: context.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: context.primaryColor,
              size: 21.sp,
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: context.primaryTextColor,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Review before submitting',
                  style: AppTextStyles.caption.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${products.length} Items',
              style: AppTextStyles.labelSmall.copyWith(
                color: context.primaryColor,
              ),
            ),
          ),

          SizedBox(width: 2.w),

          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: context.secondaryTextColor,
              size: 21.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
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
            color: context.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 15.sp, color: context.primaryColor),
        ),

        SizedBox(width: 7.w),

        Text(
          title,
          style: AppTextStyles.listTitle.copyWith(
            color: context.primaryTextColor,
          ),
        ),

        if (trailing != null) ...[
          SizedBox(width: 6.w),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: context.appTheme.inputBackground,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              trailing,
              style: AppTextStyles.badge.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderOverview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42.w,
                width: 42.w,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: context.primaryColor,
                  size: 21.sp,
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dealer',
                      style: AppTextStyles.caption.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      dealer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.listTitle.copyWith(
                        color: context.primaryTextColor,
                      ),
                    ),

                    if (dealer.mobile.trim().isNotEmpty) ...[
                      SizedBox(height: 3.h),

                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 12.sp,
                            color: context.secondaryTextColor,
                          ),

                          SizedBox(width: 4.w),

                          Text(
                            dealer.mobile,
                            style: AppTextStyles.helperText.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (dealer.address.trim().isNotEmpty) ...[
                      SizedBox(height: 3.h),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: context.secondaryTextColor,
                          ),

                          SizedBox(width: 4.w),

                          Expanded(
                            child: Text(
                              dealer.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.helperText.copyWith(
                                color: context.secondaryTextColor,
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

          Divider(height: 1, color: context.borderColor),

          SizedBox(height: 10.h),

          Row(
            children: [
              Expanded(
                child: _compactInfo(
                  context,
                  icon: Icons.warehouse_outlined,
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

  Widget _compactInfo(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17.sp, color: context.primaryColor),

        SizedBox(width: 7.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.badge.copyWith(
                  color: context.secondaryTextColor,
                ),
              ),

              SizedBox(height: 1.h),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  color: context.primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ProductEntity product) {
    final productId = product.id.toString();

    final rates = selectedRates[productId] ?? <ProductRateEntity>[];

    final quantities = packingQuantities[productId] ?? <String, int>{};

    int productQuantity = 0;
    double productTotal = 0;

    for (final rate in rates) {
      final detailsId = rate.productDetailsId.toString();

      final quantity = quantities[detailsId] ?? 1;

      productQuantity += quantity;

      productTotal += rate.amountForCases(quantity);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40.w,
                width: 40.w,
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: product.image.trim().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _productIcon(context);
                          },
                        ),
                      )
                    : _productIcon(context),
              ),

              SizedBox(width: 9.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: context.primaryTextColor,
                      ),
                    ),

                    // SizedBox(height: 5.h),

                    // Container(
                    //   padding:
                    //       EdgeInsets.symmetric(
                    //     horizontal: 6.w,
                    //     vertical: 3.h,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color:
                    //         context.primaryColor.withValues(alpha: 0.08),
                    //     borderRadius:
                    //         BorderRadius.circular(
                    //       5.r,
                    //     ),
                    //   ),

                    // ),
                  ],
                ),
              ),

              SizedBox(width: 7.w),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${productTotal.toStringAsFixed(2)}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: context.primaryColor,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  Text(
                    '$productQuantity Qty',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (rates.isNotEmpty) ...[
            SizedBox(height: 8.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'PACKING / RATE',
                        style: AppTextStyles.badge.copyWith(
                          color: context.secondaryTextColor,
                          letterSpacing: .3,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        'AMOUNT',
                        style: AppTextStyles.badge.copyWith(
                          color: context.secondaryTextColor,
                          letterSpacing: .3,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  ...rates.map((rate) {
                    final detailsId = rate.productDetailsId.toString();

                    final quantity = quantities[detailsId] ?? 1;

                    return _buildRateRow(
                      context,
                      rate: rate,
                      quantity: quantity,
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _productIcon(BuildContext context) {
    return Icon(
      Icons.inventory_2_outlined,
      color: context.primaryColor,
      size: 23.sp,
    );
  }

  Widget _buildRateRow(
    BuildContext context, {
    required ProductRateEntity rate,
    required int quantity,
  }) {
    final price = rate.price.toDouble();
    final total = rate.amountForCases(quantity);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 12.sp,
            color: context.primaryColor,
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
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.primaryTextColor,
                  ),
                ),

                SizedBox(height: 1.h),

                Text(
                  'Unit/Case: ${rate.unitsPerCase}',
                  style: AppTextStyles.badge.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 5.w),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Text(
              '$quantity × ${rate.unitsPerCase}',
              style: AppTextStyles.badge.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            '× ₹${price.toStringAsFixed(2)}',
            style: AppTextStyles.badge.copyWith(color: context.primaryColor),
          ),

          // SizedBox(width: 5.w),

          // Container(
          //   padding: EdgeInsets.symmetric(
          //     horizontal: 5.w,
          //     vertical: 2.h,
          //   ),
          //   decoration: BoxDecoration(
          //     color: context.onPrimaryColor,
          //     borderRadius: BorderRadius.circular(5.r),
          //   ),
          //   child: Text(
          //     '× $quantity × ${rate.unitsPerCase}',
          //     style: TextStyle(
          //       fontSize: 8.sp,
          //       fontWeight: FontWeight.w700,
          //       color: context.secondaryTextColor,
          //     ),
          //   ),
          // ),
          SizedBox(width: 10.w),

          SizedBox(
            // width: 58.w,
            child: Text(
              '₹${total.toStringAsFixed(2)}',
              textAlign: TextAlign.end,
              style: AppTextStyles.buttonSmall.copyWith(
                color: context.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProducts(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 34.sp,
            color: context.secondaryTextColor,
          ),

          SizedBox(height: 6.h),

          Text(
            'No products selected',
            style: AppTextStyles.labelLarge.copyWith(
              color: context.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: .15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _totalItem(
              context,
              Icons.inventory_2_outlined,
              'Products',
              '${products.length}',
            ),
          ),

          _verticalDivider(context),

          Expanded(
            child: _totalItem(
              context,
              Icons.format_list_numbered,
              'Quantity',
              '$totalQuantity',
            ),
          ),

          _verticalDivider(context),

          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'GRAND TOTAL',
                  style: AppTextStyles.badge.copyWith(
                    color: context.onPrimaryColor.withValues(alpha: .75),
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: context.onPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: context.onPrimaryColor),

        SizedBox(width: 6.w),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.helperText.copyWith(
                color: context.onPrimaryColor.withValues(alpha: .75),
              ),
            ),

            SizedBox(height: 1.h),

            Text(
              value,
              style: AppTextStyles.listTitle.copyWith(
                color: context.onPrimaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _verticalDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 32.h,
      margin: EdgeInsets.symmetric(horizontal: 7.w),
      color: context.onPrimaryColor.withValues(alpha: .22),
    );
  }

  Widget _buildDealerVerification(
    BuildContext context, {
    required bool hasPhoto,
    required bool hasSignature,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(9.w),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasPhoto)
            Expanded(
              child: _verificationItem(
                context,
                icon: Icons.camera_alt_outlined,
                title: 'Dealer Photo',
                child: Container(
                  height: 105.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.file(
                      File(imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 28.sp,
                            color: context.secondaryTextColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

          if (hasPhoto && hasSignature) SizedBox(width: 9.w),

          if (hasSignature)
            Expanded(
              child: _verificationItem(
                context,
                icon: Icons.draw_outlined,
                title: 'Signature',
                child: Container(
                  height: 105.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.memory(signatureBytes!, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _verificationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13.sp, color: context.primaryColor),

            SizedBox(width: 5.w),

            Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(
                color: context.primaryTextColor,
              ),
            ),
          ],
        ),

        SizedBox(height: 5.h),

        child,
      ],
    );
  }

  Widget _buildRemark(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28.w,
            width: 28.w,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.notes_outlined,
              size: 15.sp,
              color: context.primaryColor,
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Text(
              remark,
              style: AppTextStyles.labelSmall.copyWith(
                height: 1.4,
                color: context.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 9.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: .08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 46.h),
                  side: BorderSide(color: context.primaryColor, width: 1.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Edit Order',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: context.primaryColor,
                  ),
                ),
              ),
            ),

            SizedBox(width: 9.w),

            Expanded(
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 46.h),
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.onPrimaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 17.sp),

                    SizedBox(width: 5.w),

                    Text('Confirm Order', style: AppTextStyles.buttonSmall),
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
