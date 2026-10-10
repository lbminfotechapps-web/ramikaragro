import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:solufine/core/secure_storage/secure_storage.dart';
import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/features/dealer/data/models/dealer_products.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_bloc.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_event.dart';
import 'package:solufine/features/dealer/presentation/bloc/dealerlist_state.dart';
import 'package:solufine/features/dealer/presentation/pages/dealer_product_preview.dart';

import 'package:solufine/features/dealer/presentation/widgets/dealer_selected_card.dart';
import 'package:solufine/features/dealer/presentation/widgets/product_stock_card.dart';
import 'package:solufine/features/place_order/domain/entities/category_entity.dart';
import 'package:solufine/features/place_order/domain/entities/dealer_entity.dart';
import 'package:solufine/features/place_order/domain/entities/product_entity.dart';
import 'package:solufine/features/place_order/domain/entities/product_rate_entity.dart';
import 'package:solufine/features/place_order/presentation/bloc/place_order_bloc.dart';
import 'package:solufine/features/place_order/presentation/bloc/place_order_state.dart';

import '../../../place_order/presentation/bloc/place_order_event.dart';

class Dealerstocks extends StatefulWidget {
  const Dealerstocks({super.key});

  @override
  State<Dealerstocks> createState() => _DealerstocksState();
}

class _DealerstocksState extends State<Dealerstocks> {
  final TextEditingController dealerController = TextEditingController();
  final TextEditingController productSearchController = TextEditingController();

  DealerEntity? selectedDealer;

  final List<ProductEntity> allCategoryProducts = [];

  final Map<String, List<ProductRateEntity>> selectedRates = {};

  final List<CategoryEntity> selectedCategories = [];

  /// ProductId -> Quantity
  final Map<String, int> productQuantities = {};

  String productSearchText = '';

  Future<void> _searchDealer(String value) async {
    final searchText = value.trim();

    if (searchText.isEmpty) {
      return;
    }

    final userData = await SecureStorage.instance.getUserData();

    final String rawUserId = userData?['user_id']?.toString().trim() ?? '';

    final int userId = int.tryParse(rawUserId) ?? 0;

    context.read<PlaceOrderBloc>().add(
      SearchDealerEvent(userId: userId, searchText: searchText),
    );
  }

  void _clearAllSelectedProducts() {
    final bloc = context.read<PlaceOrderBloc>();
    final currentState = bloc.state;

    for (final product in allCategoryProducts) {
      final String productId = product.id.toString();

      final Map<String, int> packingQuantities =
          currentState.packingQuantities[productId] ?? <String, int>{};

      final bool hasQuantity = packingQuantities.values.any(
        (quantity) => quantity > 0,
      );

      if (hasQuantity) {
        bloc.add(RemoveProductEvent(productId: product.id));
      }
    }

    setState(() {
      selectedRates.clear();
      productQuantities.clear();
      allCategoryProducts.clear();
      productSearchController.clear();
      productSearchText = '';
    });
  }

  void _selectDealer(DealerEntity dealer) {
    setState(() {
      selectedDealer = dealer;

      // clear old product search
      productSearchController.clear();
      productSearchText = '';

      // clear old entered quantities
      productQuantities.clear();
    });

    context.read<DealerListBloc>().add(
      DealerProductListEvent(dealerId: dealer.id.toString()),
    );
  }

  // ===========================================================================
  // CLEAR DEALER
  // ===========================================================================

  void _clearDealer() {
    _clearAllSelectedProducts();

    setState(() {
      selectedDealer = null;

      dealerController.clear();

      selectedCategories.clear();
    });
  }

  // // ===========================================================================
  // // PRODUCT QUANTITY
  // // ===========================================================================

  // void _increaseQuantity(ProductEntity product) {
  //   final id = product.id.toString();

  //   setState(() {
  //     productQuantities[id] = (productQuantities[id] ?? 0) + 1;
  //   });
  // }

  // void _decreaseQuantity(ProductEntity product) {
  //   final id = product.id.toString();

  //   final currentQuantity = productQuantities[id] ?? 0;

  //   if (currentQuantity <= 0) {
  //     return;
  //   }

  //   setState(() {
  //     final newQuantity = currentQuantity - 1;

  //     if (newQuantity == 0) {
  //       productQuantities.remove(id);
  //     } else {
  //       productQuantities[id] = newQuantity;
  //     }
  //   });
  // }

  int get _totalQuantity {
    return productQuantities.values.fold(
      0,
      (total, quantity) => total + quantity,
    );
  }

  int get _selectedProductCount {
    return productQuantities.values.where((quantity) => quantity > 0).length;
  }

  void _openStockPreview() {
    // ===========================================================================
    // DEALER VALIDATION
    // ===========================================================================

    if (selectedDealer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dealer first')),
      );

      return;
    }

    // ===========================================================================
    // PRODUCT VALIDATION
    // ===========================================================================

