import '../../domain/entities/category_entity.dart';
import '../../domain/entities/dealer_entity.dart';
import '../../domain/entities/godown_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/place_order_repository.dart';

import '../datasources/place_order_remote_datasource.dart';

class PlaceOrderRepositoryImpl implements PlaceOrderRepository {
  final PlaceOrderRemoteDataSource remoteDataSource;

  PlaceOrderRepositoryImpl({
    required this.remoteDataSource,
  });

  // =========================================================
  // DEALER
  // =========================================================

  @override
  Future<List<DealerEntity>> getDealers({
    required int userId,
    required String searchText,
  }) {
    return remoteDataSource.getDealers(
      userId: userId,
      searchText: searchText,
    );
  }

  // =========================================================
  // GODOWN
  // =========================================================

  @override
  Future<List<GodownEntity>> getGodowns({
    required int userId,
  }) {
    return remoteDataSource.getGodowns(
      userId: userId,
    );
  }

  // =========================================================
  // CATEGORY
  // =========================================================

  @override
  Future<List<CategoryEntity>> getCategories() {
    return remoteDataSource.getCategories();
  }

  // =========================================================
  // PRODUCTS
  // =========================================================

  @override
  Future<List<ProductEntity>> getProducts({
    required String categoryId,
    required String searchText,
  }) {
    return remoteDataSource.getProducts(
      categoryId: categoryId,
      searchText: searchText,
    );
  }

  // =========================================================
  // UPLOAD SIGNATURE
  // =========================================================

  @override
  Future<String> uploadSignature({
    required String signaturePath,
  }) {
    return remoteDataSource.uploadSignature(
      signaturePath: signaturePath,
    );
  }

  // =========================================================
  // SUBMIT PLACE ORDER
  // =========================================================

  @override
  Future<void> submitOrder({
    required int userId,
    required DealerEntity dealer,
    required GodownEntity godown,
    required List<Map<String, dynamic>> products,
    required String remark,
    required List<String> imagePaths,
    required String signatureFileName,
  }) {
    return remoteDataSource.submitOrder(
      userId: userId,
      dealerId: dealer.id.toString(),
      godownId: godown.id.toString(),
      products: products,
      remark: remark,
      imagePaths: imagePaths,
      signatureFileName: signatureFileName,
    );
  }
}