import 'package:equatable/equatable.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/dealer_entity.dart';
import '../../domain/entities/godown_entity.dart';
import '../../domain/entities/product_entity.dart';

enum SalesReturnStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure,
}

class SalesReturnState extends Equatable {
  final SalesReturnStatus status;

  final List<DealerEntity> dealers;
  final List<GodownEntity> godowns;
  final List<CategoryEntity> categories;

  // ============================================================
  // MERGED PRODUCTS FROM ALL SELECTED CATEGORIES
  // ============================================================

  final List<ProductEntity> products;

  // ============================================================
  // PRODUCTS STORED CATEGORY-WISE
  // categoryId -> products
  // ============================================================

  final Map<String, List<ProductEntity>> productsByCategory;

  // ============================================================
  // PRODUCT QUANTITIES
  // ============================================================

  final Map<String, int> quantities;

  // productId -> productDetailsId -> quantity
  final Map<String, Map<String, int>> packingQuantities;

  final String errorMessage;

  const SalesReturnState({
    this.status = SalesReturnStatus.initial,
    this.dealers = const [],
    this.godowns = const [],
    this.categories = const [],
    this.products = const [],
    this.productsByCategory = const {},
    this.quantities = const {},
    this.packingQuantities = const {},
    this.errorMessage = '',
  });

  SalesReturnState copyWith({
    SalesReturnStatus? status,
    List<DealerEntity>? dealers,
    List<GodownEntity>? godowns,
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
    Map<String, List<ProductEntity>>? productsByCategory,
    Map<String, int>? quantities,
    Map<String, Map<String, int>>? packingQuantities,
    String? errorMessage,
  }) {
    return SalesReturnState(
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