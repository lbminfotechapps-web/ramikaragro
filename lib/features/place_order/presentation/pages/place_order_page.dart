import 'dart:typed_data';

import 'package:demo/core/di/place_order_target_di.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/theme/app_colors.dart';

import 'package:demo/features/place_order/domain/entities/category_entity.dart';
import 'package:demo/features/place_order/domain/entities/dealer_entity.dart';
import 'package:demo/features/place_order/domain/entities/godown_entity.dart';
import 'package:demo/features/place_order/domain/entities/product_entity.dart';
import 'package:demo/features/place_order/domain/entities/product_rate_entity.dart';

import 'package:demo/features/place_order/domain/usecases/get_product_detail_rates_usecase.dart';

import 'package:demo/features/place_order/presentation/bloc/place_order_bloc.dart';
import 'package:demo/features/place_order/presentation/bloc/place_order_event.dart';
import 'package:demo/features/place_order/presentation/bloc/place_order_state.dart';

import 'package:demo/features/place_order/presentation/widgets/dealer_search_field.dart';
import 'package:demo/features/place_order/presentation/widgets/image_picker_section.dart';
import 'package:demo/features/place_order/presentation/widgets/modern_dropdown.dart';
import 'package:demo/features/place_order/presentation/widgets/order_preview_sheet.dart';
import 'package:demo/features/place_order/presentation/widgets/product_card.dart';
import 'package:demo/features/place_order/presentation/widgets/product_rate_bottom_sheet.dart';
import 'package:demo/features/place_order/presentation/widgets/signature_section.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:signature/signature.dart';

class PlaceOrderPage extends StatefulWidget {
  const PlaceOrderPage({
    super.key,
  });

  @override
  State<PlaceOrderPage> createState() =>
      _PlaceOrderPageState();
}

class _PlaceOrderPageState extends State<PlaceOrderPage> {
  int? userId;

  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ===========================================================================
  // LOAD USER
  // ===========================================================================

