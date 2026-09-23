import 'dart:async';

import 'package:solufine/features/products/domain/entity/product_name.dart';
import 'package:solufine/features/products/domain/product_use_cases.dart';
import 'package:solufine/features/products/presentation/bloc/product_event.dart';
import 'package:solufine/features/products/presentation/bloc/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductUseCases productUseCases;

  ProductBloc(this.productUseCases) : super(const ProductState()) {
    on<ProductListingEvent>(_onGetProductListing);
    on<ProductNameListingEvent>(_onGetProductNameListing);
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

  Future<void> _onGetProductNameListing(
    ProductNameListingEvent event,
    Emitter<ProductState> emit,
  ) async {
    final String searchText = event.searchText.trim();

    debugPrint('PRODUCT SEARCH TEXT: "$searchText"');

    // ============================================================
    // EMPTY SEARCH - CLEAR SEARCH RESULTS
    // ============================================================
    if (searchText.isEmpty) {
      emit(
        state.copyWith(
          productStatus: ProductStatus.productNameSuccess,
          productNames: const [],
          message: '',
        ),
      );

      return;
    }

    // ============================================================
    // LOADING
    // ============================================================
    emit(
      state.copyWith(
        productStatus: ProductStatus.productNameLoading,
        productNames: const [],
        message: '',
      ),
    );

    try {
      // IMPORTANT:
      // Use ProductResponseEntity, NOT ProductEntity
      final ProductResponseEntity response = await productUseCases
          .getProductNameList(searchText);

      debugPrint('SEARCH STATUS: ${response.status}');

      debugPrint('SEARCH MESSAGE: ${response.message}');

      debugPrint('SEARCH PRODUCT COUNT: ${response.products.length}');

      for (final product in response.products) {
        debugPrint(
          'SEARCH PRODUCT: '
          'ID=${product.productId}, '
          'NAME=${product.productName}',
        );
      }

      // ============================================================
      // SUCCESS
      // ============================================================
      emit(
        state.copyWith(
          productStatus: ProductStatus.productNameSuccess,
          productNames: response.products,
          message: response.message,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('PRODUCT SEARCH BLOC ERROR: $e');

      debugPrint('PRODUCT SEARCH STACKTRACE: $stackTrace');

      emit(
        state.copyWith(
          productStatus: ProductStatus.failure,
          productNames: const [],
          message: e.toString(),
        ),
      );
    }
  }
}
