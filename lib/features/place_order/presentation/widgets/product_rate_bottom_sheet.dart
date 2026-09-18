
import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/features/place_order/domain/entities/product_entity.dart';
import 'package:demo/features/place_order/domain/entities/product_rate_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class ProductRateBottomSheet extends StatefulWidget {
  final ProductEntity product;
  final List<ProductRateEntity> rates;

  const ProductRateBottomSheet({
    super.key,
    required this.product,
    required this.rates,
  });

  @override
  State<ProductRateBottomSheet> createState() =>
      _ProductRateBottomSheetState();
}

class _ProductRateBottomSheetState
    extends State<ProductRateBottomSheet> {
  ProductRateEntity? selectedRate;

  @override
  void initState() {
    super.initState();

    if (widget.rates.length == 1) {
      selectedRate = widget.rates.first;
    }
  }

  // ===========================================================================
  // PRODUCT IMAGE URL
  // ===========================================================================

  String _imageUrl() {
    final image = widget.product.image.trim();

    if (image.isEmpty) {
      return '';
    }

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return image;
    }

    final cleanImage =
        image.startsWith('/') ? image.substring(1) : image;

    return '${ApiClient.imageBaseUrl}$cleanImage';
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22.r),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                14.w,
                8.h,
                14.w,
                12.h,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),

                  SizedBox(height: 14.h),

                  _buildSelectionHeader(),

                  SizedBox(height: 9.h),

                  if (widget.rates.isEmpty)
                    _buildEmptyRates()
                  else
                    ...widget.rates.map(
                      (rate) => _buildRateCard(rate),
                    ),
                ],
              ),
            ),
          ),

          _buildBottomButton(),
        ],
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        11.h,
        8.w,
        11.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 38.w,
            width: 38.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius:
                  BorderRadius.circular(11.r),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Product Rate',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Choose packing and price',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 36.w,
              minHeight: 36.w,
            ),
            icon: Icon(
              Icons.close_rounded,
              size: 21.sp,
              color:
                  AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PRODUCT HEADER
  // ===========================================================================

  Widget _buildProductHeader() {
    final imageUrl = _imageUrl();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.02),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // PRODUCT IMAGE
          Container(
            height: 52.w,
            width: 52.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius:
                  BorderRadius.circular(11.r),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(11.r),
              child: imageUrl.isEmpty
                  ? _buildImagePlaceholder()
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder:
                          (
                            context,
                            child,
                            loadingProgress,
                          ) {
                        if (loadingProgress ==
                            null) {
                          return child;
                        }

                        return Center(
                          child: SizedBox(
                            height: 18.w,
                            width: 18.w,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  AppColors.primary,
                              value:
                                  loadingProgress
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
                      errorBuilder:
                          (_, __, ___) {
                        return _buildImagePlaceholder();
                      },
                    ),
            ),
          ),

          SizedBox(width: 10.w),

          // PRODUCT INFORMATION
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  maxLines: 2,
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

                SizedBox(height: 5.h),

                Container(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 7.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        AppColors.lightGreen,
                    borderRadius:
                        BorderRadius.circular(
                      6.r,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 11.sp,
                        color:
                            AppColors.primary,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '${widget.rates.length} Rate'
                        '${widget.rates.length == 1 ? '' : 's'} Available',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // IMAGE PLACEHOLDER
  // ===========================================================================

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.lightGreen,
      alignment: Alignment.center,
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.primary,
        size: 26.sp,
      ),
    );
  }

  // ===========================================================================
  // SELECTION HEADER
  // ===========================================================================

  Widget _buildSelectionHeader() {
    return Row(
      children: [
        Container(
          height: 30.w,
          width: 30.w,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius:
                BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.tune_rounded,
            color: AppColors.primary,
            size: 16.sp,
          ),
        ),

        SizedBox(width: 8.w),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Select Packing & Rate',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),
              Text(
                'Choose packing before adding product',
                style: TextStyle(
                  fontSize: 9.5.sp,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // RATE CARD
  // ===========================================================================

  Widget _buildRateCard(
    ProductRateEntity rate,
  ) {
    final bool isSelected =
        selectedRate?.productDetailsId ==
            rate.productDetailsId;

    // Debug: should print 10 and 5 with your API response.
    debugPrint(
      'RATE => '
      'ID: ${rate.productDetailsId}, '
      'UnitsPerCase: "${rate.unitsPerCase}", '
      'DisplayCase: "${rate.displayCase}"',
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRate = rate;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 160),
        margin: EdgeInsets.only(
          bottom: 8.h,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 9.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightGreen
              : Colors.white,
          borderRadius:
              BorderRadius.circular(13.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width:
                isSelected ? 1.3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary
                      .withOpacity(0.08)
                  : Colors.black
                      .withOpacity(0.018),
              blurRadius:
                  isSelected ? 8 : 5,
              offset:
                  const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ===============================================================
            // SELECTION ICON
            // ===============================================================

            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 160,
              ),
              height: 36.w,
              width: 36.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected
                    ? Icons.check_rounded
                    : Icons.inventory_2_outlined,
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary,
                size: 18.sp,
              ),
            ),

            SizedBox(width: 9.w),

            // ===============================================================
            // DETAILS
            // ===============================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // PACKING
                  Text(
                    _packingText(rate),
                    maxLines: 1,
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

                  // UNIT PER CASE + GST
                  Row(
                    children: [
                      // UNIT PER CASE
                      _infoBadge(
                        icon:
                            Icons.inventory_2_rounded,
                        text: rate.displayCase,
                        primary: true,
                      ),

                      SizedBox(width: 5.w),

                      // GST
                      _infoBadge(
                        icon:
                            Icons.percent_rounded,
                        text:
                            'GST ${rate.gstPercentage}%',
                        primary: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 7.w),

            // ===============================================================
            // RATE
            // ===============================================================

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rate.displayRate,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        AppColors.primary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Rate',
                  style: TextStyle(
                    fontSize: 8.sp,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // INFO BADGE
  // ===========================================================================

  Widget _infoBadge({
    required IconData icon,
    required String text,
    required bool primary,
  }) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 6.w,
          vertical: 3.5.h,
        ),
        decoration: BoxDecoration(
          color: primary
              ? AppColors.lightGreen.withOpacity(0.75)
              : Colors.grey.shade100,
          borderRadius:
              BorderRadius.circular(6.r),
          border: primary
              ? Border.all(
                  color:
                      AppColors.primary.withOpacity(0.12),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 10.sp,
              color: primary
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            SizedBox(width: 3.w),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.5.sp,
                  fontWeight:
                      primary
                          ? FontWeight.w800
                          : FontWeight.w600,
                  color: primary
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // PACKING TEXT
  // ===========================================================================

  String _packingText(
    ProductRateEntity rate,
  ) {
    final packing =
        rate.packing.trim();

    final unit =
        rate.unit.trim();

    if (packing.isEmpty &&
        unit.isEmpty) {
      return 'Packing not available';
    }

    if (unit.isEmpty) {
      return packing;
    }

    if (packing.isEmpty) {
      return unit;
    }

    return '$packing $unit';
  }

  // ===========================================================================
  // EMPTY RATE
  // ===========================================================================

  Widget _buildEmptyRates() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 18.w,
        vertical: 22.h,
      ),
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
          Container(
            height: 50.w,
            width: 50.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.price_check_outlined,
              color: AppColors.primary,
              size: 25.sp,
            ),
          ),

          SizedBox(height: 9.h),

          Text(
            'No Rate Available',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 3.h),

          Text(
            'No packing or rate is available '
            'for this product.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              color:
                  AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BOTTOM BUTTON
  // ===========================================================================

  Widget _buildBottomButton() {
    final bool enabled =
        selectedRate != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        14.w,
        8.h,
        14.w,
        10.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset:
                const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            // ===============================================================
            // SELECTED RATE
            // ===============================================================

            if (selectedRate != null)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  bottom: 7.h,
                ),
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 9.w,
                  vertical: 7.h,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColors.lightGreen,
                  borderRadius:
                      BorderRadius.circular(
                    10.r,
                  ),
                  border: Border.all(
                    color: AppColors.primary
                        .withOpacity(0.10),
                  ),
                ),
                child: Row(
                  children: [
                    // CHECK
                    Container(
                      height: 27.w,
                      width: 27.w,
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.primary,
                        shape:
                            BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color:
                            Colors.white,
                        size: 15.sp,
                      ),
                    ),

                    SizedBox(width: 7.w),

                    // PACKING
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Selected Packing',
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),
                          Text(
                            _packingText(
                              selectedRate!,
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // UNIT PER CASE
                    Container(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.7),
                        borderRadius:
                            BorderRadius.circular(
                          6.r,
                        ),
                      ),
                      child: Text(
                        selectedRate!
                            .displayCase,
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          fontWeight:
                              FontWeight.w800,
                          color:
                              AppColors.primary,
                        ),
                      ),
                    ),

                    SizedBox(width: 7.w),

                    // PRICE
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          selectedRate!
                              .displayRate,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight:
                                FontWeight.w900,
                            color:
                                AppColors.primary,
                          ),
                        ),
                        Text(
                          'per unit',
                          style: TextStyle(
                            fontSize: 7.5.sp,
                            color: AppColors
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // ===============================================================
            // ADD BUTTON
            // ===============================================================

            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton.icon(
                onPressed: enabled
                    ? _addProductToCart
                    : null,
                icon: Icon(
                  Icons
                      .add_shopping_cart_rounded,
                  size: 18.sp,
                ),
                label: Text(
                  enabled
                      ? 'Add Product to Cart'
                      : 'Select Packing & Rate',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade300,
                  disabledForegroundColor:
                      Colors.grey.shade600,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12.r,
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

  // ===========================================================================
  // ADD PRODUCT TO CART
  // ===========================================================================

  void _addProductToCart() {
    if (selectedRate == null) {
      return;
    }

    // Do NOT add product to Bloc here.
    //
    // Return selected ProductRateEntity
    // to PlaceOrderPage.
    //
    // PlaceOrderPage will:
    // 1. Save selected rate
    // 2. Add product to Bloc/cart

    Navigator.pop(
      context,
      selectedRate,
    );
  }
}
