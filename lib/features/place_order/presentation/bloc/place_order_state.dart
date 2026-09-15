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
  final PlaceOrderStatus status;

  final List<DealerEntity> dealers;

  final List<GodownEntity> godowns;

  final List<CategoryEntity> categories;

  final List<ProductEntity> products;

  final Map<String, int> quantities;

  final String errorMessage;

  const PlaceOrderState({
    this.status = PlaceOrderStatus.initial,
    this.dealers = const [],
    this.godowns = const [],
    this.categories = const [],
    this.products = const [],
    this.quantities = const {},
    this.errorMessage = '',
  });

  PlaceOrderState copyWith({
    PlaceOrderStatus? status,
    List<DealerEntity>? dealers,
    List<GodownEntity>? godowns,
    List<CategoryEntity>? categories,
    List<ProductEntity>? products,
    Map<String, int>? quantities,
    String? errorMessage,
  }) {
    return PlaceOrderState(
      status: status ?? this.status,
      dealers: dealers ?? this.dealers,
      godowns: godowns ?? this.godowns,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      quantities: quantities ?? this.quantities,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        dealers,
        godowns,
        categories,
        products,
        quantities,
        errorMessage,
      ];
}