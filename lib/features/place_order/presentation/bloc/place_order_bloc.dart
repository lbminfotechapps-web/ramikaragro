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
    on<LoadPlaceOrderEvent>(_loadPlaceOrder);
    on<SearchDealerEvent>(_searchDealer);
    on<GetProductsEvent>(_getProducts);
    on<AddProductEvent>(_addProduct);
    on<ChangeProductQuantityEvent>(_changeQuantity);
    on<RemoveProductEvent>(_removeProduct);
    on<SubmitPlaceOrderEvent>(_submitOrder);
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
  // CATEGORY PRODUCTS
  // ==========================================================

  Future<void> _getProducts(
    GetProductsEvent event,
    Emitter<PlaceOrderState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PlaceOrderStatus.loading,
        products: const [],
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
    final quantities = Map<String, int>.from(
      state.quantities,
    );

    final currentQuantity =
        quantities[event.product.id] ?? 0;

    quantities[event.product.id] =
        currentQuantity + 1;

    emit(
      state.copyWith(
        quantities: quantities,
      ),
    );
  }

  // ==========================================================
  // CHANGE QUANTITY
  // ==========================================================

  void _changeQuantity(
    ChangeProductQuantityEvent event,
    Emitter<PlaceOrderState> emit,
  ) {
    final quantities = Map<String, int>.from(
      state.quantities,
    );

    if (event.quantity <= 0) {
      quantities.remove(event.productId);
    } else {
      quantities[event.productId] = event.quantity;
    }

    emit(
      state.copyWith(
        quantities: quantities,
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
    final quantities = Map<String, int>.from(
      state.quantities,
    );

    quantities.remove(event.productId);

    emit(
      state.copyWith(
        quantities: quantities,
      ),
    );
  }

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

        // IMPORTANT:
        // signaturePath has been replaced with signatureBytes.
        signatureBytes: event.signatureBytes,
      );

      emit(
        state.copyWith(
          status: PlaceOrderStatus.success,
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