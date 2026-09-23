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

  // ==========================================================
  // ALL SELECTED CATEGORY PRODUCTS
  // ==========================================================
  //
  // IMPORTANT:
  //
  // Earlier:
  //
  // final List<ProductEntity> products;
  //
  // was replaced every time a category was selected.
  //
  // Now products from all selected categories are retained.
  //
  final List<ProductEntity> products;

  // ==========================================================
  // PRODUCTS BY CATEGORY
  // ==========================================================
  //
  // categoryId -> products
  //
  // Example:
  //
  // {
  //   "1": [product1, product2],
  //   "2": [product3, product4],
  // }
  //
  final Map<String, List<ProductEntity>> productsByCategory;

  // ==========================================================
  // OLD PRODUCT-LEVEL QUANTITY
  // ==========================================================

  final Map<String, int> quantities;

  // ==========================================================
  // PACKING-LEVEL QUANTITY
  // ==========================================================

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
    this.productsByCategory = const {},
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
    Map<String, List<ProductEntity>>? productsByCategory,
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
      productsByCategory:
          productsByCategory ?? this.productsByCategory,
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
        productsByCategory,
        quantities,
        packingQuantities,
        errorMessage,
      ];
}