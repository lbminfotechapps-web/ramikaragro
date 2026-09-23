import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';

abstract class SalesReturnEvent extends Equatable {
  const SalesReturnEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// INITIAL LOAD
// ============================================================

class LoadSalesReturnEvent extends SalesReturnEvent {
  final int userId;

  const LoadSalesReturnEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

// ============================================================
// SEARCH DEALER
// ============================================================

class SearchDealerEvent extends SalesReturnEvent {
  final int userId;
  final String searchText;

  const SearchDealerEvent({
    required this.userId,
    required this.searchText,
  });

  @override
  List<Object?> get props => [
        userId,
        searchText,
      ];
}

// ============================================================
// GET PRODUCTS FOR CATEGORY
// ============================================================

class GetProductsEvent extends SalesReturnEvent {
  final String categoryId;

  const GetProductsEvent({
    required this.categoryId,
  });

  @override
  List<Object?> get props => [categoryId];
}

// ============================================================
// REMOVE CATEGORY
// ============================================================

class RemoveCategoryProductsEvent extends SalesReturnEvent {
  final String categoryId;

  const RemoveCategoryProductsEvent({
    required this.categoryId,
  });

  @override
  List<Object?> get props => [categoryId];
}

// ============================================================
// ADD PRODUCT
// ============================================================

class AddProductEvent extends SalesReturnEvent {
  final ProductEntity product;

  const AddProductEvent({
    required this.product,
  });

  @override
  List<Object?> get props => [product];
}

// ============================================================
// CHANGE PRODUCT QUANTITY
// ============================================================

class ChangeProductQuantityEvent extends SalesReturnEvent {
  final String productId;
  final int quantity;

  const ChangeProductQuantityEvent({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
        productId,
        quantity,
      ];
}

// ============================================================
// INCREASE PACKING QUANTITY
// ============================================================

class IncreasePackingQuantityEvent extends SalesReturnEvent {
  final String productId;
  final String productDetailsId;

  const IncreasePackingQuantityEvent({
    required this.productId,
    required this.productDetailsId,
  });

  @override
  List<Object?> get props => [
        productId,
        productDetailsId,
      ];
}

// ============================================================
// DECREASE PACKING QUANTITY
// ============================================================

class DecreasePackingQuantityEvent extends SalesReturnEvent {
  final String productId;
  final String productDetailsId;

  const DecreasePackingQuantityEvent({
    required this.productId,
    required this.productDetailsId,
  });

  @override
  List<Object?> get props => [
        productId,
        productDetailsId,
      ];
}

// ============================================================
// SET PACKING QUANTITY
// ============================================================

class SetPackingQuantityEvent extends SalesReturnEvent {
  final String productId;
  final String productDetailsId;
  final int quantity;

  const SetPackingQuantityEvent({
    required this.productId,
    required this.productDetailsId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
        productId,
        productDetailsId,
        quantity,
      ];
}

// ============================================================
// REMOVE PRODUCT
// ============================================================

class RemoveProductEvent extends SalesReturnEvent {
  final String productId;

  const RemoveProductEvent({
    required this.productId,
  });

  @override
  List<Object?> get props => [productId];
}

// ============================================================
// SUBMIT SALES RETURN
// ============================================================

class SubmitSalesReturnEvent extends SalesReturnEvent {
  final int userId;
  final dynamic dealer;
  final dynamic godown;
  final List<Map<String, dynamic>> products;
  final String remark;
  final List<String> imagePaths;
  final String signaturePath;

  const SubmitSalesReturnEvent({
    required this.userId,
    required this.dealer,
    required this.godown,
    required this.products,
    required this.remark,
    required this.imagePaths,
    required this.signaturePath,
  });

  @override
  List<Object?> get props => [
        userId,
        dealer,
        godown,
        products,
        remark,
        imagePaths,
        signaturePath,
      ];
}