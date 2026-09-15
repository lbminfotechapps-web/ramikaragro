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

    // Automatically select the rate
    // when only one rate is available.
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
          top: Radius.circular(28.r),
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
                16.w,
                10.h,
                16.w,
                20.h,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),

                  SizedBox(height: 20.h),

                  _buildSelectionHeader(),

                  SizedBox(height: 12.h),

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
        20.w,
        15.h,
        12.w,
        15.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r),
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
          // -------------------------------------------------------------------
          // HEADER ICON
          // -------------------------------------------------------------------

          Container(
            height: 44.w,
            width: 44.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius:
                  BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
              size: 23.sp,
            ),
          ),

          SizedBox(width: 12.w),

          // -------------------------------------------------------------------
          // HEADER TITLE
          // -------------------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Product Rate',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  'Choose packing and price',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------------
          // CLOSE BUTTON
          // -------------------------------------------------------------------

          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.close_rounded,
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17.r),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // =================================================================
          // PRODUCT IMAGE
          // =================================================================

          Container(
            height: 62.w,
            width: 62.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius:
                  BorderRadius.circular(14.r),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(14.r),
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
                            height: 20.w,
                            width: 20.w,
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

          SizedBox(width: 13.w),

          // =================================================================
          // PRODUCT INFORMATION
          // =================================================================

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
                    fontSize: 15.sp,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 7.h),

                Container(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        AppColors.lightGreen,
                    borderRadius:
                        BorderRadius.circular(
                      7.r,
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 12.sp,
                        color:
                            AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${widget.rates.length} '
                        'Available Rate'
                        '${widget.rates.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 10.sp,
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
        size: 30.sp,
      ),
    );
  }

  // ===========================================================================
  // SELECTION HEADER
  // ===========================================================================

  Widget _buildSelectionHeader() {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          height: 34.w,
          width: 34.w,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius:
                BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.tune_rounded,
            color: AppColors.primary,
            size: 18.sp,
          ),
        ),

        SizedBox(width: 10.w),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Select Packing & Rate',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                'Choose the required packing '
                'before adding the product.',
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.3,
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

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRate = rate;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        margin: EdgeInsets.only(
          bottom: 12.h,
        ),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightGreen
              : Colors.white,
          borderRadius:
              BorderRadius.circular(17.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width:
                isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary
                      .withOpacity(0.10)
                  : Colors.black
                      .withOpacity(0.025),
              blurRadius:
                  isSelected ? 12 : 8,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            // ===============================================================
            // SELECTION ICON
            // ===============================================================

            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              height: 42.w,
              width: 42.w,
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
                size: 21.sp,
              ),
            ),

            SizedBox(width: 12.w),

            // ===============================================================
            // PACKING DETAILS
            // ===============================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    _packingText(rate),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 5.h,
                    children: [
                      _smallInfo(
                        icon:
                            Icons.inventory_2_outlined,
                        text:
                            _unitsPerCaseText(
                          rate,
                        ),
                      ),

                      _smallInfo(
                        icon:
                            Icons.percent_rounded,
                        text:
                            'GST ${rate.gstPercentage}%',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // ===============================================================
            // RATE
            // ===============================================================

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  rate.displayRate,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        AppColors.primary,
                  ),
                ),

                SizedBox(height: 3.h),

                Text(
                  'Rate',
                  style: TextStyle(
                    fontSize: 9.sp,
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
  // UNITS PER CASE
  // ===========================================================================

  String _unitsPerCaseText(
    ProductRateEntity rate,
  ) {
    final units = int.tryParse(
      rate.unitsPerCase.trim(),
    );

    if (units == null || units <= 0) {
      return 'Case not specified';
    }

    return '$units units/case';
  }

  // ===========================================================================
  // SMALL INFORMATION
  // ===========================================================================

  Widget _smallInfo({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12.sp,
          color:
              AppColors.textSecondary,
        ),

        SizedBox(width: 4.w),

        Text(
          text,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight:
                FontWeight.w500,
            color:
                AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // EMPTY RATE
  // ===========================================================================

  Widget _buildEmptyRates() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 30.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 60.w,
            width: 60.w,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.price_check_outlined,
              color: AppColors.primary,
              size: 30.sp,
            ),
          ),

          SizedBox(height: 12.h),

          Text(
            'No Rate Available',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            'No packing or rate is available '
            'for this product.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
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
        16.w,
        12.h,
        16.w,
        16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset:
                const Offset(0, -4),
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
            // SELECTED RATE SUMMARY
            // ===============================================================

            if (selectedRate != null)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  bottom: 10.h,
                ),
                padding:
                    EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColors.lightGreen,
                  borderRadius:
                      BorderRadius.circular(
                    12.r,
                  ),
                  border: Border.all(
                    color: AppColors.primary
                        .withOpacity(0.12),
                  ),
                ),
                child: Row(
                  children: [
                    // -------------------------------------------------------
                    // CHECK ICON
                    // -------------------------------------------------------

                    Container(
                      height: 30.w,
                      width: 30.w,
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
                        size: 17.sp,
                      ),
                    ),

                    SizedBox(width: 9.w),

                    // -------------------------------------------------------
                    // PACKING
                    // -------------------------------------------------------

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Selected Packing',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: AppColors
                                  .textSecondary,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: 2.h),

                          Text(
                            _packingText(
                              selectedRate!,
                            ),
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // -------------------------------------------------------
                    // PRICE
                    // -------------------------------------------------------

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .end,
                      children: [
                        Text(
                          selectedRate!
                              .displayRate,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight:
                                FontWeight.w900,
                            color:
                                AppColors.primary,
                          ),
                        ),

                        Text(
                          'per unit',
                          style: TextStyle(
                            fontSize: 9.sp,
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
            // ADD PRODUCT TO CART BUTTON
            // ===============================================================

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: enabled
                    ? _addProductToCart
                    : null,
                icon: Icon(
                  Icons
                      .add_shopping_cart_rounded,
                  size: 20.sp,
                ),
                label: Text(
                  enabled
                      ? 'Add Product to Cart'
                      : 'Select Packing & Rate',
                  style: TextStyle(
                    fontSize: 14.sp,
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
                      15.r,
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

    // IMPORTANT:
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