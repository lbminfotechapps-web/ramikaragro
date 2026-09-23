import 'package:solufine/features/products/domain/entity/fertilizer_category_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:solufine/features/products/domain/entity/product_name.dart';

enum ProductStatus {
  initial,
  loading,
  success,
  failure,
  productNameLoading,
  productNameSuccess,
}

class ProductState extends Equatable {
  final ProductStatus productStatus;
  final List<FertilizerCategoryEntity> fertilizerCategoryList;
  final List<ProductEntityy> productNames;
  final String message;

  const ProductState({
    this.productStatus = ProductStatus.initial,
    this.fertilizerCategoryList = const [],
    this.message = '',
    this.productNames = const [],
  });

  ProductState copyWith({
    ProductStatus? productStatus,
    List<FertilizerCategoryEntity>? fertilizerCategoryList,
    List<ProductEntityy>? productNames,
    String? message,
  }) {
    return ProductState(
      productStatus: productStatus ?? this.productStatus,
      fertilizerCategoryList:
          fertilizerCategoryList ?? this.fertilizerCategoryList,
      productNames: productNames ?? this.productNames,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    productStatus,
    fertilizerCategoryList,
    message,
    productNames,
  ];
}