    if (productQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product quantity'),
        ),
      );

      return;
    }

    // ===========================================================================
    // GET CURRENT PRODUCT LIST FROM BLOC
    // ===========================================================================

    final DealerListState currentState = context.read<DealerListBloc>().state;

    final List<DealerStockProductModel> selectedProducts = currentState
        .productList
        .where((product) {
          final int quantity = productQuantities[product.productDetailsId] ?? 0;

          return quantity > 0;
        })
        .toList();

    // ===========================================================================
    // SAFETY CHECK
    // ===========================================================================

    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No selected product found')),
      );

      return;
    }

    // ===========================================================================
    // DEBUG
    // ===========================================================================

    debugPrint('=======================================');

    debugPrint('OPEN STOCK PREVIEW');

    debugPrint('Dealer: ${selectedDealer!.name}');

    debugPrint('Products: ${selectedProducts.length}');

    for (final product in selectedProducts) {
      final int quantity = productQuantities[product.productDetailsId] ?? 0;

      debugPrint('${product.productName} -> $quantity');
    }

    debugPrint('=======================================');

    // ===========================================================================
    // OPEN PREVIEW
    // ===========================================================================

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DealerProductPreviewPage(
          dealer: selectedDealer!,

          products: selectedProducts,

          productQuantities: Map<String, int>.from(productQuantities),
        ),
      ),
    );
  }

  /*
  void _submitStock() {
    if (selectedDealer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dealer first')),
      );

      return;
    }

    if (productQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product quantity'),
        ),
      );

      return;
    }

    debugPrint('Dealer ID: ${selectedDealer!.id}');

    productQuantities.forEach((productId, quantity) {
      debugPrint('Product ID: $productId | Quantity: $quantity');
    });
  }
  */

  List<DealerStockProductModel> _filterProducts(
    List<DealerStockProductModel> products,
  ) {
    final String search = productSearchText.trim().toLowerCase();

    if (search.isEmpty) {
      return products;
    }

    return products.where((product) {
      final String productName = product.productName.toLowerCase();

      final String packing = product.packing.toLowerCase();

      final String unit = product.unit.toLowerCase();

      final String productId = product.productId.toLowerCase();

      return productName.contains(search) ||
          packing.contains(search) ||
          unit.contains(search) ||
          productId.contains(search);
    }).toList();
  }

  @override
  void dispose() {
    dealerController.dispose();
    productSearchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Column(
        children: [
          // ---------------------------------------------------------
          // DEALER AREA
          // ---------------------------------------------------------
          BlocBuilder<PlaceOrderBloc, PlaceOrderState>(
            builder: (context, state) {
              return DealerSelectorCard(
                controller: dealerController,
                dealers: state.dealers,
                selectedDealer: selectedDealer,
                onChanged: _searchDealer,
                onDealerSelected: _selectDealer,
                onClearSelected: _clearDealer,
              );
            },
          ),

          SizedBox(height: 14.h),

          // ---------------------------------------------------------
          // PRODUCT SEARCH HEADER
          // ---------------------------------------------------------
          _buildProductHeader(),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: context.appBackground,

      appBar: CustomAppBar(title: 'Dealer Stock', showBackButton: true),

      body: SafeArea(
        child: selectedDealer == null
            ? LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        header,
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: _buildSelectDealerEmptyState(),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  // ===============================================================
                  // FIXED TOP AREA
                  // ===============================================================
                  header,

                  SizedBox(height: 8.h),

                  // ===============================================================
                  // PRODUCT LIST
                  // ===============================================================
                  Expanded(
                    child: selectedDealer == null
                        ? _buildSelectDealerEmptyState()
                        : BlocBuilder<DealerListBloc, DealerListState>(
                            builder: (context, state) {
                              // =========================================================
                              // LOADING
                              // =========================================================

                              if (state.status == DealerListStatus.loading &&
                                  state.productList.isEmpty) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: context.appPrimary,
                                  ),
                                );
                              }

                              // =========================================================
                              // API PRODUCT LIST
                              // =========================================================

                              final List<DealerStockProductModel> allProducts =
                                  state.productList;

                              // =========================================================
                              // LOCAL FILTER
                              // =========================================================

                              final List<DealerStockProductModel>
                              filteredProducts = _filterProducts(allProducts);

                              // =========================================================
                              // EMPTY API LIST
                              // =========================================================

                              if (allProducts.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 42.sp,
                                        color: context.appSubText,
                                      ),

                                      SizedBox(height: 8.h),

                                      Text(
                                        'No products available',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: context.appSubText,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // =========================================================
                              // SEARCH EMPTY
                              // =========================================================

                              if (filteredProducts.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 40.sp,
                                        color: context.appSubText,
                                      ),

                                      SizedBox(height: 8.h),

                                      Text(
                                        'No product found',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: context.appSubText,
                                        ),
                                      ),

                                      SizedBox(height: 3.h),

                                      Text(
                                        'Try another product name',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: context.appSubText,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              // =========================================================
                              // REAL PRODUCT LIST
                              // =========================================================

                              return ListView.separated(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  8.h,
                                  16.w,
                                  110.h,
                                ),

                                itemCount: filteredProducts.length,

                                separatorBuilder: (_, __) {
                                  return SizedBox(height: 8.h);
                                },

                                itemBuilder: (context, index) {
                                  final DealerStockProductModel product =
                                      filteredProducts[index];

                                  // Use productDetailsId because
                                  // one product may have multiple
                                  // packing/detail rows.
                                  final String key = product.productDetailsId;

                                  final int quantity =
                                      productQuantities[key] ?? 0;

                                  return ProductStockCard(
                                    product: product,

                                    quantity: quantity,

                                    onQuantityChanged: (qty) {
                                      setState(() {
                                        if (qty <= 0) {
                                          productQuantities.remove(key);
                                        } else {
                                          productQuantities[key] = qty;
                                        }
                                      });

                                      debugPrint(
                                        '================================',
                                      );

                                      debugPrint(
                                        'PRODUCT: ${product.productName}',
                                      );

                                      debugPrint(
                                        'PRODUCT ID: ${product.productId}',
                                      );

                                      debugPrint(
                                        'DETAIL ID: ${product.productDetailsId}',
                                      );

                                      debugPrint(
                                        'PACKING: ${product.packing} ${product.unit}',
                                      );

                                      debugPrint('QTY: $qty');

                                      debugPrint(
                                        '================================',
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: selectedDealer == null
          ? null
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),

              child: SizedBox(
                width: double.infinity,

                height: 54.h,

                child: ElevatedButton(
                  // =========================================================
                  // OPEN PREVIEW
                  // =========================================================
                  onPressed: productQuantities.isEmpty
                      ? null
                      : _openStockPreview,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appPrimary,

                    disabledBackgroundColor: context.appPrimary.withOpacity(
                      0.35,
                    ),

                    foregroundColor: context.appOnPrimary,

                    elevation: 5,

                    shadowColor: context.appPrimary.withOpacity(0.25),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(
                        Icons.preview_rounded,

                        color: context.appOnPrimary,

                        size: 20.sp,
                      ),

                      SizedBox(width: 9.w),

                      Flexible(
                        child: Text(
                          _totalQuantity > 0
                              ? 'Preview  •  $_selectedProductCount Products / $_totalQuantity Qty'
                              : 'Preview',

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            color: context.appOnPrimary,

                            fontSize: 13.sp,

                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(width: 6.w),

                      Icon(
                        Icons.arrow_forward_rounded,

                        color: context.appOnPrimary,

                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // =========================================================================
  // PRODUCT SEARCH HEADER
  // =========================================================================
  Widget _buildProductHeader() {
    return Container(
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.appBorder),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // HEADER
          // ============================================================
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 7.h),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,

                  decoration: BoxDecoration(
                    color: Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard),
                    borderRadius: BorderRadius.circular(8.r),
                  ),

                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: context.appPrimary,
                    size: 17.sp,
                  ),
                ),

                SizedBox(width: 8.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: context.appOnCard,
                        ),
                      ),

                      Text(
                        'Add stock quantity',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: context.appSubText,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_selectedProductCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      '$_selectedProductCount selected',
                      style: TextStyle(
                        color: context.appPrimary,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: context.appBorder),

          // ============================================================
          // LOCAL PRODUCT SEARCH
          // ============================================================
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: context.appInputBackground,
                borderRadius: BorderRadius.circular(10.r),
              ),

              child: TextField(
                controller: productSearchController,

                // Only enable after dealer is selected.
                enabled: selectedDealer != null,

                // ======================================================
                // THIS IS LOCAL SEARCH
                // No Bloc event.
                // No API request.
                // ======================================================
                onChanged: (value) {
                  setState(() {
                    productSearchText = value;
                  });
                },

                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),

                decoration: InputDecoration(
                  hintText: selectedDealer == null
                      ? 'Select dealer first'
                      : 'Search products...',

                  hintStyle: TextStyle(
                    fontSize: 11.sp,
                    color: context.appSubText,
                  ),

                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: context.appPrimary,
                    size: 18.sp,
                  ),

                  prefixIconConstraints: BoxConstraints(minWidth: 38.w),

                  suffixIcon: productSearchText.isNotEmpty
                      ? InkWell(
                          onTap: () {
                            productSearchController.clear();

                            setState(() {
                              productSearchText = '';
                            });
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 17.sp,
                            color: context.appSubText,
                          ),
                        )
                      : null,

                  suffixIconConstraints: BoxConstraints(minWidth: 36.w),

                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,

                  isDense: true,

                  contentPadding: EdgeInsets.symmetric(vertical: 11.h),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // EMPTY STATE
  // =========================================================================

  Widget _buildSelectDealerEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: context.appPrimary,
                size: 32.sp,
              ),
            ),

            SizedBox(height: 15.h),

            Text(
              'Select a dealer',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: context.appOnCard,
              ),
            ),

            SizedBox(height: 5.h),

            Text(
              'Choose a dealer above to start entering product stock.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.4,
                color: context.appSubText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
