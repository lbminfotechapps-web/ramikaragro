import 'package:demo/features/products/domain/entity/fertilizer_category_entity.dart';
import 'package:equatable/equatable.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  final ProductStatus productStatus;
  final List<FertilizerCategoryEntity> fertilizerCategoryList;
  final String message;

  const ProductState({
    this.productStatus = ProductStatus.initial,
    this.fertilizerCategoryList = const [],
    this.message = '',
  });

  ProductState copyWith({
    ProductStatus? productStatus,
    List<FertilizerCategoryEntity>? fertilizerCategoryList,
    String? message,
  }) {
    return ProductState(
      productStatus: productStatus ?? this.productStatus,
      fertilizerCategoryList:
          fertilizerCategoryList ?? this.fertilizerCategoryList,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [productStatus, fertilizerCategoryList, message];
}
