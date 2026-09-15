import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/features/place_order/domain/entities/product_entity.dart';
import 'package:demo/features/place_order/domain/entities/product_rate_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final int quantity;
  final ProductRateEntity? selectedRate;

  final Future<void> Function() onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.selectedRate,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  // ===========================================================================
  // IMAGE URL
  // ===========================================================================

  String _imageUrl() {
    final image = product.image.trim();

    if (image.isEmpty) {
      return '';
    }

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return image;
    }

    final cleanImage =
        image.startsWith('/')
            ? image.substring(1)
            : image;

    return '${ApiClient.imageBaseUrl}$cleanImage';
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final imageUrl = _imageUrl();
    final bool hasRate = selectedRate != null;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: hasRate
              ? AppColors.primary.withOpacity(0.18)
              : AppColors.border.withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ===================================================================
          // TOP PRODUCT AREA
          // ===================================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================================
              // IMAGE
              // =================================================================

              _buildProductImage(
                imageUrl,
              ),

              SizedBox(width: 10.w),

              // =================================================================
              // PRODUCT DETAILS
              // =================================================================

              Expanded(
                child: _buildProductDetails(
                  hasRate,
                ),
              ),
            ],
          ),

          // ===================================================================
          // BOTTOM ACTION AREA
          // ===================================================================

          if (quantity > 0)
            _buildCartActionBar()
          else
            _buildAddButton(),
        ],
      ),
    );
  }

  // ===========================================================================
  // PRODUCT IMAGE
  // ===========================================================================

  Widget _buildProductImage(
    String imageUrl,
  ) {
    return Container(
      width: 72.w,
      height: 78.w,
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.r),
        child: imageUrl.isEmpty
            ? _buildPlaceholder()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Center(
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                        value: loadingProgress
                                    .expectedTotalBytes !=
                                null
                            ? loadingProgress
                                    .cumulativeBytesLoaded /
                                loadingProgress
                                    .expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (
                  _,
                  __,
                  ___,
                ) {
                  return _buildPlaceholder();
                },
              ),
      ),
    );
  }

  // ===========================================================================
  // PRODUCT DETAILS
  // ===========================================================================

  Widget _buildProductDetails(
    bool hasRate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================================
        // PRODUCT NAME + DELETE
        // =====================================================================

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            if (quantity > 0) ...[
              SizedBox(width: 5.w),
              _buildDeleteButton(),
            ],
          ],
        ),

        SizedBox(height: 7.h),

        // =====================================================================
        // RATE / PACKING
        // =====================================================================

        if (hasRate)
          _buildSelectedRate()
        else if (product.price.trim().isNotEmpty)
          _buildOldPriceBadge()
        else
          _buildSelectRateBadge(),
      ],
    );
  }

  // ===========================================================================
  // DELETE BUTTON
  // ===========================================================================

  Widget _buildDeleteButton() {
    return Material(
      color: AppColors.error.withOpacity(0.07),
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(8.r),
        child: SizedBox(
          width: 28.w,
          height: 28.w,
          child: Icon(
            Icons.delete_outline_rounded,
            size: 17.sp,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SELECTED RATE
  // ===========================================================================

  Widget _buildSelectedRate() {
    final rate = selectedRate!;

    return Row(
      children: [
        // =====================================================================
        // PACKING
        // =====================================================================

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 7.w,
            vertical: 5.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(7.r),
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
              Flexible(
                child: Text(
                  rate.displayPacking,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(width: 6.w),

        // =====================================================================
        // RATE
        // =====================================================================

        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 7.w,
            vertical: 5.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: Text(
            rate.displayRate,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ),

        // =====================================================================
        // CASE
        // =====================================================================

        if (rate.unitsPerCase.trim().isNotEmpty) ...[
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              rate.displayCase,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // OLD PRICE
  // ===========================================================================

  Widget _buildOldPriceBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        '₹ ${product.price}',
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ===========================================================================
  // SELECT RATE
  // ===========================================================================

  Widget _buildSelectRateBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.price_check_outlined,
            size: 12.sp,
            color: Colors.orange.shade700,
          ),
          SizedBox(width: 4.w),
          Text(
            'Select packing & rate',
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w700,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CART ACTION BAR
  // ===========================================================================

  Widget _buildCartActionBar() {
    return Container(
      margin: EdgeInsets.only(top: 9.h),
      padding: EdgeInsets.only(
        top: 8.h,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.border.withOpacity(0.55),
          ),
        ),
      ),
      child: Row(
        children: [
          // ===================================================================
          // CART ICON
          // ===================================================================

          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 15.sp,
              color: AppColors.primary,
            ),
          ),

          SizedBox(width: 6.w),

          Text(
            'Qty',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),

          const Spacer(),

          // ===================================================================
          // TOTAL
          // ===================================================================

          if (selectedRate != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _totalPriceText(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(width: 9.w),
          ],

          // ===================================================================
          // QUANTITY
          // ===================================================================

          _QuantityControl(
            quantity: quantity,
            onAdd: onAdd,
            onRemove: onRemove,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ADD PRODUCT
  // ===========================================================================

  Widget _buildAddButton() {
  return Container(
    margin: EdgeInsets.only(top: 10.h),
    child: SizedBox(
      width: double.infinity,
      height: 46.h,
      child: ElevatedButton(
        onPressed: () async {
          await onAdd();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_shopping_cart_rounded,
              size: 19.sp,
            ),
            SizedBox(width: 7.w),
            Text(
              'Add Product',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ===========================================================================
  // PLACEHOLDER
  // ===========================================================================

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.lightGreen,
      alignment: Alignment.center,
      child: Icon(
        Icons.inventory_2_outlined,
        size: 28.sp,
        color: AppColors.primary,
      ),
    );
  }

  // ===========================================================================
  // TOTAL
  // ===========================================================================

  String _totalPriceText() {
    if (selectedRate == null) {
      return '₹0.00';
    }

    final total =
        selectedRate!.price * quantity;

    return '₹${total.toStringAsFixed(2)}';
  }
}

// =============================================================================
// QUANTITY CONTROL
// =============================================================================

class _QuantityControl extends StatelessWidget {
  final int quantity;

  final Future<void> Function() onAdd;
  final VoidCallback onRemove;

  const _QuantityControl({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove_rounded,
            onTap: onRemove,
          ),

          SizedBox(
            width: 29.w,
            child: Center(
              child: Text(
                '$quantity',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          _QuantityButton(
            icon: Icons.add_rounded,
            onTap: () async {
              await onAdd();
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// QUANTITY BUTTON
// =============================================================================

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(7.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7.r),
        child: SizedBox(
          width: 29.w,
          height: 29.w,
          child: Icon(
            icon,
            color: Colors.white,
            size: 15.sp,
          ),
        ),
      ),
    );
  }
}