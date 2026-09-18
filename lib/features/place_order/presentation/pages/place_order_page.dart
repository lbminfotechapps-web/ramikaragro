
import 'dart:io';
import 'dart:typed_data';

import 'package:demo/core/di/place_order_target_di.dart';
import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/secure_storage/secure_storage.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_appbar.dart';
import 'package:demo/core/utility/widgets/custom_textformfield.dart';

import 'package:demo/features/place_order/domain/entities/category_entity.dart';
import 'package:demo/features/place_order/domain/entities/dealer_entity.dart';
import 'package:demo/features/place_order/domain/entities/godown_entity.dart';
import 'package:demo/features/place_order/domain/entities/product_entity.dart';
import 'package:demo/features/place_order/domain/entities/product_rate_entity.dart';
import 'package:demo/features/place_order/domain/repositories/product_rate_repository.dart';
import 'package:demo/features/place_order/domain/usecases/get_product_detail_rates_usecase.dart';

import 'package:demo/features/place_order/presentation/bloc/place_order_bloc.dart';
import 'package:demo/features/place_order/presentation/bloc/place_order_event.dart';
import 'package:demo/features/place_order/presentation/bloc/place_order_state.dart';

import 'package:demo/features/place_order/presentation/widgets/dealer_search_field.dart';
import 'package:demo/features/place_order/presentation/widgets/image_picker_section.dart';
import 'package:demo/features/place_order/presentation/widgets/modern_dropdown.dart';
import 'package:demo/features/place_order/presentation/widgets/multi_product_selection_sheet.dart';
import 'package:demo/features/place_order/presentation/widgets/order_preview_sheet.dart';
import 'package:demo/features/place_order/presentation/widgets/product_card.dart';
import 'package:demo/features/place_order/presentation/widgets/signature_section.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class PlaceOrderPage extends StatefulWidget {
  const PlaceOrderPage({super.key});

  @override
  State<PlaceOrderPage> createState() => _PlaceOrderPageState();
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
      debugPrint('PlaceOrder user load error: $e');

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

    if (userId == null || userId! <= 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
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
                SizedBox(height: 18.h),
                Text(
                  'User information not found',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
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

    return BlocProvider(
      create: (_) {
        return sl<PlaceOrderBloc>()
          ..add(
            LoadPlaceOrderEvent(
              userId: userId!,
            ),
          );
      },
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
  State<_PlaceOrderView> createState() => _PlaceOrderViewState();
}

class _PlaceOrderViewState extends State<_PlaceOrderView> {
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
  // PRODUCT -> SELECTED RATES
  // ===========================================================================

  final Map<String, List<ProductRateEntity>> selectedRates = {};

  // ===========================================================================
  // RATE SHEET
  // ===========================================================================

  bool isOpeningRateSelector = false;

  // ===========================================================================
  // SUCCESS DIALOG
  // ===========================================================================

  bool isShowingSuccessDialog = false;

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
  // CLEAR ALL SELECTED PRODUCTS
  // ===========================================================================

  void _clearAllSelectedProducts() {
    final bloc = context.read<PlaceOrderBloc>();
    final currentState = bloc.state;

    for (final product in currentState.products) {
      final String productId = product.id.toString();

      final Map<String, int> packingQuantities =
          currentState.packingQuantities[productId] ??
              <String, int>{};

      final bool hasQuantity = packingQuantities.values.any(
        (quantity) => quantity > 0,
      );

      if (hasQuantity) {
        bloc.add(
          RemoveProductEvent(
            productId: product.id,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        selectedRates.clear();
      });
    } else {
      selectedRates.clear();
    }
  }

  // ===========================================================================
  // SEARCH DEALER
  // ===========================================================================

  void _searchDealer(String value) {
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

  void _selectDealer(DealerEntity dealer) {
    _clearAllSelectedProducts();

    setState(() {
      selectedDealer = dealer;
      dealerController.text = dealer.name;
    });

    debugPrint(
      'Dealer selected: ${dealer.id} - ${dealer.name}',
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
    });
  }

  // ===========================================================================
  // SELECT GODOWN
  // ===========================================================================

  void _selectGodown(GodownEntity godown) {
    setState(() {
      selectedGodown = godown;
    });

    debugPrint(
      'Godown selected: ${godown.id} - ${godown.name}',
    );
  }

  // ===========================================================================
  // SELECT CATEGORY
  // ===========================================================================

  void _selectCategory(CategoryEntity? category) {
    if (category == null) {
      return;
    }

    setState(() {
      selectedCategory = category;
    });

    context.read<PlaceOrderBloc>().add(
          GetProductsEvent(
            categoryId: category.id,
          ),
        );

    debugPrint(
      'Category selected: ${category.id} - ${category.name}',
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

  void _onSignatureChanged(Uint8List? bytes) {
    setState(() {
      signatureBytes = bytes;
    });
  }

  // ===========================================================================
  // SAVE DIGITAL SIGNATURE TO FILE
  // ===========================================================================

  Future<String?> _saveSignatureToFile() async {
    if (signatureBytes == null || signatureBytes!.isEmpty) {
      debugPrint('Digital signature bytes are empty');
      return null;
    }

    try {
      final Directory tempDirectory =
          await getTemporaryDirectory();

      final String fileName =
          'Signature_${DateTime.now().millisecondsSinceEpoch}.png';

      final String filePath =
          '${tempDirectory.path}/$fileName';

      final File signatureFile = File(filePath);

      await signatureFile.writeAsBytes(
        signatureBytes!,
        flush: true,
      );

      final bool exists = await signatureFile.exists();

      if (!exists) {
        debugPrint(
          'Digital signature file was not created',
        );
        return null;
      }

      final int fileSize = await signatureFile.length();

      debugPrint('========================================');
      debugPrint('DIGITAL SIGNATURE FILE');
      debugPrint('File name: $fileName');
      debugPrint('File path: ${signatureFile.path}');
      debugPrint('File size: $fileSize bytes');
      debugPrint('========================================');

      return signatureFile.path;
    } catch (e, stackTrace) {
      debugPrint(
        'Save digital signature error: $e',
      );

      debugPrint('$stackTrace');

      return null;
    }
  }

  // ===========================================================================
  // OPEN MULTI PRODUCT RATE SELECTOR
  // ===========================================================================

  Future<void> _openMultiProductSelector({
    String? initialProductId,
  }) async {
    if (selectedDealer == null) {
      _showMessage('Please select dealer first');
      return;
    }

    if (isOpeningRateSelector) {
      return;
    }

    final bloc = context.read<PlaceOrderBloc>();
    final currentState = bloc.state;

    if (currentState.products.isEmpty) {
      _showMessage('No products available');
      return;
    }

    setState(() {
      isOpeningRateSelector = true;
    });

    try {
      final getRatesUseCase =
          GetProductDetailRatesUseCase(
        repository: sl<ProductRateRepository>(),
      );

      final MultiProductRateSelectionResult? result =
          await showModalBottomSheet<
              MultiProductRateSelectionResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.45),
        builder: (bottomSheetContext) {
          return MultiProductRateBottomSheet(
            products: currentState.products,
            dealerId: selectedDealer!.id.toString(),
            existingRates: {
              for (final entry in selectedRates.entries)
                entry.key:
                    List<ProductRateEntity>.from(
                  entry.value,
                ),
            },
            existingPackingQuantities: {
              for (final entry
                  in currentState.packingQuantities.entries)
                entry.key:
                    Map<String, int>.from(
                  entry.value,
                ),
            },
            initialProductId: initialProductId,
            getRatesUseCase: getRatesUseCase,
          );
        },
      );

      if (result == null) {
        return;
      }

      await _processSelectedRates(
        result: result,
        products: currentState.products,
      );
    } finally {
      if (mounted) {
        setState(() {
          isOpeningRateSelector = false;
        });
      }
    }
  }

  // ===========================================================================
  // PROCESS SELECTED RATES
  // ===========================================================================

  Future<void> _processSelectedRates({
    required MultiProductRateSelectionResult result,
    required List<ProductEntity> products,
  }) async {
    final bloc = context.read<PlaceOrderBloc>();

    final Map<String, List<ProductRateEntity>> returnedRates =
        result.selectedRates;

    final Map<String, Map<String, int>>
        returnedPackingQuantities =
        result.packingQuantities;

    debugPrint('========================================');
    debugPrint('MULTIPLE PRODUCT RATE RESULT');

    debugPrint(
      'Returned product count: ${returnedRates.length}',
    );

    debugPrint(
      'Returned packing quantity count: '
      '${returnedPackingQuantities.length}',
    );

    for (final entry in returnedPackingQuantities.entries) {
      debugPrint(
        'Product ${entry.key} packing quantities:',
      );

      for (final quantityEntry in entry.value.entries) {
        debugPrint(
          '  ProductDetailsId: '
          '${quantityEntry.key} -> '
          'Quantity: ${quantityEntry.value}',
        );
      }
    }

    // =========================================================================
    // UPDATE PACKING-WISE QUANTITIES
    // =========================================================================

    for (final entry in returnedPackingQuantities.entries) {
      final String productId = entry.key;

      final Map<String, int> packingQuantities =
          entry.value;

      for (final quantityEntry
          in packingQuantities.entries) {
        bloc.add(
          SetPackingQuantityEvent(
            productId: productId,
            productDetailsId: quantityEntry.key,
            quantity: quantityEntry.value,
          ),
        );

        debugPrint(
          'Packing quantity updated: '
          'product=$productId, '
          'details=${quantityEntry.key}, '
          'quantity=${quantityEntry.value}',
        );
      }
    }

    // =========================================================================
    // SAVE SELECTED RATES
    // =========================================================================

    for (final entry in returnedRates.entries) {
      final String productId = entry.key;

      final List<ProductRateEntity> rates =
          entry.value;

      ProductEntity? product;

      try {
        product = products.firstWhere(
          (element) =>
              element.id.toString() == productId,
        );
      } catch (_) {
        product = null;
      }

      if (product == null) {
        debugPrint(
          'Product not found for ID: $productId',
        );
        continue;
      }

      if (rates.isEmpty) {
        selectedRates.remove(productId);

        bloc.add(
          RemoveProductEvent(
            productId: product.id,
          ),
        );

        continue;
      }

      selectedRates[productId] =
          List<ProductRateEntity>.from(rates);

      debugPrint('Product ID: $productId');
      debugPrint('Product Name: ${product.name}');
      debugPrint(
        'Selected Rates: ${rates.length}',
      );

      final Map<String, int>
          productPackingQuantities =
          returnedPackingQuantities[productId] ??
              <String, int>{};

      for (final rate in rates) {
        final String detailsId =
            rate.productDetailsId.toString();

        final int quantity =
            productPackingQuantities[detailsId] ?? 1;

        if (!productPackingQuantities
            .containsKey(detailsId)) {
          bloc.add(
            SetPackingQuantityEvent(
              productId: productId,
              productDetailsId: detailsId,
              quantity: 1,
            ),
          );
        }

        debugPrint(
          'Packing: ${rate.packing}',
        );

        debugPrint(
          'Rate: ${rate.rateWithGst}',
        );

        debugPrint(
          'Product Details ID: '
          '${rate.productDetailsId}',
        );

        debugPrint(
          'Quantity: $quantity',
        );

        debugPrint(
          '----------------------------------------',
        );
      }

      final bool hasQuantity =
          rates.any((rate) {
        final String detailsId =
            rate.productDetailsId.toString();

        final int quantity =
            productPackingQuantities[detailsId] ?? 1;

        return quantity > 0;
      });

      if (hasQuantity) {
        bloc.add(
          AddProductEvent(
            product: product,
          ),
        );
      }
    }

    // =========================================================================
    // REMOVE PRODUCTS THAT WERE DESELECTED
    // =========================================================================

    final Set<String> returnedProductIds =
        returnedRates.keys.toSet();

    final List<String> oldSelectedProductIds =
        selectedRates.keys.toList();

    for (final productId
        in oldSelectedProductIds) {
      if (returnedProductIds.contains(productId)) {
        continue;
      }

      ProductEntity? product;

      try {
        product = products.firstWhere(
          (element) =>
              element.id.toString() == productId,
        );
      } catch (_) {
        product = null;
      }

      selectedRates.remove(productId);

      if (product != null) {
        bloc.add(
          RemoveProductEvent(
            productId: product.id,
          ),
        );

        debugPrint(
          'Removed product: ${product.name}',
        );
      }
    }

    if (mounted) {
      setState(() {});
    }

    // =========================================================================
    // FINAL DEBUG
    // =========================================================================

    debugPrint('========================================');
    debugPrint('FINAL SELECTED RATES');

    int totalRates = 0;

    for (final entry in selectedRates.entries) {
      totalRates += entry.value.length;

      debugPrint(
        'Product ${entry.key} -> '
        '${entry.value.length} rate(s)',
      );

      for (final rate in entry.value) {
        final String productDetailsId =
            rate.productDetailsId.toString();

        final int quantity =
            returnedPackingQuantities[
                    entry.key]?[productDetailsId] ??
                1;

        debugPrint(
          '  ${rate.productName} -> '
          'Rate ${rate.rateWithGst} -> '
          'Packing ${rate.packing} -> '
          'Details $productDetailsId -> '
          'Quantity $quantity',
        );
      }
    }

    debugPrint(
      'Total selected rates: $totalRates',
    );

    debugPrint('========================================');
  }

  // ===========================================================================
  // ADD PRODUCT
  // ===========================================================================

  Future<void> _addProduct(
    ProductEntity product,
  ) async {
    if (selectedDealer == null) {
      _showMessage('Please select dealer first');
      return;
    }

    await _openMultiProductSelector(
      initialProductId: product.id.toString(),
    );

    debugPrint(
      'Add clicked for product: ${product.id}',
    );
  }

  // ===========================================================================
  // DELETE PRODUCT
  // ===========================================================================

  void _deleteProduct(ProductEntity product) {
    final String productId =
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
  // GET SELECTED PRODUCTS
  // ===========================================================================

  List<ProductEntity> _getSelectedProducts(
    PlaceOrderState state,
  ) {
    return state.products.where((product) {
      final String productId =
          product.id.toString();

      final Map<String, int>
          productPackingQuantities =
          state.packingQuantities[productId] ??
              <String, int>{};

      final bool hasQuantity =
          productPackingQuantities.values.any(
        (quantity) => quantity > 0,
      );

      return hasQuantity &&
          selectedRates.containsKey(productId) &&
          selectedRates[productId]!.isNotEmpty;
    }).toList();
  }

  // ===========================================================================
  // SAFE GODOWN VALUE
  // ===========================================================================

  String? _getSafeGodownValue(
    List<GodownEntity> godowns,
  ) {
    if (selectedGodown == null) {
      return null;
    }

    final selectedId = selectedGodown!.id;

    final matchingIds = godowns
        .where(
          (godown) => godown.id == selectedId,
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

    final selectedId = selectedCategory!.id;

    final matchingIds = categories
        .where(
          (category) => category.id == selectedId,
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

  List<DropdownMenuItem<String>> _buildGodownItems(
    List<GodownEntity> godowns,
  ) {
    final Map<String, GodownEntity> uniqueGodowns =
        {};

    for (final godown in godowns) {
      final id = godown.id.trim();

      if (id.isEmpty) {
        continue;
      }

      uniqueGodowns.putIfAbsent(
        id,
        () => godown,
      );
    }

    return uniqueGodowns.values
        .map(
          (godown) => DropdownMenuItem<String>(
            value: godown.id,
            child: Text(
              godown.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        )
        .toList();
  }

  // ===========================================================================
  // UNIQUE CATEGORY ITEMS
  // ===========================================================================

  List<DropdownMenuItem<String>> _buildCategoryItems(
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
          (category) => DropdownMenuItem<String>(
            value: category.id,
            child: Text(
              category.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        )
        .toList();
  }

  // ===========================================================================
  // CONFIRM ORDER
  // ===========================================================================

  Future<void> _confirmAndSubmitOrder({
    required List<Map<String, dynamic>>
        selectedProductPayload,
    required List<String> selectedImages,
  }) async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(
            20.w,
            20.h,
            20.w,
            8.h,
          ),
          contentPadding: EdgeInsets.fromLTRB(
            20.w,
            8.h,
            20.w,
            10.h,
          ),
          actionsPadding: EdgeInsets.fromLTRB(
            16.w,
            0,
            16.w,
            14.h,
          ),
          title: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_checkout_rounded,
                  color: AppColors.primary,
                  size: 23.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Confirm Order',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to submit this order?',
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            selectedDealer?.name ?? '',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 9.h),
                    Row(
                      children: [
                        Icon(
                          Icons.warehouse_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            selectedGodown?.name ?? '',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 9.h),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '${selectedProductPayload.length} rate line${selectedProductPayload.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 9.h),
                    Row(
                      children: [
                        Icon(
                          Icons.photo_camera_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            selectedImages.isNotEmpty
                                ? 'Order photo added'
                                : 'No order photo',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 9.h),
                    Row(
                      children: [
                        Icon(
                          Icons.draw_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            signatureBytes != null &&
                                    signatureBytes!
                                        .isNotEmpty
                                ? 'Dealer signature added'
                                : 'Signature not added',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              height: 44.h,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext)
                      .pop(false);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(11.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext)
                      .pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(11.r),
                  ),
                ),
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    // =========================================================================
    // SAVE SIGNATURE BEFORE BLOC
    // =========================================================================

    final String? savedSignaturePath =
        await _saveSignatureToFile();

    if (!mounted) {
      return;
    }

    if (savedSignaturePath == null ||
        savedSignaturePath.isEmpty) {
      _showMessage(
        'Unable to save digital signature',
      );
      return;
    }

    // =========================================================================
    // FINAL DEBUG BEFORE BLOC
    // =========================================================================

    debugPrint('========================================');
    debugPrint('FINAL SUBMIT TO BLOC');

    debugPrint(
      'Products count: '
      '${selectedProductPayload.length}',
    );

    for (final product
        in selectedProductPayload) {
      debugPrint(
        'SUBMIT DATA: $product',
      );
    }

    debugPrint(
      'Order Image: '
      '${selectedImages.isNotEmpty ? selectedImages.first : 'None'}',
    );

    debugPrint(
      'Digital Signature Path: '
      '$savedSignaturePath',
    );

    debugPrint(
      'Digital Signature Size: '
      '${signatureBytes?.length ?? 0} bytes',
    );

    debugPrint('========================================');

    // =========================================================================
    // SUBMIT
    // =========================================================================

    context.read<PlaceOrderBloc>().add(
          SubmitPlaceOrderEvent(
            userId: widget.userId,
            dealer: selectedDealer!,
            godown: selectedGodown!,
            products: selectedProductPayload,
            remark: remarkController.text.trim(),
            imagePaths: selectedImages,
            signaturePath: savedSignaturePath,
          ),
        );
  }

  // ===========================================================================
  // SUBMIT
  // ===========================================================================

  Future<void> _submit(
    PlaceOrderState state,
  ) async {
    // =========================================================================
    // DEALER
    // =========================================================================

    if (selectedDealer == null) {
      _showMessage('Please select dealer');
      return;
    }

    // =========================================================================
    // GODOWN
    // =========================================================================

    if (selectedGodown == null) {
      _showMessage('Please select godown');
      return;
    }

    // =========================================================================
    // CATEGORY
    // =========================================================================

    if (selectedCategory == null) {
      _showMessage('Please select category');
      return;
    }

    // =========================================================================
    // PRODUCTS
    // =========================================================================

    final selectedProducts =
        _getSelectedProducts(state);

    if (selectedProducts.isEmpty) {
      _showMessage(
        'Please add at least one product',
      );
      return;
    }

    // =========================================================================
    // RATE VALIDATION
    // =========================================================================

    for (final product in selectedProducts) {
      final String productId =
          product.id.toString();

      if (!selectedRates.containsKey(productId) ||
          selectedRates[productId]!.isEmpty) {
        _showMessage(
          'Please select rate for ${product.name}',
        );
        return;
      }
    }

    // =========================================================================
    // IMAGE
    // =========================================================================

    if (imagePath == null ||
        imagePath!.trim().isEmpty) {
      _showMessage('Please add order photo');
      return;
    }

    // =========================================================================
    // SIGNATURE
    // =========================================================================

    if (signatureBytes == null ||
        signatureBytes!.isEmpty) {
      _showMessage(
        'Please add dealer signature',
      );
      return;
    }

    // =========================================================================
    // BUILD PACKING-WISE PAYLOAD
    // =========================================================================

    final List<Map<String, dynamic>>
        selectedProductPayload = [];

    for (final product in selectedProducts) {
      final String productId =
          product.id.toString();

      final List<ProductRateEntity> rates =
          selectedRates[productId] ??
              <ProductRateEntity>[];

      final Map<String, int>
          productPackingQuantities =
          state.packingQuantities[productId] ??
              <String, int>{};

      for (final selectedRate in rates) {
        final String productDetailsId =
            selectedRate.productDetailsId.toString();

        final int quantity =
            productPackingQuantities[
                    productDetailsId] ??
                1;

        final Map<String, dynamic> payload = {
          'productId': product.id,
          'productDetailsId':
              selectedRate.productDetailsId,
          'quantity': quantity,
          'price': selectedRate.rateWithGst,
          'packing': selectedRate.packing,
          'unit': selectedRate.unit,
          'unitsPerCase':
              selectedRate.unitsPerCase,
          'gstPercentage':
              selectedRate.gstPercentage,
          'basicRate':
              selectedRate.basicRate,
          'mrp': selectedRate.mrp,
        };

        selectedProductPayload.add(
          payload,
        );

        debugPrint(
          'PAYLOAD -> '
          'product=$productId '
          'details=$productDetailsId '
          'packing=${selectedRate.packing} '
          'quantity=$quantity',
        );
      }
    }

    // =========================================================================
    // SAFETY
    // =========================================================================

    if (selectedProductPayload.isEmpty) {
      _showMessage(
        'Please select at least one product rate',
      );
      return;
    }

    // =========================================================================
    // DEBUG
    // =========================================================================

    debugPrint('========================================');
    debugPrint(
      'PLACE ORDER PACKING-WISE PAYLOAD',
    );

    debugPrint(
      'Dealer ID   : ${selectedDealer!.id}',
    );

    debugPrint(
      'Godown ID   : ${selectedGodown!.id}',
    );

    debugPrint(
      'Category ID : ${selectedCategory!.id}',
    );

    debugPrint(
      'Products    : ${selectedProducts.length}',
    );

    debugPrint(
      'Rate Lines  : '
      '${selectedProductPayload.length}',
    );

    for (final product
        in selectedProductPayload) {
      debugPrint(
        'FINAL PRODUCT PAYLOAD: $product',
      );
    }

    debugPrint('========================================');

    // =========================================================================
    // PREVIEW
    // =========================================================================

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (previewContext) {
        return OrderPreviewSheet(
          dealer: selectedDealer!,
          godown: selectedGodown!,
          category: selectedCategory!,
          products: selectedProducts,
          selectedRates: selectedRates,
          packingQuantities:
              state.packingQuantities,
          imagePath: imagePath,
          signatureBytes: signatureBytes,
          remark: remarkController.text.trim(),
          onConfirm: () {
            Navigator.pop(previewContext);

            final List<String> selectedImages =
                imagePath == null
                    ? <String>[]
                    : <String>[imagePath!];

            _confirmAndSubmitOrder(
              selectedProductPayload:
                  selectedProductPayload,
              selectedImages: selectedImages,
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // SUCCESS DIALOG
  // ===========================================================================

  Future<void> _showOrderSuccessDialog() async {
    if (!mounted || isShowingSuccessDialog) {
      return;
    }

    isShowingSuccessDialog = true;

    final bool? goHome =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.r),
          ),
          contentPadding: EdgeInsets.fromLTRB(
            24.w,
            28.h,
            24.w,
            20.h,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76.w,
                height: 76.w,
                decoration:
                    const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  margin: EdgeInsets.all(9.w),
                  decoration:
                      const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Order Placed Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Your order has been submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color:
                      AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(true);
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14.r,
                      ),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    isShowingSuccessDialog = false;

    if (goHome == true && mounted) {
      context.go(AppRouter.home);
    }
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(String message) {
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
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.primary,
          behavior:
              SnackBarBehavior.floating,
          margin: EdgeInsets.all(12.w),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14.r),
          ),
        ),
      );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: CustomAppBar(
        title: 'Place Order',
        subtitle: 'Create a new dealer order',
        showBackButton: true,
        onBackTap: () =>
            Navigator.pop(context),
      ),

      body: BlocConsumer<PlaceOrderBloc,
          PlaceOrderState>(
        listener: (context, state) {
          if (state.status ==
              PlaceOrderStatus.success) {
            _showOrderSuccessDialog();
            return;
          }

          if (state.status ==
              PlaceOrderStatus.failure) {
            _showMessage(
              state.errorMessage.isEmpty
                  ? 'Something went wrong'
                  : state.errorMessage,
            );
          }
        },

        builder: (context, state) {
          if (state.status ==
                  PlaceOrderStatus.loading &&
              state.dealers.isEmpty &&
              state.godowns.isEmpty &&
              state.categories.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final safeGodownValue =
              _getSafeGodownValue(
            state.godowns,
          );

          final safeCategoryValue =
              _getSafeCategoryValue(
            state.categories,
          );

          return SafeArea(
            child: SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),

              // ===============================================================
              // COMPACT PAGE PADDING
              // ===============================================================

              padding: EdgeInsets.fromLTRB(
                14.w,
                10.h,
                14.w,
                18.h,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =============================================================
                  // HEADER
                  // =============================================================

                  _buildOrderHeader(),

                  SizedBox(height: 12.h),

                  // =============================================================
                  // DEALER
                  // =============================================================

                  DealerSearchField(
                    controller:
                        dealerController,
                    dealers: state.dealers,
                    selectedDealer:
                        selectedDealer,
                    onChanged:
                        _searchDealer,
                    onDealerSelected:
                        _selectDealer,
                    onClearSelected:
                        _clearDealer,
                  ),

                  SizedBox(height: 12.h),

                  // =============================================================
                  // GODOWN
                  // FULL WIDTH
                  // =============================================================

                  ModernDropdown<String>(
                    label: 'Godown',
                    hint: 'Select godown',
                    icon:
                        Icons.warehouse_rounded,
                    value:
                        safeGodownValue,
                    items:
                        _buildGodownItems(
                      state.godowns,
                    ),
                    onChanged: (value) {
                      if (value == null) {
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

                      if (matches.length != 1) {
                        _showMessage(
                          'Invalid godown selection',
                        );
                        return;
                      }

                      _selectGodown(
                        matches.first,
                      );
                    },
                  ),

                  SizedBox(height: 12.h),

                  // =============================================================
                  // CATEGORY
                  // FULL WIDTH
                  // =============================================================

                  ModernDropdown<String>(
                    label: 'Category',
                    hint:
                        'Select product category',
                    icon:
                        Icons.category_rounded,
                    value:
                        safeCategoryValue,
                    items:
                        _buildCategoryItems(
                      state.categories,
                    ),
                    onChanged: (value) {
                      if (value == null) {
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

                      if (matches.length != 1) {
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

                  if (selectedCategory != null) ...[
                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Expanded(
                          child: _sectionTitle(
                            title: 'Products',
                            subtitle:
                                'Select multiple products in one order',
                            icon: Icons
                                .inventory_2_rounded,
                          ),
                        ),

                        SizedBox(width: 6.w),

                        InkWell(
                          borderRadius:
                              BorderRadius.circular(
                            10.r,
                          ),
                          onTap: state.products
                                      .isEmpty ||
                                  isOpeningRateSelector
                              ? null
                              : () =>
                                  _openMultiProductSelector(),
                          child: Container(
                            padding:
                                EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            decoration:
                                BoxDecoration(
                              color: state.products
                                          .isEmpty ||
                                      isOpeningRateSelector
                                  ? Colors.grey
                                  : AppColors
                                      .primary,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10.r,
                              ),
                            ),
                            child:
                                isOpeningRateSelector
                                    ? SizedBox(
                                        width: 18.sp,
                                        height: 18.sp,
                                        child:
                                            const CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                          color: Colors
                                              .white,
                                        ),
                                      )
                                    : Icon(
                                        Icons
                                            .library_add_check_rounded,
                                        color: Colors
                                            .white,
                                        size: 18.sp,
                                      ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    _buildSelectedProductSummary(
                      state,
                    ),

                    if (_getSelectedProducts(
                      state,
                    ).isNotEmpty)
                      SizedBox(height: 8.h),

                    if (state.status ==
                            PlaceOrderStatus.loading &&
                        state.products.isEmpty)
                      _buildProductLoading()
                    else if (state.products.isEmpty)
                      _emptyBox(
                        icon: Icons
                            .inventory_2_outlined,
                        text:
                            'No products found',
                      )
                    else
                      ...state.products.map(
                        (product) {
                          final String productId =
                              product.id.toString();

                          final List<
                                  ProductRateEntity>
                              productRates =
                              selectedRates[
                                      productId] ??
                                  <ProductRateEntity>[];

                          return Padding(
                            padding:
                                EdgeInsets.only(
                              bottom: 8.h,
                            ),
                            child: ProductCard(
                              product: product,
                              selectedRates:
                                  productRates,
                              packingQuantities:
                                  state.packingQuantities[
                                          productId] ??
                                      <String, int>{},
                              onAdd: () async {
                                await _addProduct(
                                  product,
                                );
                              },
                              onAddMore: () async {
                                await _openMultiProductSelector(
                                  initialProductId:
                                      productId,
                                );
                              },
                              onIncrease: (rate) {
                                context
                                    .read<
                                        PlaceOrderBloc>()
                                    .add(
                                      IncreasePackingQuantityEvent(
                                        productId:
                                            product.id
                                                .toString(),
                                        productDetailsId:
                                            rate.productDetailsId
                                                .toString(),
                                      ),
                                    );
                              },
                              onDecrease: (rate) {
                                context
                                    .read<
                                        PlaceOrderBloc>()
                                    .add(
                                      DecreasePackingQuantityEvent(
                                        productId:
                                            product.id
                                                .toString(),
                                        productDetailsId:
                                            rate.productDetailsId
                                                .toString(),
                                      ),
                                    );
                              },
                              onDelete: () {
                                _deleteProduct(
                                  product,
                                );
                              },
                            ),
                          );
                        },
                      ),
                  ],

                  // =============================================================
                  // PHOTO + SIGNATURE
                  // HORIZONTAL ROW
                  // =============================================================

                  SizedBox(height: 16.h),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ImagePickerSection(
                          imagePath: imagePath,
                          onChanged: (path) {
                            setState(() {
                              imagePath = path;
                            });
                          },
                        ),
                      ),

                      SizedBox(width: 10.w),

                      Expanded(
                        child: SignatureSection(
                          controller:
                              signatureController,
                          onClear:
                              _clearSignature,
                          onSignatureChanged:
                              _onSignatureChanged,
                        ),
                      ),
                    ],
                  ),

                  // =============================================================
                  // REMARK
                  // =============================================================

                  SizedBox(height: 14.h),

                  _buildRemarkField(),

                  // =============================================================
                  // SUBMIT
                  // =============================================================

                  SizedBox(height: 18.h),

                  _buildSubmitButton(state),

                  SizedBox(height: 6.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // SELECTED PRODUCT SUMMARY
  // ===========================================================================

  Widget _buildSelectedProductSummary(
    PlaceOrderState state,
  ) {
    final selectedProducts =
        _getSelectedProducts(state);

    if (selectedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    int totalQuantity = 0;
    double totalAmount = 0.0;

    for (final product
        in selectedProducts) {
      final String productId =
          product.id.toString();

      final List<ProductRateEntity> rates =
          selectedRates[productId] ??
              <ProductRateEntity>[];

      final Map<String, int>
          productPackingQuantities =
          state.packingQuantities[productId] ??
              <String, int>{};

      for (final rate in rates) {
        final String productDetailsId =
            rate.productDetailsId.toString();

        final int quantity =
            productPackingQuantities[
                    productDetailsId] ??
                1;

        totalQuantity += quantity;

        final double rateValue =
            double.tryParse(
                  rate.rateWithGst.toString(),
                ) ??
                0.0;

        totalAmount +=
            rateValue * quantity;
      }
    }

    return Container(
      width: double.infinity,

      padding: EdgeInsets.symmetric(
        horizontal: 11.w,
        vertical: 9.h,
      ),

      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius:
            BorderRadius.circular(13.r),
        border: Border.all(
          color: AppColors.primary
              .withOpacity(0.12),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration:
                const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_rounded,
              color: Colors.white,
              size: 17.sp,
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedProducts.length} '
                  'product${selectedProducts.length == 1 ? '' : 's'} selected',
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
                  'Total quantity: '
                  '$totalQuantity',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '₹${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight:
                  FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildOrderHeader() {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(14.w),

      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius:
            BorderRadius.circular(17.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.16,
              ),
              borderRadius:
                  BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons
                  .shopping_cart_checkout_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                SizedBox(height: 2.h),

                Text(
                  'Select dealer, products and order details',
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(0.82),
                    fontSize: 11.sp,
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
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius:
                BorderRadius.circular(11.r),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: AppColors.primary,
          ),
        ),

        SizedBox(width: 9.w),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 1.h),

              Text(
                subtitle,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
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
          EdgeInsets.symmetric(vertical: 24.h),

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
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),

          SizedBox(height: 8.h),

          Text(
            'Loading products...',
            style: TextStyle(
              fontSize: 12.sp,
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

  // ===========================================================================
  // EMPTY
  // ===========================================================================

  Widget _emptyBox({
    required String text,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.symmetric(
        vertical: 24.h,
        horizontal: 18.w,
      ),

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
          Container(
            padding: EdgeInsets.all(11.w),
            decoration:
                const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 25.sp,
              color: AppColors.primary,
            ),
          ),

          SizedBox(height: 8.h),

          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
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

  // ===========================================================================
  // REMARK
  // ===========================================================================

  Widget _buildRemarkField() {
    return CustomTextFormField(
      controller: remarkController,
      hintText: 'Enter order remark...',
      prefixIcon: Icons.edit_note_rounded,
      suffixIcon: null,
      maxLines: 2,
      keyboardType:
          TextInputType.multiline,
      labelText: 'Enter order remark',
    );
  }

  // ===========================================================================
  // SUBMIT BUTTON
  // ===========================================================================

  Widget _buildSubmitButton(
    PlaceOrderState state,
  ) {
    final bool isSubmitting =
        state.status ==
            PlaceOrderStatus.submitting;

    return SizedBox(
      width: double.infinity,
      height: 52.h,

      child: ElevatedButton(
        onPressed: isSubmitting
            ? null
            : () => _submit(state),

        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppColors.primary
                  .withOpacity(0.55),
          elevation: 2,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15.r),
          ),
        ),

        child: isSubmitting
            ? SizedBox(
                width: 23.w,
                height: 23.w,
                child:
                    const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .shopping_cart_checkout_rounded,
                    size: 19.sp,
                    color: Colors.white,
                  ),

                  SizedBox(width: 8.w),

                  Text(
                    'Preview Order',
                    style: TextStyle(
                      fontSize: 14.sp,
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
