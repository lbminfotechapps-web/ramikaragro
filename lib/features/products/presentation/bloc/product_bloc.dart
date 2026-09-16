import 'dart:async';

import 'package:demo/features/products/domain/product_use_cases.dart';
import 'package:demo/features/products/presentation/bloc/product_event.dart';
import 'package:demo/features/products/presentation/bloc/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductUseCases productUseCases;

  ProductBloc(this.productUseCases) : super(const ProductState()) {
    on<ProductListingEvent>(_onGetProductListing);
  }

  Future<void> _onGetProductListing(
    ProductListingEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(productStatus: ProductStatus.loading, message: ''));

    try {
      final response = await productUseCases.getProductList(event.searchText);

      debugPrint('Product response: $response');

      emit(
        state.copyWith(
          productStatus: ProductStatus.success,
          fertilizerCategoryList: response,
          message: '',
        ),
      );
    } catch (e) {
      debugPrint('Product error: $e');

      emit(
        state.copyWith(
          productStatus: ProductStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}
