import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_dealers_usecase.dart';
import '../../domain/usecases/get_godowns_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/submit_order_usecase.dart';

import 'place_order_event.dart';
import 'place_order_state.dart';

class PlaceOrderBloc
    extends Bloc<PlaceOrderEvent, PlaceOrderState> {
  final GetDealersUseCase getDealersUseCase;
  final GetGodownsUseCase getGodownsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsUseCase getProductsUseCase;
  final SubmitOrderUseCase submitOrderUseCase;

  PlaceOrderBloc({
    required this.getDealersUseCase,
    required this.getGodownsUseCase,
    required this.getCategoriesUseCase,
    required this.getProductsUseCase,
    required this.submitOrderUseCase,
  }) : super(const PlaceOrderState()) {
    // ==========================================================
    // INITIAL LOAD
    // ==========================================================

    on<LoadPlaceOrderEvent>(
      _loadPlaceOrder,
    );

    // ==========================================================
    // DEALER SEARCH
    // ==========================================================

    on<SearchDealerEvent>(
      _searchDealer,
    );

    // ==========================================================
    // CATEGORY PRODUCTS
    // ==========================================================

    on<GetProductsEvent>(
      _getProducts,
    );

    // ==========================================================
    // PRODUCT LEVEL QUANTITY
    // ==========================================================

    on<AddProductEvent>(
      _addProduct,
    );

    on<ChangeProductQuantityEvent>(
      _changeQuantity,
    );

    // ==========================================================
    // PACKING / RATE LEVEL QUANTITY
    // ==========================================================

    on<IncreasePackingQuantityEvent>(
      _increasePackingQuantity,
    );

    on<DecreasePackingQuantityEvent>(
      _decreasePackingQuantity,
    );

    on<SetPackingQuantityEvent>(
      _setPackingQuantity,
    );

    // ==========================================================
    // REMOVE PRODUCT
    // ==========================================================

    on<RemoveProductEvent>(
      _removeProduct,
    );

    // ==========================================================
    // SUBMIT ORDER
    // ==========================================================

    on<SubmitPlaceOrderEvent>(
      _submitOrder,
    );
  }

  // ==========================================================
  // INITIAL LOAD
  // ==========================================================

  Future<void> _loadPlaceOrder(
    LoadPlaceOrderEvent event,
    Emitter<PlaceOrderState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PlaceOrderStatus.loading,
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
          status: PlaceOrderStatus.loaded,
          dealers: results[0] as dynamic,
          godowns: results[1] as dynamic,
          categories: results[2] as dynamic,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PlaceOrderStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // DEALER SEARCH
  // ==========================================================

  Future<void> _searchDealer(
    SearchDealerEvent event,
    Emitter<PlaceOrderState> emit,
  ) async {
    try {
      final dealers = await getDealersUseCase(
        userId: event.userId,
        searchText: event.searchText,
      );

      emit(
        state.copyWith(
          status: PlaceOrderStatus.loaded,
          dealers: dealers,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PlaceOrderStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // GET CATEGORY PRODUCTS
  // ==========================================================

  Future<void> _getProducts(
    GetProductsEvent event,
    Emitter<PlaceOrderState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PlaceOrderStatus.loading,
        products: const [],
        errorMessage: null,
      ),
    );

    try {
      final products = await getProductsUseCase(
        categoryId: event.categoryId,
        searchText: '',
      );

      emit(
        state.copyWith(
          status: PlaceOrderStatus.loaded,
          products: products,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PlaceOrderStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ==========================================================
  // ADD PRODUCT
  // ==========================================================

  void _addProduct(
    AddProductEvent event,
    Emitter<PlaceOrderState> emit,
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

  // ==========================================================
  // CHANGE PRODUCT QUANTITY
  // ==========================================================

  void _changeQuantity(
    ChangeProductQuantityEvent event,
    Emitter<PlaceOrderState> emit,
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

  // ==========================================================
  // INCREASE PACKING QUANTITY
  // ==========================================================

  void _increasePackingQuantity(
    IncreasePackingQuantityEvent event,
    Emitter<PlaceOrderState> emit,
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
        productQuantities[productDetailsId] ?? 1;

    final int newQuantity =
        currentQuantity + 1;

    productQuantities[productDetailsId] =
        newQuantity;

    print('========================================');
    print('PACKING QUANTITY INCREASED');
    print('Product ID : $productId');
    print('Details ID : $productDetailsId');
    print(
      'Quantity   : $currentQuantity -> $newQuantity',
    );
    print('========================================');

    emit(
      state.copyWith(
        packingQuantities:
            updatedPackingQuantities,
      ),
    );
  }

  // ==========================================================
  // DECREASE PACKING QUANTITY
  // ==========================================================

  void _decreasePackingQuantity(
    DecreasePackingQuantityEvent event,
    Emitter<PlaceOrderState> emit,
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
        updatedPackingQuantities[productId];

    if (productQuantities == null) {
      return;
    }

    final int currentQuantity =
        productQuantities[productDetailsId] ?? 1;

    final int newQuantity =
        currentQuantity > 1
            ? currentQuantity - 1
            : 1;

    productQuantities[productDetailsId] =
        newQuantity;

    print('========================================');
    print('PACKING QUANTITY DECREASED');
    print('Product ID : $productId');
    print('Details ID : $productDetailsId');
    print(
      'Quantity   : $currentQuantity -> $newQuantity',
    );
    print('========================================');

    emit(
      state.copyWith(
        packingQuantities:
            updatedPackingQuantities,
      ),
    );
  }

  // ==========================================================
  // SET PACKING QUANTITY
  // ==========================================================

  void _setPackingQuantity(
    SetPackingQuantityEvent event,
    Emitter<PlaceOrderState> emit,
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

    productQuantities[productDetailsId] =
        quantity;

    print('========================================');
    print('PACKING QUANTITY SET');
    print('Product ID : $productId');
    print('Details ID : $productDetailsId');
    print('Quantity   : $quantity');
    print('========================================');

    emit(
      state.copyWith(
        packingQuantities:
            updatedPackingQuantities,
      ),
    );
  }

  // ==========================================================
  // REMOVE PRODUCT
  // ==========================================================

  void _removeProduct(
    RemoveProductEvent event,
    Emitter<PlaceOrderState> emit,
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

    print('========================================');
    print('PRODUCT REMOVED');
    print('Product ID : $productId');
    print('========================================');

    emit(
      state.copyWith(
        quantities: quantities,
        packingQuantities:
            packingQuantities,
      ),
    );
  }

  // // ==========================================================
  // // SUBMIT ORDER
  // // ==========================================================

  // Future<void> _submitOrder(
  //   SubmitPlaceOrderEvent event,
  //   Emitter<PlaceOrderState> emit,
  // ) async {
  //   emit(
  //     state.copyWith(
  //       status: PlaceOrderStatus.submitting,
  //       errorMessage: null,
  //     ),
  //   );

  //   try {
  //     await submitOrderUseCase(
  //       userId: event.userId,
  //       dealer: event.dealer,
  //       godown: event.godown,
  //       products: event.products,
  //       remark: event.remark,
  //       imagePaths: event.imagePaths,
  //       signatureBytes: event.signatureBytes,
  //     );

  //     emit(
  //       state.copyWith(
  //         status: PlaceOrderStatus.success,
  //         errorMessage: null,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(
  //       state.copyWith(
  //         status: PlaceOrderStatus.failure,
  //         errorMessage: e.toString(),
  //       ),
  //     );
  //   }
  // }


// ==========================================================
// SUBMIT ORDER
// ==========================================================

Future<void> _submitOrder(
  SubmitPlaceOrderEvent event,
  Emitter<PlaceOrderState> emit,
) async {
  emit(
    state.copyWith(
      status: PlaceOrderStatus.submitting,
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
        status: PlaceOrderStatus.success,
        errorMessage: null,
      ),
    );
  } catch (e) {
    emit(
      state.copyWith(
        status: PlaceOrderStatus.failure,
        errorMessage: e.toString(),
      ),
    );
  }
}

}