  Future<void> _loadUser() async {
    try {
      final storage = SecureStorage.instance;

      final userData = await storage.getUserData();

      if (userData == null) {
        if (!mounted) return;

        setState(() {
          userId = null;
          isLoadingUser = false;
        });

        return;
      }

      final id = int.tryParse(
        userData['user_id']?.toString() ?? '',
      );

      if (!mounted) return;

      setState(() {
        userId = id;
        isLoadingUser = false;
      });
    } catch (e) {
      debugPrint(
        'PlaceOrder user load error: $e',
      );

      if (!mounted) return;

      setState(() {
        userId = null;
        isLoadingUser = false;
      });
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    // =========================================================================
    // USER NOT FOUND
    // =========================================================================

    if (userId == null || userId! <= 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 3,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            'Place Order',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(18.w),
                  decoration: const BoxDecoration(
                    color: AppColors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_off_rounded,
                    size: 50.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(
                  height: 18.h,
                ),
                Text(
                  'User information not found',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  'Please login again and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // =========================================================================
    // BLOC
    // =========================================================================

    return BlocProvider(
      create: (_) =>
          sl<PlaceOrderBloc>()
            ..add(
              LoadPlaceOrderEvent(
                userId: userId!,
              ),
            ),
      child: _PlaceOrderView(
        userId: userId!,
      ),
    );
  }
}

// =============================================================================
// PLACE ORDER VIEW
// =============================================================================

class _PlaceOrderView extends StatefulWidget {
  final int userId;

  const _PlaceOrderView({
    required this.userId,
  });

  @override
  State<_PlaceOrderView> createState() =>
      _PlaceOrderViewState();
}

class _PlaceOrderViewState
    extends State<_PlaceOrderView> {
  // ===========================================================================
  // CONTROLLERS
  // ===========================================================================

  final TextEditingController dealerController =
      TextEditingController();

  final TextEditingController remarkController =
      TextEditingController();

  final SignatureController signatureController =
      SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  // ===========================================================================
  // SELECTED DATA
  // ===========================================================================

  DealerEntity? selectedDealer;

  GodownEntity? selectedGodown;

  CategoryEntity? selectedCategory;

  String? imagePath;

  Uint8List? signatureBytes;

  // ===========================================================================
  // SELECTED PRODUCT RATES
  // ===========================================================================
  //
  // productId -> selected rate
  //
  // Example:
  //
  // "1" -> 5 kg / ₹200
  //
  // ===========================================================================

  final Map<String, ProductRateEntity> selectedRates = {};

  // ===========================================================================
  // PRODUCT RATE LOADING
  // ===========================================================================

  String? loadingProductRateId;

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    dealerController.dispose();
    remarkController.dispose();
    signatureController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // DEALER SEARCH
  // ===========================================================================

  void _searchDealer(
    String value,
  ) {
    final searchText = value.trim();

    if (searchText.isEmpty) {
      return;
    }

    context.read<PlaceOrderBloc>().add(
          SearchDealerEvent(
            userId: widget.userId,
            searchText: searchText,
          ),
        );
  }

  // ===========================================================================
  // SELECT DEALER
  // ===========================================================================

  void _selectDealer(
    DealerEntity dealer,
  ) {
    setState(() {
      selectedDealer = dealer;
      dealerController.text = dealer.name;

      // Rate belongs to dealer.
      // Therefore changing dealer must remove old rates.
      selectedRates.clear();
    });
  }

  // ===========================================================================
  // CLEAR DEALER
  // ===========================================================================

  void _clearDealer() {
    setState(() {
      selectedDealer = null;
      dealerController.clear();
      selectedRates.clear();
    });
  }

  // ===========================================================================
  // SELECT CATEGORY
  // ===========================================================================

  void _selectCategory(
    CategoryEntity? category,
  ) {
    if (category == null) {
      return;
    }

    setState(() {
      selectedCategory = category;

      // Old product rates should not remain
      // when category changes.
      selectedRates.clear();
    });

    context.read<PlaceOrderBloc>().add(
          GetProductsEvent(
            categoryId: category.id,
          ),
        );
  }

  // ===========================================================================
  // CLEAR SIGNATURE
  // ===========================================================================

  void _clearSignature() {
    signatureController.clear();

    setState(() {
      signatureBytes = null;
    });
  }

  // ===========================================================================
  // SIGNATURE CHANGED
  // ===========================================================================

  void _onSignatureChanged(
    Uint8List? bytes,
  ) {
    setState(() {
      signatureBytes = bytes;
    });
  }

  // ===========================================================================
  // ADD PRODUCT
  // ===========================================================================
  //
  // FIRST CLICK:
  //
  // Product
  //    ↓
  // Dealer ID + Product ID
  //    ↓
  // API
  //    ↓
  // ProductRateBottomSheet
  //    ↓
  // Select packing/rate
  //    ↓
  // quantity = 1
  //
  // ===========================================================================

  Future<void> _addProduct(
    ProductEntity product,
  ) async {
    // -------------------------------------------------------------------------
    // DEALER VALIDATION
    // -------------------------------------------------------------------------

    if (selectedDealer == null) {
      _showMessage(
        'Please select dealer first',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // PRODUCT ID
    // -------------------------------------------------------------------------

    final String productId =
        product.id.toString();

    // -------------------------------------------------------------------------
    // IMPORTANT:
    //
    // If this product already has a selected rate,
    // do not call API again.
    // -------------------------------------------------------------------------

    if (selectedRates.containsKey(productId)) {
      final currentQuantity =
          context
                  .read<PlaceOrderBloc>()
                  .state
                  .quantities[product.id] ??
              0;

      context.read<PlaceOrderBloc>().add(
            ChangeProductQuantityEvent(
              productId: product.id,
              quantity: currentQuantity + 1,
            ),
          );

      return;
    }

    // -------------------------------------------------------------------------
    // PREVENT DOUBLE API CALL
    // -------------------------------------------------------------------------

    if (loadingProductRateId == productId) {
      return;
    }

    // -------------------------------------------------------------------------
    // DEALER ID
    // -------------------------------------------------------------------------

    final String dealerId =
        selectedDealer!.id.toString();

    debugPrint(
      '========================================',
    );

    debugPrint(
      'GET PRODUCT DETAIL RATE',
    );

    debugPrint(
      'Dealer ID  : $dealerId',
    );

    debugPrint(
      'Product ID : $productId',
    );

    debugPrint(
      '========================================',
    );

    setState(() {
      loadingProductRateId = productId;
    });

    try {
      // =======================================================================
      // GET USECASE
      // =======================================================================

      final getProductDetailRatesUseCase =
          sl<GetProductDetailRatesUseCase>();

      // =======================================================================
      // API
      // =======================================================================

      final List<ProductRateEntity> rates =
          await getProductDetailRatesUseCase(
        productId: productId,
        dealerId: dealerId,
      );

      if (!mounted) {
        return;
      }

      debugPrint(
        'Product rates found: ${rates.length}',
      );

      // =======================================================================
      // NO RATE
      // =======================================================================

      if (rates.isEmpty) {
        _showMessage(
          'No rate available for this product',
        );

        return;
      }

      // =======================================================================
      // BOTTOM SHEET
      // =======================================================================

      final ProductRateEntity? selectedRate =
          await showModalBottomSheet<ProductRateEntity>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(
          0.45,
        ),
        builder: (
          bottomSheetContext,
        ) {
          return ProductRateBottomSheet(
            product: product,
            rates: rates,
          );
        },
      );

      if (!mounted) {
        return;
      }

      // User closed sheet.
      if (selectedRate == null) {
        return;
      }

      // =======================================================================
      // SAVE SELECTED RATE
      // =======================================================================

      setState(() {
        selectedRates[productId] =
            selectedRate;
      });

      // =======================================================================
      // ADD PRODUCT
      //
      // Bloc increases quantity from 0 -> 1.
      // =======================================================================

      context.read<PlaceOrderBloc>().add(
            AddProductEvent(
              product: product,
            ),
          );

      // =======================================================================
      // DEBUG
      // =======================================================================

      debugPrint(
        '========================================',
      );

      debugPrint(
        'PRODUCT RATE SELECTED',
      );

      debugPrint(
        'Product ID       : ${selectedRate.productId}',
      );

      debugPrint(
        'Details ID       : ${selectedRate.productDetailsId}',
      );

      debugPrint(
        'Product Name     : ${selectedRate.productName}',
      );

      debugPrint(
        'Packing          : ${selectedRate.packing}',
      );

      debugPrint(
        'Unit             : ${selectedRate.unit}',
      );

      debugPrint(
        'Rate With GST    : ${selectedRate.rateWithGst}',
      );

      debugPrint(
        'GST              : ${selectedRate.gstPercentage}',
      );

      debugPrint(
        'Units Per Case   : ${selectedRate.unitsPerCase}',
      );

      debugPrint(
        '========================================',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'Product rate error: $e',
      );

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingProductRateId = null;
        });
      }
    }
  }

  // ===========================================================================
  // INCREASE QUANTITY
  // ===========================================================================
  //
  // IMPORTANT:
  //
  // If rate is already selected:
  //
  // + => only quantity
  //
  // NO API
  // NO BOTTOM SHEET
  //
  // ===========================================================================

  void _increaseQuantity(
    ProductEntity product,
    int currentQuantity,
  ) {
    final productId =
        product.id.toString();

    // Safety check.
    //
    // If somehow quantity exists without a rate,
    // reopen rate selection.
    if (!selectedRates.containsKey(productId)) {
      _addProduct(product);
      return;
    }

    // Only change quantity.
    context.read<PlaceOrderBloc>().add(
          ChangeProductQuantityEvent(
            productId: product.id,
            quantity: currentQuantity + 1,
          ),
        );
  }

  // ===========================================================================
  // DECREASE QUANTITY
  // ===========================================================================

  void _decreaseQuantity(
    ProductEntity product,
    int currentQuantity,
  ) {
    final productId =
        product.id.toString();

    final newQuantity =
        currentQuantity - 1;

    // -------------------------------------------------------------------------
    // REMOVE PRODUCT COMPLETELY
    // -------------------------------------------------------------------------

    if (newQuantity <= 0) {
      context.read<PlaceOrderBloc>().add(
            RemoveProductEvent(
              productId: product.id,
            ),
          );

      setState(() {
        selectedRates.remove(productId);
      });

      return;
    }

    // -------------------------------------------------------------------------
    // JUST DECREASE QUANTITY
    // -------------------------------------------------------------------------

    context.read<PlaceOrderBloc>().add(
          ChangeProductQuantityEvent(
            productId: product.id,
            quantity: newQuantity,
          ),
        );
  }

  // ===========================================================================
  // DELETE PRODUCT
  // ===========================================================================

  void _deleteProduct(
    ProductEntity product,
  ) {
    final productId =
        product.id.toString();

    context.read<PlaceOrderBloc>().add(
          RemoveProductEvent(
            productId: product.id,
          ),
        );

    setState(() {
      selectedRates.remove(productId);
    });
  }

  // ===========================================================================
  // SAFE GODOWN VALUE
  // ===========================================================================
  //
  // Fixes:
  //
  // "There should be exactly one item with DropdownButton's value: 350"
  //
  // ===========================================================================

  String? _getSafeGodownValue(
    List<GodownEntity> godowns,
  ) {
    if (selectedGodown == null) {
      return null;
    }

    final selectedId =
        selectedGodown!.id;

    final matchingIds = godowns
        .where(
          (godown) =>
              godown.id == selectedId,
        )
        .map(
          (godown) => godown.id,
        )
        .toSet();

    if (matchingIds.length != 1) {
      return null;
    }

    return selectedId;
  }

  // ===========================================================================
  // SAFE CATEGORY VALUE
  // ===========================================================================

  String? _getSafeCategoryValue(
    List<CategoryEntity> categories,
  ) {
    if (selectedCategory == null) {
      return null;
    }

    final selectedId =
        selectedCategory!.id;

    final matchingIds = categories
        .where(
          (category) =>
              category.id == selectedId,
        )
        .map(
          (category) => category.id,
        )
        .toSet();

    if (matchingIds.length != 1) {
      return null;
    }

    return selectedId;
  }

  // ===========================================================================
  // UNIQUE GODOWN ITEMS
  // ===========================================================================

  List<DropdownMenuItem<String>>
      _buildGodownItems(
    List<GodownEntity> godowns,
  ) {
    final Map<String, GodownEntity>
        uniqueGodowns = {};

    for (final godown in godowns) {
      final id = godown.id.trim();

      if (id.isEmpty) {
        continue;
      }

      // Last duplicate is ignored because
      // we only insert if ID does not exist.
      uniqueGodowns.putIfAbsent(
        id,
        () => godown,
      );
    }

    return uniqueGodowns.values
        .map(
          (godown) =>
              DropdownMenuItem<String>(
            value: godown.id,
            child: Text(
              godown.name,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),
        )
        .toList();
  }

  // ===========================================================================
  // UNIQUE CATEGORY ITEMS
  // ===========================================================================

  List<DropdownMenuItem<String>>
      _buildCategoryItems(
    List<CategoryEntity> categories,
  ) {
    final Map<String, CategoryEntity>
        uniqueCategories = {};

    for (final category in categories) {
      final id = category.id.trim();

      if (id.isEmpty) {
        continue;
      }

      uniqueCategories.putIfAbsent(
        id,
        () => category,
      );
    }

    return uniqueCategories.values
        .map(
          (category) =>
              DropdownMenuItem<String>(
            value: category.id,
            child: Text(
              category.name,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight:
                    FontWeight.w600,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ),
        )
        .toList();
  }

  // ===========================================================================
  // SUBMIT
  // ===========================================================================

  Future<void> _submit(
    PlaceOrderState state,
  ) async {
    // -------------------------------------------------------------------------
    // DEALER
    // -------------------------------------------------------------------------

    if (selectedDealer == null) {
      _showMessage(
        'Please select dealer',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // GODOWN
    // -------------------------------------------------------------------------

    if (selectedGodown == null) {
      _showMessage(
        'Please select godown',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // CATEGORY
    // -------------------------------------------------------------------------

    if (selectedCategory == null) {
      _showMessage(
        'Please select category',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // SELECTED PRODUCTS
    // -------------------------------------------------------------------------

    final selectedProducts =
        state.products
            .where(
              (product) =>
                  (state.quantities[
                              product.id] ??
                          0) >
                      0,
            )
            .toList();

    if (selectedProducts.isEmpty) {
      _showMessage(
        'Please add at least one product',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // RATE VALIDATION
    // -------------------------------------------------------------------------

    for (final product
        in selectedProducts) {
      final productId =
          product.id.toString();

      if (!selectedRates.containsKey(
        productId,
      )) {
        _showMessage(
          'Please select rate for ${product.name}',
        );

        return;
      }
    }

    // -------------------------------------------------------------------------
    // IMAGE
    // -------------------------------------------------------------------------

    if (imagePath == null ||
        imagePath!.trim().isEmpty) {
      _showMessage(
        'Please add order photo',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // SIGNATURE
    // -------------------------------------------------------------------------

    if (signatureBytes == null ||
        signatureBytes!.isEmpty ||
        signatureController.isEmpty) {
      _showMessage(
        'Please add dealer signature',
      );

      return;
    }

    // -------------------------------------------------------------------------
    // PRODUCT PAYLOAD
    // -------------------------------------------------------------------------

    final List<Map<String, dynamic>>
        selectedProductPayload =
        selectedProducts.map(
      (product) {
        final productId =
            product.id.toString();

        final selectedRate =
            selectedRates[productId]!;

        final quantity =
            state.quantities[
                    product.id] ??
                0;

        return <String, dynamic>{
          'productId': product.id,

          'productDetailsId':
              selectedRate.productDetailsId,

          'quantity': quantity,

          'price':
              selectedRate.rateWithGst,

          'packing':
              selectedRate.packing,

          'unit':
              selectedRate.unit,

          'unitsPerCase':
              selectedRate.unitsPerCase,

          'gstPercentage':
              selectedRate.gstPercentage,

          'basicRate':
              selectedRate.basicRate,

          'mrp':
              selectedRate.mrp,
        };
      },
    ).toList();

    // -------------------------------------------------------------------------
    // DEBUG PAYLOAD
    // -------------------------------------------------------------------------

    debugPrint(
      '========================================',
    );

    debugPrint(
      'PLACE ORDER PAYLOAD',
    );

    debugPrint(
      'Dealer ID: ${selectedDealer!.id}',
    );

    debugPrint(
      'Godown ID: ${selectedGodown!.id}',
    );

    debugPrint(
      'Category ID: ${selectedCategory!.id}',
    );

    debugPrint(
      'Products:',
    );

    for (final product
        in selectedProductPayload) {
      debugPrint(
        product.toString(),
      );
    }

    debugPrint(
      'Image: $imagePath',
    );

    debugPrint(
      'Signature bytes: ${signatureBytes!.length}',
    );

    debugPrint(
      '========================================',
    );

    // -------------------------------------------------------------------------
    // PREVIEW
    // -------------------------------------------------------------------------

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      barrierColor:
          Colors.black.withOpacity(
        0.45,
      ),
      builder: (
        previewContext,
      ) {
        return OrderPreviewSheet(
          dealer: selectedDealer!,
          godown: selectedGodown!,
          category: selectedCategory!,
          products: selectedProducts,
          quantities: state.quantities,
          selectedRates: selectedRates,
          imagePath: imagePath,
          signatureBytes: signatureBytes,
          remark:
              remarkController.text.trim(),
          onConfirm: () {
            Navigator.pop(
              previewContext,
            );

            final List<String>
                selectedImages =
                imagePath == null
                    ? <String>[]
                    : <String>[
                        imagePath!,
                      ];

            // ---------------------------------------------------------------
            // SUBMIT EVENT
            // ---------------------------------------------------------------

            context
                .read<PlaceOrderBloc>()
                .add(
                  SubmitPlaceOrderEvent(
                    userId:
                        widget.userId,
                    dealer:
                        selectedDealer!,
                    godown:
                        selectedGodown!,
                    products:
                        selectedProductPayload,
                    remark:
                        remarkController
                            .text
                            .trim(),
                    imagePaths:
                        selectedImages,
                    signatureBytes:
                        signatureBytes,
                  ),
                );
          },
        );
      },
    );
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          backgroundColor:
              AppColors.primary,
          behavior:
              SnackBarBehavior.floating,
          margin:
              EdgeInsets.all(12.w),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14.r,
            ),
          ),
        ),
      );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      // =========================================================================
      // APP BAR
      // =========================================================================

      appBar: AppBar(
        backgroundColor:
            AppColors.primary,
        elevation: 3,
        toolbarHeight: 68.h,
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              'Place Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Text(
              'Create a new dealer order',
              style: TextStyle(
                color: Colors.white
                    .withOpacity(
                  0.80,
                ),
                fontSize: 11.sp,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      // =========================================================================
      // BLOC
      // =========================================================================

      body: BlocConsumer<
          PlaceOrderBloc,
          PlaceOrderState>(
        listener: (
          context,
          state,
        ) {
          // =====================================================================
          // SUCCESS
          // =====================================================================

          if (state.status ==
              PlaceOrderStatus.success) {
            _showMessage(
              'Order submitted successfully',
            );
          }

          // =====================================================================
          // FAILURE
          // =====================================================================

          if (state.status ==
              PlaceOrderStatus.failure) {
            _showMessage(
              state.errorMessage.isEmpty
                  ? 'Something went wrong'
                  : state.errorMessage,
            );
          }
        },

        // =========================================================================
        // BUILDER
        // =========================================================================

        builder: (
          context,
          state,
        ) {
          // =====================================================================
          // INITIAL LOADING
          // =====================================================================

          if (state.status ==
                  PlaceOrderStatus.loading &&
              state.dealers.isEmpty &&
              state.godowns.isEmpty &&
              state.categories.isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color:
                    AppColors.primary,
              ),
            );
          }

          // =====================================================================
          // SAFE DROPDOWN VALUES
          // =====================================================================

          final safeGodownValue =
              _getSafeGodownValue(
            state.godowns,
          );

          final safeCategoryValue =
              _getSafeCategoryValue(
            state.categories,
          );

          // =====================================================================
          // BODY
          // =====================================================================

          return SafeArea(
            child:
                SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),
              padding:
                  EdgeInsets.fromLTRB(
                16.w,
                16.h,
                16.w,
                30.h,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =============================================================
                  // HEADER
                  // =============================================================

                  _buildOrderHeader(),

                  SizedBox(
                    height: 22.h,
                  ),

                  // =============================================================
                  // DEALER TITLE
                  // =============================================================

                  _sectionTitle(
                    title:
                        'Dealer Information',
                    subtitle:
                        'Search and select dealer',
                    icon:
                        Icons.storefront_rounded,
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  // =============================================================
                  // DEALER
                  // =============================================================

                  DealerSearchField(
                    controller:
                        dealerController,
                    dealers:
                        state.dealers,
                    selectedDealer:
                        selectedDealer,
                    onChanged:
                        _searchDealer,
                    onDealerSelected:
                        _selectDealer,
                    onClearSelected:
                        _clearDealer,
                  ),

                  SizedBox(
                    height: 22.h,
                  ),

                  // =============================================================
                  // GODOWN
                  // =============================================================

                  ModernDropdown<String>(
                    label: 'Godown',
                    hint:
                        'Select godown',
                    icon: Icons
                        .warehouse_rounded,

                    // IMPORTANT:
                    // Use safe value.
                    value:
                        safeGodownValue,

                    // IMPORTANT:
                    // Remove duplicate IDs.
                    items:
                        _buildGodownItems(
                      state.godowns,
                    ),

                    onChanged:
                        (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      final matches =
                          state.godowns
                              .where(
                        (element) =>
                            element.id ==
                            value,
                      )
                              .toList();

                      if (matches.length !=
                          1) {
                        _showMessage(
                          'Invalid godown selection',
                        );
                        return;
                      }

                      setState(() {
                        selectedGodown =
                            matches.first;
                      });
                    },
                  ),

                  SizedBox(
                    height: 18.h,
                  ),

                  // =============================================================
                  // CATEGORY
                  // =============================================================

                  ModernDropdown<String>(
                    label:
                        'Category',
                    hint:
                        'Select product category',
                    icon: Icons
                        .category_rounded,

                    // IMPORTANT:
                    // Use safe value.
                    value:
                        safeCategoryValue,

                    // IMPORTANT:
                    // Remove duplicate IDs.
                    items:
                        _buildCategoryItems(
                      state.categories,
                    ),

                    onChanged:
                        (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      final matches =
                          state.categories
                              .where(
                        (element) =>
                            element.id ==
                            value,
                      )
                              .toList();

                      if (matches.length !=
                          1) {
                        _showMessage(
                          'Invalid category selection',
                        );
                        return;
                      }

                      _selectCategory(
                        matches.first,
                      );
                    },
                  ),

                  // =============================================================
                  // PRODUCTS
                  // =============================================================

                  if (selectedCategory !=
                      null) ...[
                    SizedBox(
                      height: 26.h,
                    ),

                    _sectionTitle(
                      title:
                          'Products',
                      subtitle:
                          'Add products and choose packing & rate',
                      icon: Icons
                          .inventory_2_rounded,
                    ),

                    SizedBox(
                      height: 12.h,
                    ),

                    // ===========================================================
                    // PRODUCT LOADING
                    // ===========================================================

                    if (state.status ==
                            PlaceOrderStatus
                                .loading &&
                        state.products
                            .isEmpty)
                      _buildProductLoading()

                    // ===========================================================
                    // NO PRODUCTS
                    // ===========================================================

                    else if (state.products
                        .isEmpty)
                      _emptyBox(
                        icon: Icons
                            .inventory_2_outlined,
                        text:
                            'No products found',
                      )

                    // ===========================================================
                    // PRODUCTS
                    // ===========================================================

                    else
                      ...state.products
                          .map(
                        (
                          product,
                        ) {
                          // -----------------------------------------------------
                          // CURRENT QUANTITY
                          // -----------------------------------------------------

                          final quantity =
                              state.quantities[
                                      product.id] ??
                                  0;

                          // -----------------------------------------------------
                          // SELECTED RATE
                          //
                          // THIS IS THE IMPORTANT FIX.
                          // -----------------------------------------------------

                          final selectedRate =
                              selectedRates[
                                  product.id
                                      .toString()];

                          // -----------------------------------------------------
                          // RATE API LOADING
                          // -----------------------------------------------------

                          final isLoadingRate =
                              loadingProductRateId ==
                                  product.id
                                      .toString();

                          return Padding(
                            padding:
                                EdgeInsets.only(
                              bottom:
                                  10.h,
                            ),
                            child:
                                Stack(
                              children: [
                                // =================================================
                                // PRODUCT CARD
                                // =================================================

                                ProductCard(
                                  product:
                                      product,

                                  quantity:
                                      quantity,

                                  // =================================================
                                  // CRITICAL FIX
                                  // =================================================
                                  //
                                  // Your ProductCard requires this parameter.
                                  //
                                  selectedRate:
                                      selectedRate,

                                  // =================================================
                                  // ADD / PLUS
                                  // =================================================

                                  onAdd:
                                      () async {
                                    // ---------------------------------------------
                                    // FIRST CLICK
                                    // ---------------------------------------------
                                    //
                                    // quantity = 0
                                    //
                                    // API -> rate sheet -> quantity 1
                                    //

                                    if (quantity ==
                                        0) {
                                      await _addProduct(
                                        product,
                                      );
                                    }

                                    // ---------------------------------------------
                                    // PLUS
                                    // ---------------------------------------------
                                    //
                                    // quantity > 0
                                    //
                                    // NO API.
                                    //
                                    else {
                                      _increaseQuantity(
                                        product,
                                        quantity,
                                      );
                                    }
                                  },

                                  // =================================================
                                  // MINUS
                                  // =================================================

                                  onRemove:
                                      () {
                                    _decreaseQuantity(
                                      product,
                                      quantity,
                                    );
                                  },

                                  // =================================================
                                  // DELETE
                                  // =================================================

                                  onDelete:
                                      () {
                                    _deleteProduct(
                                      product,
                                    );
                                  },
                                ),

                                // =================================================
                                // LOADING OVERLAY
                                // =================================================

                                if (isLoadingRate)
                                  Positioned.fill(
                                    child:
                                        Container(
                                      decoration:
                                          BoxDecoration(
                                        color: Colors
                                            .white
                                            .withOpacity(
                                          0.78,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          18.r,
                                        ),
                                      ),
                                      child:
                                          Center(
                                        child:
                                            Container(
                                          padding:
                                              EdgeInsets.symmetric(
                                            horizontal:
                                                16.w,
                                            vertical:
                                                10.h,
                                          ),
                                          decoration:
                                              BoxDecoration(
                                            color:
                                                Colors.white,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              12.r,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors
                                                    .black
                                                    .withOpacity(
                                                  0.08,
                                                ),
                                                blurRadius:
                                                    12,
                                              ),
                                            ],
                                          ),
                                          child:
                                              Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height:
                                                    18.w,
                                                width:
                                                    18.w,
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth:
                                                      2,
                                                  color:
                                                      AppColors.primary,
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    9.w,
                                              ),
                                              Text(
                                                'Loading rate...',
                                                style:
                                                    TextStyle(
                                                  fontSize:
                                                      11.sp,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  color:
                                                      AppColors.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],

                  SizedBox(
                    height: 24.h,
                  ),

                  // =============================================================
                  // IMAGE
                  // =============================================================

                  _sectionTitle(
                    title:
                        'Order Photo',
                    subtitle:
                        'Add one order photo',
                    icon: Icons
                        .photo_camera_rounded,
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  ImagePickerSection(
                    imagePath:
                        imagePath,
                    onChanged:
                        (path) {
                      setState(() {
                        imagePath =
                            path;
                      });
                    },
                  ),

                  SizedBox(
                    height: 24.h,
                  ),

                  // =============================================================
                  // SIGNATURE
                  // =============================================================

                  _sectionTitle(
                    title:
                        'Dealer Signature',
                    subtitle:
                        'Signature is required',
                    icon: Icons
                        .draw_rounded,
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  SignatureSection(
                    controller:
                        signatureController,
                    onClear:
                        _clearSignature,
                    onSignatureChanged:
                        _onSignatureChanged,
                  ),

                  SizedBox(
                    height: 24.h,
                  ),

                  // =============================================================
                  // REMARK
                  // =============================================================

                  _sectionTitle(
                    title:
                        'Remark',
                    subtitle:
                        'Add additional information',
                    icon: Icons
                        .notes_rounded,
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  _buildRemarkField(),

                  SizedBox(
                    height: 28.h,
                  ),

                  // =============================================================
                  // SUBMIT
                  // =============================================================

                  _buildSubmitButton(
                    state,
                  ),

                  SizedBox(
                    height: 10.h,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildOrderHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius:
            BorderRadius.circular(
          20.r,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withOpacity(0.18),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withOpacity(0.16),
              borderRadius:
                  BorderRadius.circular(
                16.r,
              ),
            ),
            child: Icon(
              Icons
                  .shopping_cart_checkout_rounded,
              color: Colors.white,
              size: 27.sp,
            ),
          ),
          SizedBox(
            width: 14.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Create New Order',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 17.sp,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  'Select dealer, products and order details',
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(
                      0.82,
                    ),
                    fontSize: 12.sp,
                    fontWeight:
                        FontWeight.w500,
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
  // SECTION TITLE
  // ===========================================================================

  Widget _sectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration:
              BoxDecoration(
            color:
                AppColors.lightGreen,
            borderRadius:
                BorderRadius.circular(
              13.r,
            ),
          ),
          child: Icon(
            icon,
            size: 21.sp,
            color:
                AppColors.primary,
          ),
        ),
        SizedBox(
          width: 11.w,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight:
                      FontWeight.w800,
                  color: AppColors
                      .textPrimary,
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                subtitle,
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
      ],
    );
  }

  // ===========================================================================
  // PRODUCT LOADING
  // ===========================================================================

  Widget _buildProductLoading() {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(
        vertical: 35.h,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18.r,
        ),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color:
                AppColors.primary,
          ),
          SizedBox(
            height: 12.h,
          ),
          Text(
            'Loading products...',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight:
                  FontWeight.w600,
              color: AppColors
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY BOX
  // ===========================================================================

  Widget _emptyBox({
    required String text,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(
        vertical: 30.h,
        horizontal: 20.w,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18.r,
        ),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding:
                EdgeInsets.all(14.w),
            decoration:
                const BoxDecoration(
              color:
                  AppColors.lightGreen,
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28.sp,
              color:
                  AppColors.primary,
            ),
          ),
          SizedBox(
            height: 12.h,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight:
                  FontWeight.w600,
              color: AppColors
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // REMARK
  // ===========================================================================

  Widget _buildRemarkField() {
    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18.r,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.035,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller:
            remarkController,
        maxLines: 4,
        minLines: 3,
        textCapitalization:
            TextCapitalization
                .sentences,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight:
              FontWeight.w600,
          color:
              AppColors.textPrimary,
        ),
        decoration:
            InputDecoration(
          hintText:
              'Enter order remark...',
          hintStyle:
              TextStyle(
            color: AppColors
                .textSecondary,
            fontSize: 13.sp,
            fontWeight:
                FontWeight.w500,
          ),
          prefixIcon:
              Padding(
            padding:
                EdgeInsets.only(
              left: 14.w,
              right: 8.w,
              top: 12.h,
            ),
            child: Icon(
              Icons
                  .edit_note_rounded,
              color:
                  AppColors.primary,
              size: 22.sp,
            ),
          ),
          prefixIconConstraints:
              BoxConstraints(
            minWidth: 42.w,
            minHeight: 42.h,
          ),
          filled: true,
          fillColor:
              Colors.white,
          alignLabelWithHint:
              true,
          contentPadding:
              EdgeInsets.all(
            16.w,
          ),
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              18.r,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.border,
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              18.r,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.border,
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              18.r,
            ),
            borderSide:
                const BorderSide(
              color:
                  AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SUBMIT BUTTON
  // ===========================================================================

  Widget _buildSubmitButton(
    PlaceOrderState state,
  ) {
    final isSubmitting =
        state.status ==
            PlaceOrderStatus
                .submitting;

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: isSubmitting
            ? null
            : () => _submit(state),
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
          disabledBackgroundColor:
              AppColors.primary
                  .withOpacity(
            0.55,
          ),
          elevation: 3,
          shadowColor:
              AppColors.primary
                  .withOpacity(
            0.25,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              17.r,
            ),
          ),
        ),
        child: isSubmitting
            ? SizedBox(
                width: 25.w,
                height: 25.w,
                child:
                    const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color:
                      Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.all(
                      5.w,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors
                          .white
                          .withOpacity(
                        0.15,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        8.r,
                      ),
                    ),
                    child: Icon(
                      Icons
                          .shopping_cart_checkout_rounded,
                      size: 20.sp,
                      color:
                          Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(
                    'Place Order',
                    style:
                        TextStyle(
                      fontSize: 15.sp,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}