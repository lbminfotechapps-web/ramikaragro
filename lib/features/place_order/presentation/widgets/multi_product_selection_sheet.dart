import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/features/place_order/domain/entities/product_entity.dart';
import 'package:demo/features/place_order/domain/entities/product_rate_entity.dart';
import 'package:demo/features/place_order/domain/usecases/get_product_detail_rates_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

/// ===========================================================================
/// RESULT
/// ===========================================================================
///
/// selectedRates:
///     Product ID -> selected packing/rates
///
/// packingQuantities:
///     Product ID -> Product Details ID -> Quantity
///
/// Example:
///
/// {
///   "1": {
///     "101": 2,
///     "102": 5,
///   }
/// }
///
class MultiProductRateSelectionResult {
  final Map<String, List<ProductRateEntity>> selectedRates;

  final Map<String, Map<String, int>> packingQuantities;

  const MultiProductRateSelectionResult({
    required this.selectedRates,
    required this.packingQuantities,
  });
}

class MultiProductRateBottomSheet extends StatefulWidget {
  final List<ProductEntity> products;

  final String dealerId;

  /// Product ID -> selected rates
  final Map<String, List<ProductRateEntity>> existingRates;

  /// Product ID -> Product Details ID -> Quantity
  ///
  /// Example:
  ///
  /// {
  ///   "1": {
  ///     "101": 2,
  ///     "102": 5,
  ///   }
  /// }
  final Map<String, Map<String, int>> existingPackingQuantities;

  /// Product which should be displayed initially.
  final String? initialProductId;

  final GetProductDetailRatesUseCase getRatesUseCase;

  const MultiProductRateBottomSheet({
    super.key,
    required this.products,
    required this.dealerId,
    required this.existingRates,
    required this.existingPackingQuantities,
    this.initialProductId,
    required this.getRatesUseCase,
  });

  @override
  State<MultiProductRateBottomSheet> createState() =>
      _MultiProductRateBottomSheetState();
}

