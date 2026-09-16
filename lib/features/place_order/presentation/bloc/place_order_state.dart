import 'package:equatable/equatable.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/dealer_entity.dart';
import '../../domain/entities/godown_entity.dart';
import '../../domain/entities/product_entity.dart';

enum PlaceOrderStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure,
}

class PlaceOrderState extends Equatable {
  // ==========================================================
  // STATUS
  // ==========================================================

  final PlaceOrderStatus status;

  // ==========================================================
  // MASTER DATA
  // ==========================================================

  final List<DealerEntity> dealers;
  final List<GodownEntity> godowns;
  final List<CategoryEntity> categories;
  final List<ProductEntity> products;

  // ==========================================================
  // OLD PRODUCT-LEVEL QUANTITY
  // ==========================================================
  //
  // Keep this temporarily because your existing page/code
  // may still use it.
  //
  // Example:
  //
  // {
  //   "1": 2,
  //   "2": 3,
  // }
  //
  final Map<String, int> quantities;

  // ==========================================================
  // NEW PACKING-LEVEL QUANTITY
  // ==========================================================
  //
  // Structure:
  //
  // productId
  //      ↓
  // productDetailsId
  //      ↓
  // quantity
  //
  // Example:
  //
  // {
  //   "1": {
  //     "1": 2,
  //     "2": 5,
  //   }
  // }
  //
  // Meaning:
  //
  // Product 1
  //   Details 1 = quantity 2
  //   Details 2 = quantity 5
  //
  final Map<String, Map<String, int>> packingQuantities;

  // ==========================================================
  // ERROR
  // ==========================================================

  final String errorMessage;

  const PlaceOrderState({
    this.status = PlaceOrderStatus.initial,
    this.dealers = const [],
    this.godowns = const [],
    this.categories = const [],
    this.products = const [],
    this.quantities = const {},
    this.packingQuantities = const {},
    this.errorMessage = '',
  });

  // ==========================================================
  // COPY WITH
  // ==========================================================

  PlaceOrderState copyWith({
    PlaceOrderStatus? status,
    List<DealerEntity>? dealers,
    List<GodownEntity>? godowns,
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
    Map<String, int>? quantities,
    Map<String, Map<String, int>>? packingQuantities,
    String? errorMessage,
  }) {
    return PlaceOrderState(
      status: status ?? this.status,
      dealers: dealers ?? this.dealers,
      godowns: godowns ?? this.godowns,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      quantities: quantities ?? this.quantities,
      packingQuantities:
          packingQuantities ?? this.packingQuantities,
      errorMessage:
          errorMessage ?? this.errorMessage,
    );
  }

  // ==========================================================
  // EQUATABLE
  // ==========================================================

  @override
  List<Object?> get props => [
        status,
        dealers,
        godowns,
        categories,
        products,
        quantities,
        packingQuantities,
        errorMessage,
      ];
}