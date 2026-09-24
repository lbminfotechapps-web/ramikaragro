import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solufine/features/salesreturn/presentation/bloc/sales_return_event.dart';
import 'package:solufine/features/salesreturn/presentation/bloc/sales_return_state.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_dealers_usecase.dart';
import '../../domain/usecases/get_godowns_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/submit_order_usecase.dart';

class SalesReturnBloc
    extends Bloc<SalesReturnEvent, SalesReturnState> {
  final GetDealersUseCase getDealersUseCase;
  final GetGodownsUseCase getGodownsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsUseCase getProductsUseCase;
  final SubmitOrderUseCase submitOrderUseCase;

  SalesReturnBloc({
    required this.getDealersUseCase,
    required this.getGodownsUseCase,
    required this.getCategoriesUseCase,
    required this.getProductsUseCase,
    required this.submitOrderUseCase,
  }) : super(const SalesReturnState()) {
    on<LoadSalesReturnEvent>(_loadSalesReturn);
    on<SearchDealerEvent>(_searchDealer);

    on<GetProductsEvent>(_getProducts);
    on<RemoveCategoryProductsEvent>(
      _removeCategoryProducts,
    );

    on<AddProductEvent>(_addProduct);
    on<ChangeProductQuantityEvent>(_changeQuantity);

    on<IncreasePackingQuantityEvent>(
      _increasePackingQuantity,
    );

    on<DecreasePackingQuantityEvent>(
      _decreasePackingQuantity,
    );

    on<SetPackingQuantityEvent>(
      _setPackingQuantity,
    );

    on<RemoveProductEvent>(_removeProduct);

    on<SubmitSalesReturnEvent>(_submitOrder);
  }

  // ============================================================
  // LOAD DEALERS + GODOWNS + CATEGORIES
  // ============================================================

  Future<void> _loadSalesReturn(
    LoadSalesReturnEvent event,
    Emitter<SalesReturnState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SalesReturnStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final results = await Future.wait([
        getDealersUseCase(
          userId: event.userId,
          searchText: '',
        ),
        getGodownsUseCase(
          userId: event.userId,
        ),
        getCategoriesUseCase(),
      ]);

      emit(
        state.copyWith(
          status: SalesReturnStatus.loaded,
          dealers: results[0] as dynamic,
          godowns: results[1] as dynamic,
          categories: results[2] as dynamic,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SalesReturnStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // SEARCH DEALER
  // ============================================================

  Future<void> _searchDealer(
    SearchDealerEvent event,
    Emitter<SalesReturnState> emit,
  ) async {
    try {
      final dealers = await getDealersUseCase(
        userId: event.userId,
        searchText: event.searchText,
      );

      emit(
        state.copyWith(
          status: SalesReturnStatus.loaded,
          dealers: dealers,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SalesReturnStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // GET PRODUCTS FOR CATEGORY
  // ============================================================

  Future<void> _getProducts(
    GetProductsEvent event,
    Emitter<SalesReturnState> emit,
  ) async {
    debugPrint(
      '========================================',
    );
    debugPrint(
      'GET PRODUCTS FOR CATEGORY',
    );
    debugPrint(
      'Category ID: ${event.categoryId}',
    );
    debugPrint(
      '========================================',
    );

    // IMPORTANT:
    // Do NOT clear state.products here.
    //
    // Existing category products must remain visible.
    emit(
      state.copyWith(
        status: SalesReturnStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final products = await getProductsUseCase(
        categoryId: event.categoryId,
        searchText: '',
      );

      // ----------------------------------------------------------
      // COPY EXISTING CATEGORY-WISE PRODUCTS
      // ----------------------------------------------------------

      final Map<String, List<ProductEntity>>
          updatedProductsByCategory = {};

      for (final entry
          in state.productsByCategory.entries) {
        updatedProductsByCategory[entry.key] =
            List<ProductEntity>.from(
          entry.value,
        );
      }

      // ----------------------------------------------------------
      // SAVE PRODUCTS FOR THIS CATEGORY
      // ----------------------------------------------------------

      updatedProductsByCategory[event.categoryId] =
          List<ProductEntity>.from(products);

      // ----------------------------------------------------------
      // MERGE PRODUCTS FROM ALL CATEGORIES
      // ----------------------------------------------------------

      final List<ProductEntity> mergedProducts =
          _mergeProducts(
        updatedProductsByCategory,
      );

      debugPrint(
        '========================================',
      );
      debugPrint(
        'PRODUCTS LOADED',
      );
      debugPrint(
        'Category ID: ${event.categoryId}',
      );
      debugPrint(
        'Products for category: ${products.length}',
      );
      debugPrint(
        'Total merged products: ${mergedProducts.length}',
      );
      debugPrint(
        '========================================',
      );

      emit(
        state.copyWith(
          status: SalesReturnStatus.loaded,
          products: mergedProducts,
          productsByCategory:
              updatedProductsByCategory,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SalesReturnStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // MERGE PRODUCTS
  // ============================================================

  List<ProductEntity> _mergeProducts(
    Map<String, List<ProductEntity>>
        productsByCategory,
  ) {
    final Map<String, ProductEntity> uniqueProducts = {};

    for (final categoryProducts
        in productsByCategory.values) {
      for (final product in categoryProducts) {
        final String productId =
            product.id.toString();

        uniqueProducts[productId] = product;
      }
    }

    return uniqueProducts.values.toList();
  }

  // ============================================================
  // REMOVE CATEGORY
  // ============================================================

  void _removeCategoryProducts(
    RemoveCategoryProductsEvent event,
    Emitter<SalesReturnState> emit,
  ) {
    final Map<String, List<ProductEntity>>
        updatedProductsByCategory = {};

    for (final entry
        in state.productsByCategory.entries) {
      updatedProductsByCategory[entry.key] =
          List<ProductEntity>.from(
        entry.value,
      );
    }

    // Remove only this category
    updatedProductsByCategory.remove(
      event.categoryId,
    );

    // Rebuild merged products
    final List<ProductEntity> mergedProducts =
        _mergeProducts(
      updatedProductsByCategory,
    );

    debugPrint(
      '========================================',
    );
    debugPrint(
      'CATEGORY REMOVED',
    );
    debugPrint(
      'Category ID: ${event.categoryId}',
    );
    debugPrint(
      'Remaining categories: '
      '${updatedProductsByCategory.keys.toList()}',
    );
    debugPrint(
      'Remaining products: '
      '${mergedProducts.length}',
    );
    debugPrint(
      '========================================',
    );

    // ----------------------------------------------------------
    // ALSO REMOVE QUANTITIES / RATES ARE HANDLED BY PAGE.
    //
    // Here we only manage product lists.
    // ----------------------------------------------------------

    emit(
      state.copyWith(
        status: SalesReturnStatus.loaded,
        products: mergedProducts,
        productsByCategory:
            updatedProductsByCategory,
        errorMessage: null,
      ),
    );
  }

  // ============================================================
  // ADD PRODUCT
  // ============================================================

  void _addProduct(
    AddProductEvent event,
    Emitter<SalesReturnState> emit,
  ) {
    final Map<String, int> quantities =
        Map<String, int>.from(
      state.quantities,
    );

    final String productId =
        event.product.id.toString();

    final int currentQuantity =
        quantities[productId] ?? 0;

    quantities[productId] =
        currentQuantity + 1;

    emit(
      state.copyWith(
        quantities: quantities,
      ),
    );
  }

  // ============================================================
  // CHANGE PRODUCT QUANTITY
  // ============================================================

  void _changeQuantity(
    ChangeProductQuantityEvent event,
    Emitter<SalesReturnState> emit,
  ) {
    final Map<String, int> quantities =
        Map<String, int>.from(
      state.quantities,
    );

    if (event.quantity <= 0) {
      quantities.remove(
        event.productId,
      );
    } else {
      quantities[event.productId] =
          event.quantity;
    }

    emit(
      state.copyWith(
        quantities: quantities,
      ),
    );
  }

  // ============================================================
  // INCREASE PACKING QUANTITY
  // ============================================================

  void _increasePackingQuantity(
    IncreasePackingQuantityEvent event,
    Emitter<SalesReturnState> emit,
  ) {
    final Map<String, Map<String, int>>
        updatedPackingQuantities = {};

    for (final entry
        in state.packingQuantities.entries) {
      updatedPackingQuantities[entry.key] =
          Map<String, int>.from(
        entry.value,
      );
    }

    final String productId =
        event.productId.toString();

    final String productDetailsId =
        event.productDetailsId.toString();

    final Map<String, int> productQuantities =
        updatedPackingQuantities.putIfAbsent(
      productId,
      () => <String, int>{},
    );

    final int currentQuantity =
        productQuantities[
                productDetailsId] ??
            1;

    final int newQuantity =
        currentQuantity + 1;

    productQuantities[
        productDetailsId] = newQuantity;

    debugPrint(
      'PACKING INCREASED | '
      'Product: $productId | '
      'Details: $productDetailsId | '
      '$currentQuantity -> $newQuantity',
    );

    emit(
      state.copyWith(
        packingQuantities:
            updatedPackingQuantities,
      ),
    );
  }

  // ============================================================
  // DECREASE PACKING QUANTITY
  // ============================================================

  void _decreasePackingQuantity(
    DecreasePackingQuantityEvent event,
    Emitter<SalesReturnState> emit,
  ) {
    final Map<String, Map<String, int>>
        updatedPackingQuantities = {};

    for (final entry
        in state.packingQuantities.entries) {
      updatedPackingQuantities[entry.key] =
          Map<String, int>.from(
        entry.value,
      );
    }

    final String productId =
        event.productId.toString();

    final String productDetailsId =
        event.productDetailsId.toString();

    final Map<String, int>? productQuantities =
        updatedPackingQuantities[
            productId];

    if (productQuantities == null) {
      return;
    }

    final int currentQuantity =
        productQuantities[
                productDetailsId] ??
            1;

    final int newQuantity =
        currentQuantity > 1
            ? currentQuantity - 1
            : 1;

    productQuantities[
        productDetailsId] = newQuantity;

    emit(
      state.copyWith(
        packingQuantities:
            updatedPackingQuantities,
      ),
    );
  }

  // ============================================================
  // SET PACKING QUANTITY
  // ============================================================

  void _setPackingQuantity(
    SetPackingQuantityEvent event,
    Emitter<SalesReturnState> emit,
  ) {
    final Map<String, Map<String, int>>
        updatedPackingQuantities = {};

    for (final entry
        in state.packingQuantities.entries) {
      updatedPackingQuantities[entry.key] =
          Map<String, int>.from(
        entry.value,
      );
    }

    final String productId =
        event.productId.toString();

    final String productDetailsId =
        event.productDetailsId.toString();

    final Map<String, int> productQuantities =
        updatedPackingQuantities.putIfAbsent(
      productId,
      () => <String, int>{},
    );

    final int quantity =
        event.quantity < 1
            ? 1
            : event.quantity;

    productQuantities[
        productDetailsId] = quantity;

    emit(
      state.copyWith(
        packingQuantities:
            updatedPackingQuantities,
      ),
    );
  }

  // ============================================================
  // REMOVE PRODUCT
  // ============================================================

  void _removeProduct(
    RemoveProductEvent event,
    Emitter<SalesReturnState> emit,
  ) {
    final Map<String, int> quantities =
        Map<String, int>.from(
      state.quantities,
    );

    final Map<String, Map<String, int>>
        packingQuantities = {};

    for (final entry
        in state.packingQuantities.entries) {
      packingQuantities[entry.key] =
          Map<String, int>.from(
        entry.value,
      );
    }

    final String productId =
        event.productId.toString();

    quantities.remove(productId);
    packingQuantities.remove(productId);

    emit(
      state.copyWith(
        quantities: quantities,
        packingQuantities:
            packingQuantities,
      ),
    );
  }

  // ============================================================
  // SUBMIT ORDER
  // ============================================================

  Future<void> _submitOrder(
    SubmitSalesReturnEvent event,
    Emitter<SalesReturnState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SalesReturnStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      await submitOrderUseCase(
        userId: event.userId,
        dealer: event.dealer,
        godown: event.godown,
        products: event.products,
        remark: event.remark,
        imagePaths: event.imagePaths,
        signaturePath: event.signaturePath,
      );

      emit(
        state.copyWith(
          status: SalesReturnStatus.success,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SalesReturnStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}