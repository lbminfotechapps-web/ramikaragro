import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';

abstract class PlaceOrderEvent extends Equatable {
  const PlaceOrderEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// INITIAL LOAD
// ============================================================

class LoadPlaceOrderEvent extends PlaceOrderEvent {
  final int userId;

  const LoadPlaceOrderEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [
        userId,
      ];
}

// ============================================================
// SEARCH DEALER
// ============================================================

class SearchDealerEvent extends PlaceOrderEvent {
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
// PRODUCTS
// ============================================================

class GetProductsEvent extends PlaceOrderEvent {
  final String categoryId;

  const GetProductsEvent({
    required this.categoryId,
  });

  @override
  List<Object?> get props => [
        categoryId,
      ];
}

// ============================================================
// ADD PRODUCT
// ============================================================

class AddProductEvent extends PlaceOrderEvent {
  final ProductEntity product;

  const AddProductEvent({
    required this.product,
  });

  @override
  List<Object?> get props => [
        product,
      ];
}

// ============================================================
// CHANGE QUANTITY
// ============================================================

class ChangeProductQuantityEvent extends PlaceOrderEvent {
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
// REMOVE PRODUCT
// ============================================================

class RemoveProductEvent extends PlaceOrderEvent {
  final String productId;

  const RemoveProductEvent({
    required this.productId,
  });

  @override
  List<Object?> get props => [
        productId,
      ];
}

// ============================================================
// SUBMIT
// ============================================================



class SubmitPlaceOrderEvent extends PlaceOrderEvent {
  final int userId;
  final dynamic dealer;
  final dynamic godown;
  final List<Map<String, dynamic>> products;
  final String remark;
  final List<String> imagePaths;
  final Uint8List? signatureBytes;

  const SubmitPlaceOrderEvent({
    required this.userId,
    required this.dealer,
    required this.godown,
    required this.products,
    required this.remark,
    required this.imagePaths,
    required this.signatureBytes,
  });

  @override
  List<Object?> get props => [
        userId,
        dealer,
        godown,
        products,
        remark,
        imagePaths,
        signatureBytes,
      ];

 
}