class _MultiProductRateBottomSheetState
    extends State<MultiProductRateBottomSheet> {
  // ===========================================================================
  // DATA
  // ===========================================================================

  /// Product ID -> selected rates/packings
  late Map<String, List<ProductRateEntity>> _selectedRates;

  /// Product ID -> Product Details ID -> Quantity
  late Map<String, Map<String, int>> _packingQuantities;

  /// Product ID -> available rates
  final Map<String, List<ProductRateEntity>> _ratesCache = {};

  String? _selectedProductId;

  bool _isLoadingRates = false;

  String? _errorMessage;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _selectedRates = {};

    // =========================================================================
    // COPY EXISTING SELECTED RATES
    // =========================================================================

    for (final entry in widget.existingRates.entries) {
      _selectedRates[entry.key] =
          List<ProductRateEntity>.from(entry.value);
    }

    // =========================================================================
    // COPY EXISTING PACKING-WISE QUANTITIES
    // =========================================================================

    _packingQuantities = {
      for (final entry in widget.existingPackingQuantities.entries)
        entry.key: Map<String, int>.from(entry.value),
    };

    // =========================================================================
    // SELECT PRODUCT
    // =========================================================================

    if (widget.initialProductId != null &&
        widget.products.any(
          (product) =>
              product.id.toString() == widget.initialProductId,
        )) {
      _selectedProductId = widget.initialProductId;
    } else if (widget.products.isNotEmpty) {
      _selectedProductId =
          widget.products.first.id.toString();
    }

    // =========================================================================
    // LOAD RATES AFTER BUILD
    // =========================================================================

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadRates();
      }
    });
  }

  // ===========================================================================
  // CURRENT PRODUCT
  // ===========================================================================

  ProductEntity? get _selectedProduct {
    if (_selectedProductId == null) {
      return null;
    }

    for (final product in widget.products) {
      if (product.id.toString() == _selectedProductId) {
        return product;
      }
    }

    return null;
  }

  // ===========================================================================
  // LOAD RATES
  // ===========================================================================

  Future<void> _loadRates() async {
    final productId = _selectedProductId;

    if (productId == null) {
      return;
    }

    if (_ratesCache.containsKey(productId)) {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }

      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingRates = true;
        _errorMessage = null;
      });
    }

    try {
      debugPrint('========================================');
      debugPrint('LOAD PRODUCT RATES');
      debugPrint('Dealer ID  : ${widget.dealerId}');
      debugPrint('Product ID : $productId');
      debugPrint('========================================');

      final rates = await widget.getRatesUseCase(
        dealerId: widget.dealerId,
        productId: productId,
      );

      if (!mounted) {
        return;
      }

      _ratesCache[productId] =
          List<ProductRateEntity>.from(rates);

      setState(() {
        _isLoadingRates = false;
        _errorMessage = null;
      });

      debugPrint('Rates loaded: ${rates.length}');
    } catch (e, stackTrace) {
      debugPrint('Get product rates error: $e');
      debugPrint(stackTrace.toString());

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingRates = false;
        _errorMessage = 'Unable to load product rates';
      });
    }
  }

  // ===========================================================================
  // SELECTED COUNT
  // ===========================================================================

  int _selectedCount(String productId) {
    return _selectedRates[productId]?.length ?? 0;
  }

  int get _totalSelectedRates {
    int count = 0;

    for (final rates in _selectedRates.values) {
      count += rates.length;
    }

    return count;
  }

  // ===========================================================================
  // PACKING QUANTITY
  // ===========================================================================

  int _quantity(
    String productId,
    String productDetailsId,
  ) {
    return _packingQuantities[productId]?[productDetailsId] ?? 1;
  }

  // ===========================================================================
  // INCREASE PACKING QUANTITY
  // ===========================================================================

  void _increaseQuantity(
    String productId,
    String productDetailsId,
  ) {
    final productQuantities =
        _packingQuantities.putIfAbsent(
      productId,
      () => <String, int>{},
    );

    final currentQuantity =
        productQuantities[productDetailsId] ?? 1;

    setState(() {
      productQuantities[productDetailsId] =
          currentQuantity + 1;
    });

    debugPrint(
      'Packing quantity increased: '
      'product=$productId '
      'details=$productDetailsId '
      'quantity=${productQuantities[productDetailsId]}',
    );
  }

  // ===========================================================================
  // DECREASE PACKING QUANTITY
  // ===========================================================================

  void _decreaseQuantity(
    String productId,
    String productDetailsId,
  ) {
    final productQuantities =
        _packingQuantities[productId];

    if (productQuantities == null) {
      return;
    }

    final currentQuantity =
        productQuantities[productDetailsId] ?? 1;

    if (currentQuantity <= 1) {
      return;
    }

    setState(() {
      productQuantities[productDetailsId] =
          currentQuantity - 1;
    });

    debugPrint(
      'Packing quantity decreased: '
      'product=$productId '
      'details=$productDetailsId '
      'quantity=${productQuantities[productDetailsId]}',
    );
  }

  // ===========================================================================
  // CHECK RATE
  // ===========================================================================

  bool _isRateSelected(
    String productId,
    ProductRateEntity rate,
  ) {
    final selected = _selectedRates[productId];

    if (selected == null) {
      return false;
    }

    return selected.any(
      (item) =>
          item.productDetailsId ==
          rate.productDetailsId,
    );
  }

  // ===========================================================================
  // TOGGLE RATE
  // ===========================================================================

  void _toggleRate(
    String productId,
    ProductRateEntity rate,
  ) {
    final current = List<ProductRateEntity>.from(
      _selectedRates[productId] ??
          <ProductRateEntity>[],
    );

    final existingIndex = current.indexWhere(
      (item) =>
          item.productDetailsId ==
          rate.productDetailsId,
    );

    // =========================================================================
    // REMOVE RATE
    // =========================================================================

    if (existingIndex >= 0) {
      current.removeAt(existingIndex);

      final String productDetailsId =
          rate.productDetailsId.toString();

      // Remove this packing's quantity.
      _packingQuantities[productId]
          ?.remove(productDetailsId);

      if (current.isEmpty) {
        _selectedRates.remove(productId);

        // Remove all quantities because no packing
        // is selected for this product.
        _packingQuantities.remove(productId);
      } else {
        _selectedRates[productId] = current;
      }
    }

    // =========================================================================
    // ADD RATE
    // =========================================================================

    else {
      current.add(rate);

      _selectedRates[productId] = current;

      final productQuantities =
          _packingQuantities.putIfAbsent(
        productId,
        () => <String, int>{},
      );

      final String productDetailsId =
          rate.productDetailsId.toString();

      // Every newly selected packing starts with quantity 1.
      productQuantities.putIfAbsent(
        productDetailsId,
        () => 1,
      );

      debugPrint(
        'Packing selected: '
        'product=$productId '
        'details=$productDetailsId '
        'quantity=${productQuantities[productDetailsId]}',
      );
    }

    setState(() {});
  }

  // ===========================================================================
  // CLEAR PRODUCT RATES
  // ===========================================================================

  void _clearProductRates(
    String productId,
  ) {
    setState(() {
      _selectedRates.remove(productId);
      _packingQuantities.remove(productId);
    });
  }

  // ===========================================================================
  // DONE
  // ===========================================================================

  void _done() {
    debugPrint('========================================');
    debugPrint('BOTTOM SHEET RESULT');
    debugPrint('Selected rates: $_selectedRates');
    debugPrint(
      'Packing quantities: $_packingQuantities',
    );
    debugPrint('========================================');

    final result =
        MultiProductRateSelectionResult(
      selectedRates: {
        for (final entry in _selectedRates.entries)
          entry.key:
              List<ProductRateEntity>.from(
            entry.value,
          ),
      },
      packingQuantities: {
        for (final entry
            in _packingQuantities.entries)
          entry.key:
              Map<String, int>.from(
            entry.value,
          ),
      },
    );

    Navigator.of(context).pop(result);
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height:
            MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(24.r),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildSelectedProduct(),
            Expanded(
              child: _buildRatesArea(),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18.w,
        14.h,
        12.w,
        14.h,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 42.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius:
                  BorderRadius.circular(20.r),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration:
                    const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.price_check_rounded,
                  color: AppColors.primary,
                  size: 23.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Product Rates',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Select one or more packings',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight:
                            FontWeight.w500,
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
                icon: Icon(
                  Icons.close_rounded,
                  color:
                      AppColors.textSecondary,
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SELECTED PRODUCT
  // ===========================================================================

  Widget _buildSelectedProduct() {
    final product = _selectedProduct;

    if (product == null) {
      return const SizedBox.shrink();
    }

    final productId =
        product.id.toString();

    final selectedCount =
        _selectedCount(productId);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        14.w,
        10.h,
        14.w,
        4.h,
      ),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius:
            BorderRadius.circular(13.r),
        border: Border.all(
          color:
              AppColors.primary.withOpacity(
            0.15,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
                  BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
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
                  product.name,
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
                SizedBox(height: 3.h),
                Text(
                  selectedCount == 0
                      ? 'Select packing / rate'
                      : '$selectedCount packing selected',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight:
                        FontWeight.w600,
                    color: selectedCount == 0
                        ? AppColors
                            .textSecondary
                        : AppColors.primary,
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
  // RATES AREA
  // ===========================================================================

  Widget _buildRatesArea() {
    if (_selectedProductId == null) {
      return _buildEmptyState(
        icon:
            Icons.inventory_2_outlined,
        title: 'Select a product',
        subtitle:
            'Choose a product to view available rates',
      );
    }

    if (_isLoadingRates) {
      return Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 14.h),
            Text(
              'Loading rates...',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildEmptyState(
        icon:
            Icons.error_outline_rounded,
        title:
            'Unable to load rates',
        subtitle:
            _errorMessage!,
      );
    }

    final rates =
        _ratesCache[
                _selectedProductId!] ??
            <ProductRateEntity>[];

    if (rates.isEmpty) {
      return _buildEmptyState(
        icon:
            Icons.price_change_outlined,
        title:
            'No rates available',
        subtitle:
            'No rates were found for this product',
      );
    }

    final selectedCount =
        _selectedCount(
      _selectedProductId!,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            14.h,
            16.w,
            10.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Available Packings',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ),
              if (selectedCount > 0)
                TextButton(
                  onPressed: () {
                    _clearProductRates(
                      _selectedProductId!,
                    );
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color:
                          AppColors.primary,
                      fontSize: 12.sp,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child:
              ListView.separated(
            padding:
                EdgeInsets.fromLTRB(
              14.w,
              0,
              14.w,
              20.h,
            ),
            physics:
                const BouncingScrollPhysics(),
            itemCount:
                rates.length,
            separatorBuilder:
                (_, __) =>
                    SizedBox(height: 10.h),
            itemBuilder:
                (context, index) {
              return _buildRateCard(
                productId:
                    _selectedProductId!,
                rate:
                    rates[index],
              );
            },
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // RATE CARD
  // ===========================================================================

  Widget _buildRateCard({
    required String productId,
    required ProductRateEntity rate,
  }) {
    final selected =
        _isRateSelected(
      productId,
      rate,
    );

    final String productDetailsId =
        rate.productDetailsId.toString();

    final int quantity =
        _quantity(
      productId,
      productDetailsId,
    );

    return InkWell(
      onTap: () {
        _toggleRate(
          productId,
          rate,
        );
      },
      borderRadius:
          BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 160,
        ),
        padding:
            EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightGreen
              : Colors.white,
          borderRadius:
              BorderRadius.circular(16.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border,
            width:
                selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.035,
              ),
              blurRadius: 8,
              offset:
                  const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              activeColor:
                  AppColors.primary,
              checkColor:
                  Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  5.r,
                ),
              ),
              onChanged: (_) {
                _toggleRate(
                  productId,
                  rate,
                );
              },
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Packing: ${rate.packing} ${rate.unit}',
                          style:
                              TextStyle(
                            fontSize:
                                13.sp,
                            fontWeight:
                                FontWeight.w800,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '₹${rate.rateWithGst}',
                        style:
                            TextStyle(
                          fontSize:
                              15.sp,
                          fontWeight:
                              FontWeight.w900,
                          color: AppColors
                              .primary,
                        ),
                      ),
                    ],
                  ),

                  // ==========================================================
                  // PACKING-WISE QUANTITY
                  // ==========================================================

                  if (selected)
                    Padding(
                      padding:
                          EdgeInsets.only(
                        top: 8.h,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 32.h,
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                8.r,
                              ),
                              border:
                                  Border.all(
                                color: AppColors
                                    .primary
                                    .withOpacity(
                                  0.20,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize
                                      .min,
                              children: [
                                InkWell(
                                  onTap:
                                      quantity >
                                              1
                                          ? () {
                                              _decreaseQuantity(
                                                productId,
                                                productDetailsId,
                                              );
                                            }
                                          : null,
                                  child:
                                      SizedBox(
                                    width:
                                        32.w,
                                    height:
                                        32.h,
                                    child:
                                        Icon(
                                      Icons
                                          .remove_rounded,
                                      size:
                                          16.sp,
                                      color: quantity >
                                              1
                                          ? AppColors
                                              .primary
                                          : AppColors
                                              .border,
                                    ),
                                  ),
                                ),
                                Container(
                                  constraints:
                                      BoxConstraints(
                                    minWidth:
                                        30.w,
                                  ),
                                  alignment:
                                      Alignment
                                          .center,
                                  child:
                                      Text(
                                    '$quantity',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          12.sp,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                      color: AppColors
                                          .primary,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _increaseQuantity(
                                      productId,
                                      productDetailsId,
                                    );
                                  },
                                  child:
                                      SizedBox(
                                    width:
                                        32.w,
                                    height:
                                        32.h,
                                    child:
                                        Icon(
                                      Icons
                                          .add_rounded,
                                      size:
                                          16.sp,
                                      color: AppColors
                                          .primary,
                                    ),
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
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding:
            EdgeInsets.all(25.w),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 62.w,
              height: 62.w,
              decoration:
                  const BoxDecoration(
                color:
                    AppColors.lightGreen,
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                icon,
                color:
                    AppColors.primary,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight:
                    FontWeight.w800,
                color: AppColors
                    .textPrimary,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              subtitle,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight:
                    FontWeight.w500,
                color: AppColors
                    .textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // BOTTOM BUTTON
  // ===========================================================================

  Widget _buildBottomButton() {
    return Container(
      padding:
          EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        14.h,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width:
              double.infinity,
          height: 52.h,
          child:
              ElevatedButton(
            onPressed:
                _totalSelectedRates ==
                        0
                    ? null
                    : _done,
            style:
                ElevatedButton
                    .styleFrom(
              backgroundColor:
                  AppColors.primary,
              disabledBackgroundColor:
                  AppColors.border,
              foregroundColor:
                  Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  15.r,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons
                      .check_circle_outline_rounded,
                ),
                SizedBox(width: 8.w),
                Text(
                  _totalSelectedRates ==
                          0
                      ? 'Select Rate'
                      : 'Done ($_totalSelectedRates Selected)',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}