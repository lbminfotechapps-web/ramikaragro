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
// OLD PRODUCT QUANTITY
// ============================================================
//
// Keep this because existing page code may still use it.
// New packing quantity UI should use the events below.
//

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
// INCREASE PACKING QUANTITY
// ============================================================
//
// Example:
//
// Product ID = 1
// Product Details ID = 10
//
// 5 KG -> 1
//       -> press +
// 5 KG -> 2
//

class IncreasePackingQuantityEvent extends PlaceOrderEvent {
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

class DecreasePackingQuantityEvent extends PlaceOrderEvent {
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
//
// Used when the multi-rate bottom sheet returns quantities.
//
// Example:
//
// Product 1
// Details 1 -> 2
// Details 2 -> 5
//

class SetPackingQuantityEvent extends PlaceOrderEvent {
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
// SUBMIT ORDER
// ============================================================

// class SubmitPlaceOrderEvent extends PlaceOrderEvent {
//   final int userId;
//   final dynamic dealer;
//   final dynamic godown;
//   final List<Map<String, dynamic>> products;
//   final String remark;
//   final List<String> imagePaths;
//   final Uint8List? signatureBytes;
//    final Uint8List? signatureBytes;

//   const SubmitPlaceOrderEvent({
//     required this.userId,
//     required this.dealer,
//     required this.godown,
//     required this.products,
//     required this.remark,
//     required this.imagePaths,
//    // required this.signatureBytes,
//     required String signaturePath,
//   });



class SubmitPlaceOrderEvent extends PlaceOrderEvent {
  final int userId;
  final dynamic dealer;
  final dynamic godown;
  final List<Map<String, dynamic>> products;
  final String remark;
  final List<String> imagePaths;
  final String signaturePath;

  const SubmitPlaceOrderEvent({
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
      //  signatureBytes,
        signaturePath,
      ];
}