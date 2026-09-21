
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/features/place_order/domain/entities/product_entity.dart';
import 'package:solufine/features/place_order/domain/entities/product_rate_entity.dart';
import 'package:solufine/features/place_order/domain/usecases/get_product_detail_rates_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

/// ===========================================================================
/// RESULT
/// ===========================================================================
///
/// selectedRates:
/// Product ID -> selected packing/rates
///
/// packingQuantities:
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

  late Map<String, List<ProductRateEntity>> _selectedRates;

  late Map<String, Map<String, int>> _packingQuantities;

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

    // -------------------------------------------------------------------------
    // COPY EXISTING SELECTED RATES
    // -------------------------------------------------------------------------

    _selectedRates = {
      for (final entry in widget.existingRates.entries)
        entry.key: List<ProductRateEntity>.from(entry.value),
    };

    // -------------------------------------------------------------------------
    // COPY EXISTING QUANTITIES
    // -------------------------------------------------------------------------

    _packingQuantities = {
      for (final entry in widget.existingPackingQuantities.entries)
        entry.key: Map<String, int>.from(entry.value),
    };

    // -------------------------------------------------------------------------
    // SELECT INITIAL PRODUCT
    // -------------------------------------------------------------------------

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

    // -------------------------------------------------------------------------
    // LOAD RATES
    // -------------------------------------------------------------------------

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

      for (final rate in rates) {
        debugPrint(
          'RATE => '
          'detailsId=${rate.productDetailsId}, '
          'packing=${rate.packing}, '
          'unit=${rate.unit}, '
          'unitsPerCase="${rate.unitsPerCase}", '
          'displayCase="${rate.displayCase}", '
          'rate=${rate.rateWithGst}',
        );
      }
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
  // QUANTITY
  // ===========================================================================

  int _quantity(
    String productId,
    String productDetailsId,
  ) {
    return _packingQuantities[productId]?[productDetailsId] ?? 1;
  }

  // ===========================================================================
  // INCREASE QUANTITY
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
  // DECREASE QUANTITY
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

    // -------------------------------------------------------------------------
    // REMOVE
    // -------------------------------------------------------------------------

    if (existingIndex >= 0) {
      current.removeAt(existingIndex);

      final productDetailsId =
          rate.productDetailsId.toString();

      _packingQuantities[productId]
          ?.remove(productDetailsId);

      if (current.isEmpty) {
        _selectedRates.remove(productId);
        _packingQuantities.remove(productId);
      } else {
        _selectedRates[productId] = current;
      }
    }

    // -------------------------------------------------------------------------
    // ADD
    // -------------------------------------------------------------------------

    else {
      current.add(rate);

      _selectedRates[productId] = current;

      final productQuantities =
          _packingQuantities.putIfAbsent(
        productId,
        () => <String, int>{},
      );

      final productDetailsId =
          rate.productDetailsId.toString();

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
  // CLEAR
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
            top: Radius.circular(22.r),
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
        16.w,
        9.h,
        7.w,
        9.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(22.r),
        ),
      ),
      child: Column(
        children: [
          // DRAG HANDLE
          Container(
            width: 36.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius:
                  BorderRadius.circular(20.r),
            ),
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration:
                    const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.price_check_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),

              SizedBox(width: 9.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Product Rates',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight:
                            FontWeight.w800,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Select one or more packings',
                      style: TextStyle(
                        fontSize: 9.5.sp,
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
                  minWidth: 34.w,
                  minHeight: 34.w,
                ),
                icon: Icon(
                  Icons.close_rounded,
                  color:
                      AppColors.textSecondary,
                  size: 20.sp,
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
        12.w,
        7.h,
        12.w,
        2.h,
      ),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius:
            BorderRadius.circular(11.r),
        border: Border.all(
          color:
              AppColors.primary.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
                  BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),

          SizedBox(width: 8.w),

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
                    fontSize: 12.sp,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  selectedCount == 0
                      ? 'Select packing / rate'
                      : '$selectedCount packing selected',
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight:
                        FontWeight.w600,
                    color: selectedCount == 0
                        ? AppColors.textSecondary
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
            SizedBox(
              width: 27.w,
              height: 27.w,
              child:
                  const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Loading rates...',
              style: TextStyle(
                fontSize: 11.sp,
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
        _ratesCache[_selectedProductId!] ??
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
        // ---------------------------------------------------------------------
        // SECTION TITLE
        // ---------------------------------------------------------------------

        Padding(
          padding: EdgeInsets.fromLTRB(
            13.w,
            7.h,
            13.w,
            6.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Available Packings',
                  style: TextStyle(
                    fontSize: 13.5.sp,
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
                  style:
                      TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.h,
                    ),
                    minimumSize:
                        Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize
                            .shrinkWrap,
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color:
                          AppColors.primary,
                      fontSize: 10.5.sp,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ---------------------------------------------------------------------
        // RATE LIST
        // ---------------------------------------------------------------------

        Expanded(
          child:
              ListView.separated(
            padding:
                EdgeInsets.fromLTRB(
              12.w,
              0,
              12.w,
              10.h,
            ),
            physics:
                const BouncingScrollPhysics(),
            itemCount:
                rates.length,
            separatorBuilder:
                (_, __) =>
                    SizedBox(height: 6.h),
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

    final productDetailsId =
        rate.productDetailsId.toString();

    final quantity =
        _quantity(
      productId,
      productDetailsId,
    );

    // Debug to verify Unit Per Case.
    debugPrint(
      'RATE CARD => '
      'Product=$productId | '
      'Details=$productDetailsId | '
      'Packing=${rate.packing} ${rate.unit} | '
      'UnitsPerCase="${rate.unitsPerCase}" | '
      'DisplayCase="${rate.displayCase}"',
    );

    return InkWell(
      onTap: () {
        _toggleRate(
          productId,
          rate,
        );
      },
      borderRadius:
          BorderRadius.circular(13.r),
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 150,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 9.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lightGreen
              : Colors.white,
          borderRadius:
              BorderRadius.circular(13.r),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border,
            width:
                selected ? 1.3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primary
                      .withOpacity(0.07)
                  : Colors.black
                      .withOpacity(0.018),
              blurRadius:
                  selected ? 7 : 5,
              offset:
                  const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // =================================================================
            // FIRST ROW
            // Packing + Price
            // =================================================================

            Row(
              children: [
                // CHECKBOX
                SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: Checkbox(
                    value: selected,
                    activeColor:
                        AppColors.primary,
                    checkColor:
                        Colors.white,
                    materialTapTargetSize:
                        MaterialTapTargetSize
                            .shrinkWrap,
                    visualDensity:
                        VisualDensity.compact,
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
                ),

                SizedBox(width: 6.w),

                // PACKING
                Expanded(
                  child: Text(
                    'Packing: ${rate.packing} ${rate.unit}',
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
                ),

                SizedBox(width: 7.w),

                // PRICE
                Text(
                  rate.displayRate,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        AppColors.primary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            // =================================================================
            // SECOND ROW
            // Unit Per Case + GST + Quantity
            // =================================================================

            Row(
              children: [
                // UNIT PER CASE
                _rateInfoBadge(
                  icon:
                      Icons.inventory_2_rounded,
                  label:
                      'Unit/Case',
                  value:
                      rate.displayCase,
                  highlighted: true,
                ),

                SizedBox(width: 5.w),

                // // GST
                // _rateInfoBadge(
                //   icon:
                //       Icons.percent_rounded,
                //   label: 'GST',
                //   value:
                //       '${rate.gstPercentage}%',
                //   highlighted: false,
                // ),

                const Spacer(),

                // QUANTITY
                if (selected)
                  _buildQuantityControl(
                    productId:
                        productId,
                    productDetailsId:
                        productDetailsId,
                    quantity:
                        quantity,
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

  Widget _rateInfoBadge({
    required IconData icon,
    required String label,
    required String value,
    required bool highlighted,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.lightGreen.withOpacity(0.85)
            : Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(6.r),
        border: Border.all(
          color: highlighted
              ? AppColors.primary
                  .withOpacity(0.12)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10.sp,
            color: highlighted
                ? AppColors.primary
                : AppColors.textSecondary,
          ),

          SizedBox(width: 3.w),

          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors.textSecondary,
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 8.5.sp,
              fontWeight:
                  FontWeight.w800,
              color: highlighted
                  ? AppColors.primary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // QUANTITY CONTROL
  // ===========================================================================

  Widget _buildQuantityControl({
    required String productId,
    required String productDetailsId,
    required int quantity,
  }) {
    return Container(
      height: 28.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(7.r),
        border: Border.all(
          color:
              AppColors.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          InkWell(
            onTap: quantity > 1
                ? () {
                    _decreaseQuantity(
                      productId,
                      productDetailsId,
                    );
                  }
                : null,
            child: SizedBox(
              width: 27.w,
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
              minWidth: 27.w,
            ),
            alignment:
                Alignment.center,
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight:
                    FontWeight.w900,
                color:
                    AppColors.primary,
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
            child: SizedBox(
              width: 27.w,
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
            EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
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
                size: 27.sp,
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight:
                    FontWeight.w800,
                color:
                    AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 4.h),

            Text(
              subtitle,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight:
                    FontWeight.w500,
                color:
                    AppColors.textSecondary,
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
    final enabled =
        _totalSelectedRates > 0;

    return Container(
      padding:
          EdgeInsets.fromLTRB(
        13.w,
        8.h,
        13.w,
        10.h,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.07,
            ),
            blurRadius: 10,
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
          height: 46.h,
          child:
              ElevatedButton(
            onPressed:
                enabled ? _done : null,
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.primary,
              disabledBackgroundColor:
                  Colors.grey.shade300,
              disabledForegroundColor:
                  Colors.grey.shade600,
              foregroundColor:
                  Colors.white,
              elevation: 0,
              padding:
                  EdgeInsets.zero,
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
                      .check_circle_outline_rounded,
                  size: 18.sp,
                ),

                SizedBox(width: 7.w),

                Text(
                  enabled
                      ? 'Done ($_totalSelectedRates Selected)'
                      : 'Select Rate',
                  style: TextStyle(
                    fontSize: 13.sp,
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


